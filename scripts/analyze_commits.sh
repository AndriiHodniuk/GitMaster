#!/bin/bash

# GitMaster - analyze_commits.sh
# Privides options to analyze commit history.

echo "📊 GitMaster: Commit Analyzer"
echo "-----------------------------"

while true; do 
    echo ""
    echo "Select the analysis option:"
    echo "1. Show recent N commits (short format)"
    echo "2. Show commits of a specific author"
    echo "3. Show change statistics for the last N commits"
    echo "q. Exit"
    echo ""

    read -p "Your choice: " choice

    case "$choice" in
       1) 
          read -p "How many recent commits to show? (For example, 5): " num_commits
          if [[ "$num_commits =~ ^[0-9]+$" ]]; then 
             echo "📜 Latest $num_commits commits:"
             git log --oneline -n "$num_commits"
          else 
             echo "⚠️ Please enter the number."
          fi
          ;;
       2)
          read -p "Enter the author's name (or part of the name): " author_name
          if [ -n "$author_name" ]; then
            echo "📜 Author Commits '$author_name':"
            git log --author="$author_name" --oneline --no-merges
          else 
            echo "⚠️ The author's name cannot be empty."
          fi
          ;;
       3)
          read -p "For how many recent commits show statistics? (For example, 3): " num_stat_commits
          if [[  "$num_stat_commits =~ ^[0-9]+$" ]]; then 
            echo "📊 Change statistics for the last $num_stat_commits:"
            git log --stat -n "$num_stat_commits"
          else
            echo "⚠️ Please enter the number."
          fi
          ;;
       q|Q)
          echo "👋 Thank you for using GitMaster Commit Analyzer!"
          break
          ;;
       *)
          echo "❌ Wrong choice. Try again."
          ;;
    esac
done

exit 0 
