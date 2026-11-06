"""
Keep the workflow label of a pull request in sync with its state.

- New PRs get their author as assignee.
- The "Workflow/In Progress" label and the "WIP:" title prefix are kept in sync.
- Every PR carries the workflow label matching its current state.

Usage:
- pr_label_automation.py  # react to the current pull_request / pull_request_review event

Environment:
- API
- TOKEN
- REPO
- (+ GITHUB_EVENT_NAME / GITHUB_EVENT_PATH / GITHUB_ACTOR).
"""
from typing import Any
from typing import Dict
from typing import List
from typing import Optional
from typing import Set

from gitea_api import REPO
from gitea_api import api
from gitea_api import get_all

import json
import os
import re

IN_PROGRESS: str = "Workflow/In Progress"
READY_FOR_REVIEW: str = "Workflow/Ready for Review"
READY_FOR_MERGE: str = "Workflow/Ready for Merge"
REVISION: str = "Workflow/Revision"
MERGED: str = "Workflow/Merged"
ABANDONED: str = "Workflow/Abandoned"

LABEL_COLOR: str = "#0E8A16"
WIP_PREFIX: re.Pattern = re.compile(r"^WIP:\s*", re.IGNORECASE)


def pr_labels(pr: int) -> Set[str]:
    """
    Fetch the label names currently attached to a pull request.

    :param pr: The pull request number.
    :returns: The set of label names.
    """
    return {label["name"] for label in api("GET", f"/repos/{REPO}/issues/{pr}/labels") or []}


def ensure_label(name: str) -> None:
    """
    Create the given (exclusive) label in the repository if it does not exist yet.

    :param name: The label name.
    """
    if any(label["name"] == name for label in get_all(f"/repos/{REPO}/labels")):
        return
    api("POST", f"/repos/{REPO}/labels", {"name": name, "color": LABEL_COLOR, "exclusive": True})


def add_label(pr: int, name: str) -> None:
    """
    Add a label to a pull request, creating it in the repository if needed.

    :param pr: The pull request number.
    :param name: The label name.
    """
    ensure_label(name)
    api("POST", f"/repos/{REPO}/issues/{pr}/labels", {"labels": [name]})


def set_title(pr: int, title: str) -> None:
    """
    Change the title of a pull request.

    :param pr: The pull request number.
    :param title: The new title.
    """
    api("PATCH", f"/repos/{REPO}/pulls/{pr}", {"title": title})


def assign_author(pr: int, author: str) -> None:
    """
    Add the author to the assignees of a pull request, keeping existing ones.

    :param pr: The pull request number.
    :param author: The login of the pull request author.
    """
    issue: Dict[str, Any] = api("GET", f"/repos/{REPO}/issues/{pr}")
    assignees: List[str] = [user["login"] for user in issue.get("assignees") or []]
    if author in assignees:
        return
    api("PATCH", f"/repos/{REPO}/issues/{pr}", {"assignees": assignees + [author]})


def sync_wip(pr: int, action: str, title: str) -> None:
    """
    Keep the "In Progress" label and the "WIP:" title prefix in sync.

    :param pr: The pull request number.
    :param action: The pull_request event action.
    :param title: The current pull request title.
    """
    is_wip: bool = bool(WIP_PREFIX.match(title))
    if action in ("labeled", "label_updated"):
        # Label drives title: someone added "In Progress" -> ensure "WIP:" prefix.
        if not is_wip and IN_PROGRESS in pr_labels(pr):
            set_title(pr, f"WIP: {title}")
    elif action == "edited":
        # Title drives label: someone added "WIP:" -> ensure "In Progress" label.
        if is_wip and IN_PROGRESS not in pr_labels(pr):
            add_label(pr, IN_PROGRESS)


def target_label(event: str, action: str, payload: Dict[str, Any]) -> Optional[str]:
    """
    Map the incoming event to the single workflow label the pull request should have.

    :param event: The event name.
    :param action: The event action.
    :param payload: The event payload.
    :returns: The target label, or None if the event does not change the state.
    """
    pull: Dict[str, Any] = payload["pull_request"]
    if event == "pull_request":
        if action == "opened":
            return IN_PROGRESS if WIP_PREFIX.match(pull["title"]) else READY_FOR_REVIEW
        if action == "review_requested":
            return READY_FOR_REVIEW
        if action == "review_request_removed":
            return IN_PROGRESS
        if action == "closed":
            return MERGED if pull.get("merged") else ABANDONED
    elif event == "pull_request_review":
        review_type: str = (payload.get("review") or {}).get("type", "")
        if review_type == "pull_request_review_approved":
            return READY_FOR_MERGE
        if review_type == "pull_request_review_rejected":
            return REVISION
    return None


def main() -> None:
    with open(os.environ["GITHUB_EVENT_PATH"]) as event_file:
        payload: Dict[str, Any] = json.load(event_file)
    event: str = os.environ["GITHUB_EVENT_NAME"]
    action: str = payload.get("action", "")
    pull: Dict[str, Any] = payload["pull_request"]
    pr: int = pull["number"]
    title: str = pull["title"]

    if event == "pull_request" and action == "opened":
        assign_author(pr, pull["user"]["login"])

    # Only react to manual actions: skip anything triggered by the bot itself,
    # which also prevents feedback loops between label and title.
    bot: str = api("GET", "/user")["login"]
    if event == "pull_request" and os.environ.get("GITHUB_ACTOR") != bot:
        sync_wip(pr, action, title)

    target: Optional[str] = target_label(event, action, payload)
    if target is None:
        print(f"no state change for {event}/{action}")
        return

    # When a review is requested, drop a leading "WIP:" from the title.
    if event == "pull_request" and action == "review_requested":
        new_title: str = WIP_PREFIX.sub("", title)
        if new_title != title:
            set_title(pr, new_title)

    if target not in pr_labels(pr):
        add_label(pr, target)


if __name__ == "__main__":
    main()
