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

// Brief: Return the backup object that has the given name
// Param: name_, The name of the backup object to return
+ (NSDictionary*)backupObjectForName:(NSString*)name_;

// Brief: Add a backup object to the list
// Param: backupObject_, NSDictionary object to add
// Param: load_, BOOL to load the daemon during creation
+ (BOOL)addBackupObject:(NSDictionary*)object_ loadDaemon:(BOOL)load_;

// Brief: Edit a backup object in the list
// Param: backupObject_, NSDictionary object to edit
+ (BOOL)editBackupObject:(NSDictionary*)object_;

// Brief: Remove a backup object from the list
// Param: backupObject_, NSDictionary object to remove
// Param: remove_, BOOL to permanently remove the daemon or just disable it
+ (BOOL)removeBackupObject:(NSDictionary*)object_ forRemoval:(BOOL)remove_;

// Brief: Construct the plist name for the given backup object
// Param: backupObject_, NSDictionary object to remove
+ (NSString*)plistNameForBackupObject:(NSDictionary*)object_;

// Brief: Return the last error if there is one
+ (NSString*)lastError;

@end

#endif //BACKUP_MANAGER_H
