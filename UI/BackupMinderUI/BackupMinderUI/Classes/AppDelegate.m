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
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender_
{
    // We want to close the program when the user exits the main window
    return YES;
}

#pragma mark -
#pragma mark SFAuthorizationView Methods

- (void)authorizationViewDidAuthorize:(SFAuthorizationView *)view
{
	[mainMenuController setAuthorized:YES];
    
    [FileUtilities setAuthorizationRef: 
        [[m_authView authorization] authorizationRef]];
}

- (void)authorizationViewDidDeauthorize:(SFAuthorizationView *)view
{
	[mainMenuController setAuthorized:NO];
    
    [FileUtilities setAuthorizationRef:nil];
}

@end
