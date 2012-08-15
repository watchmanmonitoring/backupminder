//
//  BackupManager.h
//  BackupMinderUI
//
//  Created by Christopher Thompson on 7/31/12.
//

#ifndef BACKUP_MANAGER_H
#define BACKUP_MANAGER_H

#import <Foundation/Foundation.h>

@interface BackupManager : NSObject

// Brief: Read backups from disk and store locally
+ (void)initializeBackups;

// Brief: Return the list of backups
+ (NSMutableArray*)backups;

// Brief: Return the index of a backup object
// Param: backupObject_, NSDictionary object to find in the list
+ (NSUInteger)indexOfBackupObject:(NSDictionary*)backupObject_;

// Brief: Return the backup object at the given index
// Param: index_, NSUInteger index in the list of the desired object
+ (NSDictionary*)backupObjectAtIndex:(NSUInteger)index_;

// Brief: Add a backup object to the list
// Param: backupObject_, NSDictionary object to add
+ (BOOL)addBackupObject:(NSDictionary*)object_;

// Brief: Edit a backup object in the list
// Param: backupObject_, NSDictionary object to edit
+ (BOOL)editBackupObject:(NSDictionary*)object_;

// Brief: Remove a backup object from the list
// Param: backupObject_, NSDictionary object to remove
+ (BOOL)removeBackupObject:(NSDictionary*)object_;

// Brief: Construct the plist name for the given backup object
// Param: backupObject_, NSDictionary object to remove
+ (NSString*)plistNameForBackupObject:(NSDictionary*)object_;

// Brief: Return the last error if there is one
+ (NSString*)lastError;

@end

#endif //BACKUP_MANAGER_H
