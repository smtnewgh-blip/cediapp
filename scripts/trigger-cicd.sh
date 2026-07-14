#!/bin/bash

# CI/CD Pipeline Trigger Script
# Manually trigger GitHub Actions workflow for testing

set -e

echo "🔄 CEDI App - CI/CD Pipeline Trigger"
echo "====================================="
echo ""

# Get repository information
REPO_URL=$(git remote get-url origin 2>/dev/null)
if [ -z "$REPO_URL" ]; then
    echo "❌ Error: Not a git repository or no remote configured"
    exit 1
fi

echo "Repository: $REPO_URL"
echo ""

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "⚠️  GitHub CLI not found. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install gh
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Please install GitHub CLI from: https://cli.github.com"
        exit 1
    fi
fi

# Login to GitHub
echo "🔑 Authenticating with GitHub..."
gh auth login --web || true

echo ""
echo "Available workflows:"
echo "  1) Run CI/CD pipeline"
echo "  2) View recent runs"
echo "  3) View workflow status"
echo ""
read -p "Select option (1-3): " OPTION

case $OPTION in
    1)
        echo ""
        echo "Triggering CI/CD pipeline..."
        # Force push to trigger workflow
        git push --force origin HEAD:main
        echo "✓ Pipeline triggered. View at: $REPO_URL/actions"
        ;;
    2)
        echo ""
        echo "Recent workflow runs:"
        gh run list --limit 5
        ;;
    3)
        echo ""
        echo "Workflow status:"
        gh run list --status all --limit 5
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

echo ""
