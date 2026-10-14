"""
Keep the issues of this repository in sync with the organization project board.

Usage:
- project_board.py event                 # react to the current issues / pull_request event
- project_board.py move <issue> <column> # put issue #<issue> into <column>

Environment:
- API
- TOKEN
- REPO
- ORG
- PROJECT_ID
- (+ GITHUB_EVENT_NAME / GITHUB_EVENT_PATH for "event").
"""
from typing import Any
from typing import Dict
from typing import List
from typing import Optional
from typing import Set
from urllib.error import HTTPError
from urllib.request import Request
from urllib.request import urlopen

import functools
import json
import os
import re
import sys

API: str = os.environ["API"]
REPO: str = os.environ["REPO"]
ORG: str = os.environ["ORG"]
PROJECT_ID: str = os.environ["PROJECT_ID"]
AUTH: Dict[str, str] = {"Authorization": "token " + os.environ["TOKEN"]}

BACKLOG: str = "Backlog"
TODO: str = "To Do"
IN_PROGRESS: str = "In Progress"
IN_REVIEW: str = "In Review"
DONE: str = "Done"

BACKLOG_LABEL: str = "Workflow/Backlog"

# PR workflow label -> board column.
PR_LABEL_COLUMNS: Dict[str, str] = {
    "Workflow/In Progress": IN_PROGRESS,
    "Workflow/Ready for Review": IN_REVIEW,
    "Workflow/Revision": IN_REVIEW,
    "Workflow/Ready for Merge": IN_REVIEW,
    "Workflow/Ready to Merge": IN_REVIEW,
    "Workflow/Merged": DONE,
    "Workflow/Abandoned": DONE,
}


def api(method: str, path: str, body: Any = None) -> Any:
    """
    Call the Gitea API.

    :param method: The HTTP method to use.
    :param path: The API path to request.
    :param body: The JSON-serializable request body, if any.
    :returns: The parsed JSON response, or None for empty responses.
    """
    data: Optional[bytes] = json.dumps(body).encode() if body is not None else None
    headers: Dict[str, str] = {**AUTH, "Content-Type": "application/json"} if data else AUTH
    with urlopen(Request(API + path, data=data, method=method, headers=headers)) as response:
        raw: bytes = response.read()
        return json.loads(raw) if raw else None


def get_all(path: str) -> List[Dict[str, Any]]:
    """
    GET a paginated list endpoint and return all items.

    :param path: The API path of the paginated list endpoint.
    :returns: Every item across all pages.
    """
    out: List[Dict[str, Any]] = []
    page: int = 1
    separator: str = "&" if "?" in path else "?"
    while True:
        batch: List[Dict[str, Any]] = api("GET", f"{path}{separator}limit=50&page={page}")
        if not batch:
            return out
        out += batch
        if len(batch) < 50:
            return out
        page += 1


def label_names(obj: Dict[str, Any]) -> Set[str]:
    """
    Collect the label names attached to an object.

    :param obj: An API object carrying a "labels" field.
    :returns: The set of label names.
    """
    return {label["name"] for label in obj.get("labels") or []}


def is_issue(obj: Any) -> bool:
    """
    Determine whether an API object is an issue rather than a pull request.

    Issues and pull requests share one index space; Gitea sets "pull_request"
    only for PRs.

    :param obj: The API object to inspect.
    :returns: True if the object is an issue.
    """
    return isinstance(obj, dict) and obj.get("pull_request") is None


def get_issue(number: int) -> Optional[Dict[str, Any]]:
    """
    Fetch an issue by its number.

    :param number: The issue number.
    :returns: The issue object, or None if it is missing or a pull request.
    """
    try:
        obj: Dict[str, Any] = api("GET", f"/repos/{REPO}/issues/{number}")
    except HTTPError:
        return None
    return obj if is_issue(obj) else None


@functools.lru_cache(maxsize=None)
def columns() -> List[Dict[str, Any]]:
    """
    Fetch the project board columns.

    :returns: All columns of the configured project.
    """
    return get_all(f"/orgs/{ORG}/projects/{PROJECT_ID}/columns")


def column_id(title: str) -> int:
    """
    Resolve a column title to its project board column id.

    :param title: The column title, matched case-insensitively.
    :returns: The id of the matching column.
    """
    board_columns: List[Dict[str, Any]] = columns()
    for column in board_columns:
        if column["title"].strip().lower() == title.lower():
            return column["id"]
    sys.exit(f"column '{title}' not found on project {PROJECT_ID}; "
             f"available: {[column['title'] for column in board_columns]}")


def move(issue: Dict[str, Any], column: str) -> None:
    """
    Add the issue to the project (if needed) and place it in the given column.

    :param issue: The issue object to move.
    :param column: The title of the target column.
    """
    api("POST", f"/orgs/{ORG}/projects/{PROJECT_ID}/columns/{column_id(column)}/issues/{issue['id']}")
    print(f"issue #{issue['number']} '{issue['title']}' -> {column}")


@functools.lru_cache(maxsize=None)
def all_issues() -> List[Dict[str, Any]]:
    """
    Fetch every issue in the repository, caching the result.

    :returns: All issues in the repository.
    """
    return get_all(f"/repos/{REPO}/issues?state=all&type=issues")


def issue_numbers_for_pr(pr: Dict[str, Any]) -> Set[int]:
    """
    Find the issue numbers a pull request belongs to.

    Matches the branch "<type>/<nr>-...", explicit issue refs equal to the
    branch, and closing keywords in the body.

    :param pr: The pull request object.
    :returns: The set of referenced issue numbers.
    """
    branch: str = pr["head"]["ref"]
    nums: Set[int] = set()
    match: Optional[re.Match] = re.match(r"^[^/]+/0*(\d+)(?:[-_/]|$)", branch)
    if match:
        nums.add(int(match.group(1)))
    for keyword in re.finditer(r"(?i)\b(?:close[sd]?|fix(?:e[sd])?|resolve[sd]?)\s*:?\s+#(\d+)", pr.get("body") or ""):
        nums.add(int(keyword.group(1)))
    # Branches linked by branch_issue_link.yaml without a number in their name.
    if not nums:
        for issue in all_issues():
            if issue.get("ref") in (branch, f"refs/heads/{branch}"):
                nums.add(issue["number"])
    return nums

def has_open_pr_for_issue(issue: Dict[str, Any]) -> bool:
    """
    Check whether any open pull request references an issue.

    :param issue: The issue object to look up.
    :returns: True if an open pull request is linked to the issue.
    """
    return any(issue["number"] in issue_numbers_for_pr(pr)
               for pr in get_all(f"/repos/{REPO}/pulls?state=open"))


def handle_issue_event(action: str, issue: Dict[str, Any]) -> None:
    """
    Update the board in response to an issue event.

    :param action: The issue event action.
    :param issue: The issue object carried by the event.
    """
    if not is_issue(issue):
        return
    labels: Set[str] = label_names(issue)
    if action == "opened":
        move(issue, BACKLOG if BACKLOG_LABEL in labels else TODO)
    elif action in ("labeled", "label_updated"):
        if BACKLOG_LABEL in labels:
            move(issue, BACKLOG)
    elif action == "closed":
        # Issues with an open PR are driven by that PR's labels instead.
        if has_open_pr_for_issue(issue):
            print(f"issue #{issue['number']} has an open PR; leaving it to the PR")
        else:
            move(issue, DONE)
    elif action == "reopened":
        move(issue, IN_PROGRESS if issue.get("ref") else TODO)
    else:
        print(f"no board change for issues/{action}")


def handle_pr_event(pr: Dict[str, Any]) -> None:
    """
    Update the board in response to a pull request event.

    :param pr: The pull request object carried by the event.
    """
    # Fetch fresh labels: the payload may predate the label automation's change.
    labels: Set[str] = label_names(api("GET", f"/repos/{REPO}/issues/{pr['number']}"))
    column: Optional[str] = next(
        (mapped for label, mapped in PR_LABEL_COLUMNS.items() if label in labels), None)
    if not column:
        print(f"PR #{pr['number']} has no workflow label mapped to a column")
        return
    nums: Set[int] = issue_numbers_for_pr(pr)
    if not nums:
        print(f"PR #{pr['number']} is not linked to any issue")
    for number in sorted(nums):
        issue: Optional[Dict[str, Any]] = get_issue(number)
        if issue:
            move(issue, column)
        else:
            print(f"#{number} referenced by PR #{pr['number']} is not an issue; skipping")


def main() -> None:
    """
    Run the command line entry point.

    """
    if sys.argv[1:2] == ["move"]:
        issue: Optional[Dict[str, Any]] = get_issue(int(sys.argv[2]))
        if not issue:
            sys.exit(f"#{sys.argv[2]} is not an issue")
        move(issue, sys.argv[3])
        return

    with open(os.environ["GITHUB_EVENT_PATH"]) as event_file:
        payload: Dict[str, Any] = json.load(event_file)
    event: str = os.environ["GITHUB_EVENT_NAME"]
    if event == "issues":
        handle_issue_event(payload["action"], payload["issue"])
    elif event == "pull_request":
        handle_pr_event(payload["pull_request"])
    else:
        print(f"unsupported event '{event}'")


if __name__ == "__main__":
    main()
