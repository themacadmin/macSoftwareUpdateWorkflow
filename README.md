# macSoftwareUpdateWorkflow
Casper Suite

## Process
### Policy runs softwareupdateCheck.bash
  * Policy is run daily on all computers
  * If softwareupdateCheck.bash returns any instances of "restart", the swurestartrequired trigger is called. (via script)
  * If softwareupdateCheck.bash doesn't return any instances of "restart", the swunorestart trigger is called. (via script)
### Policy runs softwareupdateNoRestart.sh
  * Triggered by "swunorestart"
  * Ongoing frequency
  * Installs all updates that don't require reboot (via script)
  * Submits inventory report (via script)
### Policy runs softwareupdateRestartRequired.sh
  * Triggered by "swunorestart"
  * Ongoing frequency
  * Has deferment counter of 4 (via script)
  * Executes automatically on the 5th run (via script)
  * Calls "swuwithrestart" trigger.
### Policy triggered by "swuwithrestart"
  * ongoing frequency
  * installs all software updates
  * reboots
  * No recon (I collect inventory at reboot in my environment)
