//
//  BackupManager.m
//  BackupMinderUI
//
//  Created by Christopher Thompson on 7/31/12.
//

#import "BackupManager.h"
#import "Definitions.h"
#import "FileUtilities.h"

@implementation BackupManager

static NSMutableArray *m_backups;

+ (void)initializeBackups
{	
	// Enumerate files in the Launch Daemons Directory
	NSDirectoryEnumerator* enumerator = 
    [[NSFileManager defaultManager] enumeratorAtPath:kLaunchDaemonsDirectory];
	
	if (enumerator == nil)
	{
#ifdef DEBUG
        NSLog (@"BackupManager::initializeBackups: Could not create enumerator"
               " for %@", kLaunchDaemonsDirectory);
		return;
#endif //DEBUG
	}
	
	NSString* file;
	
	// Iterate through all of the plists in the directory
	while (file = [enumerator nextObject])
	{
		// Check to make sure it's a plist file, 
        // this will also reject Directories
		if (! [[file pathExtension] isEqualToString:kPlistSuffix])
		{
#ifdef DEBUG
            NSLog (@"BackupManager::initializeBackups: %@ is not a plist,"
                   " skipping", file);
#endif //DEBUG
			continue;
		}
        
		// Test to see that I start with the prefix
        if (! [[file commonPrefixWithString:kLaunchDaemonPrefix options:
                NSCaseInsensitiveSearch] isEqualToString:kLaunchDaemonPrefix])
        {
#ifdef DEBUG
            NSLog (@"BackupManager::initializeBackups: %@ does not start with"
                   " prefix, skipping", file);
#endif //DEBUG
            continue;
        }
		
		NSDictionary *backupDict = [NSDictionary dictionaryWithContentsOfFile:
                                    [NSString stringWithFormat:@"%@/%@", 
                                     kLaunchDaemonsDirectory, file]];
		
		if (backupDict == nil)
		{
#ifdef DEBUG
            NSLog (@"BackupManager::initializeBackups: %@ does not contain a"
                   " valid dictionary skipping", file);
#endif //DEBUG
			continue;
		}
        
        // Check to make sure it has all of the necessary keys to be a valid 
        // backup file
        
        if ([backupDict objectForKey:kBackupName] == nil)
        {
#ifdef DEBUG
            NSLog (@"BackupManager::initializeBackups: %@ does not contain the"
                   " key %@ in its dictionary, skipping", file, kBackupName);
#endif //DEBUG
            continue;
        }
        
        if ([backupDict objectForKey:kBackupSource] == nil)
        {
#ifdef DEBUG
            NSLog (@"BackupManager::initializeBackups: %@ does not contain the"
                   " key %@ in its dictionary, skipping", file, kBackupSource);
#endif //DEBUG
            continue;
        }
        
        if ([backupDict objectForKey:kArchiveDestination] == nil)
        {
#ifdef DEBUG
            NSLog (@"BackupManager::initializeBackups: %@ does not contain the"
                   " key %@ in its dictionary, skipping", file, 
                   kArchiveDestination);
#endif //DEBUG
            continue;
        }
        
        if ([backupDict objectForKey:kBackupsToLeave] == nil)
        {
#ifdef DEBUG
            NSLog (@"BackupManager::initializeBackups: %@ does not contain the"
                   " key %@ in its dictionary, skipping", file, 
                   kBackupsToLeave);
#endif //DEBUG
            continue;
        }
        
        if ([backupDict objectForKey:kWarnDays] == nil)
        {
#ifdef DEBUG
            NSLog (@"BackupManager::initializeBackups: %@ does not contain the"
                   " key %@ in its dictionary, skipping", file, kWarnDays);
#endif //DEBUG
            continue;
        }
        
#ifdef DEBUG
        NSLog (@"BackupManager::initializeBackups: Adding %@", file);
#endif //DEBUG
        
        [[BackupManager backups] addObject: backupDict];
	}
}

+ (NSMutableArray*)backups
{
    if (m_backups == nil)
    {
        m_backups = [NSMutableArray new];
        [BackupManager initializeBackups];
    }
    
    return m_backups;
}

+ (NSUInteger)indexOfBackupObject:(NSDictionary*)backupObject_
{
    return [m_backups indexOfObject:backupObject_];
}

+ (NSDictionary*)backupObjectAtIndex:(NSUInteger)index_
{
    if (index_ >= [[BackupManager backups] count])
    {
        return nil;
    }
    
    return [[BackupManager backups] objectAtIndex:index_];
}

+ (BOOL)addBackupObject:(NSDictionary*)object_
{
    // Create the full plist name
    NSString *plistName = [[BackupManager plistNameForBackupObject: object_]
                           autorelease];
    
    [FileUtilities addLaunchDaemonFile:plistName withObject:object_];
    [FileUtilities loadLaunchDaemon:plistName];
    
    return YES;
}

+ (BOOL)editBackupObject:(NSDictionary*)object_ 
{
    // Try and remove the object first
    if (! [BackupManager removeBackupObject:object_])
    {
        // Error logging will be handled in removeBackupObject
        return NO;
    }
    
    return [BackupManager addBackupObject:object_];
}

+ (BOOL)removeBackupObject:(NSDictionary*)object_
{
    if (object_ == nil)
    {
#ifdef DEBUG
        NSLog (@"BackupManager::removeBackupObject: Cannot remove a nil object");
#endif //DEBUG
        return NO;
    }
    
    // If it's not there to begin with, should be an error
    if ([BackupManager indexOfBackupObject:object_] == NSNotFound)
    {
#ifdef DEBUG
        NSLog (@"BackupManager::removeBackupObject: Cannot remove an object"
               " that does not exist in the list");
#endif //DEBUG
        return NO;
    }
    
    // Create the full plist name
    NSString *plistName = [[BackupManager plistNameForBackupObject: object_]
                           autorelease];
    
    // First, unload the launch daemon
    if (! [FileUtilities unloadLaunchDaemon:plistName])
    {
        // Error logging will be handled in unloadLaunchDaemon
        return NO;
    }    
    
    // Second, try and remove from disk
    if (! [FileUtilities removeLaunchDaemonFile:plistName])
    {
        // Error logging will be handled in removeLaunchDaemonFile
        return NO;
    }
    
    // Last, remove from the list    
    [[BackupManager backups] removeObject:object_];
    
    return YES;
}


// Brief: Construct the plist name for the given backup object
// Param: backupObject_, NSDictionary object to remove
+ (NSString*)plistNameForBackupObject:(NSDictionary*)object_
{
    return [[NSString stringWithFormat:@"%@%@.%@", 
                            kLaunchDaemonPrefix, 
                            [object_ objectForKey:kBackupName], 
                            kPlistSuffix] autorelease];
    
}

@end
