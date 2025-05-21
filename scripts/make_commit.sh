#!/bin/bash

# GitMaster - make_commit.sh
# Adds all changes and makes a commit with the provided message.
# If no message is provided, it prompts for one.
# If arguments are 'status' or 'log', it shows git status or log.

echo "🚀 GitMaster: Quick Commit"
echo "-------------------------"

if [ "$1" == "status" ]; then
    echo "🔍 Current Git status:"
    git status
    exit 0
elif [  "$1" == "log"  ]; then
    echo "📜 Recent Git log:"
    git log --online -n 10
    exit 0
fi

echo "➕ Staging all changes..."
git add .

if git diff --staged --quiet; then
    echo "🤔 No changes staged for commit. Working tree clean?"
    exit 0
fi

commit_message="$*"

if [ -z "$commit_message" ]; then
    read -p "💬 Enter commit message: " commit_message
    if [ -z "$commit_message" ]; then
        echo "🛑 Commit message cannot be empty. Commit aborted."
        git reset
        exit 1
    fi
fi

echo "💾 Committing with message: \"$commit_message\""
git commit -m "$commit_message"

if [ $? -eq 0 ]; then 
     echo "✅ Commit successful!"
else
  echo "❌ Commit failed."
  exit 1
fi

exit 0
