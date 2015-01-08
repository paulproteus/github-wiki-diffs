#!/bin/bash
#
# The purpose of this web hook is to allow GitHub
# to ping it and it will update the timestamp on the
# "trigger" file.
#
# It does nothing else. You have to enable a cron job
# to run 'make' periodically, to make sure that the
# trigger gets responded to.
#
# It also currently has no support for github's HMAC-based
# authorization checking.

# Directory traversal issues will probably render the configuration
# non-secret, so keep that in mind.

# On any kind of failure, fail fast.
set -e

# 'cd' into the directory where this script is stored,
# dealing with symlinks and the like.
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Sanity-check assertions: are we in the right directory?
if [ ! -e "git-ignored/trigger" ] ; then
    exit 1
fi

# OK, so in that case, let's touch trigger.
#
# The next time the cron job wakes up, it'll do the mirroring and
# git-multimail thing.
touch git-ignored/trigger

# OK, so that's a wrap. But on the web, people expect a valid HTTP
# response, so let's give them what they want.
printf "Content-Type:text/plain\r\n\r\nSuccess."
