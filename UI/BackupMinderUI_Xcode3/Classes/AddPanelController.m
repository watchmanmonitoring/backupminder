//
//  AddPanelController.m
//  BackupMinderUI
//
//  Created by Christopher Thompson on 8/1/12.
//

#import "AddPanelController.h"
#import "Definitions.h"
#import "BackupManager.h"


/*
 
 To Do: 
 enable/disable buttons based on text entry (see SU for that)
 choose filename automatically
 fix writable check
 fix source/dest same check
 fix error on adding
 
 */

@implementation AddPanelController

@synthesize currentView, nameTextField, sourceTextField, destinationTextField, filenameTextField, daysTextField, copiesTextField;
@synthesize summaryNameTextField, summarySourceTextField, summaryDestinationTextField, summaryFilenameTextField, summaryCopiesTextField, summaryDaysTextField;

- (id) init
{
    if (! (self = [super initWithWindowNibName: @"AddPanel"]))
    {
        return nil; 
    }
	
    return self;
}

- (void)awakeFromNib
{
    NSView *contentView = [[self window] contentView];
    [contentView setWantsLayer:YES];
    [contentView addSubview:[self currentView]];
    
    transition = [CATransition animation];
    [transition setType:kCATransitionPush];
    [transition setSubtype:kCATransitionFromLeft];
    
    NSDictionary *ani = [NSDictionary dictionaryWithObject:transition forKey:@"subviews"];
    [contentView setAnimations:ani];
	
	// Format the Watchman Monitoring link text	
	NSDictionary *urlTextDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
									   [NSParagraphStyle defaultParagraphStyle], NSParagraphStyleAttributeName,
									   [NSColor blueColor], NSForegroundColorAttributeName,
									   [NSNumber numberWithBool:TRUE], NSUnderlineStyleAttributeName,
									   [NSFont fontWithName:@"Arial" size:13], NSFontAttributeName, nil];
	
	[urlButton setAttributedTitle:[[[NSMutableAttributedString alloc] initWithString:[urlButton title]
																			  attributes:urlTextDictionary] autorelease]];
	
}

- (void)setCurrentView:(AddView*)newView
{
    if (!currentView) {
        currentView = newView;
        return;
    }
    NSView *contentView = [[self window] contentView];
    [[contentView animator] replaceSubview:currentView with:newView];
    currentView = newView;
}

- (IBAction)nextView:(id)sender;
{
    if (![[self currentView] nextView]) return;
		
	switch ([[[self currentView] viewID] intValue]) 
	{
		case k_name:
		{
			NSString *nameText = [nameTextField stringValue];
			
			if (nameText==nil || [nameText length]==0)
			{
				[self showErrorDialog:@"Name is empty and is a required field"];
				return;
			}
			
			if ([BackupManager backupObjectForName:nameText] != nil)
			{
				[self showErrorDialog:@"Name must be unique and the current entry is not"];
				return;
			}			
			break;
		}
		case k_monitor:
		{
			NSString *sourceText = [sourceTextField stringValue];
			
			if (sourceText==nil || [sourceText length]==0)
			{
				[self showErrorDialog:@"Source is empty and is a required field"];
				return;
			}
			break;
		}
		case k_archive:
		{
			NSString *destinationText = [destinationTextField stringValue];
			
			if (destinationText==nil || [destinationText length]==0)
			{
				[self showErrorDialog:@"Destination is empty and is a required field"];
				return;
			}
			break;
			
			// Ensure I can write to the destination directory
			if (! [[NSFileManager defaultManager] isWritableFileAtPath:[destinationTextField toolTip]])
			{
				[self showErrorDialog:@"Cannot write to destination. Please check permissions or select a different folder."];
				return; 
			}
			
			// Ensure source and destination aren't the same
			if ([[destinationTextField toolTip] compare:[sourceTextField toolTip]]==NSOrderedSame)
			{
				[self showErrorDialog:@"Source and Destination directories cannot be the same. Please select a different folder."];
				return; 
			}
		}
		case k_filename:
		{
			NSString *fileNameText = [filenameTextField stringValue];
			
			if (fileNameText==nil || [fileNameText length]==0)
			{
				[self showErrorDialog:@"Filename is empty and is a required field"];
				return;
			}
			break;			
		}
		case k_copies:
		{
			NSString *daysText = [daysTextField stringValue];
			NSString *copiesText = [copiesTextField stringValue];
			
			if (daysText==nil || [daysText length]==0)
			{
				[self showErrorDialog:@"Days is empty and is a required field"];
				return;
			}
			
			if (copiesText==nil || [copiesText length]==0)
			{
				[self showErrorDialog:@"Copies is empty and is a required field"];
				return;
			}
			
			int copies = [copiesTextField intValue];
			if (copies <= 0 || copies > MAX_BACKUPS_TO_LEAVE)
			{
				[self showErrorDialog:[NSString stringWithFormat: @"Copies must be between 1 and %d", MAX_BACKUPS_TO_LEAVE]];
				return;
			}
			
			int days = [daysTextField intValue];
			if (days <= 0 || copies > MAX_WARN_DAYS_VALUE)
			{
				[self showErrorDialog:[NSString stringWithFormat: @"Days must be between 1 and %d", MAX_WARN_DAYS_VALUE]];
				return;
			}
			
			[summaryNameTextField setStringValue:[nameTextField stringValue]];
			[summarySourceTextField setStringValue:[sourceTextField stringValue]];
			[summaryDestinationTextField setStringValue:[destinationTextField stringValue]];
			[summaryFilenameTextField setStringValue:[filenameTextField stringValue]];
			[summaryCopiesTextField setStringValue:[copiesTextField stringValue]];
			[summaryDaysTextField setStringValue:[nameTextField stringValue]];
			
			break;
		}
		default:
			break;
	}

	
    [transition setSubtype:kCATransitionFromRight];
    [self setCurrentView:[[self currentView] nextView]];
}

- (IBAction)previousView:(id)sender;
{
    if (![[self currentView] previousView]) return;
    [transition setSubtype:kCATransitionFromLeft];
    [self setCurrentView:[[self currentView] previousView]];
}

- (IBAction)finish:(id)sender
{
	
	// Create the arguments array first
    NSArray *arguments = [NSArray arrayWithObjects:
                          kBackupMinderCommand,
                          kBackupSource,
                          [sourceTextField toolTip],
                          kArchiveDestination,
                          [destinationTextField toolTip],
                          kName,
                          [nameTextField stringValue],
                          kNameContains,
                          [filenameTextField stringValue],
                          kBackupsToLeave,
                          [copiesTextField stringValue],
						  kWarnDays,
                          [daysTextField stringValue], nil];
    
    // Create an array for the WatchPath
    NSArray *watchPaths = [NSArray arrayWithObjects: 
                           [sourceTextField toolTip], nil];
    
    // Create the backupObject
    NSString *label = [NSString stringWithFormat:@"%@%@", 
                       kLaunchDaemonPrefix, [nameTextField stringValue]];
    
    NSMutableDictionary *backupObject = 
	[NSMutableDictionary dictionaryWithObjectsAndKeys:
	 label, kLabel,
	 [NSNumber numberWithBool:NO], kDisabled,
	 arguments, kProgramArguments,
	 watchPaths, kWatchPath,
	 nil];
    
    if (! backupObject)
    {
        return;
    }
	
    if (! [BackupManager addBackupObject:backupObject loadDaemon:YES])
    {
        [self showErrorDialog:@"Error adding object. Please contact support."];
    }
	
	[[self window] orderOut:nil];
    [NSApp endSheet:[self window]];
}

- (IBAction)cancel:(id)sender
{
	[[self window] orderOut:nil];
    [NSApp endSheet:[self window]];
}


- (IBAction)selectBackupSource:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setTitle:@"Select backups location"];
	
	// Get the return value
	NSInteger returnValue = [openPanel runModal]; 
	if(returnValue == NSOKButton)
	{
		// Make sure the user selected something
		NSArray *urls = [openPanel URLs];
		if ([urls count] > 0)
		{
            NSString *folder = [[urls objectAtIndex:0] path];
            // Only need the folder to display
            [sourceTextField setStringValue:[folder lastPathComponent]];
            
            // Set the tooltip as the full path
            [sourceTextField setToolTip:folder];
		}
	}
}

- (IBAction)selectArchiveDestination:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanCreateDirectories:YES];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setTitle:@"Create a folder to store archives"];

	// If I've set the archive directory once, use it
	// Otherwise base off of the Backup Source
	if ([[destinationTextField stringValue] length] > 0)
	{
		[openPanel setDirectory: [destinationTextField toolTip]];
	}
	else
	{
		// The tooltip contains the full path, use it as the source
		// Set the initial directory to be the parent directory of the backup destination
		NSString *sourceFolder = [sourceTextField toolTip];
		[openPanel setDirectory: [sourceFolder stringByDeletingLastPathComponent]];
	}

	// Get the return value
	NSInteger returnValue = [openPanel runModal]; 
	if(returnValue == NSOKButton)
	{
		// Make sure the user selected something
		NSArray *urls = [openPanel URLs];
		if ([urls count] > 0)
		{
            NSString *folder = [[urls objectAtIndex:0] path];
            // Only need the folder to display
            [destinationTextField setStringValue: [folder lastPathComponent]];
            
            // Set the tooltip as the full path
            [destinationTextField setToolTip:folder];
			
		}
	}    
}

- (void)showErrorDialog: (NSString *) errorText
{
	NSAlert *errorAlert = [[NSAlert alloc] init];
    NSString *iconPath = [[NSBundle bundleForClass:[self class]] 
                          pathForResource:@"BackupMinder" ofType:@"icns"];
    NSImage *image = [[[NSImage alloc] initWithContentsOfFile:iconPath] 
                      autorelease];
    [errorAlert setIcon:image];
    [errorAlert addButtonWithTitle:@"OK"];
    [errorAlert setAlertStyle:NSCriticalAlertStyle];
    NSArray *buttons = [errorAlert buttons];
    NSButton *okButton = [buttons objectAtIndex:0];
    [okButton setKeyEquivalent:@""];
    [okButton setKeyEquivalent:@"\r"];
	
	[errorAlert setMessageText:@"Error in Entries"];
	[errorAlert setInformativeText:errorText];
	 
	[errorAlert beginSheetModalForWindow:[self window] 
							  modalDelegate:self 
							 didEndSelector:nil 
								contextInfo:nil];
	
	[errorAlert autorelease];
	 
}

- (IBAction)openBackupMinderURL:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.watchmanmonitoring.com/backupminder"]];
}


/*

- (void)updateWizardPage
{

	// Disable the next button based on entered values
	// If there are no entered values, force the user to enter something
	switch (m_currentPage)
	{
		case 0:
			[m_nextButton setEnabled:[[m_nameTextField stringValue] length] > 0];
			break;
		case 1:
			[m_nextButton setEnabled:[[m_backupSourceTextField stringValue] length] > 0];
			break;
		case 2:
			[m_nextButton setEnabled:[[m_archiveDestinationTextField stringValue] length] > 0];
			break;
		case 3:
			[m_nextButton setEnabled:[[m_nameContainsTextField stringValue] length] > 0];
			break;
		case 4:
			[m_nextButton setEnabled:[[m_backupsToLeaveTextField stringValue] length] > 0 && 
			 [[m_warnDaysTextField stringValue] length] > 0];
			break;
		case 5:
			// Update the summary page text
			[m_summaryTextField setStringValue:
			 [NSString stringWithFormat:
				@"BackupMinder will watch the folder\n%@\n for files with the name '%@' and store them in folder\n%@",
			  [m_backupSourceTextField toolTip], 
			  [m_nameContainsTextField stringValue], 
			  [m_archiveDestinationTextField toolTip]]];
			break;
	}
	
	// Lastly, show the new page
	[m_wizardTabView selectTabViewItemAtIndex:m_currentPage];
}


#pragma mark -
#pragma mark NSTextFieldDelegate methods

- (void)controlTextDidChange:(NSNotification *)notification
{
	NSTextField *sender = [notification object];
	if (sender == nil)
	{
		return;
	}
	
	// For every page except the Number of Backups page, only the one text field needs a value
	if (m_currentPage != 4)
	{
		[m_nextButton setEnabled:[[sender stringValue] length] > 0];
	}
	// The Number of Backups page needs to make sure that both fields have text
	else
	{
		[m_nextButton setEnabled:[[m_backupsToLeaveTextField stringValue] length] > 0 && 
		 [[m_warnDaysTextField stringValue] length] > 0];
	}
}
 
 */

@end
