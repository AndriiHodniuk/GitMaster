#!/bin/bash

# GitMaster - init_repo.sh
# A simple script to initialize a Git repository in the current directory.

echo "🚀 Initializing Git repository in the current directory..."

# Run git init command
git init

# Check the exit status of git init
if [ $? -eq 0 ]; then
    echo "✅ Git repository initialized successfully!"
    echo "Default branch is likely 'main' or 'master'."
    echo "Don't forget to set your user.name and user.email if you haven't already:"
    echo "  git config --global user.name \"Your Name\""
    echo "  git config --global user.email \"you@example.com\""
else
    echo "❌ Failed to initialize Git repository."
    exit 1 # Exit with an error code
fi

exit 0 # Exit successfully
