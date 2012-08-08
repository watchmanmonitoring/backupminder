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
	IBOutlet NSTableView *m_backupsTableView;
    
    // Button controls
    IBOutlet NSButton *m_addButton;
    IBOutlet NSButton *m_removeButton;
    IBOutlet NSButton *m_editButton;
    
    // Text field controls
    IBOutlet NSTextField *m_nameTextField;
    IBOutlet NSTextField *m_backupSourceTextField;
    IBOutlet NSTextField *m_archiveDestinationTextField;
    IBOutlet NSTextField *m_nameContainsTextField;
    IBOutlet NSTextField *m_backupsToLeaveTextField;
    IBOutlet NSTextField *m_warnDaysTextField;
    
    // Enabled control
    IBOutlet NSSegmentedControl *m_enabledSegmentControl;
    
    // To run privileged commands
    IBOutlet SFAuthorizationView *m_authView;
    
    // The window control
    IBOutlet NSWindow *m_window;
    
    // The Add/Edit panels
    AddPanelController *m_addPanel;
    AddPanelController *m_editPanel;
    
    // To maintain a relationship between a backup argument and the textField
    // the argument should be placed in
    NSDictionary *m_textFieldsMap;
    
    // The error dialog
    NSAlert *m_errorAlert;
    
    // The "Are you sure?" alert
    NSAlert *m_removeAlert;
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
