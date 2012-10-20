#BackupMinder

An open source tool by Watchman Monitoring, Inc.
http://backupminder.org

### What does BackupMinder do for me? 
Backup Minder is a utility to help manage the many backup files left by repetitive backup processes. 

### What are some examples of these "repetitive backup proceses", and why are they a problem?
*Each time Quickbooks is quit, a backup is created, sometimes leaving 3-4 backups per day.
*LightSpeed Retail's server will create a backup every day, potentially filling the entire drive.
*FileMaker Pro Server can rotate daily backups, but have no long term history.
*An Excel file may be updated in place, and not have a backup placed elsewhere.


### How does BackupMinder help in these cases? 
*BackupMinder can be configured to keep only a specified number of backups, perhaps the last 60 daily backups.
*BackupMinder can move the last backup of the month to a specified Archive Folder, resulting in 12 good backups per year.
*BackupMinder can keep only the latest copy of a file version in a specified folder, allowing an archival tool to see only one backup.
*BackupMinder can tell if a backup has not been added within a designated number of days. 

### What are BackupMinder's components?

/Applications/BackupMinderUI.app
/Library/Application Support/BackupMinder
/Library/LaunchDeamons/org.backupminder.[your set name]

### How does BackupMinder operate?

The BackupMinder executable is the brains of the operation.  This python script is to be launched using a series of switches which guide its operation.  The BackupMinderUI is included as a tool to construct a launchd to run BackupMinder with a specified set of variables.

### What are BackupMinder's inputs?

The BackupMinder script should be launched with the following inputs defined:

*Name*  A cosmetic name for a backup set.
*BackupSource*	The folder in which backup files are created, we'll watch this folder to know when to run.
*ArchiveDestination	The folder in which the historical archives should be stored.
*NameContains*	This snippit of a name is used to identify 
*BackupsToLeave*	The script will trim old copies of backups, in excess of this number.  ie if a backup happens daily, a value of 7 here will trim backups over 1 week old.
*WarnDays*	A flag used by [Watchman Monitoring](http://www.watchmanmonitoring/) to send an alert if backups aren't happening in a timely fashion.


### How do we implement BackupMinder? 
BackupMinder can be installed by downloading the .pkg we have posted in the downloads area in github.

The BackupMinderUI app is designed to ask for the variables needed to create a BackupSet, and store them in a LaunchDeamon plist.

Each time a file is placed the monitored folder, the OS will trigger BackupMinder as declared in the plist.

### To Do List

Enhance this readme for futher clarity.
Incorporate changes to this readme into the GUI app
Update the readability of the BackupMinderUI
Find a neat icon for the project. 



