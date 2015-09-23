//
//  Definitions.h
//  BackupMinderUI
//
//  Created by Christopher Thompson on 7/31/12.
//

#ifndef DEFINITIONS_H
#define DEFINITIONS_H

// File defintions
#define kLaunchDaemonsDirectory @"/Library/LaunchDaemons"
#define kLaunchDaemonPrefix @"org.backupminder."
#define kPlistSuffix @"plist"

// Backup Dictionary keys
#define kDisabled @"Disabled"
#define kLabel @"Label"
#define kProgramArguments @"ProgramArguments"
#define kBackupSource @"--BackupSource"
#define kArchiveDestination @"--ArchiveDestination"
#define kNameContains @"--NameContains"
#define kName @"--Name"
#define kBackupsToLeave @"--BackupsToLeave"
#define kWarnDays @"--WarnDays"
#define kWatchPath @"WatchPaths"
#define kBackupMinderCommand @"/Library/Application Support/BackupMinder/BackupMinder"

// Table column header names
#define kColumnEnabled @"Enabled"
#define kColumnBackup @"BackupMinder Set"

// BackupMinder log
#define kBackupMinderLog @"/Library/Application Support/BackupMinder/BackupMinder_Log.plist"
#define kBackupMinderLogNameKey @"Name"
#define kExitStatus @"ExitStatus"

// Commands
#define kLaunchHelper @"/Library/Application Support/BackupMinder/BackupMinderHelper"
#define kLoad @"-l"
#define kUnload @"-u"
#define kRmCommand @"/bin/rm"
#define kCopyCommand @"/bin/cp"

// Backup Defaults
#define kBackupsToLeaveDefault @"90"
#define kWarnDaysDefault @"7"

// Maximum possible values
static const int MAX_BACKUPS_TO_LEAVE = 999;
static const int MAX_WARN_DAYS_VALUE = 99;

#endif //DEFINITIONS_H