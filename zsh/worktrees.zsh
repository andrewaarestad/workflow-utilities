#!/usr/bin/env zsh
# Shell aliases for working with git worktrees
# Source this file from your .zshrc with: source /path/to/file

_get_git_root() {
    git rev-parse --show-toplevel 2>/dev/null
}

_require_git_repo_cwd() {
    local git_root=$(_get_git_root)
    if [ -z "$git_root" ]; then
        echo "Error: This command must be run from within a git repository." >&2
        return 1
    fi
    echo "$git_root"
}

_require_non_worktree_cwd() {
    local git_root=$(_get_git_root)
    if [[ "$git_root" == *"/.worktrees"* ]]; then
        echo "Error: This command cannot be run from within a git worktree. Change to the main repository first." >&2
        return 1
    fi
}

_make_worktree_branch_name_safe() {
    # convert / to - in worktree path:
    echo "$1" | tr '/' '-'
}

_prepare_worktrees_subfolder() {
    local git_root="$1"
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
}

# Create a git worktree
# This function is self-contained (all helper functions inlined) to work in shell snapshots
# like those used by Claude Code, where helper functions may not be available.
wt() {
    if [ -z "$1" ]; then
        echo "Error: Branch name is required." >&2
        echo "Usage: wt <branch-name> [base-branch]" >&2
        return 1
    fi

    # Set the base branch (default to 'main' if not provided)
    local base_branch_raw="${2:-main}"
    local branch_name="$1"

    # Inline: _get_git_root() - Get git repository root directory
    local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    
    # Inline: _require_git_repo_cwd() - Check that we are in a git repository
    if [ -z "$git_root" ]; then
        echo "Error: This command must be run from within a git repository." >&2
        return 1
    fi

    # Inline: _require_non_worktree_cwd() - Check that we're not already in a worktree
    if [[ "$git_root" == *"/.worktrees"* ]]; then
        echo "Error: This command cannot be run from within a git worktree. Change to the main repository first." >&2
        return 1
    fi

    # Inline: _prepare_worktrees_subfolder() - Prepare .worktrees directory and .gitignore
    local worktree_dir="$git_root/.worktrees"
    local gitignore_path="$git_root/.gitignore"
    mkdir -p "$worktree_dir"
    [ -f "$gitignore_path" ] || touch "$gitignore_path"
    if ! grep -q "^\.worktrees$" "$gitignore_path"; then
        echo ".worktrees" >> "$gitignore_path"
    fi

    # Inline: _make_worktree_branch_name_safe() - Convert / to - in branch name for path
    local safe_branch_name=$(echo "$branch_name" | tr '/' '-')
    local worktree_path="$worktree_dir/$safe_branch_name"

    if [ -d "$worktree_path" ]; then
        echo "Error: Worktree path '$worktree_path' already exists." >&2
        return 1
    fi

    local remote_name="origin"
    local base_ref

    if [[ "$base_branch_raw" == "$remote_name/"* ]]; then
        local remote_branch="${base_branch_raw#"$remote_name/"}"
        if [ -z "$remote_branch" ]; then
            echo "Error: Invalid remote branch name." >&2
            return 1
        fi

        if ! git fetch "$remote_name" "$remote_branch" >/dev/null 2>&1; then
            echo "Error: Failed to fetch remote branch '$base_branch_raw'." >&2
            return 1
        fi

        base_ref="$remote_name/$remote_branch"
    else
        base_ref="$base_branch_raw"
        if ! git rev-parse --verify "$base_ref" >/dev/null 2>&1; then
            echo "Error: Base branch '$base_ref' does not exist locally. Use '$remote_name/<branch>' to fetch from remote." >&2
            return 1
        fi
    fi

    if git show-ref --verify "refs/heads/$branch_name" >/dev/null 2>&1; then
        echo "Error: Branch '$branch_name' already exists." >&2
        return 1
    fi

    local base_commit=$(git rev-parse "$base_ref^{commit}" 2>/dev/null)
    if [ -z "$base_commit" ]; then
        echo "Error: Could not resolve base reference '$base_ref' to a commit." >&2
        return 1
    fi

    echo "Creating branch '$branch_name' from '$base_ref' at commit '$base_commit'."
    if ! git branch "$branch_name" "$base_commit" >/dev/null 2>&1; then
        echo "Error: Failed to create branch '$branch_name'." >&2
        return 1
    fi

    if git worktree add "$worktree_path" "$branch_name" >/dev/null 2>&1; then
        echo "Worktree '$branch_name' created successfully from base '$base_ref'."
        cd "$worktree_path"
        code .
        cd - >/dev/null
    else
        git branch -D "$branch_name" >/dev/null 2>&1
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
    local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    
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
    if git show-ref --verify "refs/heads/$branch_name" >/dev/null 2>&1; then
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
            if git fetch "$remote_name" >/dev/null 2>&1; then
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
        if ! git branch --track "$branch_name" "$remote_name/$branch_name" >/dev/null 2>&1; then
            echo "Error: Failed to create tracking branch '$branch_name'." >&2
            return 1
        fi
    fi

    # Create the worktree from the branch (now guaranteed to exist locally)
    if git worktree add "$worktree_path" "$branch_name" >/dev/null 2>&1; then
        echo "Worktree '$branch_name' created successfully."
        # Navigate to the new worktree and open in VS Code
        cd "$worktree_path"
        code .
        cd - >/dev/null
    else
        echo "Error: Failed to create worktree '$branch_name'." >&2
        return 1
    fi
}

# Clean up git worktrees
wtc() {
    # Get the root directory of the Git repository
    local git_root=$(_get_git_root)
    if [ -z "$git_root" ]; then
        echo "Error: not a git repository." >&2
        return 1
    fi

    local worktree_dir="$git_root/.worktrees"

    if [ ! -d "$worktree_dir" ]; then
        echo "No .worktrees directory found."
        return 0
    fi

    # Remove each worktree properly before removing the directory
    for worktree in "$worktree_dir"/*; do
        if [ -d "$worktree" ]; then
            git worktree remove "$worktree" --force >/dev/null 2>&1
        fi
    done
    # Prune worktrees to clean up git's internal state
    git worktree prune
    # Remove the .worktrees directory if it still exists
    if [ -d "$worktree_dir" ]; then
        rm -rf "$worktree_dir"
    fi
    echo "All worktrees have been removed."
}