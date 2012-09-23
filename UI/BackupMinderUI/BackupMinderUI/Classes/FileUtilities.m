//
//  FileUtilities.m
//  BackupMinderUI
//
//  Created by Christopher Thompson on 7/31/12.
//

#import "FileUtilities.h"
#import "Definitions.h"

@implementation FileUtilities

static AuthorizationRef m_authorizationRef;
static NSString *m_error;

+ (BOOL)unloadLaunchDaemon:(NSString*)daemon_
{
    // Initialize error string if not already
    if (m_error == nil)
    {
        m_error = [NSString new];
    }
    
    // Reset error string
    m_error = @"";
    
    // Build file path
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", 
                           kLaunchDaemonsDirectory, daemon_];
    
    NSArray *arguments = [NSArray arrayWithObjects:kUnload, 
                          filePath, nil];
    
    const char **argv = 
        (const char **)malloc(sizeof(char *) * [arguments count] + 1);
	int argvIndex = 0;
	for (NSString *string in arguments)
	{
		argv[argvIndex] = [string UTF8String];
		argvIndex++;
	}
	
	argv[argvIndex] = nil;
    
    OSStatus err = AuthorizationExecuteWithPrivileges(m_authorizationRef,
                                               [kLaunchHelper UTF8String],
                                               kAuthorizationFlagDefaults,
                                               (char *const *)argv,
                                               nil);
	free(argv);
     
    if (err != errAuthorizationSuccess && 
        err != errAuthorizationToolEnvironmentError)
    {
        NSString *errorText = [FileUtilities errorTextForOSStatus:err];
        
#ifdef DEBUG
        NSLog (@"FileUtilities::unloadLaunchDaemon: Failed to unload launch "
               "daemon: (%d) %@", err, errorText);
#endif //DEBUG
        m_error = [NSString stringWithFormat:
                   @"\nFailed to unload launch daemon:\n%d: %@", 
                   err, errorText];
        
        return NO;
    }
        
    
#ifdef DEBUG
    NSLog (@"FileUtilities::unloadLaunchDaemon: Successfully unloaded launch "
           "daemon");
#endif //DEBUG
    
    return [FileUtilities logUnloadLaunchDaemon:daemon_];
}

// Brief: Update the BackupMinder log to note the disabled daemon
// Param: daemon_, NSString name of the daemon
+ (BOOL)logUnloadLaunchDaemon:(NSString*)daemon_
{
    // Initialize error string if not already
    if (m_error == nil)
    {
        m_error = [NSString new];
    }
    
    // Reset error string
    m_error = @"";
    
    // Get the log file from disk
    NSMutableDictionary *logDict = 
        [NSMutableDictionary dictionaryWithContentsOfFile:kBackupMinderLog];
    
    if (logDict == nil)
    {
#ifdef DEBUG
        NSLog (@"FileUtilities::logUnloadLaunchDaemon: Cannot load log file %@",
            kBackupMinderLog);
#endif //DEBUG
        m_error = [NSString stringWithFormat:
                   @"\nFailed to load log file %@", kBackupMinderLog];
        
        return NO;
    }
    
    // Get the name from the daemon_
    NSArray *daemonName = [daemon_ componentsSeparatedByString:@"."];
    
    // Make sure there are atleast 3 components
    if ([daemonName count] < 3)
    {
#ifdef DEBUG
        NSLog (@"FileUtilities::logUnloadLaunchDaemon: Failed to parse the "
               "daemon name");
#endif //DEBUG
        m_error = [NSString stringWithFormat: 
                    @"\nFailed to parse the daemon name"];
        
        return NO;
    }
    
    // The actual name will be the 3rd component
    NSString *nameContains = [daemonName objectAtIndex:2];    
    
    // Retrieve the array containing all the log information
    NSMutableArray *array = [logDict objectForKey:nameContains];
    
    // Make sure we didn't get a nil array
    if (array == nil)
    {
        // Create a new one if we did
        array = [[NSMutableArray new] autorelease];
    }
    
    // Create a new dictionary entry for the disabled daemon
    NSMutableDictionary *disabledLogDict = 
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:25], kExitStatus, 
                                     nil];
    
    if (disabledLogDict == nil)
    {
#ifdef DEBUG
        NSLog (@"FileUtilities::logUnloadLaunchDaemon: Failed to create a new "
               " entry in the log file for the disabled daemon %@", daemon_);
#endif //DEBUG
        m_error = [NSString stringWithFormat:
                   @"\nFailed to create a new entry in the log file for the "
                   "disabled daemon %@", daemon_];
        
        return NO;
    }
    
    // Add the new object to the list
    [array addObject:disabledLogDict];
    
    // Add the array back to the log dictionary
    [logDict setValue:array forKey:nameContains];
       
    // Now write the file back to disk
    NSString *tmpName = [NSString stringWithFormat:@"/tmp/%@", daemon_];
	if (![logDict writeToFile:tmpName atomically:YES])
	{        
#ifdef DEBUG
		NSLog (@"FileUtilites::logUnloadLaunchDaemon: Failed to write tmp file");
#endif //DEBUG
        
        m_error = @"Failed to write tmp file";
        
        return NO;
	}
        
    NSArray *arguments = [NSArray arrayWithObjects:tmpName, kBackupMinderLog, 
                          nil];
    const char **argv = 
    (const char **)malloc(sizeof(char *) * [arguments count] + 1);
	int argvIndex = 0;
	for (NSString *string in arguments)
	{
		argv[argvIndex] = [string UTF8String];
		argvIndex++;
	}
	
	argv[argvIndex] = nil;    
    
    OSStatus err = AuthorizationExecuteWithPrivileges(m_authorizationRef,
                                                      [kCopyCommand UTF8String],
                                                      kAuthorizationFlagDefaults,
                                                      (char *const *)argv,
                                                      nil);
	free(argv);
    
    if (err != errAuthorizationSuccess && 
        err != errAuthorizationToolEnvironmentError)
    {
        NSString *errorText = [FileUtilities errorTextForOSStatus:err];
        
#ifdef DEBUG
        NSLog(@"FileUtilites::logUnloadLaunchDaemon: Error adding log to disk: "
              "(%d) %@", err, errorText);
#endif //DEBUG
        m_error = [NSString stringWithFormat:
                   @"\nFailed to update log file:\n%d: %@", 
                   err, errorText];
        
        return NO;
    }
    
#ifdef DEBUG
    NSLog (@"FileUtilities::logUnloadLaunchDaemon: Successfully updated log " 
           "file");
#endif //DEBUG
    
    return YES;
}

+ (BOOL)loadLaunchDaemon:(NSString*)daemon_
{
    // Initialize error string if not already
    if (m_error == nil)
    {
        m_error = [NSString new];
    }
    
    // Reset error string
    m_error = @"";
    
    // Build file path
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", 
                           kLaunchDaemonsDirectory, daemon_];
    
    NSArray *arguments = [NSArray arrayWithObjects:kLoad, 
                          filePath, nil];
    
    const char **argv = 
    (const char **)malloc(sizeof(char *) * [arguments count] + 1);
	int argvIndex = 0;
	for (NSString *string in arguments)
	{
		argv[argvIndex] = [string UTF8String];
		argvIndex++;
	}
	
	argv[argvIndex] = nil;
    
    OSStatus err = AuthorizationExecuteWithPrivileges(m_authorizationRef,
                                              [kLaunchHelper UTF8String],
                                              kAuthorizationFlagDefaults,
                                              (char *const *)argv,
                                              nil);
	free(argv);
    
    if (err != errAuthorizationSuccess && 
        err != errAuthorizationToolEnvironmentError)
    {
        NSString *errorText = [FileUtilities errorTextForOSStatus:err];
        
#ifdef DEBUG
        NSLog (@"FileUtilities::loadLaunchDaemon: Failed to load launch "
               "daemon: (%d) %@", err, errorText);
#endif //DEBUG
        m_error = [NSString stringWithFormat:
                   @"\nFailed to load launch daemon:\n%d: %@", 
                   err, errorText];
        
        return NO;
    }
    
#ifdef DEBUG
    NSLog (@"FileUtilities::loadLaunchDaemon: Successfully loaded launch "
           "daemon");
#endif //DEBUG
    
    return YES;  
}

+ (BOOL)removeLaunchDaemonFile:(NSString*)daemon_
{
    // Initialize error string if not already
    if (m_error == nil)
    {
        m_error = [NSString new];
    }
    
    // Reset error string
    m_error = @"";
    
    // Build file path
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", 
                           kLaunchDaemonsDirectory, daemon_];

    NSArray *arguments = [NSArray arrayWithObjects:@"-f", filePath, nil];
    const char **argv = 
        (const char **)malloc(sizeof(char *) * [arguments count] + 1);
	int argvIndex = 0;
	for (NSString *string in arguments)
	{
		argv[argvIndex] = [string UTF8String];
		argvIndex++;
	}
	
	argv[argvIndex] = nil;    
        
    OSStatus err = AuthorizationExecuteWithPrivileges(m_authorizationRef,
                                              [kRmCommand UTF8String],
                                              kAuthorizationFlagDefaults,
                                              (char *const *)argv,
                                              nil);
	free(argv);
    
    if (err != errAuthorizationSuccess && 
        err != errAuthorizationToolEnvironmentError)
    {
        NSString *errorText = [FileUtilities errorTextForOSStatus:err];
        
#ifdef DEBUG
        NSLog(@"FileUtilites::removeLaunchDaemonFile: Failed to remove daemon "
              "from disk (%d) %@", err, errorText);
#endif //DEBUG
        m_error = [NSString stringWithFormat:
                   @"\nFailed to remove daemon from disk:\n%d: %@", 
                   err, errorText];

        return NO;
    }
    
#ifdef DEBUG
    NSLog (@"FileUtilities::removeLaunchDaemonFile: Successfully removed launch "
           "daemon");
#endif //DEBUG
    
    return YES;    
}

+ (BOOL)addLaunchDaemonFile:(NSString*)daemon_ 
                 withObject:(NSMutableDictionary*)dict_
{
    // Initialize error string if not already
    if (m_error == nil)
    {
        m_error = [NSString new];
    }
    
    // Reset error string
    m_error = @"";
    
    NSString *tmpName = [NSString stringWithFormat:@"/tmp/%@", daemon_];
	if (![dict_ writeToFile:tmpName atomically:YES])
	{        
#ifdef DEBUG
		NSLog (@"FileUtilites::addLaunchDaemonFile: Failed to write tmp file");
#endif //DEBUG
        m_error = @"Failed to write tmp file";
        return NO;
	}
    
    // Build file path
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", 
                           kLaunchDaemonsDirectory, daemon_];
    
    NSArray *arguments = [NSArray arrayWithObjects:tmpName, filePath, nil];
    const char **argv = 
        (const char **)malloc(sizeof(char *) * [arguments count] + 1);
	int argvIndex = 0;
	for (NSString *string in arguments)
	{
		argv[argvIndex] = [string UTF8String];
		argvIndex++;
	}
	
	argv[argvIndex] = nil;    
        
    OSStatus err = AuthorizationExecuteWithPrivileges(m_authorizationRef,
                                              [kCopyCommand UTF8String],
                                              kAuthorizationFlagDefaults,
                                              (char *const *)argv,
                                              nil);
	free(argv);
    
    if (err != errAuthorizationSuccess && 
        err != errAuthorizationToolEnvironmentError)
    {
        NSString *errorText = [FileUtilities errorTextForOSStatus:err];
        
#ifdef DEBUG
        NSLog(@"FileUtilites::addLaunchDaemonFile: Error adding file to disk: "
              "(%d) %@", err, errorText);
#endif //DEBUG
        m_error = [NSString stringWithFormat:
                   @"\nFailed to add daemon to disk:\n%d: %@", 
                   err, errorText];
        
        return NO;
    }
    
#ifdef DEBUG
    NSLog (@"FileUtilities::addLaunchDaemonFile: Successfully added launch "
           "daemon");
#endif //DEBUG
    
    return YES;
}

+ (void)setAuthorizationRef:(AuthorizationRef)authorizatioRef_
{
    // Initialize error string if not already
    if (m_error == nil)
    {
        m_error = [NSString new];
    }
    
    // Reset error string
    m_error = @"";
    
    m_authorizationRef = authorizatioRef_;
}

+ (NSString*)lastError
{
    return m_error;
}

+ (NSString*)errorTextForOSStatus: (OSStatus)status_
{
    switch (status_)
    {
        case errAuthorizationSuccess: 
            return @"The operation completed successfully."; 
            break;
            
        case errAuthorizationInvalidSet: 
            return @"The set parameter is invalid.";
            break;
            
        case errAuthorizationInvalidRef: 
            return @"The authorization parameter is invalid.";
            break;
            
        case errAuthorizationInvalidTag: 
            return @"The tag parameter is invalid.";
            break;
            
        case errAuthorizationInvalidPointer: 
            return @"The authorizedRights parameter is invalid.";
            break;
            
        case errAuthorizationDenied: 
            return @"The Security Server denied authorization for one or more "
            "requested rights. This error is also returned if there was no "
            "definition found in the policy database, or a definition "
            "could not be created.";
            break;
            
        case errAuthorizationCanceled: 
            return @"The user canceled the operation.";
            break;
            
        case errAuthorizationInteractionNotAllowed: 
            return @"The Security Server denied authorization because no user "
            "interaction is allowed.";
            break;
            
        case errAuthorizationInternal: 
            return @"An unrecognized internal error occurred.";
            break;
            
        case errAuthorizationExternalizeNotAllowed: 
            return @"The Security Server denied externalization of the "
            "authorization reference.";
            break;
            
        case errAuthorizationInternalizeNotAllowed: 
            return @"The Security Server denied internalization of the "
            "authorization reference.";
            break;
            
        case errAuthorizationInvalidFlags: 
            return @"The flags parameter is invalid.";
            break;
            
        case errAuthorizationToolExecuteFailure: 
            return @"The tool failed to execute.";
            break;
            
        case errAuthorizationToolEnvironmentError: 
            return @"The attempt to execute the tool failed to return a "
            "success or an error code.";
            break;
    }
    
    return @"";
}

@end
