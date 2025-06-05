#!/bin/bash

# GitMaster - start_feature.sh
# Creates a new feature branch based on a chosen base branch (default: main)
# and optionally creates a corresponding issue on GitHub.

DEFAULT_BASE_BRANCH="main" 
FEATURE_BRANCH_PREFIX="feature/" 

echo "🚀 GitMaster: Start New Feature"
echo "--------------------------------"

if ! gh auth status > /dev/null 2>&1; then
  echo "⚠️ GitHub CLI (gh) is not authenticated. Creating a GitHub Issue will not be possible."
  echo "Please run 'gh auth login'."
  GH_AUTHED=false
else
  GH_AUTHED=true
fi

read -p "Enter the name of the base branch (from which to create the feature branch, default: $DEFAULT_BASE_BRANCH): " base_branch_name
base_branch_name=${base_branch_name:-$DEFAULT_BASE_BRANCH}

echo "🔄 Checking and updating base branch '$base_branch_name'..."
if ! git rev-parse --verify "$base_branch_name" > /dev/null 2>&1; then
    echo "❌ Base branch '$base_branch_name' does not exist locally. Try 'git fetch origin' or check the name."
    exit 1
fi

current_branch=$(git branch --show-current)
if [ "$current_branch" != "$base_branch_name" ]; then
    git switch "$base_branch_name"
    if [ $? -ne 0 ]; then echo "❌ Failed to switch to branch '$base_branch_name'."; exit 1; fi
fi

echo "⏬ Pulling branch '$base_branch_name' from origin..."
git pull origin "$base_branch_name"
if [ $? -ne 0 ]; then
    echo "⚠️ Failed to update branch '$base_branch_name' from origin. It may not be tracked or there is no connection."
    read -p "Continue creating the feature branch from the current local version of '$base_branch_name'? (yes/no): " continue_anyway
    if [ "$continue_anyway" != "yes" ]; then
        echo "👋 Action cancelled."
        exit 1
    fi
fi

feature_description=""
while [ -z "$feature_description" ]; do
    read -p "Enter a short feature description (for the branch name, e.g., 'add-user-login'): " feature_description
    if [ -z "$feature_description" ]; then
        echo "⚠️ Feature description cannot be empty."
    fi
done

formatted_description=$(echo "$feature_description" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
new_branch_name="${FEATURE_BRANCH_PREFIX}${formatted_description}"

if git rev-parse --verify "$new_branch_name" > /dev/null 2>&1; then
    echo "🤔 Branch '$new_branch_name' already exists."
    read -p "Switch to it? (yes/no): " switch_to_existing
    if [ "$switch_to_existing" == "yes" ]; then
        git switch "$new_branch_name"
        exit 0
    else
        echo "👋 Action cancelled. You can delete the existing branch or choose another name."
        exit 1
    fi
fi

issue_url=""
if [ "$GH_AUTHED" = true ]; then
    read -p "❓ Create a corresponding GitHub Issue? (yes/no): " create_issue_choice
    if [ "$create_issue_choice" == "yes" ]; then
        default_issue_title="Implement: $feature_description"
        read -p "Title for GitHub Issue (default: '$default_issue_title'): " issue_title
        issue_title=${issue_title:-$default_issue_title}
        read -p "Description for GitHub Issue (optional, press Enter to skip): " issue_body
        repo_full_name=$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)
        if [ -z "$repo_full_name" ]; then
            echo "⚠️ Failed to determine current GitHub repository. Make sure you are in a GitHub repository directory."
        else
            echo "⏳ Creating GitHub Issue for repository '$repo_full_name'..."
            if [ -n "$issue_body" ]; then
                issue_url=$(gh issue create --title "$issue_title" --body "$issue_body" --repo "$repo_full_name" 2>/dev/null)
            else
                issue_url=$(gh issue create --title "$issue_title" --repo "$repo_full_name" 2>/dev/null)
            fi

            if [ -n "$issue_url" ]; then
                echo "✅ GitHub Issue created: $issue_url"
                issue_number=$(echo "$issue_url" | grep -oE '[0-9]+$')
                new_branch_name="${FEATURE_BRANCH_PREFIX}${issue_number}-${formatted_description}"
                echo "Updated branch name with Issue number: $new_branch_name"
            else
                echo "❌ Error creating GitHub Issue. Check the message above or your 'gh' settings."
            fi
        fi
    fi
fi

echo "🌿 Creating new branch '$new_branch_name' from '$base_branch_name'..."
git switch -c "$new_branch_name" "$base_branch_name" 

if [ $? -eq 0 ]; then
  echo "✅ Successfully created and switched to branch '$new_branch_name'."
  if [ -n "$issue_url" ]; then
      echo "🔗 Linked GitHub Issue: $issue_url"
  fi
  echo "👍 You can start working on the feature!"
else
  echo "❌ Failed to create or switch to branch '$new_branch_name'."
  if [ -n "$current_branch" ] && [ "$current_branch" != "$base_branch_name" ]; then
    git switch "$current_branch"
  elif [ "$base_branch_name" != "$new_branch_name" ]; then
    git switch "$base_branch_name"
  fi
  exit 1
fi

exit 0
