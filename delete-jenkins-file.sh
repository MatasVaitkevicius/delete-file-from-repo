#!/bin/bash

# The remote repository URL
REPO_URL='git@github.com:MatasVaitkevicius/script-to-delete-branches.git'

# File to remove
FILE_TO_DELETE='test.txt'

# Your Git email and name for the commit
GIT_EMAIL='test@gmail.com'
GIT_NAME='Test'

# Commit message that will be used for pushing the change
GIT_COMMIT_MESSAGE="Remove $FILE_TO_DELETE"

# Cutoff date and time (format: YYYY-MM-DD HH:MM:SS)
CUTOFF_DATETIME="2024-03-04 15:30:20"

# Directory to clone the repository into
CLONE_DIR=$(mktemp -d temp_directory_XXXXXX)

# Array of branches to skip
SKIP_BRANCHES=("master" "main")

# Clone the repository into a temporary directory
if [ -d "$CLONE_DIR" ]; then
    echo "Directory $CLONE_DIR already exists. Removing..."
    rm -rf "$CLONE_DIR"
fi

echo "Cloning $REPO_URL into $CLONE_DIR..."
git clone $REPO_URL $CLONE_DIR
cd $CLONE_DIR

# Configure Git with your email and name
echo "Configuring git config..."
git config user.email "$GIT_EMAIL"
git config user.name "$GIT_NAME"
echo -e "user.email: $GIT_EMAIL\nuser.name: $GIT_EMAIL"

# Fetch all branches
echo "Fetching branches..."
git fetch --all

# Convert cutoff date to Unix timestamp
echo "Cutoff datetime: $CUTOFF_DATETIME"
CUTOFF_TIMESTAMP_UNIX=$(date -d "$CUTOFF_DATETIME" +%s)
echo "Cutoff datetime (Unix timestamp): $CUTOFF_TIMESTAMP_UNIX"

# Loop through all remote branches
for branch in $(git branch -r | grep -v '\->'); do
    # Strip remote part from branch name (origin/branchName -> branchName)
    branch=${branch#origin/}

    # Skip specific branches
    if [[ " ${SKIP_BRANCHES[@]} " =~ " ${branch} " ]]; then
        echo -e "\nBranch: $branch is in SKIP_BRANCHES array skipping..."
        continue
    fi

    echo -e "\nProcessing branch: $branch"

    echo "Checking out to $branch..."
    # Check out the branch
    git checkout $branch

    echo "Checking if $FILE_TO_DELETE exists in $branch..."
    if [ -f $FILE_TO_DELETE ]; then
        # Get the last commit date for the specific branch in UNIX timestamp
        LAST_COMMIT_DATE=$(git log -1 --format=%ct)
        echo "Branch: $branch, Last commit date (Unix Timestamp): $LAST_COMMIT_DATE, Last commit date: $(date -d @$LAST_COMMIT_DATE +'%Y-%m-%d %H:%M:%S')"
        
        # Check if the last commit date is older than the CUTOFF_TIMESTAMP_UNIX
        if [ $LAST_COMMIT_DATE -lt $CUTOFF_TIMESTAMP_UNIX ]; then
            echo "Found $FILE_TO_DELETE, deleting..."
            git rm $FILE_TO_DELETE

            echo "Commiting changes..."
            git commit -m $GIT_COMMIT_MESSAGE
            
            echo "Pushing changes to repository..."
            git push origin $branch
        else
            echo "Latest commit in $branch is newer than $CUTOFF_DATETIME, skipping..."
        fi
    else
        echo "$FILE_TO_DELETE does not exist in $branch"
    fi
done

# Cleanup: remove the temporary directory
echo -e "\nCleaning up the temporary directory..."
cd ..
rm -rf $CLONE_DIR
