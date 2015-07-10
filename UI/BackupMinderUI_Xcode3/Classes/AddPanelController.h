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
	IBOutlet NSTextField *filenameTextField;
	IBOutlet NSTextField *copiesTextField;
	IBOutlet NSTextField *daysTextField;
	
	IBOutlet NSTextField *summaryNameTextField;
	IBOutlet NSTextField *summarySourceTextField;
	IBOutlet NSTextField *summaryDestinationTextField;
	IBOutlet NSTextField *summaryFilenameTextField;
	IBOutlet NSTextField *summaryCopiesTextField;
	IBOutlet NSTextField *summaryDaysTextField;	
	
	IBOutlet NSButton *urlButton;
	
	CATransition *transition;	
}

@property(retain) AddView *currentView;
@property(retain) NSTextField *nameTextField, *sourceTextField, *destinationTextField, *filenameTextField, *copiesTextField, *daysTextField;
@property(retain) NSTextField *summaryNameTextField, *summarySourceTextField, *summaryDestinationTextField, *summaryFilenameTextField, *summaryCopiesTextField, *summaryDaysTextField;
@property(retain) NSButton *urlButton;

- (IBAction)nextView:(id)sender;
- (IBAction)previousView:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)finish:(id)sender;

- (IBAction)selectBackupSource:(id)sender;
- (IBAction)selectArchiveDestination:(id)sender;
- (IBAction)openBackupMinderURL:(id)sender;

- (void)showErrorDialog: (NSString *) errorText;

@end

#endif //ADD_PANEL_CONTROLLER_H
