//
//  AddPanelController.h
//  BackupMinderUI
//
//  Created by Christopher Thompson on 8/1/12.
//

// The AddPanelController is a dual purpose dialog
// 1) Add a new backup object
// 2) Edit an existing object
// 
// The default implementation is to add an object
// Nothing special needs to be done to use the Add panel
//
// To create an Edit panel, use the initWithMode:EDIT_PANEL_MODE
// Before you show the panel, set the dictionary to edit by calling
// setBackupDictionary:(NSDictionary*)

#import <Cocoa/Cocoa.h>

enum panelMode_t 
{
    ADD_PANEL_MODE, 
    EDIT_PANEL_MODE, 
    NUM_PANEL_MODES
};

@interface AddPanelController : NSWindowController <NSWindowDelegate>
{
    // Local storage of the Backup object
    NSDictionary *m_backupObject;
    
    // Controls whether we are an Add or Edit panel
    enum panelMode_t m_panelMode;
    
    // Track so I can change to Edit if necessary
    IBOutlet NSButton *m_addButton;
    
    // Text field controls
    IBOutlet NSTextField *m_nameTextField;
    IBOutlet NSTextField *m_backupSourceTextField;
    IBOutlet NSTextField *m_archiveDestinationTextField;
    IBOutlet NSTextField *m_nameContainsTextField;
    IBOutlet NSTextField *m_backupsToLeaveTextField;
    IBOutlet NSTextField *m_warnDaysTextField;
    
    // Enabled control
    IBOutlet NSSegmentedControl *m_enabledSegmentControl;
    
    // The error dialog
    NSAlert *m_errorAlert;
    
    // To maintain a relationship between a backup argument and the textField
    // the argument should be placed in
    NSDictionary *m_textFieldsMap;
}

// Brief: Initialize the window with a given Add/Edit mode
// Param: window_, the NSWindow object to use
// Param: mode_, the Add/Edit mode to show as
- (id)initWithMode:(enum panelMode_t)mode_;

// Brief: Validate the values in the text field
- (BOOL)validateInput;

// Brief: Validate the input and add an object then hide
//        Add or edit a backup item depending on panelMode
// Param: sender_, Id of the sender object
- (IBAction)commit:(id)sender_;

// Brief: Hide the window
// Param: sender_, Id of the sender object
- (IBAction)cancel:(id)sender_;

// Brief: Set the dictionary containing the Backup information
// Param: backupObject_, NSDictionary backup object to use
- (void)setBackupDictionary:(NSDictionary*)backupObject_;

// Brief: Display an NSOpenPanel window to select the backup source directory
// Param: sender_, Id of the sender object
- (IBAction)selectBackupSource:(id)sender_;

// Brief: Display an NSOpenPanel window to select the archive destination 
//        directory
// Param: sender_, Id of the sender object
- (IBAction)selectArchiveDestination:(id)sender_;

@end
