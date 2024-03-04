# Delete File from Multi-Branch Repository Script
This script is a simple Bash utility designed to remove a specified file from all branches within a given repository. It allows you to select which file to remove based on the latest commit date threshold.

# How it Works

1. Clones the repository into the CLONE_DIR folder.
2. Configures git config with your user.email and user.name.
3. Fetches all the branches.
4. Converts your entered date (CUTOFF_DATETIME) to a UNIX timestamp.
5. Loops over all the branches.
6. Skips all the branches that are listed in the SKIP_BRANCHES array.
7. Checks if FILE_TO_DELETE exists on the branch.
8. Verifies if the last commit date is older than the CUTOFF_TIMESTAMP_UNIX.
9. Deletes FILE_TO_DELETE if it exists on the branch and meets the time condition.
10. Commits and pushes changes to the branch.
11. Removes the temporary directory that was created.

# Variables
You must provide the following variables for the script to work:

Remote Repository URL:
- REPO_URL='git@github.com:MatasVaitkevicius/test-multibranch-jenkins-delete-file.git'

File to Remove:
- FILE_TO_DELETE='test.txt'

Your Git Email and Name for the Commit:
- GIT_EMAIL='test@gmail.com'
- GIT_NAME='Test'

Commit Message that will be used for pushing the change:
- GIT_COMMIT_MESSAGE="Remove $FILE_TO_DELETE"

Cutoff Date and Time (format: YYYY-MM-DD HH:MM:SS) that will be compared with the branch's latest commit:
- CUTOFF_DATETIME="2024-03-04 15:30:20"

Directory to clone the repository into:
- CLONE_DIR="repo_clone"

Array of Branches to Skip:
- SKIP_BRANCHES=("master" "main" "dev")