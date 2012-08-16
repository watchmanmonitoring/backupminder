//
//  Definitions.h
//  BackupMinderUI
//
//  Created by Christopher Thompson on 7/31/12.
//

#ifndef DEFINTIONS_H
#define DEFINTIONS_H

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
#define kBackupsToLeave @"--BackupsToLeave"
#define kWarnDays @"--WarnDays"
#define kWatchPath @"WatchPaths"

// Table column header names
#define kColumnEnabled @"Enabled"
#define kColumnBackup @"Backup"

// BackupMinder log
#define kBackupMinderLog @"/Library/Application Support/BackupMinder/BackupMinder_Log.plist"
#define kBackupMinderLogNameKey @"Name"
#define kExitStatus @"ExitStatus"

// Commands
#define kLaunchctlCommand @"/bin/launchctl"
#define kRmCommand @"/bin/rm"
#define kCopyCommand @"/bin/cp"

#endif //DEFINTIONS_H