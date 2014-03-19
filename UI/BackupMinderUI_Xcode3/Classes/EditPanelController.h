//
//  EditPanelController.h
//  BackupMinderUI
//
//  Created by Christopher Thompson on 8/1/12.
//

#ifndef EDIT_PANEL_CONTROLLER_H
#define EDIT_PANEL_CONTROLLER_H

#import <Cocoa/Cocoa.h>


@interface EditPanelController : NSWindowController <NSWindowDelegate>
{    
    // Track so I can change the icon to a folder
    IBOutlet NSButton *m_backupSourceButton;
    IBOutlet NSButton *m_archiveDestinationButton;
    
    // Text field controls
    IBOutlet NSTextField *m_backupSourceTextField;
    IBOutlet NSTextField *m_archiveDestinationTextField;
    IBOutlet NSTextField *m_nameContainsTextField;
    IBOutlet NSTextField *m_backupsToLeaveTextField;
    IBOutlet NSTextField *m_warnDaysTextField;
        
    // Name label control
    IBOutlet NSTextField *m_nameLabel;
    
    // The error dialog
    NSAlert *m_errorAlert;
    
    // Track the state of the editted backup
    BOOL currentlyDisabled;
}

// Brief: Set the dictionary containing the Backup information
// Param: backupObject_, NSMutableDictionary backup object to use
- (void)setBackupDictionary:(NSMutableDictionary*)backupObject_;

// Brief: Validate the values in the text field
- (BOOL)validateInput;

// Brief: Validate the input and add an object then hide
//        Add or edit a backup item depending on panelMode
// Param: sender_, Id of the sender object
- (IBAction)commit:(id)sender_;

// Brief: Hide the window
// Param: sender_, Id of the sender object
- (IBAction)cancel:(id)sender_;

// Brief: Display an NSOpenPanel window to select the backup source directory
// Param: sender_, Id of the sender object
- (IBAction)selectBackupSource:(id)sender_;

// Brief: Display an NSOpenPanel window to select the archive destination 
//        directory
// Param: sender_, Id of the sender object
- (IBAction)selectArchiveDestination:(id)sender_;

// Brief: Reset the text fields
- (void)clearSelection;

@end

#endif //EDIT_PANEL_CONTROLLER_H
