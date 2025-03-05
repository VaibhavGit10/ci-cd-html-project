#!/bin/bash

# Define project directory and GitHub repo
PROJECT_DIR="/var/www/ci-cd-html-project"
LOCAL_DIR="/mnt/e/All Assignments/CICD Tool/ci-cd-html-project"
REPO_URL="https://github.com/VaibhavGit10/ci-cd-html-project.git"
BRANCH="main"
LOG_FILE="/var/log/deploy.log"

# Logging function
log_message() {
    echo "[$(date)] $1" | tee -a $LOG_FILE
}

log_message "---------------------------------"
log_message "Deployment started"

# Ensure the project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    log_message "Project directory does not exist. Cloning repository..."
    git clone -b $BRANCH $REPO_URL $PROJECT_DIR
else
    log_message "Pulling latest changes..."
    cd $PROJECT_DIR
    git fetch origin $BRANCH
    git reset --hard origin/$BRANCH
    git pull origin $BRANCH
fi

# Sync local changes from WSL-mounted folder to Nginx directory
log_message "Syncing files from local directory..."
rsync -av --delete "$LOCAL_DIR/" "$PROJECT_DIR/"

# Set correct permissions
log_message "Setting correct file permissions..."
chown -R www-data
