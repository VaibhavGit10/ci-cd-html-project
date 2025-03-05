#!/bin/bash

# Define project directory and GitHub repo
PROJECT_DIR="/var/www/ci-cd-html-project"
REPO_URL="https://github.com/your-username/ci-cd-html-project.git"
BRANCH="main"

# Log the deployment
echo "---------------------------------" >> /var/log/deploy.log
echo "Deployment started at $(date)" >> /var/log/deploy.log

# Ensure the project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Project directory does not exist. Cloning repository..."
    git clone -b $BRANCH $REPO_URL $PROJECT_DIR
else
    echo "Pulling latest changes..."
    cd $PROJECT_DIR
    git reset --hard origin/$BRANCH
    git pull origin $BRANCH
fi

# Set correct permissions
chown -R www-data:www-data $PROJECT_DIR
chmod -R 755 $PROJECT_DIR

# Restart Nginx to apply changes
echo "Restarting Nginx..."
systemctl restart nginx

echo "Deployment completed at $(date)" >> /var/log/deploy.log
echo "---------------------------------" >> /var/log/deploy.log
