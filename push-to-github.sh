#!/bin/bash

# push-to-github.sh - Push the goquorum-qbft-network repository to GitHub

echo "This script will help you push your goquorum-qbft-network repository to GitHub."
echo "Make sure you have already created a repository on GitHub."
echo ""

# Prompt for GitHub username
read -p "Enter your GitHub username: " username

# Prompt for repository name
read -p "Enter your GitHub repository name (default: goquorum-qbft-network): " reponame
reponame=${reponame:-goquorum-qbft-network}

# Set the remote URL
git remote set-url origin "https://github.com/$username/$reponame.git"
echo "Remote URL set to: https://github.com/$username/$reponame.git"

# Push to GitHub
echo "Pushing to GitHub..."
git push -u origin main

echo ""
echo "If the push was successful, your code is now on GitHub at:"
echo "https://github.com/$username/$reponame"
