owner=$1
repo=$2
repo_path="${1}/${2}"
name=${3:-$repo_path}

main_branch=main
main_branch=$(github-get-default-branch "$repo_path")

npins -d flake-modules/projects/comfyui/customNodes-npins \
 add github "$owner" "$repo" --name "$name" --branch "$main_branch"
