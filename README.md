#BackupMinder

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

### What are BackupMinder's inputs

The folder that your current backups are saved to the new folder that you want Backup Minder to archive to an identifier in the backup file name that Backup Minder can look for the number of the most recent backups you want it to keep the number of days before you want to be notified if no backup has occurred After that, you are on autopilot. You don't have to do anything else!



### How do we implement BackupMinder? 
BackupMinder can be installed by downloading the .pkg we have posted in the downloads area in github.

Launch the BackupMinderUI app, 


