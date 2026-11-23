"""
Shared helpers for talking to the Gitea API from workflow scripts.

Environment:
- API
- TOKEN
- REPO
"""
from typing import Any
from typing import Dict
from typing import List
from typing import Optional
from urllib.request import Request
from urllib.request import urlopen

import json
import os

API: str = os.environ["API"]
REPO: str = os.environ["REPO"]
AUTH: Dict[str, str] = {"Authorization": "token " + os.environ["TOKEN"]}


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


def is_issue(obj: Any) -> bool:
    """
    Determine whether an API object is an issue rather than a pull request.

    Issues and pull requests share one index space; Gitea sets "pull_request"
    only for PRs (the key is always present, null for plain issues).

    :param obj: The API object to inspect.
    :returns: True if the object is an issue.
    """
    return isinstance(obj, dict) and obj.get("pull_request") is None
