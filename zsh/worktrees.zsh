#!/usr/bin/env zsh
# Shell aliases for working with git worktrees
# Source this file from your .zshrc with: source /path/to/file

# Create a new git worktree with a new branch
# Usage: wt <branch-name> [base-branch]
# Creates a new branch from base-branch (defaults to 'main') and sets up a worktree for it
wt() {
    # Validate branch name argument
    if [ -z "$1" ]; then
        echo "Error: Branch name is required." >&2
        echo "Usage: wt <branch-name> [base-branch]" >&2
        return 1
    fi

    local branch_name="$1"
    
    # Set the base branch (auto-detect default branch if not provided)
    if [ -z "$2" ]; then
        # Try to get the default branch from the remote HEAD
        local default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>&1 | sed 's@^refs/remotes/origin/@@')
        # Fall back to 'main' if detection fails
        local base_branch_raw="${default_branch:-main}"
    else
        local base_branch_raw="$2"
    fi

    # Get git repository root directory
    local git_root=$(git rev-parse --show-toplevel 2>&1)
    
    # Verify we are in a git repository
    if [ -z "$git_root" ]; then
        echo "Error: This command must be run from within a git repository." >&2
        return 1
    fi

    # Verify we're not already in a worktree (path shouldn't contain /.worktrees)
    if [[ "$git_root" == *"/.worktrees"* ]]; then
        echo "Error: This command cannot be run from within a git worktree. Change to the main repository first." >&2
        return 1
    fi

    # Prepare .worktrees directory and ensure it's in .gitignore
    local worktree_dir="$git_root/.worktrees"
    local gitignore_path="$git_root/.gitignore"
    mkdir -p "$worktree_dir"
    [ -f "$gitignore_path" ] || touch "$gitignore_path"
    if ! grep -q "^\.worktrees$" "$gitignore_path"; then
        echo ".worktrees" >> "$gitignore_path"
    fi

    # Convert / to - in branch name to create a safe directory path
    local safe_branch_name=$(echo "$branch_name" | tr '/' '-')
    local worktree_path="$worktree_dir/$safe_branch_name"

    # Check if worktree path already exists
    if [ -d "$worktree_path" ]; then
        echo "Error: Worktree path '$worktree_path' already exists." >&2
        return 1
    fi

    local remote_name="origin"
    local base_ref

    # Determine if base branch is a remote reference (e.g., origin/main)
    if [[ "$base_branch_raw" == "$remote_name/"* ]]; then
        # Extract the remote branch name
        local remote_branch="${base_branch_raw#"$remote_name/"}"
        if [ -z "$remote_branch" ]; then
            echo "Error: Invalid remote branch name." >&2
            return 1
        fi

        # Fetch the remote branch
        if ! git fetch "$remote_name" "$remote_branch"; then
            echo "Error: Failed to fetch remote branch '$base_branch_raw'." >&2
            return 1
        fi

        base_ref="$remote_name/$remote_branch"
    else
        # Use local branch as base
        base_ref="$base_branch_raw"
        if ! git rev-parse --verify "$base_ref" 2>&1; then
            echo "Error: Base branch '$base_ref' does not exist locally. Use '$remote_name/<branch>' to fetch from remote." >&2
            return 1
        fi
    fi

    # Verify the new branch doesn't already exist
    if git show-ref --verify "refs/heads/$branch_name" 2>&1; then
        echo "Error: Branch '$branch_name' already exists." >&2
        return 1
    fi

    # Resolve base reference to a commit SHA
    local base_commit=$(git rev-parse "$base_ref^{commit}" 2>&1)
    if [ -z "$base_commit" ]; then
        echo "Error: Could not resolve base reference '$base_ref' to a commit." >&2
        return 1
    fi

    # Create the new branch from the base commit
    echo "Creating branch '$branch_name' from '$base_ref' at commit '$base_commit'."
    if ! git branch "$branch_name" "$base_commit"; then
        echo "Error: Failed to create branch '$branch_name'." >&2
        return 1
    fi

    # Create the worktree and open in VS Code
    if git worktree add "$worktree_path" "$branch_name"; then
        # Print fancy summary
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "  ✓ Worktree Created Successfully"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        echo "  Command:        wt $1$([ -n "$2" ] && echo " $2")"
        echo "  New Branch:     $branch_name"
        echo "  Based On:       $base_ref"
        echo "  Commit:         ${base_commit:0:8}"
        echo "  Worktree Path:  $worktree_path"
        echo ""
        echo "  Branch Relationship:"
        echo "    $branch_name (new local branch)"
        echo "      └─ branched from → $base_ref"
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        cd "$worktree_path"
        code .
        cd -
    else
        # Clean up the branch if worktree creation fails
        git branch -D "$branch_name"
        echo "Error: Failed to create worktree '$branch_name'." >&2
        return 1
    fi
}

wt_from_branch() {
    # Check if branch name argument was provided
    if [ -z "$1" ]; then
        echo "Error: Branch name is required." >&2
        echo "Usage: wt_from_branch <branch-name>" >&2
        return 1
    fi

    local branch_name="$1"

    # Get git repository root directory
    local git_root=$(git rev-parse --show-toplevel 2>&1)
    
    # Verify we are in a git repository
    if [ -z "$git_root" ]; then
        echo "Error: This command must be run from within a git repository." >&2
        return 1
    fi

    # Verify we're not already in a worktree (path shouldn't contain /.worktrees)
    if [[ "$git_root" == *"/.worktrees"* ]]; then
        echo "Error: This command cannot be run from within a git worktree. Change to the main repository first." >&2
        return 1
    fi

    # Prepare .worktrees directory and ensure it's in .gitignore
    local worktree_dir="$git_root/.worktrees"
    local gitignore_path="$git_root/.gitignore"
    
    # Create the .worktrees directory if it doesn't exist
    mkdir -p "$worktree_dir"
    
    # Ensure .gitignore exists before trying to append to it
    [ -f "$gitignore_path" ] || touch "$gitignore_path"
    
    # Add .worktrees to .gitignore if it's not already there
    if ! grep -q "^\.worktrees$" "$gitignore_path"; then
        echo ".worktrees" >> "$gitignore_path"
    fi

    # Convert / to - in branch name to create a safe directory path
    local safe_branch_name=$(echo "$branch_name" | tr '/' '-')
    local worktree_path="$worktree_dir/$safe_branch_name"

    # Check if worktree path already exists
    if [ -d "$worktree_path" ]; then
        echo "Error: Worktree path '$worktree_path' already exists." >&2
        return 1
    fi

    local remote_name="origin"
    local branch_exists_locally=false
    local branch_exists_remotely=false

    # Check if the branch exists locally
    if git show-ref --verify "refs/heads/$branch_name" 2>&1; then
        branch_exists_locally=true
    fi

    # If branch doesn't exist locally, check if it exists on the remote
    if [ "$branch_exists_locally" = false ]; then
        # Check if the branch exists on origin
        if git ls-remote --heads "$remote_name" "$branch_name" | grep -q "$branch_name"; then
            branch_exists_remotely=true
        else
            # Branch not found on remote, try fetching and checking again
            echo "Branch '$branch_name' not found locally or on remote. Fetching from '$remote_name'..."
            if git fetch "$remote_name"; then
                # Check again after fetch
                if git ls-remote --heads "$remote_name" "$branch_name" | grep -q "$branch_name"; then
                    branch_exists_remotely=true
                fi
            fi
        fi

        # If branch still doesn't exist anywhere, error out
        if [ "$branch_exists_remotely" = false ]; then
            echo "Error: Branch '$branch_name' does not exist locally or on '$remote_name'." >&2
            return 1
        fi

        # Branch exists on remote, so create a local tracking branch and worktree
        echo "Creating local branch '$branch_name' tracking '$remote_name/$branch_name'."
        if ! git branch --track "$branch_name" "$remote_name/$branch_name"; then
            echo "Error: Failed to create tracking branch '$branch_name'." >&2
            return 1
        fi
    fi

    # Create the worktree from the branch (now guaranteed to exist locally)
    if git worktree add "$worktree_path" "$branch_name"; then
        # Get current commit and tracking info
        local current_commit=$(git rev-parse "$branch_name" 2>&1 | cut -c1-8)
        local tracking_info=""
        local relationship=""
        
        # Check if branch is tracking a remote
        if git config "branch.$branch_name.remote" >/dev/null 2>&1; then
            local remote=$(git config "branch.$branch_name.remote")
            local merge=$(git config "branch.$branch_name.merge" | sed 's@^refs/heads/@@')
            tracking_info="$remote/$merge"
            relationship="    $branch_name (local branch)\n      └─ tracking → $tracking_info"
        else
            relationship="    $branch_name (local branch, no remote tracking)"
        fi
        
        # Print fancy summary
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "  ✓ Worktree Created Successfully"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        echo "  Command:        wt_from_branch $1"
        echo "  Branch:         $branch_name"
        echo "  Commit:         $current_commit"
        echo "  Worktree Path:  $worktree_path"
        echo ""
        echo "  Branch Relationship:"
        echo "$relationship"
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        # Navigate to the new worktree and open in VS Code
        cd "$worktree_path"
        code .
        cd -
    else
        echo "Error: Failed to create worktree '$branch_name'." >&2
        return 1
    fi
}

# Clean up all git worktrees
# WARNING: This is a destructive operation that removes all worktrees
wtc() {
    # Get the root directory of the git repository
    local git_root=$(git rev-parse --show-toplevel 2>&1)
    if [ -z "$git_root" ]; then
        echo "Error: not a git repository." >&2
        return 1
    fi

    local worktree_dir="$git_root/.worktrees"

    # Check if .worktrees directory exists
    if [ ! -d "$worktree_dir" ]; then
        echo "No .worktrees directory found."
        return 0
    fi

    # Count and list worktrees to be removed
    local worktree_count=0
    local worktree_list=()
    
    for worktree in "$worktree_dir"/*; do
        if [ -d "$worktree" ]; then
            worktree_count=$((worktree_count + 1))
            worktree_list+=("$(basename "$worktree")")
        fi
    done

    # Exit if no worktrees found
    if [ "$worktree_count" -eq 0 ]; then
        echo "No worktrees found in $worktree_dir"
        return 0
    fi

    # Display worktrees to be removed
    echo "The following $worktree_count worktree(s) will be removed:"
    for wt in "${worktree_list[@]}"; do
        echo "  - $wt"
    done
    echo ""

    # Prompt for confirmation
    echo -n "Press Enter to continue or Ctrl+C to cancel..."
    read REPLY
    echo ""

    # Remove each worktree using git worktree remove
    echo "Removing worktrees..."
    for worktree in "$worktree_dir"/*; do
        if [ -d "$worktree" ]; then
            local wt_name=$(basename "$worktree")
            echo "  Removing $wt_name..."
            git worktree remove "$worktree" --force
        fi
    done
    
    # Prune worktrees to clean up git's internal state
    git worktree prune
    
    # Remove the .worktrees directory if it still exists
    if [ -d "$worktree_dir" ]; then
        rm -rf "$worktree_dir"
    fi
    
    echo "All worktrees have been removed successfully."
}

# Close the current worktree
# Removes the current worktree directory and switches to the repository root
# Usage: wt_close
wt_close() {
    # Get the current directory
    local current_dir="$PWD"
    
    # Get git repository root directory
    local git_root=$(git rev-parse --show-toplevel 2>&1)
    
    # Verify we are in a git repository
    if [ -z "$git_root" ]; then
        echo "Error: This command must be run from within a git repository." >&2
        return 1
    fi

    # Verify we're in a worktree (path should contain /.worktrees)
    if [[ "$git_root" != *"/.worktrees"* ]]; then
        echo "Error: This command must be run from within a git worktree." >&2
        echo "Current directory does not appear to be a worktree." >&2
        return 1
    fi

    # Extract the worktree name from the path
    local worktree_name=$(basename "$git_root")
    local worktree_path="$git_root"
    
    # Get the actual repository root (parent of .worktrees)
    local repo_root=$(dirname "$(dirname "$git_root")")
    
    # Get the branch name for this worktree
    local branch_name=$(git rev-parse --abbrev-ref HEAD 2>&1)
    if [ -z "$branch_name" ]; then
        echo "Error: Could not determine branch name for this worktree." >&2
        return 1
    fi

    # Display summary of what will be removed
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Worktree Closure Summary"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "  Worktree Name:  $worktree_name"
    echo "  Branch:         $branch_name"
    echo "  Path:           $worktree_path"
    echo "  Repo Root:      $repo_root"
    echo ""
    echo "  Actions:"
    echo "    • Remove worktree directory"
    echo "    • Clean up git worktree references"
    echo "    • Switch to repository root: $repo_root"
    echo ""
    echo "  Note: The branch '$branch_name' will remain in the repository."
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo ""

    # Prompt for confirmation
    echo -n "Press Enter to continue or Ctrl+C to cancel..."
    read REPLY
    echo ""

    # Change to the repository root first (required before removing worktree)
    cd "$repo_root" || {
        echo "Error: Failed to change to repository root." >&2
        return 1
    }

    # Remove the worktree
    echo ""
    echo "Removing worktree..."
    if git worktree remove "$worktree_path" --force; then
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "  ✓ Worktree Closed Successfully"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        echo "  Removed:        $worktree_name"
        echo "  Branch:         $branch_name (still exists)"
        echo "  Current Dir:    $repo_root"
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
    else
        echo "Error: Failed to remove worktree." >&2
        return 1
    fi

    # Prune to clean up any stale references
    git worktree prune
}