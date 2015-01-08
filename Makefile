all: git-ignored/configuration git-ignored/git-multimail git-ignored/source-repo git-ignored/dest-repo git-ignored/responded-to-trigger

clean:
	rm -rf git-ignored/git-multimail git-ignored/source-repo git-ignored/source-repo.tmp git-ignored/dest-repo git-ignored/responded-to-trigger

git-ignored/configuration:
	echo "You need to create a file called configuration. For instructions, see README."
	exit 1

include git-ignored/configuration

git-ignored/git-multimail:
	git clone https://github.com/mhagger/git-multimail.git git-ignored/git-multimail

git-ignored/source-repo:
	git clone ${REMOTE_GIT_REPO_URL} git-ignored/source-repo.tmp
	(cd git-ignored/source-repo.tmp ; git remote add dest ../dest-repo )
	mv git-ignored/source-repo.tmp git-ignored/source-repo

git-ignored/dest-repo:
	(cd git-ignored ; git clone --bare source-repo dest-repo)

	# Set up git-multimail has post-receive hook
	(cd git-ignored/dest-repo ; ln -s ../../git-multimail/git-multimail/git_multimail.py hooks/post-receive )

	# Tell git-multimail to send emails to the people we configured.
	(cd git-ignored/dest-repo ; git config multimailhook.mailingList ${MULTIMAILHOOK_MAILINGLIST} )

	# Tell git-multimail to send no ref change emails, since all we want is diffs.
	(cd git-ignored/dest-repo ; git config multimailhook.refchangeList '' )

	# Tell git-multimail who to send emails as.
	#
	# Note that it seems FROM_NAME does not any extra quoting, so
	# long as it is quoted in the configuration file.
	(cd git-ignored/dest-repo ; git config user.name ${FROM_NAME} )
	(cd git-ignored/dest-repo ; git config user.email ${FROM_EMAIL} )

	# Tell git-multimail to actually send patches, not just diff stat.
	(cd git-ignored/dest-repo ; git config multimailhook.diffOpts '--stat --summary --find-copies-harder -p' )

git-ignored/responded-to-trigger: git-ignored/trigger
	# The purpose of this Make target is that, if 'trigger' has been updated
	# since we last ran, we respond to the trigger.
	#
	# It doesn't do any locking, so a race condition is theoretically possible.
	#
	# All it does is cd into source-repo, and do a push to dest-repo.
	#
	# The git-multimail configuration in dest-repo should take care of sending
	# out emails.
	#
	# "origin" here should already be configured as the github URL.
	(cd git-ignored/source-repo && git fetch --quiet origin && git push --quiet dest origin/master:master )
	# Now, store a note so that Make doesn't do this repeatedly unnecessarily.
	touch git-ignored/responded-to-trigger

git-ignored/trigger:
	# The creation/updating of trigger is usually done by an external command,
	# like a CGI script or whatever that is a github web hook.
	touch git-ignored/trigger
