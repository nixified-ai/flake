repo=$1

curl -sS -L ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/$repo" \
  | jq .default_branch -r