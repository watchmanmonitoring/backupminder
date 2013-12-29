#BackupMinder

An open source tool by Watchman Monitoring, Inc.<br />
http://backupminder.org<br />

### What are BackupMinder's components?

`/Applications/BackupMinderUI.app`  A GUI to create and set launchd plists<br />
`/Library/Application Support/BackupMinder` The tool which does all the work.<br />
`/Library/Application Support/BackupMinderHelper` A privilaged helper for the GUI<br \r>
`/Library/LaunchDeamons/org.backupminder.[your set name]` The launchd which watches a folder, and runs the BackupMinder tool.<br />

### How does BackupMinder operate?

The BackupMinder executable is the brains of the operation.  This python script is to be launched using a series of switches which guide its operation.  The BackupMinderUI is included as a tool to construct a launchd to run BackupMinder with a specified set of variables.

### What are BackupMinder's inputs?

The BackupMinder script should be launched with the following inputs defined:

*Name*  A cosmetic name for a backup set.<br />
*BackupSource*	The folder in which backup files are created, we'll watch this folder to know when to run.<br />
*ArchiveDestination	The folder in which the historical archives should be stored.<br />
*NameContains*	This snippit of a name is used to identify <br />
*BackupsToLeave*	The script will trim old copies of backups, in excess of this number.  ie if a backup happens daily, a value of 7 here will trim backups over 1 week old.<br />
*WarnDays*	A flag used by [Watchman Monitoring](http://www.watchmanmonitoring/) to send an alert if backups aren't happening in a timely fashion.<br />


### How do we implement BackupMinder? 
Install BackupMinder by downloading the [latest release](https://github.com/watchmanmonitoring/backupminder/releases/latest) from its GitHub repository.<br />

Install the BackupMinder.pkg and open the BackupMinder.app from /Applications.

The BackupMinderUI app allows the creation of BackupMinder sets.  

Within each set, the app allows you to set the needed paths and file names, and stores them in a LaunchDeamon plist.

Each time a file is placed the monitored folder, the OS will trigger BackupMinder as declared in the plist.


### To Do List

Update the readability of the BackupMinderUI<br />



