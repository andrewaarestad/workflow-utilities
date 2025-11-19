#!/usr/bin/env zsh
# Shell aliases for working with git worktrees
# Source this file from your .zshrc with: source /path/to/file

_get_git_root() {
    git rev-parse --show-toplevel 2>/dev/null
}

_require_git_repo_cwd() {
    git_root=$(_get_git_root)
    if [ -z "$git_root" ]; then
        echo "Error: This command must be run from within a git repository."
        return 1
    fi
}

_require_non_worktree_cwd() {
    git_root=$(_get_git_root)
    if [[ "$git_root" == *"/.worktrees/"* ]] || [[ "$git_root" == *"/.worktrees" ]]; then
        echo "Error: This command cannot be run from within a git worktree. Change to the main repository first."
        return 1
    fi
}

_make_worktree_branch_name_safe() {
	# convert / to - in worktree path:
    echo "$1" | tr '/' '-'
}

_prepare_worktrees_subfolder() {
    git_root="$1"
    worktree_dir="$git_root/.worktrees"

	gitignore_path="$git_root/.gitignore"

	# Create the .worktrees directory if it doesn't exist
	mkdir -p "$worktree_dir"

	# Ensure .gitignore exists before trying to append to it
	if [ ! -f "$gitignore_path" ]; then
		touch "$gitignore_path"
	fi

	# Add .worktrees to .gitignore if it's not already there
	if ! grep -q "^\.worktrees$" "$gitignore_path"; then
		echo ".worktrees" >> "$gitignore_path"
	fi

    return 0
}

# Create a git worktree
wt() {
	if [ -z "$1" ]; then
		echo "Error: Branch name is required."
		echo "Usage: wt <branch-name> [base-branch]"
		return 1
	fi

	# Set the base branch (default to 'main' if not provided)
	base_branch_raw="${2:-main}"
	branch_name="$1"

    # Check that we are in a git repository and not already in a worktree
    _require_git_repo_cwd || return 1
    _require_non_worktree_cwd || return 1

    # Prepare for worktree creation
    git_root=$(_get_git_root)
    _prepare_worktrees_subfolder "$git_root" || return 1

	worktree_path="$git_root/.worktrees/$(_make_worktree_branch_name_safe "$branch_name")"
	if [ -d "$worktree_path" ]; then
		echo "Error: Worktree path '$worktree_path' already exists."
		return 1
	fi    

	remote_name="origin"
	base_ref=""

	if [[ "$base_branch_raw" == "$remote_name/"* ]]; then
	    remote_branch="${base_branch_raw#"$remote_name/"}"
		if [ -z "$remote_branch" ]; then
			echo "Error: Invalid remote branch name."
			return 1
		fi

		if ! git fetch "$remote_name" "$remote_branch" >/dev/null 2>&1; then
			echo "Error: Failed to fetch remote branch '$base_branch_raw'."
			return 1
		fi

		base_ref="$remote_name/$remote_branch"
	else
		base_ref="$base_branch_raw"
		if ! git rev-parse --verify "$base_ref" >/dev/null 2>&1; then
			echo "Error: Base branch '$base_ref' does not exist locally. Use '$remote_name/<branch>' to fetch from remote."
			return 1
		fi
	fi

	if git show-ref --verify "refs/heads/$branch_name" >/dev/null 2>&1; then
		echo "Error: Branch '$branch_name' already exists."
		return 1
	fi

	base_commit=$(git rev-parse "$base_ref^{commit}" 2>/dev/null)
	if [ -z "$base_commit" ]; then
		echo "Error: Could not resolve base reference '$base_ref' to a commit."
		return 1
	fi

	echo "Creating branch '$branch_name' from '$base_ref' at commit '$base_commit'."
	if ! git branch "$branch_name" "$base_commit" >/dev/null 2>&1; then
		echo "Error: Failed to create branch '$branch_name'."
		return 1
	fi

	if git worktree add "$worktree_path" "$branch_name" >/dev/null 2>&1; then
		echo "Worktree '$branch_name' created successfully from base '$base_ref'."
	else
		git branch -D "$branch_name" >/dev/null 2>&1
		echo "Error: Failed to create worktree '$branch_name'."
		return 1
	fi

    cd "$worktree_path"
    code .
    cd ../..
}

wt_from_branch() {
    if [ -z "$1" ]; then
        echo "Error: Branch name is required."
        echo "Usage: wt_from_branch <branch-name>"
        return 1
    fi

    branch_name="$1"

    _require_git_repo_cwd || return 1
    _require_non_worktree_cwd || return 1

	# Get the root directory of the Git repository
    git_root=$(_get_git_root)
    _prepare_worktrees_subfolder "$git_root" || return 1

	worktree_dir="$git_root/.worktrees"
    safe_branch_name=$(_make_worktree_branch_name_safe "$branch_name")
	worktree_path="$worktree_dir/$safe_branch_name"
}

# Clean up git worktrees
wtc() {
	# Get the root directory of the Git repository
	git_root=$(git rev-parse --show-toplevel)
	if [ -z "$git_root" ]; then
		echo "Error: not a git repository."
		return 1
	fi

	worktree_dir="$git_root/.worktrees"
	
	if [ -d "$worktree_dir" ]; then
		# Prune worktrees first to clean up git's internal state
		git worktree prune
		# Forcefully remove the .worktrees directory
		rm -rf "$worktree_dir"
		echo "All worktrees have been removed."
	else
		echo "No .worktrees directory found."
	fi

}