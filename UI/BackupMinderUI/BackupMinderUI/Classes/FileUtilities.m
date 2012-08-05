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

+ (BOOL)unloadLaunchDaemon:(NSString*)daemon_
{
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
    
    OSErr err = AuthorizationExecuteWithPrivileges(m_authorizationRef,
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
        return NO;
    }
    
    return YES;
}

+ (BOOL)loadLaunchDaemon:(NSString*)daemon_
{
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
    
    OSErr err = AuthorizationExecuteWithPrivileges(m_authorizationRef,
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
        return NO;
    }
    
    return YES;  
}

+ (BOOL)removeLaunchDaemonFile:(NSString*)daemon_
{
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
    
    OSErr err = AuthorizationExecuteWithPrivileges(m_authorizationRef,
                                             [kRmCommand UTF8String],
                                             kAuthorizationFlagDefaults,
                                             (char *const *)argv,
                                                   nil);
	free(argv);
    
    if (err != errAuthorizationSuccess)
    {
#ifdef DEBUG
        NSLog(@"FileUtilites::removeLaunchDaemonFile: Error removing file from"
                   " disk %d", err);
#endif //DEBUG
        return NO;
    }
    
    return YES;    
}

+ (BOOL)addLaunchDaemonFile:(NSString*)daemon_ withObject:(NSDictionary*)dict_
{
    NSString *tmpName = [NSString stringWithFormat:@"/tmp/%@", daemon_];
	if (![dict_ writeToFile:tmpName atomically:YES])
	{
		NSLog (@"Failed to write tmp file");
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
    
    OSErr err = AuthorizationExecuteWithPrivileges (m_authorizationRef,
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
        return NO;
    }
    
    return YES;
}

+ (void)setAuthorizationRef:(AuthorizationRef)authorizatioRef_
{
    m_authorizationRef = authorizatioRef_;
}
@end
