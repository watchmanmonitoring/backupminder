//
//  AppDelegate.h
//  BackupMinderUI
//
//  Created by Christopher Thompson on 7/31/12.
//

#ifndef APP_DELEGATE_H
#define APP_DELEGATE_H

#import <Cocoa/Cocoa.h>
#import <SecurityInterface/SFAuthorizationView.h>
#import "MainMenuController.h"
#import "Sparkle/Sparkle.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{    
    // To run privileged commands
    IBOutlet SFAuthorizationView *m_authView;
    
    // To connect to the main menu
    IBOutlet MainMenuController *m_mainMenuController;
    
    // To set the version number
    IBOutlet NSTextField *m_versionTextField;
	
	// About Box
	IBOutlet NSWindow *aboutBox;
	IBOutlet NSTextField *webLink;
	
	// Update Box
	IBOutlet NSWindow *updateBox;
	IBOutlet NSTextField *versionText;
};

- (IBAction) showAbout: (id)sender;
- (IBAction) cancelUpdates: (id)sender;
- (IBAction) downloadUpdate: (id)sender;
- (IBAction) checkForUpdates: (id)sender;

@end

#endif //APP_DELEGATE_H