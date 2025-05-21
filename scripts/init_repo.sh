#!/bin/bash

# GitMaster - init_repo.sh
# Initializes a Git repository, optionally creates a .gitignore file.

echo "🚀 GitMaster: Repository Initializer"
echo "--------------------------------------"

if [ -d ".git" ]; then
    echo "🤔 This directory already seems to be a Git repository."
    read -p "Do you want to re-initialize it? This is usually not recommended. (yes/no): " confirm_reinit
    if [ "$confirm_reinit" != "yes" ]; then
        echo "👍 Initialization cancelled by user."
        exit 0
    else
        echo "⚠️ Re-initializing repository as requested..."
        rm -rfi .git
    fi
fi

echo "✨ Initializing Git repository..."
git init

# Check the exit status of git init
if [ $? -eq 0 ]; then
    echo "✅ Git repository initialized successfully!"
    git config --local user.name "$(git config --global user.name)"
    git config --local user.email "$(git config --global user.email)"
    echo "👤 Local user.name and user.email set from global configuration."

read -p "❓ Do you want to create a .gitignore file? (yes/no): " create_gitignore

if [ "$create_gitignore" == "yes" ]; then
    read -p "Enter comma-separated list of technologies/OS to ignore (e.g., node,python,macos,windows): " gitignore_types
    echo "⏳ Generating .gitignore for: $gitignore_types ..."
    
    cat << EOF > .gitignore
# Created by GitMaster

# General
.DS_Store
Thumbs.db
*.log
tmp/
temp/

# Secrets - NEVER commit secrets!
*.env
*.key
*.pem
secrets/
EOF
    if [[ "$gitignore_types" == *"node"* ]]; then
      echo "" >> .gitignore
      echo "# Node" >> .gitignore
      echo "node_modules/" >> .gitignore
      echo "npm-debug.log*" >> .gitignore
      echo "yarn-debug.log*" >> .gitignore
      echo "yarn-error.log*" >> .gitignore
      echo ".pnp/" >> .gitignore
      echo ".pnp.js" >> .gitignore
    fi

    if [[ "$gitignore_types" == *"python"* ]]; then
      echo "" >> .gitignore
      echo "# Python" >> .gitignore
      echo "__pycache__/" >> .gitignore
      echo "*.pyc" >> .gitignore
      echo "*.pyo" >> .gitignore
      echo "*.pyd" >> .gitignore
      echo ".Python" >> .gitignore
      echo "build/" >> .gitignore
      echo "develop-eggs/" >> .gitignore
      echo "dist/" >> .gitignore
      echo "downloads/" >> .gitignore
      echo "eggs/" >> .gitignore
      echo ".eggs/" >> .gitignore
      echo "lib/" >> .gitignore
      echo "lib64/" >> .gitignore
      echo "parts/" >> .gitignore
      echo "sdist/" >> .gitignore
      echo "var/" >> .gitignore
      echo "*.egg-info/" >> .gitignore
      echo ".installed.cfg" >> .gitignore
      echo "*.egg" >> .gitignore
      echo "instance/" >> .gitignore
      echo ".env" >> .gitignore
      echo ".venv" >> .gitignore
      echo "env/" >> .gitignore
      echo "venv/" >> .gitignore
      echo "ENV/" >> .gitignore
      echo "venv.bak/" >> .gitignore
      echo "env.bak/" >> .gitignore
    fi
    
    echo "✅ .gitignore file created."
    echo "👉 Remember to 'git add .gitignore' and commit it."
 else
     echo "👍 .gitignore file was not created."
 fi

else
    echo "❌ Failed to initialize Git repository."
    exit 1 # Exit with an error code
fi

exit 0 # Exit successfully
