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
	SUUpdater *updater;
    
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
	
	updater=[SUUpdater sharedUpdater];
	[updater checkForUpdateInformation];
		
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

- (IBAction) showAbout: (id)sender
{
	// both are needed, otherwise hyperlink won't accept mousedown
    [webLink setAllowsEditingTextAttributes: YES];
    [webLink setSelectable: YES];
	
    NSURL* url = [NSURL URLWithString:@"https://backupminder.org"];
	
	NSMutableAttributedString* webString = [[NSMutableAttributedString alloc] initWithString: @"http://backupminder.org"];
    NSRange range = NSMakeRange(0, [webString length]);
	
    [webString beginEditing];
    [webString addAttribute:NSLinkAttributeName value:[url absoluteString] range:range];
	
    // make the text appear in blue
    [webString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
	
    // next make the text appear with an underline
    [webString addAttribute:
	 NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
	
    [webString endEditing];
	
    // set the attributed string to the NSTextField
    [webLink setAttributedStringValue: webString];
	
    [webString release];
	
	[aboutBox makeKeyAndOrderFront:0];
}


- (void)updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)update
{
	[versionText setStringValue:[NSString stringWithFormat:@"BackupMinder %@ is now available- you have %@.", [update versionString], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
	[updateBox makeKeyAndOrderFront:0];
}

- (IBAction) cancelUpdates: (id)sender
{
	[updateBox orderOut: 0];
}

- (IBAction) downloadUpdate: (id)sender;
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://backupminder.org"]];
	[updateBox orderOut: 0];
}

- (IBAction) checkForUpdates: (id)sender;
{
	[[SUUpdater sharedUpdater] checkForUpdateInformation];

}


@end
