//
//  MainMenuController.h
//  BackupMinderUI
//
//  Created by Christopher Thompson on 8/8/12.
//

#ifndef MAIN_MENU_CONTROLLER_H
#define MAIN_MENU_CONTROLLER_H

#import <Cocoa/Cocoa.h>
#import "AddPanelController.h"
#import "EditPanelController.h"

@interface MainMenuController : NSWindowController <NSTableViewDataSource,
    NSTableViewDelegate>
{ 
    // Table control
	IBOutlet NSTableView *m_backupsTableView;
    
    // Button controls
    IBOutlet NSButton *m_addButton;
    IBOutlet NSButton *m_removeButton;
    IBOutlet NSButton *m_editButton;
    IBOutlet NSButton *m_refreshButton;
    
    // Text field controls
    IBOutlet NSTextField *m_nameTextField;
    IBOutlet NSTextField *m_backupSourceTextField;
    IBOutlet NSTextField *m_archiveDestinationTextField;
    IBOutlet NSTextField *m_nameContainsTextField;
    IBOutlet NSTextField *m_backupsToLeaveTextField;
    IBOutlet NSTextField *m_warnDaysTextField;
    
    // The Add/Edit panels
	AddPanelController *m_addPanel;
    EditPanelController *m_editPanel;
    
    // The error dialog
    NSAlert *m_errorAlert;
    
    // The "Are you sure?" alert
    NSAlert *m_removeAlert;
}

// Brief: Enable/disable components of the app based on the authorized status
// Param: authorized_, BOOL of whether or not the app is authorized
- (void)setAuthorized:(BOOL)authorized_;

// Brief: Add a new backup object
// Param: sender_, Id of the sender object
- (IBAction)addBackupObject:(id)sender_;

// Brief: Remove a backup object
// Param: sender_, Id of the sender object
- (IBAction)removeBackupObject:(id)sender_;

// Brief: Edit a backup object
// Param: sender_, Id of the sender object
- (IBAction)editBackupObject:(id)sender_;

// Brief: Refresh the list of backup objects
// Param: sender_, Id of the sender object
- (IBAction)refresh:(id)sender_;

// Brief: Show the About dialog
// Param: sender_, Id of the sender object
- (IBAction)showAbout:(id)sender_;

// Brief: Reset the table selection and clear the table selection
- (void)clearSelection;

@end

#endif //MAIN_MENU_CONTROLLER_H
