#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <destination_repo_name>   # e.g. CameraService"
  exit 1
fi

DEST_REPO_NAME="$1"
DEST_REPO="TrySight-Inc/${DEST_REPO_NAME}"

# required tools
for cmd in gh jq curl; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: required command '$cmd' not found in PATH" >&2
    exit 2
  fi
done

# temp files (cleaned on exit)
SRC_JSON="$(mktemp /tmp/src_ruleset.XXXXXX.json)"
PAYLOAD_JSON="$(mktemp /tmp/payload.XXXXXX.json)"
trap 'rm -f "$SRC_JSON" "$PAYLOAD_JSON"' EXIT

echo "1) Fetching source ruleset..."
gh api "repos/TrySight-Inc/cctv/rulesets/7999611" --jq '.' > "$SRC_JSON"

echo "2) Building payload (name: MainRules)..."
jq --arg name "MainRules" \
  '{name: $name, target: .target, enforcement: .enforcement, conditions: .conditions, rules: .rules, bypass_actors: .bypass_actors}' \
  "$SRC_JSON" > "$PAYLOAD_JSON"

echo "Payload preview:"
jq . "$PAYLOAD_JSON"

# Find existing rulesets named "MainRules"
echo "3) Looking for existing ruleset(s) named 'MainRules' in ${DEST_REPO}..."
mapfile -t EXISTING_IDS < <(gh api "repos/${DEST_REPO}/rulesets" --jq '.[] | select(.name=="MainRules") | .id' 2>/dev/null || true)

if [ "${#EXISTING_IDS[@]}" -gt 0 ]; then
  echo "Found ${#EXISTING_IDS[@]} existing ruleset(s). Deleting..."
  for id in "${EXISTING_IDS[@]}"; do
    echo "  - Deleting ruleset ${id}..."
    gh api --method DELETE "repos/${DEST_REPO}/rulesets/${id}" || { echo "Failed to delete ruleset ${id}" >&2; exit 3; }
  done
else
  echo "No existing ruleset named 'MainRules' found in ${DEST_REPO}."
fi

# Create (POST) the new ruleset
echo "4) Creating new ruleset on ${DEST_REPO}..."
GH_TOKEN="$(gh auth token 2>/dev/null || true)"
if [ -z "$GH_TOKEN" ]; then
  echo "Error: could not get GH token. Run 'gh auth login' first." >&2
  exit 4
fi

curl -s \
  -H "Authorization: Bearer ${GH_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  -X POST "https://api.github.com/repos/${DEST_REPO}/rulesets" \
  -d @"${PAYLOAD_JSON}" | jq .

echo "Done."
