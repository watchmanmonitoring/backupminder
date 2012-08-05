//
//  FileUtilities.h
//  BackupMinderUI
//
//  Created by Christopher Thompson on 7/31/12.
//

#import <Foundation/Foundation.h>

@interface FileUtilities : NSObject

// Brief: Call the command line launchctl to unload the daemon
// Param: daemon_, NSString name of the daemon
+ (BOOL)unloadLaunchDaemon:(NSString*)daemon_;

// Brief: Call the command line launchctl to load the daemon
// Param: daemon_, NSString name of the daemon
+ (BOOL)loadLaunchDaemon:(NSString*)daemon_;

// Brief: Delete the file from disk
// Param:  daemon_, NSString name of the plist to remove
+ (BOOL)removeLaunchDaemonFile:(NSString*)daemon_;

// Brief: Create a new file on disk
// Param: daemon_, NSString name of the plist to create
// Param: dict_, NSDictionary contents of the new daemon
+ (BOOL)addLaunchDaemonFile:(NSString*)daemon_ withObject:(NSDictionary*)dict_;

// Brief: Set the authorization
// Param: authorizationRef_, Authorization priviliges to execute commands
+ (void)setAuthorizationRef:(AuthorizationRef)authorizatioRef_;

@end
