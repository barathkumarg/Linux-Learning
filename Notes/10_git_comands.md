# Git Essential Commands & Production Workflows

## Table of Contents
1. [Synopsis](#synopsis)
2. [Quick Reference](#quick-reference)
3. [Core Concepts](#core-concepts)
4. [Branching & Navigation](#branching--navigation)
5. [Merging vs Rebase](#merging-vs-rebase)
6. [Common Workflows](#common-workflows)
7. [Interactive Rebase](#interactive-rebase)
8. [Cherry-pick & Hotfixes](#cherry-pick--hotfixes)
9. [Resolving Merge/Rebase Conflicts](#resolving-mergerebase-conflicts)
10. [Reset vs Revert](#reset-vs-revert)
11. [Stash](#stash)
12. [Remote Management](#remote-management)
13. [Logs & Recovery](#logs--recovery)
14. [Bisect](#bisect)
15. [Advanced Maintenance](#advanced-maintenance)
16. [Hooks & Signing](#hooks--signing)
17. [Tips & Best Practices](#tips--best-practices)
18. [Production Workflow](#production-workflow)

---

## Synopsis

Git is a distributed version control system that tracks code changes, enables collaboration, and maintains project history. This guide covers essential commands for daily development, production workflows, and advanced scenarios.

**Key purposes of Git:**
- Track changes and maintain project history
- Enable team collaboration with branching and merging
- Recover lost work and identify when bugs were introduced
- Maintain clean, linear history (via rebase) or preserve merge commits (via merge)

**Core workflow:** Create feature branches → Commit changes → Test → Open PR → Merge to main → Deploy

---

## Quick Reference
- Initialize repo: `git init`
- Clone: `git clone <url>`
- Check status: `git status`
- Stage files: `git add <file>` or `git add .`
- Commit: `git commit -m "message"`
- Amend last commit: `git commit --amend --no-edit`
- Push: `git push [remote] [branch]`
- Fetch: `git fetch`
- Pull (fetch+merge): `git pull`
- Create & switch branch: `git switch -c <branch>`
- Delete branch: `git branch -d <branch>` (force: `-D`)
- View history: `git log --oneline --graph --decorate --all`

---

## Core Concepts

### Repository
A Git repository is a directory containing all project files and a `.git/` folder that stores version history, configurations, and references.

### Commit
A snapshot of your project at a point in time with a unique hash, author info, timestamp, and message. Commits form an immutable history.

### Branch
A named reference (pointer) to a commit, allowing parallel development lines without interfering with each other.

### Remote
A reference to an external repository (e.g., GitHub, GitLab) to which you push and pull changes.

### HEAD
A pointer to the current commit you're viewing. Usually points to a branch, but can point directly to a commit (detached HEAD state).

---

## Branching & Navigation

- List local branches: `git branch`
- List all branches (including remote): `git branch -a`
- Create branch: `git branch <branch-name>`
- Create and switch to branch: `git switch -c <branch-name>` (or `git checkout -b`)
- Switch branch: `git switch <branch>` (or `git checkout <branch>`)
- Delete branch: `git branch -d <branch>` (force: `-D`)
- Rename branch: `git branch -m <old-name> <new-name>`
- See commit log: `git log --oneline --graph --decorate --all`
- See log for specific branch: `git log <branch-name>`

---

## Merging vs Rebase

Both combine changes from one branch into another, but they differ in approach and result.

### Merge
Combines two branches by creating a **merge commit**. Preserves complete history of both branches. No commits are rewritten.

**When to use:** 
- Final integration onto main branch
- When you want a clear merge marker showing when features were integrated
- On public/shared branches

```bash
# Switch to target branch
git checkout main

# Merge feature branch
git merge --no-ff feature/x
# --no-ff forces a merge commit even if fast-forward is possible
```

### Rebase
Reapplies commits from current branch onto another base, creating a **linear history**. Rewrites commit hashes.

**When to use:**
- Local feature branch cleanup before opening PR
- Keeping your branch up-to-date without merge commits
- Before final integration to ensure clean history

```bash
# Switch to feature branch
git checkout feature/x

# Rebase onto main
git rebase main
# Git will replay your commits on top of main

# Resolve conflicts if any
git rebase --continue

# Then fast-forward main
git checkout main && git merge feature/x
```

**Important Caution:** 
Never rebase commits already pushed to a shared branch. Only rebase local commits. Use `git push --force-with-lease` only for branches you've rewritten, and inform team members.

---

## Common Workflows

### Feature Branch Workflow
```bash
# Create and switch to feature branch from main
git switch -c feature/JIRA-123

# Make changes and commit
git add <file>
git commit -m "Implement feature X"

# Make more commits
git add <file2>
git commit -m "Add tests for feature X"

# Keep branch updated with latest main
git fetch origin
git rebase origin/main

# Clean up history before PR (optional)
git rebase -i origin/main
# In editor: combine or reorder commits as needed

# Push branch
git push -u origin feature/JIRA-123

# Open PR, get reviewed, and merge after approval
```

### Hotfix Workflow
```bash
# Create hotfix branch from main
git switch -c hotfix/1.2.1 main

# Make fix and test
git add <fixed-file>
git commit -m "Fix critical bug in payment flow"

# Merge back to main
git checkout main
git merge --no-ff hotfix/1.2.1

# Create release tag
git tag -a v1.2.1 -m "Release v1.2.1"

# Push main and tags
git push origin main --tags

# Clean up hotfix branch
git branch -d hotfix/1.2.1
git push origin --delete hotfix/1.2.1
```

---

## Interactive Rebase

Interactive rebase allows you to rewrite history by editing, reordering, squashing, or splitting commits. Useful for cleaning up local branches before sharing.

### Basic Command
```bash
# Rewrite last N commits
git rebase -i HEAD~N

# Or specify base commit
git rebase -i <base-commit>
```

### Interactive Rebase Operations

In the editor, each commit line starts with a command keyword:

- `pick` - use commit as is
- `reword` - use commit but edit message
- `edit` - use commit but stop to amend (change code)
- `squash` (or `s`) - use commit but combine with previous commit
- `fixup` (or `f`) - like squash but discard commit message
- `drop` - remove commit from history

### Example 1: Squash Multiple Commits
Combine last 3 commits into one:
```bash
git rebase -i HEAD~3
# In editor:
pick 1111111 Add README
pick 2222222 Add tests
pick 3333333 Fix formatting    # Change to: squash
squash 3333333 Fix formatting

# Git opens editor for combined commit message
# Edit and save
```

### Example 2: Edit a Middle Commit
Change content of a commit in the middle of history:
```bash
# History before:
# 1111111 Add README
# 2222222 Implement feature A    <- want to change this
# 3333333 Fix typo

git rebase -i HEAD~3
# In editor, change 'pick 2222222' to 'edit 2222222'

# Rebase stops at that commit
# Make your edits to files
git add <modified-file>

# Amend the commit
git commit --amend --no-edit    # keep same message
# OR: git commit --amend -m "new message"

# Continue rebase
git rebase --continue
# Commit 2222222 is rewritten with new hash
```

### Example 3: Reorder Commits
Move commits around to change their order:
```bash
# History: A->B->C->D, want C before B

git rebase -i HEAD~4
# In editor, move C's line before B's line
# Save and exit
# Rebase replays in new order
```

### Example 4: Delete a Commit
```bash
git rebase -i HEAD~4
# In editor, delete the entire line OR change 'pick' to 'drop'
# Save and exit
```

### Recovering from Rebase Mistakes
```bash
# Cancel in-progress rebase if something goes wrong
git rebase --abort

# Find previous state using reflog
git reflog

# Restore to a previous state
git switch -c recover <reflog-commit-hash>
```

---

## Cherry-pick & Hotfixes

### Cherry-pick
Apply a specific commit (or range of commits) from one branch to another. Useful for backporting fixes to release branches.

```bash
# Apply single commit
git cherry-pick <commit-hash>

# Apply range of commits (inclusive)
git cherry-pick A^..B

# Apply multiple specific commits
git cherry-pick <hash1> <hash2> <hash3>
```

### Handling Cherry-pick Conflicts
If conflicts occur during cherry-pick:
```bash
# Edit conflicted files to resolve
git add <resolved-files>

# Continue cherry-pick
git cherry-pick --continue

# Or abort if something went wrong
git cherry-pick --abort
```

### Use Case: Backport Fix to Release Branch
```bash
# Bug discovered and fixed on main
# Need to apply same fix to release-1.2 branch

# First, get the commit hash from main
git log main --oneline | grep "Fix payment bug"

# Switch to release branch
git checkout release-1.2

# Apply the fix
git cherry-pick <commit-hash>

# Push release branch
git push origin release-1.2
```

---

## Resolving Merge/Rebase Conflicts

When changes from different branches conflict (same lines modified differently), Git stops and asks you to resolve.

### Identifying Conflicts

Git marks conflicts in files with special markers:
```
<<<<<<< HEAD
your changes (current branch)
=======
incoming changes (branch being merged/applied)
>>>>>>> branch-name
```

### Resolving Steps

1. **Edit conflicted files** - Choose desired changes:
   - Keep your changes: remove `<<<< HEAD`, `=======`, `>>>> branch`
   - Keep incoming: do the same but remove your version
   - Keep both: combine them manually
   - Create hybrid version: select parts from each

2. **Stage resolved files**:
   ```bash
   git add <resolved-file>
   ```

3. **Complete the operation**:
   ```bash
   # For merge:
   git commit

   # For rebase:
   git rebase --continue

   # For cherry-pick:
   git cherry-pick --continue
   ```

### To Abort Without Resolving
```bash
git merge --abort    # during merge
git rebase --abort   # during rebase
git cherry-pick --abort  # during cherry-pick
```

---

## Reset vs Revert

Both undo changes, but in very different ways.

### `git reset`
Moves HEAD to a different commit. Can keep, stage, or discard changes. **Rewrites history**, so avoid on public branches.

```bash
# Soft reset: move HEAD, keep changes staged
git reset --soft HEAD~1

# Mixed reset (default): move HEAD, keep changes in working tree (unstaged)
git reset --mixed HEAD~1
git reset HEAD~1    # same as --mixed

# Hard reset: move HEAD, discard all changes
git reset --hard HEAD~1

# Reset to specific commit
git reset --hard <commit-hash>

# Reset a specific file to HEAD
git reset HEAD <file>

# Reset staged changes to a file
git reset <file>
```

**Use case:** 
- Undo uncommitted changes
- Undo local commits before pushing
- Clean up staging area

### `git revert`
Creates a **new commit** that undoes the changes from a previous commit. Does NOT rewrite history. Safe for public branches.

```bash
# Create commit that reverts specific commit
git revert <commit-hash>

# Revert without opening editor
git revert <commit-hash> --no-edit

# Revert multiple consecutive commits
git revert <commit1>..<commit2>
```

**Use case:**
- Undo a change on a shared/public branch
- You need to preserve the fact that a commit was reverted

### Comparison Table

| Operation | Rewrites History? | Safe for Public Branches? | Use When |
|-----------|-------------------|--------------------------|----------|
| `reset` | Yes | No | Undoing local commits |
| `revert` | No | Yes | Undoing shared commits |

---

## Stash

Temporarily save uncommitted changes without committing them. Useful for switching branches or pulling without committing WIP.

### Basic Commands
```bash
# Save current changes to stash
git stash push -m "WIP: describe work"
# or shorter: git stash save "WIP: describe"

# List all stashes
git stash list

# Apply stash (keep in stash)
git stash apply stash@{0}

# Apply and remove stash
git stash pop

# Discard a stash
git stash drop stash@{0}

# Clear all stashes
git stash clear
```

### Partial Stash
```bash
# Stash only working tree changes (keep staged)
git stash push -k

# Include untracked files in stash
git stash push -u

# Stash only specific files
git stash push <file1> <file2>
```

### Create Branch from Stash
Useful when WIP should become a feature branch:
```bash
git stash branch feature/from-wip stash@{0}
# Creates new branch and applies stash
```

### Handling Stash Conflicts
If applying a stash creates conflicts:
```bash
# Edit conflicted files
git add <resolved-files>

# If using apply, drop stash manually
git stash drop stash@{0}

# If conflicts during pop, resolve them as above
```

---

## Remote Management

Remotes are pointers to external repositories, commonly on GitHub, GitLab, etc.

```bash
# Add new remote
git remote add origin <url>

# List all remotes with URLs
git remote -v

# Rename a remote
git remote rename origin upstream

# Remove a remote
git remote remove origin

# Show remote details
git remote show origin

# Change remote URL
git remote set-url origin <new-url>

# Add a new remote
git remote add backup <backup-url>
```

### Push and Pull with Remotes
```bash
# Push to remote
git push origin main

# Push current branch
git push

# Push all branches
git push --all

# Push with tags
git push origin main --tags

# Pull from remote (fetch + merge)
git pull origin main

# Fetch without merging
git fetch origin

# Prune deleted remote branches
git fetch origin --prune
```

---

## Logs & Recovery

### Viewing History
```bash
# Compact log with graph
git log --oneline --graph --decorate --all

# Log for specific branch
git log main --oneline

# Find commits by author
git log --author="John"

# Find commits by message
git log --all --grep='fix deadlock'

# Show commits affecting specific file
git log -- <file>

# See what changed in each commit
git log -p

# Last N commits
git log -n 5
```

### Recovery Using Reflog
The reflog records all changes to HEAD, allowing recovery of "lost" commits.

```bash
# View reflog
git reflog

# Example output:
# 1234567 HEAD@{0}: commit: Add feature
# 2345678 HEAD@{1}: reset: moving to HEAD~1
# 3456789 HEAD@{2}: commit: Earlier commit

# Recover accidentally deleted branch
git branch recovered 3456789

# Switch to recovered commit
git checkout 3456789

# Create branch from recovered commit
git switch -c recovered-work 3456789
```

### Finding Commits
```bash
# Find commit by partial message
git log --all --grep='payment'

# Find who and when changed a line
git blame <file>

# Show commit that changed specific line
git log -L 10,20:<file>
```

---

## Bisect

Binary search through commits to find which one introduced a bug. Git will checkout commits for you to test.

### Basic Workflow
```bash
# Start bisection
git bisect start

# Mark current commit as bad (has the bug)
git bisect bad
# or: git bisect bad <commit-hash>

# Mark a known good commit
git bisect good <commit-hash>

# Git checks out a midpoint
# Run tests to determine if this commit is good or bad
git bisect good    # if this commit is fine
# OR
git bisect bad     # if bug exists in this commit

# Repeat until Git finds the bad commit
# Git will show:
# "<hash> is the first bad commit"

# Return to normal state
git bisect reset
```

### With Automated Testing
```bash
# Start bisection
git bisect start

# Mark bad/good
git bisect bad HEAD
git bisect good v1.0

# Run automated test script
git bisect run ./test.sh
# Git runs test.sh at each commit automatically
# test.sh should exit 0 for success, non-zero for failure
# Git finds the bad commit automatically
```

### Example
```
Commits: 1 -- 2 -- 3 -- 4 -- 5 -- 6 -- 7 (bug here)

git bisect start
git bisect bad HEAD        # 7 is bad
git bisect good v1.0       # assume 1 is good

# Git checks out 4 (midpoint)
# Test your code
git bisect bad             # 4 is bad

# Git checks out 2
git bisect good            # 2 is good

# Git checks out 3
git bisect bad             # 3 is bad - FOUND IT
```

---

## Advanced Maintenance

Maintenance commands for cleaning up and optimizing repositories.

```bash
# Garbage collection (optimize repo)
git gc --prune=now --aggressive

# Verify object database integrity
git fsck --full

# Show repository size
du -sh .git

# Remove large files from history
git filter-repo --path <large-file> --invert-paths
# or legacy: git filter-branch (slower, less reliable)

# Manage submodules (dependencies)
git submodule add <url> <path>
git submodule update --init --recursive

# Work with multiple branches in parallel
git worktree add ../path feature/x
git worktree list
git worktree remove ../path
```

---

## Hooks & Signing

### Git Hooks
Scripts that run automatically at specific Git events. Useful for automated checks and formatting.

```bash
# Hooks location
.git/hooks/

# Common hooks:
# pre-commit - runs before commit
# pre-push - runs before push
# post-merge - runs after merge

# Create pre-commit hook example:
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
npm run lint
EOF

chmod +x .git/hooks/pre-commit
```

### Signing Commits
Sign commits with GPG or SSH key for verification.

```bash
# Sign a commit
git commit -S -m "message"

# Set default signing key
git config user.signingkey <key-id>

# Sign all commits by default
git config commit.gpgSign true

# Verify signed commits
git log --show-signature
```

---

## Tips & Best Practices

1. **Use `--force-with-lease` not `--force`**
   - Forces push but checks for remote changes first
   - Reduces risk of overwriting others' work
   ```bash
   git push --force-with-lease
   ```

2. **Commit early and often**
   - Small, focused commits are easier to review and understand
   - Better for bisecting to find bugs
   - Use clear commit messages

3. **Keep commits small and focused**
   - One feature/fix per commit
   - Makes PR reviews easier
   - Simplifies git blame and history reading

4. **Write helpful commit messages**
   ```
   [JIRA-123] Add payment processing feature
   
   - Integrate Stripe API
   - Add payment validation
   - Add success/error handling
   
   Closes JIRA-123
   ```

5. **Protect main branch**
   - Require branch protection rules
   - Require PR reviews before merging
   - Run CI checks before merge allowed
   - Prevent force pushes to main

6. **Use branches for everything**
   - Never commit directly to main
   - Create branch for each feature/fix
   - Use descriptive branch names: `feature/`, `fix/`, `hotfix/`

7. **Review before merging**
   - Have at least one other person review
   - Use PR comments for discussion
   - Request changes if issues found

8. **Prefer revert for public branches**
   - Never rewrite shared history
   - Use `git revert` to undo public commits
   - Creates new commit explaining the undo

9. **Clean up local branches**
   ```bash
   # Delete merged branches
   git branch --merged | grep -v main | xargs git branch -d

   # Delete remote tracking branches for deleted branches
   git fetch origin --prune
   ```

10. **Tag releases**
    ```bash
    git tag -a v1.2.3 -m "Release v1.2.3"
    git push origin v1.2.3
    ```

---

## Production Workflow

Recommended workflow for production development teams.

### 1. Repository Setup
- Keep `main` (or `master`) deployable at all times
- Protect main branch with:
  - Require PR reviews (at least 1-2 reviewers)
  - Require CI checks pass
  - Dismiss stale PR approvals on new commits
  - Prevent force pushes

### 2. Feature Development
```bash
# Create feature branch from main
git switch -c feature/JIRA-123

# Commit early and often with clear messages
git add <file>
git commit -m "[JIRA-123] Implement search feature"

# Keep branch updated
git fetch origin
git rebase origin/main

# If behind, rebase to stay current
git rebase origin/main --interactive

# Push when ready for review
git push -u origin feature/JIRA-123
```

### 3. Pull Request Process
- Open PR on GitHub/GitLab
- Run title/description checks: `[JIRA-123] Add feature description`
- Link to issue/ticket
- Describe what changed and why
- Let CI run automatically
- Request reviewers
- Address feedback and push additional commits
- Get approved

### 4. Merging Strategy
**Option A: Linear History (Rebase)**
```bash
# Locally: Clean up commits
git rebase -i origin/main

# On GitHub: Choose "Rebase and merge"
# Creates linear history
```

**Option B: Preserve Merge Commits**
```bash
# Merge creates merge commit
git merge --no-ff feature/JIRA-123
# Shows complete branching history
```

**Recommendation:** 
Use Option A for linear, clean history. Use Option B if you want to see exactly which commits were related.

### 5. Release Process
```bash
# Create release branch from main
git switch -c release/v1.2.0 main

# Make release-only changes (version numbers, etc)
git add version.json
git commit -m "Bump version to v1.2.0"

# Tag release
git tag -a v1.2.0 -m "Release v1.2.0"

# Push
git push origin release/v1.2.0 --tags

# Deploy release/v1.2.0 or tag to production
```

### 6. Hotfix Process
```bash
# Create hotfix from main (or tag)
git switch -c hotfix/1.2.1 main

# Fix bug
git add <file>
git commit -m "Fix critical payment bug"

# Test thoroughly
./run-tests.sh

# Merge to main
git checkout main
git pull
git merge --no-ff hotfix/1.2.1

# Create tag
git tag -a v1.2.1 -m "Hotfix v1.2.1"

# Push and deploy
git push origin main --tags

# Also merge to release branches if needed
git checkout release-1.2
git cherry-pick <hotfix-commit>
git push

# Clean up
git branch -d hotfix/1.2.1
git push origin --delete hotfix/1.2.1
```

### 7. Commit Message Conventions
```
[TYPE-ISSUE] Short description (50 chars max)

Detailed explanation of changes (wrap at 72 chars)
- List specific changes
- Why was change needed
- Any gotchas or considerations

Closes ISSUE-123
Reviewed-by: John Doe
```

**Types:** `feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `test:`, `chore:`

---

**This is a living reference document. Adapt commands and workflows to your team's specific needs and policies.**
