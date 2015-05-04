#!/bin/zsh
# Purpose: send a message via  https://pushover.net
#
# 		USING THIS SCRIPT WILL REQUIRE YOU TO REGISTER WITH https://pushover.net/apps
#		IN ORDER TO GET A "PUSHOVER_TOKEN" WHICH WILL HAVE TO BE ENTERED BELOW.
#		As of 2014-03-10, each "app" can send 7,500 messages per month for free.
#
# From:	Tj Luo.ma
# Mail:	luomat at gmail dot com
# Web: 	http://RhymesWithDiploma.com
# Date:	2014-02-22



	# PUSHOVER_TOKEN and PUSHOVER_USER_KEY are defined like this:
	#
	# 	PUSHOVER_TOKEN='tttttttttttttt'
	# 	PUSHOVER_USER_KEY='uuuuuuuuuuuu'
	#
	# except, of course, replace the "tttttttttttttt" with your actual token and replace
	# "uuuuuuuuuuuu" with your Pushover user key
	# (NOTE: THIS IS __NOT__ YOUR PUSHOVER.NET USERNAME).
	# You can find the Pushover User Key in the settings part of the Pushover app
	#
	# You can define them in ~/.zshenv if you want, or in another file
	#
	# NOTE:
	# The format of that file is important.
	# PUSHOVER_USER_KEY and PUSHOVER_TOKEN must be uppercase
	# followed by a literal ='
	# then put in your specific values.
	# Be sure that there is another literal ' at the end of the line
	# No spaces!
	#		PUSHOVER_TOKEN='xxxxx'
POSH_FILE="$HOME/Dropbox/etc/posh.txt"

	# NOTE! Alternatively, you could define them here.
	# Just remove the '#' from the start of the next two lines and enter the correct values
# PUSHOVER_TOKEN='tttttttttttttt'
# PUSHOVER_USER_KEY='uuuuuuuuuuuu'






NAME="$0:t:r"

HOST=$(hostname)
HOST="$HOST:l"

zmodload zsh/datetime

TIME=$(strftime "%Y-%m-%d @ %H.%M.%S" "$EPOCHSECONDS")

## LOGGING SECTION: Start
		# This is where OS X stores logs which are specific to a user
	LOG="$HOME/Library/Logs/posh ${TIME}.log"

		# this shouldn't happen, but it might if we try to run this script
		# on another Unix machine other than OS X
	[[ ! -d "$LOG:h" ]] && mkdir -p "$LOG:h"

		# rather than have to repeat this syntax every time we want to send
		# a message to the log file, we'll just define a nice 'log' function.
	function log {
					echo "$NAME [$TIME]: $@" | tee -a "$LOG"
	}
## LOGGING SECTION: End

	# If the POSH_FILE exists as a readable file, source it.
	# !! If it does not exist, then PUSHOVER_TOKEN and PUSHOVER_USER_KEY must be defined in ~/.zshenv
if [ -f "${POSH_FILE}" -a -r "${POSH_FILE}" ]
then
		source "${POSH_FILE}"
fi

	# if the variable PUSHOVER_TOKEN is empty, we can't continue
if [ "$PUSHOVER_TOKEN" = "" ]
then
		log "[fatal] [reason] PUSHOVER_TOKEN is empty or undefined."
		log "[fatal] [explanation] PUSHOVER_USER_KEY and PUSHOVER_TOKEN must be defined in ~/.zshenv or $POSH_FILE or $0"
		log "[fatal] [information] See $0 for more details. This is a fatal error, meaning that $NAME cannot continue."
		exit 1
fi

	# if the variable PUSHOVER_USER_KEY is empty, we can't continue
if [ "$PUSHOVER_USER_KEY" =  "" ]
then
		log "[fatal] [reason]: PUSHOVER_USER_KEY is empty or undefined."
		log "[fatal] [explanation]: PUSHOVER_USER_KEY and PUSHOVER_TOKEN must be defined in ~/.zshenv or $POSH_FILE or $0"
		log "[fatal] [information]: See $0 for more details. This is a fatal error, meaning that $NAME cannot continue."
		exit 1
fi

	# If there are no arguments given, we can't try to send any message
if [ "$#" = "0" ]
then
		log "[fatal] [reason]: No input received"
		log "[fatal] [explanation]: $0 is meant to send a message, but you did not give me anything to send."
		log "[fatal] [information]: This is a fatal error, meaning that $NAME cannot continue."
		exit 1
fi

	# first we take whatever the user gave us as input ($@)
	# and then we append information as to which computer this came from, and at what time
MESSAGE=`echo "$@ [from $HOST at $TIME]"`

	# use a newline instead of a space as IFS
IFS=$'\n'

	# THIS IS WHERE WE ACTUALLY DO SOMETHING
	# using `curl` we attempt to send the message via the Pushover API
	# and the token and user information we have been given
	# to send the message that the user specified
curl --dump-header - \
	--silent \
	--location \
	--form "token=${PUSHOVER_TOKEN}" \
	--form "user=${PUSHOVER_USER_KEY}" \
	--form "message=${MESSAGE}" \
		'https://api.pushover.net/1/messages.json' 2>&1 >> "${LOG}"

EXIT="$?"

if [[ "$EXIT" == "0" ]]
then
		exit 0

else
		log "Exit code for curl was not zero, it was: $EXIT. A log file can be found at $LOG"

		exit 1
fi




exit
#
#EOF
