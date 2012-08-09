//
//  AppDelegate.h
//  BackupMinderUI
//
//  Created by Christopher Thompson on 7/31/12.
//

#import <Cocoa/Cocoa.h>
#import <SecurityInterface/SFAuthorizationView.h>
#import "MainMenuController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{    
    // To run privileged commands
    IBOutlet SFAuthorizationView *m_authView;
    
    // To connect to the main menu
    IBOutlet MainMenuController *mainMenuController;
};

@end
