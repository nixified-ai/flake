---
name: git-history-cleaner
description: Cleans up git commit history by rebasing and combining commits that edit the same files or logical units, ensuring each logical change is isolated to a single commit.
---
# Git History Cleaner

This skill provides a procedural workflow and strategies for cleaning up git commit history. It details how to reorganize, reorder, and combine (squash or fixup) commits to achieve a clean history where each file, feature, or logical unit is introduced/modified in a single self-contained commit.

## Workflow

1. **Analyze Commit History**:
   - Identify the base commit (e.g., `origin/main`, `master`, or a specific hash where the branch diverged) and the current branch HEAD.
   - View the commit messages in reverse chronological order: `git log <base>..HEAD --oneline`
   - List files modified in each commit: `git log <base>..HEAD --name-status`

2. **Group Changes by Logical Units**:
   - Map files to their logical units (e.g., a specific module, script, library, or config).
   - Identify "fixup" commits (commits fixing errors or formatting in files that were introduced or modified in earlier commits on the branch).
   - Plan the squashing order: each logical unit or file set should be introduced in a single commit, incorporating all subsequent fixes to those same files.

3. **Rebase and Combine Commits**:

   - **Method A: Interactive Rebase (For straightforward rebases)**:
     - Run `git rebase -i <base>`.
     - In the todo list, reorder commits so that any fixup/update commits are positioned immediately below the commit that originally introduced those changes.
     - Change the action of the fixup commits from `pick` to `fixup` (or `f`) to merge them into the parent commit without changing the original commit message, or `squash` (or `s`) to combine their commit messages.

   - **Method B: Programmatic Rebase Script (For complex histories or index files)**:
     - If commits frequently modify shared index files (e.g., JSON registries, lockfiles) that cause heavy conflicts during a standard interactive rebase, write a temporary helper script (Bash or Python) to rebuild the history.
     - Create a temporary branch starting at the base commit: `git checkout -b rebase-temp <base>`
     - For each planned clean commit:
       1. Check out the final state of the relevant files from the target HEAD: `git checkout <target_head> -- <files>`
       2. If a shared index file needs to be built incrementally, extract the specific changes using command-line tools (such as `jq` for JSON files) and apply them.
       3. Commit the staged changes, preserving the original author metadata and dates using environment variables:
          ```bash
          GIT_AUTHOR_DATE="<date>" GIT_COMMITTER_DATE="<date>" git commit -m "<message>"
          ```
       4. Repeat for all logical units in the planned order.

4. **Verify the Rebased History**:
   - Verify that the file state at the new rebased HEAD is identical to the target HEAD:
     ```bash
     git diff <target_head> HEAD
     ```
     *The diff must be completely empty.*
   - Review the final commit history to ensure it contains exactly one logical commit per feature/file group:
     ```bash
     git log <base>..HEAD --oneline
     ```

5. **Update Branch Pointer**:
   - Switch back to the main feature branch and hard-reset it to the rebased HEAD:
     ```bash
     git checkout <feature-branch>
     git reset --hard rebase-temp
     git branch -D rebase-temp
     ```
