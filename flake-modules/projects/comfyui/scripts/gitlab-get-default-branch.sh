repo=$1
encoded_repo="${repo/\//%2F}"

curl -sS -L ${GITLAB_TOKEN:+-H "PRIVATE-TOKEN: $GITLAB_TOKEN"} \
  "https://gitlab.com/api/v4/projects/$encoded_repo" \
  | jq .default_branch -r
