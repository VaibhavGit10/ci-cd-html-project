import requests
import json
import os

# GitHub Repository Details
GITHUB_USERNAME = "VaibhavGit10"  # Change this to your GitHub username
REPO_NAME = "ci-cd-html-project"  # Change this to your repo name
BRANCH = "main"  # Change this if using a different branch

# GitHub API URL to Get Latest Commit SHA
API_URL = f"https://api.github.com/repos/{GITHUB_USERNAME}/{REPO_NAME}/commits/{BRANCH}"

# File to Store Last Checked Commit SHA
SHA_FILE = "/var/www/ci-cd-html-project/last_commit_sha.txt"

def get_latest_commit():
    """Fetch the latest commit SHA from GitHub API."""
    response = requests.get(API_URL)
    if response.status_code == 200:
        commit_data = response.json()
        return commit_data["sha"]
    else:
        print(f"Error fetching commit: {response.status_code}, {response.text}")
        return None

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
    latest_commit = get_latest_commit()
    if not latest_commit:
        return

    last_commit = read_last_commit()
    if last_commit != latest_commit:
        print("New commit detected! Triggering deployment...")
        os.system("bash deploy.sh")  # Call deployment script
        write_last_commit(latest_commit)
    else:
        print("No new updates.")

if __name__ == "__main__":
    check_for_updates()
