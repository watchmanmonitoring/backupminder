//
//  AddPanelController.h
//  BackupMinderUI
//
//  Created by Christopher Thompson on 8/1/12.
//

#ifndef ADD_PANEL_CONTROLLER_H
#define ADD_PANEL_CONTROLLER_H

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>
#import "AddView.h"

@interface AddPanelController : NSWindowController <NSWindowDelegate, NSTextFieldDelegate>
{
    IBOutlet AddView *currentView;
	
	IBOutlet NSTextField *nameTextField;
	IBOutlet NSTextField *sourceTextField;
	IBOutlet NSTextField *destinationTextField;
	
	CATransition *transition;	
}

@property(retain) AddView *currentView;
@property(retain) NSTextField *nameTextField, *sourceTextField, *destinationTextField;

- (IBAction)nextView:(id)sender;
- (IBAction)previousView:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)finish:(id)sender;

- (IBAction)selectBackupSource:(id)sender;
- (IBAction)selectArchiveDestination:(id)sender;

- (void)showErrorDialog: (NSString *) errorText;

	
	
/*	// Button controls
	IBOutlet NSButton *m_addButton;
	IBOutlet NSButton *m_backButton;
	IBOutlet NSButton *m_nextButton;
	IBOutlet NSButton *m_wmUrlButton;
	
	// TabView
	IBOutlet NSTabView *m_wizardTabView;
	
    // Track so I can change the icon to a folder
    IBOutlet NSButton *m_backupSourceButton;
    IBOutlet NSButton *m_archiveDestinationButton;
    
    // Text field controls
    IBOutlet NSTextField *m_nameTextField;
    IBOutlet NSTextField *m_backupSourceTextField;
    IBOutlet NSTextField *m_archiveDestinationTextField;
    IBOutlet NSTextField *m_nameContainsTextField;
    IBOutlet NSTextField *m_backupsToLeaveTextField;
    IBOutlet NSTextField *m_warnDaysTextField;
	IBOutlet NSTextField *m_summaryTextField;
	
    // The error dialog
    NSAlert *m_errorAlert;
	
	int m_currentPage;
}

// Brief: Validate the values in the text field
- (BOOL)validateInput;

// Brief: Move backwards one page in the wizard
- (IBAction)backwards:(id)sender_;

// Brief: Validate the input and add an object then hide
//        Add or edit a backup item depending on panelMode
// Param: sender_, Id of the sender object
- (IBAction)commit:(id)sender_;

// Brief: Hide the window
// Param: sender_, Id of the sender object
- (IBAction)cancel:(id)sender_;

// Brief: Move forward one page in the wizard
- (IBAction)forward:(id)sender_;

// Brief: Display an NSOpenPanel window to select the backup source directory
// Param: sender_, Id of the sender object
- (IBAction)selectBackupSource:(id)sender_;

// Brief: Display an NSOpenPanel window to select the archive destination 
//        directory
// Param: sender_, Id of the sender object
- (IBAction)selectArchiveDestination:(id)sender_;

// Brief: Open a web browser when the Watchman Monitoring link is clicked
- (IBAction)wmUrlButtonClicked:(id)sender_;

// Brief: Reset the text fields
- (void)clearSelection;

// Brief: Update the display based on which page of the wizard we are on
- (void)updateWizardPage;
 */

@end

#endif //ADD_PANEL_CONTROLLER_H
