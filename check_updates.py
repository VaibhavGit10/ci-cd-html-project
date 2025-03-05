import requests
import json
import os
from datetime import datetime

# GitHub Repository Details
GITHUB_USERNAME = "VaibhavGit10"  # Change this to your GitHub username
REPO_NAME = "ci-cd-html-project"  # Change this to your repo name
BRANCH = "main"  # Change this if using a different branch

# GitHub API URL to Get Latest Commit SHA
API_URL = f"https://api.github.com/repos/{GITHUB_USERNAME}/{REPO_NAME}/commits/{BRANCH}"

# Project Directory
PROJECT_DIR = "/mnt/e/All Assignments/CICD Tool/ci-cd-html-project"

# Paths to Files
SHA_FILE = os.path.join(PROJECT_DIR, "last_commit_sha.txt")
LOG_FILE = os.path.join(PROJECT_DIR, "deploy.log")
COMMIT_LOG = os.path.join(PROJECT_DIR, "commit_history.log")

def ensure_log_files():
    """Ensure log files exist."""
    for file in [LOG_FILE, COMMIT_LOG]:
        if not os.path.exists(file):
            with open(file, "w") as f:
                f.write(f"Log file created on {datetime.now()}\n")

def log_message(log_file, message):
    """Log messages to the specified log file."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(log_file, "a") as file:
        file.write(f"{timestamp} - {message}\n")

def get_latest_commit():
    """Fetch the latest commit SHA from GitHub API."""
    response = requests.get(API_URL)
    if response.status_code == 200:
        commit_data = response.json()
        return commit_data["sha"], commit_data["commit"]["message"]
    else:
        log_message(LOG_FILE, f"Error fetching commit: {response.status_code}, {response.text}")
        return None, None

def read_last_commit():
    """Read the last recorded commit SHA from file."""
    if os.path.exists(SHA_FILE):
        with open(SHA_FILE, "r") as file:
            return file.read().strip()
    return None

def write_last_commit(sha):
    """Write the latest commit SHA to file."""
    with open(SHA_FILE, "w") as file:
        file.write(sha)

def check_for_updates():
    """Check if a new commit is available."""
    ensure_log_files()  # Ensure log files exist before writing

    latest_commit, commit_message = get_latest_commit()
    if not latest_commit:
        return

    last_commit = read_last_commit()
    if last_commit != latest_commit:
        log_message(LOG_FILE, "New commit detected! Triggering deployment...")
        log_message(COMMIT_LOG, f"New commit: {latest_commit} - {commit_message}")

        os.system("bash deploy.sh")  # Call deployment script
        write_last_commit(latest_commit)
    else:
        log_message(LOG_FILE, "No new updates.")

if __name__ == "__main__":
    check_for_updates()
