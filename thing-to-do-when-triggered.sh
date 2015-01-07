#!/bin/bash
set -e

KEYWORD_FOR_SANITY_CHECKING_SOURCE_ORIGIN="github"
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
pushd "$SOURCE_REPO_DIR"

# Make sure there is a remote called origin; if not, bail now.
git remote -v | grep -q "origin"

# Make sure the remote called origin points at what we expect
# to be origin.
git remote -v | grep -q "$KEYWORD_FOR_SANITY_CHECKING_SOURCE_ORIGIN"

# Make sure there is a remote called dest; if not, bail now.
git remote -v | grep -q "dest"

# Make sure the remote called dest points at DEST_REPO_DIR.
git remote -v | grep -q "$(basename $DEST_REPO_DIR")

# OK, great.
git fetch origin
git push dest origin/master:master

# And now, the magic should have happened.
