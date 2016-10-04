#!/bin/bash

updates=$(softwareupdate -l | egrep "restart|No new software available.")

if [ "$updates" = "No new software available." ]
then
	echo "Software Update: No new software available."
	exit 0
elif [ "$updates" = "" ]
then
	echo "Software Update: Updates available, no restart required"
	#jamf policy -event swunorestart
	# swunorestart is a custom trigger for a policy that installs all updates except
	# those that require a restart.
else
	echo "Software Update: Updates available, restart required"
	#jamf policy -event swurestartrequired
	# swurestartrequired is a custom trigger for a policy that installs all updates including
	# those that require a restart. This policy has finite deferment options.
fi

exit 0
