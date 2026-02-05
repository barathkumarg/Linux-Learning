
# Git Essential Commands & Production Workflows

## Quick Reference
- Initialize repo: `git init`
- Clone: `git clone <url>`
- Check status: `git status`
- Stage files: `git add <file|.>`
- Commit: `git commit -m "msg"`
- Amend last commit: `git commit --amend --no-edit`
- Push: `git push [remote] [branch]`
- Fetch: `git fetch`
- Pull (fetch+merge): `git pull`

## Branching & Inspecting
- List branches: `git branch` or `git branch -a`
- Create branch: `git branch feature/x` or `git switch -c feature/x`
- Switch branch: `git switch <branch>` (or `git checkout <branch>`)
- Delete branch: `git branch -d branch` (force: `-D`)
- See commit log: `git log --oneline --graph --decorate --all`

## Merging vs Rebase (short)
- Merge (preserves history):
  - `git checkout main`
  - `git merge --no-ff feature/x`
- Rebase (linear history):
  - `git checkout feature/x`
  - `git rebase main`
  - Resolve conflicts, `git rebase --continue`
  - Then fast-forward main: `git checkout main && git merge feature/x`

When to use: prefer `rebase` for local feature branch cleanup before opening PR; use `merge` for final integration on main if you want a merge commit.

## Interactive Rebase (squash, reorder, edit)
- Start interactive rebase to rewrite last N commits: `git rebase -i HEAD~N`
- In editor: use `pick`, `squash` (or `s`), `reword`, `edit` to combine/modify commits.

## Cherry-pick & Hotfixes
- Apply a single commit to current branch: `git cherry-pick <commit-hash>`
- Cherry-pick range: `git cherry-pick A^..B`
- Example hotfix flow:
  - Create hotfix branch from `main`: `git switch -c hotfix/1.2.1 main`
  - Fix, commit, test
  - `git checkout main && git merge --no-ff hotfix/1.2.1` (or cherry-pick into release branch)
  - Push and tag: `git tag -a v1.2.1 -m "v1.2.1" && git push origin main --tags`

## Resolving Merge/Rebase Conflicts
- During merge or rebase, edit conflicted files, then:
  - After merge: `git add <file>` then `git commit` (if merge created conflict state)
  - During rebase: `git add <file>` then `git rebase --continue`
  - To abort: `git merge --abort` or `git rebase --abort`

## Reset vs Revert
- `git revert <commit>`: create a new commit that undoes a previous commit (safe for public branches)
- `git reset --soft HEAD~1`: move HEAD but keep changes staged
- `git reset --hard <commit>`: discard working tree changes (use with caution)

## Stash
- Save uncommitted changes: `git stash push -m "WIP: ..."`
- List stashes: `git stash list`
- Apply and keep stash: `git stash apply stash@{0}`
- Pop (apply + drop): `git stash pop`

## Remote Management
- Add remote: `git remote add origin <url>`
- Show remotes: `git remote -v`
- Rename: `git remote rename origin upstream`

## Useful Logs & Recovery
- Reflog (recover lost commits): `git reflog`
- Recover accidentally deleted branch: `git branch recovered <reflog-hash>`
- Find a commit by message: `git log --all --grep='text'`

## Bisect (find bad commit)
- Start bisection: `git bisect start`
- Mark bad: `git bisect bad` (HEAD)
- Mark good: `git bisect good <commit>`
- Git will checkout commits to test; after finish: `git bisect reset`

## Advanced / Maintenance
- Garbage collect: `git gc --prune=now --aggressive`
- Verify object DB: `git fsck --full`
- Remove large files/history: use `git filter-repo` (preferred) or `git filter-branch` (legacy)
- Manage submodules: `git submodule add <url> path` and `git submodule update --init --recursive`
- Worktrees: `git worktree add ../path feature/x`

## Hooks & Signing
- Local hooks live in `.git/hooks/` (e.g., `pre-commit`, `pre-push`)
- Sign commits: `git commit -S -m "msg"` (requires GPG/SSH key setup)

## Production Development Scenario (recommended workflow)
1. Keep `main` (or `master`) deployable at all times. Protect it with branch protections and required CI.
2. Feature branch workflow:
   - `git switch -c feature/JIRA-123` from `main`
   - Commit early and often: small commits with clear messages
   - Rebase locally onto updated `main` to keep changes current: `git fetch origin && git rebase origin/main`
   - Clean up history before PR: `git rebase -i origin/main` (squash/fixup as needed)
   - Push branch: `git push -u origin feature/JIRA-123` (force-push only after rebasing: `git push --force-with-lease`)
3. Open a Pull Request (PR): CI runs, reviewers approve.
4. Merge strategy:
   - Option A (maintain linear history): Rebase-and-merge on Git host, or `git rebase` locally then fast-forward `main`.
   - Option B (preserve merge commits): `git merge --no-ff feature/JIRA-123` to create a merge commit.
5. Hotfix scenario:
   - Create `hotfix/x` from `main`, implement fix, test.
   - Merge back to `main` and release branch. If fix applied on release branch first, cherry-pick into `main`:
     `git checkout main && git cherry-pick <hotfix-commit>`

## Examples
```
git rebase -i HEAD~3
# change 'pick' to 'squash' for commits to combine
git push --force-with-lease
```

```
git fetch origin
git switch feature/x
git rebase origin/main
# resolve conflicts if any
git push --force-with-lease
```

```
git checkout main
git pull
git cherry-pick <commit-hash>
git push
```

#### Clear Examples: Edit / Move / Delete a Commit
Below are concise, copy-pasteable examples that show the exact steps and expected outcome for common interactive-rebase tasks.

1) Edit a middle commit (change content or message)

Scenario: history (most recent last):
```
1111111 Add README
2222222 Implement feature A   <-- want to change this commit
3333333 Fix typo
4444444 Update docs
```
Steps:
```
git rebase -i HEAD~4
# In editor: change 'pick 2222222' -> 'edit 2222222'
# Save and exit; rebase will stop at that commit
# Make your source edits
git add changed_file
git commit --amend --no-edit   # or change message with --amend -m "new msg"
git rebase --continue
```
Outcome: the commit 2222222 is rewritten (new hash) with your edits incorporated.

2) Move (reorder) a commit

Scenario before:
```
A (111) -> B (222) -> C (333) -> D (444)
```
Goal: move C so history becomes A -> C -> B -> D.
Steps:
```
git rebase -i HEAD~4
# In the editor reorder lines so C appears before B
# Save and exit; resolve any conflicts
git rebase --continue
```
Outcome: commits are replayed in the new order; hashes change for affected commits.

3) Delete (drop) a commit

Two safe ways depending on whether commit is local-only or already shared.

a) Local-only (interactive drop):
```
git rebase -i HEAD~4
# delete the line for the commit you want to remove, or change 'pick' -> 'drop'
# save and exit, then 'git rebase --continue' as needed
```

b) Shared/public branch (do NOT rewrite public history):
```
# create a new commit that undoes the change
git revert <commit-hash>
git push
```

Recovering if you make a mistake:
```
git rebase --abort           # cancel an in-progress rebase
git reflog                   # find the previous HEAD or commit hash
git switch -c recover <hash> # restore lost state into a branch
```

Push policy after rewriting:
- If you rewrote commits that were already pushed, update remote with:
```
git push --force-with-lease
```
Use `--force-with-lease` to reduce risk of overwriting others' work.

These examples should cover the most common edit/move/delete needs when tidying local history before sharing changes.

## Tips & Best Practices
- Use `--force-with-lease` instead of `--force` to reduce accidental overwrites.
- Prefer `git revert` for undoing public history.
- Keep commits small and focused; write helpful commit messages.
- Protect `main` with branch protections and require PR reviews + CI.
- Automate formatting and linting with pre-commit hooks and CI.

---
This file is a concise reference; adapt commands to your team's branching and release policies.

## Advanced Concepts — Detailed Explanations

### Rebase (what, why, how)
Rebase reapplies commits from your current branch onto a different base commit, producing a linear history. It's ideal for cleaning up local feature branches before merging or for keeping your branch up-to-date without merge commits.

Pictorial (before):
```
o---o---o---A---B---C   (main)
       \
        D---E---F (feature)
```

After `git checkout feature && git rebase main`:
```
o---o---o---A---B---C---D'---E'---F' (feature)
```

Common flow:
```
git fetch origin
git switch feature/x
git rebase origin/main
# resolve conflicts; then
git rebase --continue
git push --force-with-lease
```

Interactive rebase (squash/reword):
```
git rebase -i HEAD~N
# change 'pick' to 's' (squash) or 'r' (reword) as needed
```

When NOT to rebase: avoid rebasing commits already pushed and shared with others (public history). Use `git revert` or merges for public branch changes.

### Bisect (find the commit that introduced a bug)
`git bisect` performs a binary search through commit history to find the first bad commit quickly.

Example scenario: you know commit X is good and HEAD is bad.

Commands:
```
git bisect start
git bisect bad            # current bad commit (usually HEAD)
git bisect good <good-commit-hash>
# Git checks out a midpoint; run tests
git bisect good|bad      # mark that midpoint accordingly
# repeat until the offending commit is identified
git bisect reset
```

Pictorial (concept):
```
good ... o o o o o o o bad
        ^
      Git tests midpoint here -> good/bad -> narrows range
```

Bisect is extremely helpful when tests can deterministically signal pass/fail; it reduces the search from N to ~log2(N) steps.

### Stash (temporary save of work-in-progress)
`git stash` saves uncommitted changes (working tree and/or index) to a stack so you can switch branches or pull without committing WIP.

Common commands:
```
git stash push -m "WIP: describe"
git stash list
git stash apply stash@{0}   # apply but keep stash
git stash pop               # apply and drop stash
git stash drop stash@{0}
git stash clear
```

Create a branch from stash (handy when WIP should become a feature branch):
```
git stash branch feature/from-wip stash@{0}
```

Partial stash (only staged or only untracked):
```
git stash push -k   # keep index (stages), stash working tree only
git stash push -u   # include untracked files
```

Stash conflicts: `git apply`/`git merge` style conflicts may occur; resolve files, then `git add` and `git stash drop` if applied.

---

These sections have been added to provide clearer examples and pictorial commit-flow illustrations for `rebase`, `bisect`, and `stash`.

### Editing, Dropping, Moving Commits (interactive rebase scenarios)
Common starting point (you want to rewrite the last N commits):
```
git rebase -i HEAD~N
In the editor you'll see lines like:
```
pick 1111111 Add README
- Edit a middle commit (change content):
  - Replace `pick` with `edit` on the commit you want to change.
  - Save & exit. Rebase will stop at that commit.
Example:
```
git rebase -i HEAD~4
- Drop a commit:
  - Remove the line for that commit in the interactive rebase editor or change `pick` to `drop` (Git >=2.17 supports `drop`).

Example (drop WIP commit 3333333):
- Reorder commits (move a commit earlier/later):
  - In the interactive rebase editor, reorder the lines to reflect desired order.

Pictorial before:
A (111) -> B (222) -> C (333) -> D (444)
```
After moving C before B (edit file order):
- Split a commit into smaller commits:
  - Mark the commit as `edit` in the interactive rebase.
  - When stopped, use `git reset HEAD^` to uncommit but keep changes in the working tree.
Example splitting commit 222:
```
git rebase -i HEAD~4
- Move commits to another branch (two approaches):
  1) Create a new branch from the commit you want to move and cherry-pick the commits there.
 2) Use `git rebase --onto` to transplant a range of commits onto another base.
Example `git rebase --onto`:
```
