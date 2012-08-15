//
//  AppDelegate.m
//  BackupMinderUI
//
//  Created by Christopher Thompson on 7/31/12.
//

#import "AppDelegate.h"
#import "BackupManager.h"
#import "FileUtilities.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Query to initialize
    [BackupManager backups];
    
    // Setup security.
    AuthorizationItem items = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights rights = {1, &items};
    [m_authView setAuthorizationRights:&rights];
    [m_authView setDelegate:self];
    [m_authView updateStatus:nil];
    
    // Set the version number
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    if (infoDict == nil)
        return;
    
    NSString *clientVersionString = [NSString stringWithFormat:@"Version %@",
                                    [infoDict objectForKey:@"CFBundleVersion"]];
    [m_versionTextField setStringValue:clientVersionString];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender_
{
    // We want to close the program when the user exits the main window
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification_
{
    OSStatus err = AuthorizationFree (
        [[m_authView authorization] authorizationRef], 
                                      kAuthorizationFlagDestroyRights);   
    
    if (err != errAuthorizationSuccess)
    {
#ifdef DEBUG
        NSLog(@"AppDelegate::applicationWillTerminate: Failed to free "
              "authorization: %d", err);
#endif //DEBUG
    }
}

#pragma mark -
#pragma mark SFAuthorizationView Methods

- (void)authorizationViewDidAuthorize:(SFAuthorizationView *)view
{
	[m_mainMenuController setAuthorized:YES];
    
    [FileUtilities setAuthorizationRef: 
        [[m_authView authorization] authorizationRef]];
}

- (void)authorizationViewDidDeauthorize:(SFAuthorizationView *)view
{
	[m_mainMenuController setAuthorized:NO];
    
    [FileUtilities setAuthorizationRef:nil];
}

@end
