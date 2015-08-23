//
//  BackupManager.m
//  BackupMinderUI
//
//  Created by Christopher Thompson on 7/31/12.
//

#import "BackupManager.h"
#import "Definitions.h"
#import "FileUtilities.h"

//#define DEBUG TRUE;

@implementation BackupManager

static NSMutableArray *m_backups;
static NSString *m_error;

+ (void)initializeBackups
{
    // Reset error string
    m_error = @"";
    
    // Delete the old list and create a new one
    if (m_backups)
    {
        [m_backups release];
    }
    m_backups = [NSMutableArray new];
    
	// Enumerate files in the Launch Daemons Directory
	NSDirectoryEnumerator* enumerator = 
        [[NSFileManager defaultManager] enumeratorAtPath:
            kLaunchDaemonsDirectory];
	
	if (enumerator == nil)
	{
#ifdef DEBUG
        NSLog (@"BackupManager::initializeBackups: Could not create enumerator"
               " for %@", kLaunchDaemonsDirectory);
#endif //DEBUG
        
		return;
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
		
		NSMutableDictionary *backupDict = 
            [NSMutableDictionary dictionaryWithContentsOfFile:
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
        {
            continue;
        }
        
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
        {
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
    if (m_error == nil)
    {
        m_error = [NSString new];
    }
    
    if (m_backups == nil)
    {
        [BackupManager initializeBackups];
    }
    
    return m_backups;
}

+ (NSUInteger)indexOfBackupObject:(NSMutableDictionary*)backupObject_
{
    // Reset error string
    m_error = @"";
    
    NSString *name = [[backupObject_ objectForKey: kLabel] 
                      substringFromIndex: 
                      [kLaunchDaemonPrefix length]];
    
    return [m_backups indexOfObject:
            [BackupManager backupObjectForName:name]];
}

+ (NSMutableDictionary*)backupObjectAtIndex:(NSUInteger)index_
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
                   "backups count %lu", index_, 
                    [[BackupManager backups] count]];
        
        return nil;
    }
    
    return [[BackupManager backups] objectAtIndex:index_];
}

+ (NSMutableDictionary*)backupObjectForName:(NSString*)name_
{
    // Reset error string
    m_error = @"";
    
    if ([name_ isEqualToString:@""])
    {
#ifdef DEBUG
        NSLog (@"BackupManager::backupObjectForName: Cannot search for a "
               "backup object with a blank name");
#endif //DEBUG
        m_error = [NSString stringWithFormat:@"Cannot search for a BackupSet "
                   "with a blank name"];
        
        return nil;        
    }
    
    NSEnumerator *iter = [[BackupManager backups] objectEnumerator];
    NSMutableDictionary *object;
    while (object = [iter nextObject]) 
    {
        if ([name_ isEqualToString:[[object objectForKey: kLabel] 
                                    substringFromIndex: 
                                        [kLaunchDaemonPrefix length]]])
        {
            return object;
        }
    }
    
    return nil;
}

+ (BOOL)addBackupObject:(NSMutableDictionary*)object_ loadDaemon:(BOOL)load_
{
    // Reset error string
    m_error = @"";
    
    // Create the full plist name
    NSString *plistName = [BackupManager plistNameForBackupObject: object_];
    
    if (plistName == nil)
    {
#ifdef DEBUG
        NSLog (@"BackupManager::addBackupObject: Could not get a plist name "
               "for the backup object");
#endif //DEBUG
        m_error = [NSString stringWithFormat:@"Could not get a plist name for "
                   "the BackupSet"];
        
        return NO;
    }
    
    if (! [FileUtilities addLaunchDaemonFile:plistName withObject:object_])
    {
        // Error logging will be handled in addLaunchDaemonFile
        m_error = [FileUtilities lastError];
        
        return NO;
    }
    
    if (load_)
    {
        if (! [FileUtilities loadLaunchDaemon:plistName])
        {
            // Error logging will be handled in loadLaunchDaemon
            m_error = [FileUtilities lastError];
            
            return NO;
        }
    }
    
    [[BackupManager backups] addObject:object_];
    
    return YES;
}

+ (BOOL)editBackupObject:(NSMutableDictionary*)originalObject withObject: (NSMutableDictionary *)newObject
{
    // Reset error string
    m_error = @"";

    // Try and remove the object first
    if (! [BackupManager removeBackupObject:originalObject])
    {
        // Error logging will be handled in removeBackupObject
        m_error = [BackupManager lastError];
        
        return NO;
    }
    
    // We only want to load the daemon if the backup is not disabled    
    return [BackupManager addBackupObject:newObject loadDaemon:
                ! [[newObject objectForKey:kDisabled] boolValue]];
}

+ (BOOL)removeBackupObject:(NSMutableDictionary*)object_
{
    // Reset error string
    m_error = @"";
    
    if (object_ == nil)
    {
#ifdef DEBUG
        NSLog (@"BackupManager::removeBackupObject: Cannot remove a nil object"
               );
#endif //DEBUG
        
        return NO;
    }
    
    // Save the index for later
    NSUInteger index = [BackupManager indexOfBackupObject:object_];
    
    // If it's not there to begin with, should be an error
    if (index == NSNotFound)
    {
#ifdef DEBUG
        NSLog (@"BackupManager::removeBackupObject: Cannot remove an object"
               " that does not exist in the list");
#endif //DEBUG
        m_error = @"Cannot remove an object that does not exist in the list";
        
        return NO;
    }
    
    // Create the full plist name
    NSString *plistName = [BackupManager plistNameForBackupObject: object_];
    
    // First, unload the launch daemon
    if (! [FileUtilities unloadLaunchDaemon:plistName])
    {
        // Error logging will be handled in unloadLaunchDaemon
       // m_error = [FileUtilities lastError];
        
        //return NO;
    } 
    
    // Second, try and remove from disk
    if (! [FileUtilities removeLaunchDaemonFile:plistName])
    {
        // Error logging will be handled in removeLaunchDaemonFile
        m_error = [FileUtilities lastError];
        
        return NO;
    }
    
    // Last, remove from the list    
    [[BackupManager backups] removeObjectAtIndex:index];
    
    return YES;
}

+ (NSString*)plistNameForBackupObject:(NSMutableDictionary*)object_
{
    // Reset error string
    m_error = @"";
    
    return [NSString stringWithFormat:@"%@.%@",
            [object_ objectForKey:kLabel], kPlistSuffix];
}

+ (NSString*)lastError
{
    return m_error;
}

@end
