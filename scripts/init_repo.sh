#!/bin/bash

# GitMaster - init_repo.sh
# Initializes a Git repository, optionally creates a .gitignore file.
# And can create corresponding repisitory on GitHub.

echo "🚀 GitMaster: Repository Initializer and GitHub setup"
echo "--------------------------------------"

# --- Authentication check gh ---
if ! gh auth status > /dev/null 2>&1; then
    echo "⚠️ GitHub CLI (gh) is not authenticated or installed."
    echo "Please install gh and execute 'gh auth login'."
    read -p "Continue only with local initialization? (Yes/no): " continue_local_only
    if [ "continue_local_only" != "yes" ]; then
        echo "👋 The action was canceled by the user."
        exit 1
    fi
    GH_AUTHED=false
else 
    GH_AUTHED=true
    echo "✅ GitHub CLI authenticated."
fi

# --- Local initialization ---

if [ -d ".git" ]; then
    echo "🤔 This directory already seems to be a Git repository."
    read -p "Do you want to re-initialize it? (Usually not recommended. This will delete the existing .git folder!) (yes/no): " confirm_reinit
    if [ "$confirm_reinit" != "yes" ]; then
        if [ "GH_AUTHED" = true ]; then
            read -p "❓ Maybe you just want to create/connect a GitHub repository for an existing local one? (Yes/no): " setup_github_existing
            if [ "$setup_github_existing" != yes ]; then        
                echo "👍 Initialization cancelled by user."
                exit 0
            fi
        else
            exit 0
        fi
    else
        echo "⚠️ Re-initializing repository as requested..."
        rm -rfi .git
        git init
        if [ $? -ne 0 ]; then echo "❌ Reinitialization error." exit 1; fi
        echo "✅ The local repository has been reinitialized."
        git config --local user.name "$(git config --global user.name)"
        git config --local user.email "$(git config --global user.email)"
        echo "👤 Local user.name and user.email set from global configuration."
    fi
else
    echo "✨ Initialization of the local Git repository..."
    git init

    if [ $? -ne 0 ]; then echo "❌ Local repository initialization error." exit 1; fi
        echo "✅ Local git repository initialized successfully!"
        git config --local user.name "$(git config --global user.name)"
        git config --local user.email "$(git config --global user.email)"
        echo "👤 Local user.name and user.email set from global configuration."
fi

# --- Creating .gitignore ---

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
    echo "👉 It is recommended to add .gitignore to the first commit: 'git add .gitignore && git commit -m \"Add .gitignore\"'"
else
    echo "👍 .gitignore file was not created."
fi

# --- Setting up the GitHub repository (if gh is authorized) ---

if [ "$GH_AUTHED" = true ]; then
  echo ""
  read -p "❓ Create and connect a repository on GitHub? (Yes/no):" create_gh_repo
  if [ "$create_gh_repo" == "yes" ]; then
    default_repo_name=$(basename "$PWD") 
    read -p "Repository name on GitHub (default: $default_repo_name):" repo_name
    repo_name=${repo_name:-$default_repo_name}

    repo_visibility="--private" 
    read -p "Visibility of the repository: public or private? (pUblic/pRivate, private by default):" visibility_choice
    if [[ "$visibility_choice" == "public" || "$visibility_choice" == "pUblic" || "$visibility_choice" == "pu" ]]; then
        repo_visibility="--public"
    fi

    echo "⏳ Creating a $repo_visibility repository '$repo_name' on GitHub..."
    if gh repo create "$repo_name" "$repo_visibility" --description "Created by GitMaster"; then
      echo "✅ The repository '$repo_name' has been successfully created on GitHub."
      
      if git remote get-url origin > /dev/null 2>&1; then
        echo "🤔 Remote 'origin' already exists. Current URL: $(git remote get-url origin)"
        read -p "Хочете видалити існуючий 'origin' та підключити новий? (yes/no): " replace_origin
        if [ "$replace_origin" == "yes" ]; then
          git remote remove origin
          echo "🗑️ The existing 'origin' has been removed."
        else
          echo "👍 The existing 'origin' is left. Connect the new repository manually if necessary."
          GH_REPO_CONNECTED=false
        fi
      fi

      if ! git remote get-url origin > /dev/null 2>&1 || [ "$replace_origin" == "yes" ]; then
        gh_user=$(gh api user --jq .login) 
        if [ -n "$gh_user" ]; then
            git remote add origin "https://github.com/$gh_user/$repo_name.git"
            echo "🔗 Local repository connected to origin: https://github.com/$gh_user/$repo_name.git"
            GH_REPO_CONNECTED=true
        else
            echo "❌ Could not get GitHub username. Connect the remote manually."
            GH_REPO_CONNECTED=false
        fi
      fi

      if [ "$GH_REPO_CONNECTED" = true ]; then
          if ! git rev-parse --verify HEAD > /dev/null 2>&1; then 
            echo "🤔 You don't have any comments yet. It is recommended to make the first commit before push."
            read -p "Do you want to first commit the .gitignore file (if created) and README.md (if existing)? (Yes/no):" make_first_commit
            if [ "$make_first_commit" == "yes" ]; then
              if [ -f ".gitignore" ]; then git add .gitignore; fi
              if [ -f "README.md" ]; then git add README.md; fi 
              if ! git diff --staged --quiet; then
                  git commit -m "Initial commit by GitMaster"
                  echo "🎉 The first commit has been created."
              else
                  echo "🤷 .gitignore or README.md files not found or modified, first commit not created."
              fi
            fi
          fi
          if git rev-parse --verify HEAD > /dev/null 2>&1; then
            current_branch=$(git branch --show-current)
            if [ -z "$current_branch" ]; then
                current_branch="main"
                git checkout -b "$current_branch"
            fi
            read -p "❓ Send the current branch ('$current_branch') to GitHub (git push -u origin $current_branch)? (Yes/no):" push_to_gh
            if [ "$push_to_gh" == "yes" ]; then
              echo "⏫ Sending the '$current_branch' branch to GitHub..."
              git push -u origin "$current_branch"
              if [ $? -eq 0 ]; then
                echo "✅ The '$current_branch' branch has been successfully sent to GitHub!"
              else
                echo "❌ Error sending branch '$current_branch' to GitHub."
              fi
            fi
          fi
      fi
    else
      echo "❌ Error creating repository '$repo_name' on GitHub."
    fi
  else
    echo "👍 No GitHub repository created."
  fi
else 
  echo "ℹ️T  To create a repository on GitHub, you need authentication through 'gh auth login'."
fi
# -------------------------------------------------------

echo ""
echo "🎉 GitMaster: Initialization completed!"

exit 0

