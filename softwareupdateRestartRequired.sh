#!/bin/bash

##### FUNCTIONS #####
fUpdateEverything ()
{

    ## Once the user OKs the updates or they run automatically, reset the timer to 4 
    echo "4" > /Library/myOrganization/.SoftwareUpdateTimer.txt

	# trigger policy that will install all Apple updates and reboot
	# following two lines commented out for testing
	# /usr/local/bin/jamf policy -event swuwithrestart
	# following line used for testing
	echo "I would have installed updates and rebooted"

}

##### VARIABLES #####
## Set up the software update timer if it does not exist already
if [ ! -e /Library/myOrganization/.SoftwareUpdateTimer.txt ]; then
	mkdir /Library/myOrganization
    echo "4" > /Library/myOrganization/.SoftwareUpdateTimer.txt
fi

## Get the timer value
Timer=`cat /Library/myOrganization/.SoftwareUpdateTimer.txt`

#see if user logged in
USER=`/usr/bin/who | /usr/bin/grep console | /usr/bin/cut -d " " -f 1`;

timeSingularPlural="times"

if [ "$Timer" -lt 2 ]
then
	timeSingularPlural="time"
fi

deferMessage="This Mac requires Apple updates and a reboot.

You may defer the updates "$Timer" "$timeSingularPlural".

Would you like to install the udpates now?"

updateRebootMessage="This Mac requires Apple updates and a reboot.

The deferral limit has been exhausted.

These updates will install now, followed by an automatic restart."

##### SCRIPT #####

if [ -n "$USER" ]
	then
		#Check if restart required
		/usr/sbin/softwareupdate -l | /usr/bin/grep -i "restart"
		if [[ `/bin/echo "$?"` == 0 ]] #if it was successful

			then
				# Prompt user to accept updates that require restart (4 times deferral)
				if [ "$Timer" -ne "0" ] #timer is not done
					then
						OKTORESTART=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -startlaunchd -windowType utility -icon /System/Library/CoreServices/Software\ Update.app/Contents/Resources/SoftwareUpdate.icns -heading "Software Updates Pending" -description "$deferMessage" -button1 "Install" -button2 "Defer" -cancelButton "2" -defaultButton "1"`
						if [ "$OKTORESTART" == "0" ]
							then
								fUpdateEverything
							else
								echo "User deferred update"
								newTimer=$((Timer-1))
								echo "$newTimer" > /Library/myOrganization/.SoftwareUpdateTimer.txt
						fi
					else
						/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Software\ Update.app/Contents/Resources/SoftwareUpdate.icns -heading "Software Updates will Install" -description "$updateRebootMessage" -timeout 30
						fUpdateEverything
				fi
  
			else
				# trigger policy that installs all Apple updates that do not require reboot
				## following line commented out for testing
				# /usr/local/bin/jamf policy -event swunorestart
				# following line used for testing
				echo "Software Update: Updates without restart required would install."
		fi
	else
	#No logged in user
	fUpdateEverything
fi

exit 0
