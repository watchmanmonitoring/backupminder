//
//  FileUtilities.m
//  BackupMinderUI
//
//  Created by Christopher Thompson on 7/31/12.
//

#import "FileUtilities.h"
#import "Definitions.h"

#define kLaunchctlCommand @"/bin/launchctl"
#define kRmCommand @"/bin/rm"
#define kCopyCommand @"/bin/cp"

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
    NSString *filePath = [[NSString stringWithFormat:@"%@/%@", 
                           kLaunchDaemonsDirectory, daemon_] autorelease];
    
    NSArray *arguments = [NSArray arrayWithObjects:@"unload", filePath, nil];
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
                                                   [kLaunchctlCommand UTF8String],
                                                   kAuthorizationFlagDefaults,
                                                   (char *const *)argv,
                                                   nil);
	free(argv);
    
    if (err != errAuthorizationSuccess)
    {
#ifdef DEBUG
        NSLog (@"FileUtilities::unloadLaunchDaemon: Failed to unload launch "
               "daemon: %d", err);
#endif //DEBUG}
        m_error = [NSString stringWithFormat:
                    @"Failed to unload launch daemon: %d", err];
        return NO;
    }
    
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
    NSString *filePath = [[NSString stringWithFormat:@"%@/%@", 
                           kLaunchDaemonsDirectory, daemon_] autorelease];
    
    NSArray *arguments = [NSArray arrayWithObjects:@"load", filePath, nil];
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
                                                   [kLaunchctlCommand UTF8String],
                                                   kAuthorizationFlagDefaults,
                                                   (char *const *)argv,
                                                   nil);
	free(argv);
    
    if (err != errAuthorizationSuccess)
    {
#ifdef DEBUG
        NSLog (@"FileUtilities::loadLaunchDaemon: Failed to load launch daemon:"
               " %d", err);
#endif //DEBUG}
        m_error = [NSString stringWithFormat:
                   @"Failed to load launch daemon: %d", err];
        return NO;
    }
    
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
    NSString *filePath = [[NSString stringWithFormat:@"%@/%@", 
                           kLaunchDaemonsDirectory, daemon_] autorelease];

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
    
    if (err != errAuthorizationSuccess)
    {
#ifdef DEBUG
        NSLog(@"FileUtilites::removeLaunchDaemonFile: Failed to remove daemon "
                   "from disk %d", err);
#endif //DEBUG
        m_error = [NSString stringWithFormat:
                   @"Failed to remove daemon from disk: %d", err];
        return NO;
    }
    
    return YES;    
}

+ (BOOL)addLaunchDaemonFile:(NSString*)daemon_ withObject:(NSDictionary*)dict_
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
    NSString *filePath = [[NSString stringWithFormat:@"%@/%@", 
                           kLaunchDaemonsDirectory, daemon_] autorelease];
    
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
    
    OSStatus err = AuthorizationExecuteWithPrivileges (m_authorizationRef,
                                                   [kCopyCommand UTF8String],
                                                   kAuthorizationFlagDefaults,
                                                   (char *const *)argv,
                                                    nil);
	free(argv);
    
    if (err != errAuthorizationSuccess)
    {
#ifdef DEBUG
        NSLog(@"FileUtilites::addLaunchDaemonFile: Error adding file to disk: "
              "%d", err);
#endif //DEBUG
        m_error = [NSString stringWithFormat:
                   @"Failed to add daemon to disk: %d", err];
        return NO;
    }
    
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
@end
