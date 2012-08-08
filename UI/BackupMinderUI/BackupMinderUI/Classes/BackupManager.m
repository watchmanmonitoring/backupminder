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
static NSString *m_error;

+ (void)initializeBackups
{
    // Reset error string
    m_error = @"";
    
	// Enumerate files in the Launch Daemons Directory
	NSDirectoryEnumerator* enumerator = 
        [[NSFileManager defaultManager] enumeratorAtPath:
            kLaunchDaemonsDirectory];
	
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
        NSArray *keys = [[NSArray alloc] initWithObjects:kDisabled, kLabel, 
                         kProgramArguments, nil];
        
        BOOL notFound = NO;
        for (NSString *key in keys)
        {
            if ([backupDict objectForKey:key] == nil)
            {
#ifdef DEBUG
                NSLog (@"BackupManager::initializeBackups: %@ does not contain "
                       "the key %@ in its dictionary, skipping", file, key);
#endif //DEBUG
                notFound = YES;
                break;
            }
        }
        
        [keys release];
        
        // If something was not found, skip
        if (notFound)
            continue;
        
        // Check to make sure it has all of the necessary arguments for a valid
        // backup        
        NSArray *arguments = [backupDict objectForKey:kProgramArguments];
        
        NSArray *args = [[NSArray alloc] initWithObjects:kBackupSource,
                         kArchiveDestination, kNameContains, kBackupsToLeave, 
                         kWarnDays, nil];

        for (NSString *arg in args)
        {
            // If indexOfObject returns NSNotFound, then the string isn't in
            // the array
            if ([arguments indexOfObject:arg] == NSNotFound)
            {
#ifdef DEBUG
                NSLog (@"BackupManager::initializeBackups: %@ does not contain "
                       "the key %@ in its dictionary, skipping", file, arg);
#endif //DEBUG
                notFound = YES;
                break;
            }
        }
        
        [args release];
        
        if (notFound)
            continue;
        
#ifdef DEBUG
        NSLog (@"BackupManager::initializeBackups: Adding %@", file);
#endif //DEBUG
        
        [[BackupManager backups] addObject: backupDict];
	}
}

+ (NSMutableArray*)backups
{
    if (m_error == nil)
    {
        m_error = [NSString new];
    }
    
    if (m_backups == nil)
    {
        m_backups = [NSMutableArray new];
        [BackupManager initializeBackups];
    }
    
    return m_backups;
}

+ (NSUInteger)indexOfBackupObject:(NSDictionary*)backupObject_
{
    // Reset error string
    m_error = @"";
    
    return [m_backups indexOfObject:backupObject_];
}

+ (NSDictionary*)backupObjectAtIndex:(NSUInteger)index_
{
    // Reset error string
    m_error = @"";
    
    if (index_ >= [[BackupManager backups] count])
    {
#ifdef DEBUG
        NSLog (@"BackupManager::backupObjectAtIndex: Index %lu is greater than "
               "backups count %lu", index_, [[BackupManager backups] count]);
#endif //DEBUG
        m_error = [NSString stringWithFormat:@"Index %lu is greater than "
                   "backups count %lu", index_, [[BackupManager backups] count]];
        return nil;
    }
    
    return [[BackupManager backups] objectAtIndex:index_];
}

+ (BOOL)addBackupObject:(NSDictionary*)object_
{
    // Reset error string
    m_error = @"";
    
    // Create the full plist name
    NSString *plistName = [[BackupManager plistNameForBackupObject: object_]
                           autorelease];
    
    if (! [FileUtilities addLaunchDaemonFile:plistName withObject:object_])
    {
        // Error logging will be handled in addLaunchDaemonFile
        m_error = [FileUtilities lastError];
        return NO;
    }
    
    if (! [FileUtilities loadLaunchDaemon:plistName])
    {
        // Error logging will be handled in loadLaunchDaemon
        m_error = [FileUtilities lastError];
        return NO;
    }
    
    return YES;
}

+ (BOOL)editBackupObject:(NSDictionary*)object_ 
{
    // Reset error string
    m_error = @"";
    
    // Try and remove the object first
    if (! [BackupManager removeBackupObject:object_])
    {
        // Error logging will be handled in removeBackupObject
        m_error = [BackupManager lastError];
        return NO;
    }
    
    return [BackupManager addBackupObject:object_];
}

+ (BOOL)removeBackupObject:(NSDictionary*)object_
{
    // Reset error string
    m_error = @"";
    
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
        m_error = @"Cannot remove an object that does not exist in the list";
        return NO;
    }
    
    // Create the full plist name
    NSString *plistName = [[BackupManager plistNameForBackupObject: object_]
                           autorelease];
    
    // First, unload the launch daemon
    if (! [FileUtilities unloadLaunchDaemon:plistName])
    {
        // Error logging will be handled in unloadLaunchDaemon
        m_error = [FileUtilities lastError];
        return NO;
    } 
    
    // Second, try and remove from disk
    if (! [FileUtilities removeLaunchDaemonFile:plistName])
    {
        // Error logging will be handled in removeLaunchDaemonFile
        m_error = [FileUtilities lastError];
        return NO;
    }
    
    // Last, remove from the list    
    [[BackupManager backups] removeObject:object_];
    
    return YES;
}

+ (NSString*)plistNameForBackupObject:(NSDictionary*)object_
{
    // Reset error string
    m_error = @"";
    
    return [[NSString stringWithFormat:@"%@.%@",
                            [object_ objectForKey:kLabel], kPlistSuffix] 
            autorelease];
}

+ (NSString*)lastError
{
    return m_error;
}

@end
