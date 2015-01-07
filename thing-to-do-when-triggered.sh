#!/bin/bash
set -e

SOURCE_REPO_DIR="fake-source-repo"
DEST_REPO_DIR="fake-dest-repo"

# This script gets run when a git hook is triggered.
#
# Some notes:
#
# - It doesn't do any kind of locking, so a race condition
#   is possible.
#
# - Its general mode of operation is that when triggered, it
#   cds into a repo called source-repo, gets the latest data
#   from github, and then pushes that to dest-repo.
#   The real logic for sending out emails lives in dest-repo.
#
