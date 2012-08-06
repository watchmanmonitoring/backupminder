//
//  AppDelegate.h
//  BackupMinderUI
//
//  Created by Christopher Thompson on 7/31/12.
//

#import <Cocoa/Cocoa.h>
#import <SecurityInterface/SFAuthorizationView.h>
#import "AddPanelController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, 
    NSTableViewDelegate>
{
    // Table control
	IBOutlet NSTableView *backupsTableView;
    
    // Button controls
    IBOutlet NSButton *addButton;
    IBOutlet NSButton *removeButton;
    IBOutlet NSButton *editButton;
    
    // Text field controls
    IBOutlet NSTextField *nameTextField;
    IBOutlet NSTextField *backupSourceTextField;
    IBOutlet NSTextField *archiveDestinationTextField;
    IBOutlet NSTextField *nameContainsTextField;
    IBOutlet NSTextField *backupsToLeaveTextField;
    IBOutlet NSTextField *warnDaysTextField;
    
    // Enabled control
    IBOutlet NSSegmentedControl *enabledSegmentControl;
    
    // To run privileged commands
    IBOutlet SFAuthorizationView *authView;
    
    // The window control
    IBOutlet NSWindow *window;
    
    // The Add/Edit panels
    AddPanelController *addPanel;
    AddPanelController *editPanel;
};

// Brief: Add a new backup object
// Param: sender_, Id of the sender object
- (IBAction)addBackupObject:(id)sender_;

// Brief: Remove a backup object
// Param: sender_, Id of the sender object
- (IBAction)removeBackupObject:(id)sender_;

// Brief: Edit a backup object
// Param: sender_, Id of the sender object
- (IBAction)editBackupObject:(id)sender_;

@end
