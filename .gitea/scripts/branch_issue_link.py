"""
Link a newly created branch to its best matching issue.

Reads the branch name from the environment, assigns the branch reference
to the matching issue via the API, and exposes it as the "issue" output.

Usage:
- branch_issue_link.py

Environment:
- API
- TOKEN
- REPO
- BRANCH
- DEFAULT_BRANCH
- MIN_SCORE
- GITHUB_OUTPUT
"""
from difflib import SequenceMatcher
from typing import Any
from typing import Dict
from typing import List
from typing import Optional
from typing import Set
from typing import Tuple
from urllib.error import HTTPError
from urllib.request import Request
from urllib.request import urlopen

import json
import os
import re
import sys

API: str = os.environ["API"]
REPO: str = os.environ["REPO"]
BRANCH: str = os.environ["BRANCH"]
DEFAULT_BRANCH: str = os.environ["DEFAULT_BRANCH"]
MIN_SCORE: float = float(os.environ["MIN_SCORE"])
AUTH: Dict[str, str] = {"Authorization": "token " + os.environ["TOKEN"]}

# Words that only describe the kind of work and carry no matching signal.
STOP: Set[str] = {
    "feature", "bug", "hotfix", "enhancement", "setup", "test", "testing",
    "chore", "docs", "documentation", "refactor", "refactoring", "technical debt",
}


def api(path: str) -> Tuple[int, Dict[str, str], Any]:
    """
    GET a path; return status, headers and parsed JSON (or None).

    :param path: The API path to request.
    :returns: The status code, response headers and parsed body.
    """
    req: Request = Request(API + path, headers=AUTH)
    try:
        with urlopen(req) as response:
            return response.status, dict(response.headers), json.load(response)
    except HTTPError as err:
        return err.code, dict(err.headers), None


def is_issue(obj: Any) -> bool:
    """
    Determine whether an API object is an issue rather than a pull request.

    The index space is shared with pull requests; keep only real issues.
    Gitea always includes the "pull_request" key (null for plain issues).

    :param obj: The API object to inspect.
    :returns: True if the object is an issue.
    """
    return isinstance(obj, dict) and obj.get("pull_request") is None


def collect_open_issues() -> List[Dict[str, Any]]:
    """
    Collect all open issues, falling back to direct enumeration.

    Uses the normal listing endpoint (backed by the issue indexer) first;
    if that yields nothing, walks the shared index space via the DB-backed
    single-issue endpoint, which does not depend on the indexer.

    :returns: All open issues.
    """
    out: List[Dict[str, Any]] = []
    page: int = 1
    while True:
        status, headers, batch = api(f"/repos/{REPO}/issues?state=open&limit=50&page={page}")
        count: int = len(batch) if isinstance(batch, list) else 0
        print(f"[list] page={page} status={status} "
              f"total={headers.get('X-Total-Count')} got={count}")
        if not isinstance(batch, list) or not batch:
            break
        out += batch
        if len(batch) < 50:
            break
        page += 1
    issues: List[Dict[str, Any]] = [issue for issue in out if is_issue(issue)]
    if issues:
        return issues

    print("[walk] list endpoint empty -> enumerating issues directly")
    found: List[Dict[str, Any]] = []
    index: int = 1
    misses: int = 0
    while index <= 2000 and misses < 25:
        status, _, obj = api(f"/repos/{REPO}/issues/{index}")
        if status == 200 and isinstance(obj, dict):
            misses = 0
            if is_issue(obj) and obj.get("state") == "open":
                found.append(obj)
        else:
            misses += 1
        index += 1
    print(f"[walk] found {len(found)} open issue(s)")
    return found


def tokens(text: str) -> Set[str]:
    """
    Split text into significant lowercase word tokens.

    :param text: The text to tokenize.
    :returns: The set of tokens without stop words.
    """
    raw: List[str] = re.split(r"[^a-z0-9]+", (text or "").lower())
    return {token for token in raw if token and token not in STOP}


def score_issue(branch_tokens: Set[str], branch_norm: str,
                branch_nums: Set[str], issue: Dict[str, Any]) -> float:
    """
    Score how well an issue matches the branch name.

    Blends word overlap (Jaccard) with raw string similarity; a branch
    carrying the issue number is treated as an almost certain match.

    :param branch_tokens: The significant tokens of the branch name.
    :param branch_norm: The normalized branch tokens as a string.
    :param branch_nums: The digit tokens of the branch name.
    :param issue: The issue object to score.
    :returns: The match score between 0 and 1.
    """
    issue_tokens: Set[str] = tokens(issue["title"])
    union: Set[str] = branch_tokens | issue_tokens
    jaccard: float = (len(branch_tokens & issue_tokens) / len(union)) if union else 0.0
    ratio: float = SequenceMatcher(None, branch_norm, " ".join(sorted(issue_tokens))).ratio()
    result: float = 0.6 * jaccard + 0.4 * ratio
    if str(issue["number"]) in branch_nums:
        result = max(result, 0.95)
    return result


def assign(number: Any) -> None:
    """
    Set the issue's branch reference and expose it as the "issue" output.

    :param number: The issue number to link the branch to.
    """
    data: bytes = json.dumps({"ref": BRANCH}).encode()
    req: Request = Request(
        f"{API}/repos/{REPO}/issues/{number}",
        data=data, method="PATCH",
        headers={**AUTH, "Content-Type": "application/json"},
    )
    with urlopen(req) as response:
        print(f"assigned branch '{BRANCH}' to issue #{number} (HTTP {response.status})")
    with open(os.environ["GITHUB_OUTPUT"], "a") as output:
        output.write(f"issue={number}\n")


def direct_match() -> bool:
    """
    Link the branch directly if its name encodes an issue number.

    Expects the "<type>/<issue-no>-<name>" convention (e.g. feature/52-foo).

    :returns: True if the branch was linked directly.
    """
    match: Optional[re.Match] = re.match(r"^[^/]+/0*(\d+)(?:[-_/]|$)", BRANCH)
    if not match:
        return False
    number: str = match.group(1)
    status, _, obj = api(f"/repos/{REPO}/issues/{number}")
    if status == 200 and is_issue(obj):
        print(f"branch encodes issue #{number} '{obj.get('title')}' -> direct match")
        assign(number)
        return True
    print(f"branch encodes #{number} but no matching issue (status={status}); "
          f"falling back to title similarity")
    return False


def similarity_match() -> None:
    """
    Link the branch to the open issue with the most similar title.
    """
    branch_nums: Set[str] = {token for token in re.split(r"[^0-9]+", BRANCH) if token}
    branch_tokens: Set[str] = tokens(BRANCH)
    branch_norm: str = " ".join(sorted(branch_tokens))

    issues: List[Dict[str, Any]] = collect_open_issues()
    if not issues:
        print("no open issues to match against")
        return

    best: Dict[str, Any] = max(
        issues, key=lambda issue: score_issue(branch_tokens, branch_norm, branch_nums, issue))
    best_score: float = score_issue(branch_tokens, branch_norm, branch_nums, best)
    print(f"branch '{BRANCH}' -> best issue #{best['number']} '{best['title']}' score={best_score:.3f}")

    if best_score < MIN_SCORE:
        print(f"skip: best score {best_score:.3f} below threshold {MIN_SCORE}")
        return

    assign(best["number"])


def main() -> None:
    # Never link the default branch to an issue.
    if BRANCH == DEFAULT_BRANCH:
        print(f"skip: '{BRANCH}' is the default branch")
        return

    if direct_match():
        return
    similarity_match()


if __name__ == "__main__":
    main()
