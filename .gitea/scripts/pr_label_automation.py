"""
Keep the workflow label of a pull request in sync with its state.

- New PRs and their linked issues get the PR author as assignee.
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
from gitea_api import is_issue
from gitea_api import issue_numbers_for_pr

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


def assign_author(number: int, author: str) -> None:
    """
    Add the author to the assignees of an issue or pull request, keeping existing ones.

    :param number: The issue or pull request number.
    :param author: The login of the pull request author.
    """
    issue: Dict[str, Any] = api("GET", f"/repos/{REPO}/issues/{number}")
    assignees: List[str] = [user["login"] for user in issue.get("assignees") or []]
    if author in assignees:
        return
    api("PATCH", f"/repos/{REPO}/issues/{number}", {"assignees": assignees + [author]})


def assign_author_to_issues(pull: Dict[str, Any], author: str) -> None:
    """
    Add the pull request author to the assignees of every issue the PR belongs to.

    :param pull: The pull request object.
    :param author: The login of the pull request author.
    """
    for number in sorted(issue_numbers_for_pr(pull)):
        issue: Optional[Dict[str, Any]] = api("GET", f"/repos/{REPO}/issues/{number}")
        if not is_issue(issue):
            print(f"#{number} referenced by PR #{pull['number']} is not an issue; skipping")
            continue
        assign_author(number, author)


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


def has_reviewers(pr: int, author: str) -> bool:
    """
    Check whether a pull request still has any reviewer: either an open review request
    or a reviewer who already submitted a (non-dismissed) verdict.

    :param pr: The pull request number.
    :param author: The login of the pull request author, whose own reviews are ignored.
    :returns: True if at least one reviewer remains.
    """
    pull: Dict[str, Any] = api("GET", f"/repos/{REPO}/pulls/{pr}")
    if pull.get("requested_reviewers") or pull.get("requested_reviewers_teams"):
        return True
    return any(
        review.get("state") in ("APPROVED", "REQUEST_CHANGES", "REQUEST_REVIEW")
        and not review.get("dismissed")
        and (review.get("user") or {}).get("login") != author
        for review in get_all(f"/repos/{REPO}/pulls/{pr}/reviews")
    )


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


def final_label(pr: int) -> Optional[str]:
    """
    Determine the terminal workflow label from the live pull request state.

    Event payloads can be stale: an approval run may still be in flight when the PR
    gets merged, so the live state has to win over the event.

    :param pr: The pull request number.
    :returns: MERGED or ABANDONED if the pull request is closed, otherwise None.
    """
    pull: Dict[str, Any] = api("GET", f"/repos/{REPO}/pulls/{pr}")
    if pull.get("state") != "closed":
        return None
    return MERGED if pull.get("merged") else ABANDONED


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
        assign_author_to_issues(pull, pull["user"]["login"])
        # Reviewers selected on creation fire a separate "review_requested" event that may
        # be processed before this one. Use the live state so a stale "WIP:" title in the
        # payload does not demote the PR back to "In Progress".
        live: Dict[str, Any] = api("GET", f"/repos/{REPO}/pulls/{pr}")
        if live.get("requested_reviewers"):
            action = "review_requested"
            title = live["title"]

    # Only react to manual actions: skip anything triggered by the bot itself,
    # which also prevents feedback loops between label and title.
    bot: str = api("GET", "/user")["login"]
    if event == "pull_request" and os.environ.get("GITHUB_ACTOR") != bot:
        sync_wip(pr, action, title)

    target: Optional[str] = target_label(event, action, payload)

    # A reviewer stepping out only sends the PR back to "In Progress" if nobody is left
    # to review it; otherwise the current state (e.g. "Revision") stays as it is.
    if target == IN_PROGRESS and action == "review_request_removed" and has_reviewers(pr, pull["user"]["login"]):
        target = None

    if target is None:
        print(f"no state change for {event}/{action}")
        return

    # When a review is requested, drop a leading "WIP:" from the title.
    if event == "pull_request" and action == "review_requested":
        new_title: str = WIP_PREFIX.sub("", title)
        if new_title != title:
            set_title(pr, new_title)

    # A closed PR always keeps its terminal label, even if this run was triggered
    # by an earlier event (e.g. an approval right before a fast merge).
    if target not in (MERGED, ABANDONED):
        target = final_label(pr) or target

    if target not in pr_labels(pr):
        add_label(pr, target)

    # Runs may still overlap (or arrive out of order): the PR may have been closed and
    # labelled between our state check and our label write. Re-check and restore the
    # terminal label if we just overwrote it.
    if target not in (MERGED, ABANDONED):
        final: Optional[str] = final_label(pr)
        if final is not None and final not in pr_labels(pr):
            add_label(pr, final)


if __name__ == "__main__":
    main()
