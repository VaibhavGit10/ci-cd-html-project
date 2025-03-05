#!/bin/bash

# Define project directory and GitHub repo
PROJECT_DIR="/var/www/ci-cd-html-project"
REPO_URL="https://github.com/VaibhavGit10/ci-cd-html-project.git"
BRANCH="main"
LOG_FILE="$PROJECT_DIR/deploy.log"
COMMIT_LOG="$PROJECT_DIR/commit_history.log"

# Function to log messages
log_message() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Function to log commits
log_commit() {
    echo "$1" | tee -a "$COMMIT_LOG"
}

# Start deployment log
log_message "---------------------------------"
log_message "🚀 Deployment started at $(date)"

# Ensure the project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    log_message "❌ Project directory does not exist. Cloning repository..."
    git clone -b "$BRANCH" "$REPO_URL" "$PROJECT_DIR" || { log_message "❌ Clone failed! Exiting..."; exit 1; }
else
    log_message "🔄 Pulling latest changes..."
    cd "$PROJECT_DIR" || { log_message "❌ Failed to change directory! Exiting..."; exit 1; }
    git fetch origin "$BRANCH"

    # Check for new commits
    LATEST_COMMIT=$(git rev-parse origin/$BRANCH)
    CURRENT_COMMIT=$(git rev-parse HEAD)

    if [ "$LATEST_COMMIT" != "$CURRENT_COMMIT" ]; then
        log_commit "📌 New commit found: $LATEST_COMMIT"
        git reset --hard origin/"$BRANCH"
        git pull origin "$BRANCH" || { log_message "❌ Git pull failed! Exiting..."; exit 1; }

        # Log commit details
        COMMIT_DETAILS=$(git log -1 --pretty=format:"%h - %an: %s (%cd)" --date=short)
        log_commit "✅ $COMMIT_DETAILS"
    else
        log_message "✔ No new commits to deploy."
    fi  # ✅ This `fi` properly closes the inner `if`
fi  # ✅ This `fi` properly closes the outer `if`

# Set correct permissions
chown -R www-data:www-data "$PROJECT_DIR"
chmod -R 755 "$PROJECT_DIR"

# Restart Nginx
log_message "🔄 Restarting Nginx..."
systemctl restart nginx || { log_message "❌ Failed to restart Nginx!"; exit 1; }

log_message "✅ Deployment completed at $(date)"
log_message "---------------------------------"
