//
//  AddPanelController.m
//  BackupMinderUI
//
//  Created by Christopher Thompson on 8/1/12.
//

#import "AddPanelController.h"
#import "Definitions.h"
#import "BackupManager.h"


@implementation AddPanelController

- (id) init
{
    if (! (self = [super initWithWindowNibName: @"AddPanel"]))
    {
#ifdef DEBUG
        NSLog (@"AddPanelController::initWithMode: Failed to init "
               "AddPanel.xib");
#endif // DEBUG
        return nil; 
    }
	        
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Initialize the error alert
    m_errorAlert = [[NSAlert alloc] init];
    NSString *iconPath = [[NSBundle bundleForClass:[self class]] 
                          pathForResource:@"BackupMinder" ofType:@"icns"];
    NSImage *image = [[[NSImage alloc] initWithContentsOfFile:iconPath] 
                      autorelease];
    [m_errorAlert setIcon:image];
    [m_errorAlert addButtonWithTitle:@"OK"];
    [m_errorAlert setAlertStyle:NSCriticalAlertStyle];
    NSArray *buttons = [m_errorAlert buttons];
    NSButton *okButton = [buttons objectAtIndex:0];
    [okButton setKeyEquivalent:@""];
    [okButton setKeyEquivalent:@"\r"];
    
    // Update the button images to be a document
    [m_backupSourceButton setImage:
     [[NSWorkspace sharedWorkspace] iconForFileType:
      NSFileTypeForHFSTypeCode (kOpenFolderIcon)]];
    [m_archiveDestinationButton setImage:
     [[NSWorkspace sharedWorkspace] iconForFileType:
      NSFileTypeForHFSTypeCode (kOpenFolderIcon)]];
	
	// Format the Watchman Monitoring link text	
	NSDictionary *urlTextDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
									   [NSParagraphStyle defaultParagraphStyle], NSParagraphStyleAttributeName,
									   [NSColor blueColor], NSForegroundColorAttributeName,
									   [NSNumber numberWithBool:TRUE], NSUnderlineStyleAttributeName,
									   [NSFont fontWithName:@"Arial" size:13], NSFontAttributeName, nil];
	
	[m_wmUrlButton setAttributedTitle:[[[NSMutableAttributedString alloc] initWithString:[m_wmUrlButton title]
																		  attributes:urlTextDictionary] autorelease]];
    
    // Call the cancel function to set the default values
    [self cancel:nil];
	
	m_currentPage = 0;
	[self updateWizardPage];
}

- (void)dealloc
{
    [m_errorAlert release];
    
    [super dealloc];   
}

- (BOOL)validateInput
{
    BOOL good = YES;
    NSString *errors = [[NSString new] autorelease];
    
    // If I'm adding, make sure I add a unique name
    NSString *name = [m_nameTextField stringValue];

	if ([BackupManager backupObjectForName:name] != nil)
	{
#ifdef DEBUG
		NSLog (@"AddPanelController::validateInput: %@ is not a unique "
			   "name", name);
#endif // DEBUG
		errors = [NSString stringWithFormat:@"%@\n %@ is not a unique "
					"name", errors, name];
		good = NO;
	}
    
    // Ensure backupSource exists
    NSString *path = [m_backupSourceTextField toolTip];
    if (! [[NSFileManager defaultManager] fileExistsAtPath:path])
    {
#ifdef DEBUG
        NSLog (@"AddPanelController::validateInput: %@ does not exist, "
               "cannot set to BackupSource", path);
#endif // DEBUG
        errors = [NSString stringWithFormat:@"%@\n\n %@ does not exist, cannot "
                  "set to Backup Source", errors, path];
        good = NO;
    }
    
    // Ensure archiveDestination exists
    path = [m_archiveDestinationTextField toolTip];
    if (! [[NSFileManager defaultManager] fileExistsAtPath: path])
    {
#ifdef DEBUG
        NSLog (@"AddPanelController::validateInput: %@ does not exist, "
               "cannot set to ArchiveDestination", path);
#endif // DEBUG
        errors = [NSString stringWithFormat:@"%@\n\n %@ does not exist, cannot "
                  "set to Archive Destination", errors, path];
        good = NO;
    }
    
    // Ensure I can write to the destination directory
    if (! [[NSFileManager defaultManager] isWritableFileAtPath:path])
    {
#ifdef DEBUG
        NSLog (@"AddPanelController::validateInput: Cannot write to %@", path);
#endif // DEBUG
        errors = [NSString stringWithFormat:@"%@\n\n Cannot write to %@, cannot "
                  "set to Archive Destination.", errors, path];
        good = NO;    
    }
    
    // Ensure number of backups is a valid int
    int backups = [m_backupsToLeaveTextField intValue];
    if (backups <= 0 || backups > MAX_BACKUPS_TO_LEAVE)
    {
#ifdef DEBUG
        NSLog (@"AddPanelController::validateInput: Invalid number of backups "
               "to leave: %d", backups);
#endif // DEBUG
        errors = [NSString stringWithFormat:@"%@\n\n %d is an invalid number of "
                  "Backups to Leave.  Must be between 1 and %d", 
                  errors, backups, MAX_BACKUPS_TO_LEAVE];
        good = NO;
    }
    
    // Ensure warn days is a valid int
    int days = [m_warnDaysTextField intValue];
    if (days <= 0 || days > MAX_WARN_DAYS_VALUE)
    {
#ifdef DEBUG
        NSLog (@"AddPanelController::validateInput: Invalid number of warn "
               "days: %d", days);
#endif // DEBUG
        errors = [NSString stringWithFormat:@"%@\n\n %d is an invalid number of "
                  "Warning days. Must be between 1 and %d", 
                  errors, days, MAX_WARN_DAYS_VALUE];
        good = NO;
    }
    
    if (! good)
    {
        [m_errorAlert setMessageText:@"Invalid Inputs"];
        [m_errorAlert setInformativeText:[NSString stringWithFormat:
                                @"Failed to validate input with the following "
                                                      " errors:\n%@", errors]];
        
        [m_errorAlert beginSheetModalForWindow:[self window] 
                                 modalDelegate:self 
                                didEndSelector:nil 
                                   contextInfo:nil];
		return NO;
    }
           
    return YES;
}

#pragma mark -
#pragma mark Button methods

- (IBAction)backwards:(id)sender_
{
	if (m_currentPage == 0)
	{
		return;
	}
	
	m_currentPage--;
	
	[self updateWizardPage];
}

- (IBAction)commit:(id)sender_
{
    if (! [self validateInput])
    {
#ifdef DEBUG
        NSLog (@"AddPanelController::commit: Failed to validate inputs");
#endif // DEBUG
        return;
    }
    
    // Create the arguments array first
    NSArray *arguments = [NSArray arrayWithObjects:
                          kBackupMinderCommand,
                          kBackupSource,
                          [m_backupSourceTextField toolTip],
                          kArchiveDestination,
                          [m_archiveDestinationTextField toolTip],
                          kName,
                          [m_nameTextField stringValue],
                          kNameContains,
                          [m_nameContainsTextField stringValue],
                          kBackupsToLeave,
                          [m_backupsToLeaveTextField stringValue],
                           kWarnDays,
                          [m_warnDaysTextField stringValue], nil];
    
    // Create an array for the WatchPath
    NSArray *watchPaths = [NSArray arrayWithObjects: 
                           [m_backupSourceTextField toolTip], nil];
    
    // Create the backupObject
    NSString *label = [NSString stringWithFormat:@"%@%@", 
                       kLaunchDaemonPrefix, [m_nameTextField stringValue]];
    
    NSMutableDictionary *backupObject = 
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    label, kLabel,
                    [NSNumber numberWithBool:NO], kDisabled,
                                  arguments, kProgramArguments,
                                  watchPaths, kWatchPath,
                    nil];
    
    if (! backupObject)
    {
#ifdef DEBUG
        NSLog (@"AddPanelController::commit: Failed to create backupObject");
#endif // DEBUG
        return;
    }

    if (! [BackupManager addBackupObject:backupObject loadDaemon:YES])
    {
        [m_errorAlert setMessageText:@"Error"];
        [m_errorAlert setInformativeText:[BackupManager lastError]];
        
        [m_errorAlert beginSheetModalForWindow:[self window] 
                                 modalDelegate:self 
                                didEndSelector:nil 
                                   contextInfo:nil];
        return;
    }
	
	// Clear the selection so the next time we appear we won't have any data
	[self clearSelection];
	
    [[self window] orderOut:nil];
    [NSApp endSheet:[self window]];
}

- (IBAction)cancel:(id)sender_
{	
	[self clearSelection];
    
    [[self window] orderOut:nil];
    [NSApp endSheet:[self window]];
}

- (IBAction)forward:(id)sender_
{
	if (m_currentPage == ([m_wizardTabView numberOfTabViewItems] - 1))
	{
		return;
	}
	
	// Check the name before continuing
	if (m_currentPage == 0)
	{
		NSString *name = [m_nameTextField stringValue];
		
		if ([BackupManager backupObjectForName: name]!= nil)
		{
#ifdef DEBUG
			NSLog (@"AddPanelController::forward: Duplicate name: %@", name);
#endif // DEBUG
			
			[m_errorAlert setMessageText:@"Duplicate Name"];
			[m_errorAlert setInformativeText:[NSString stringWithFormat:
											  @"A BackupSet with the name %@ already exists.  "
											  "Please choose a unique name.", name]];
			
			[m_errorAlert beginSheetModalForWindow:[self window] 
									 modalDelegate:self 
									didEndSelector:nil 
									   contextInfo:nil];
			
			return;
		}
	}
	
	m_currentPage++;
	
	[self updateWizardPage];
}

- (IBAction)selectBackupSource:(id)sender_
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setAllowsMultipleSelection:NO];
	
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
            [m_backupSourceTextField setStringValue:[folder lastPathComponent]];
            
            // Set the tooltip as the full path
            [m_backupSourceTextField setToolTip:folder];
			
			// Enabled the next button since the controlTextDidChange
			// notification will not be sent
			[m_nextButton setEnabled:YES];
		}
	}
}

- (IBAction)selectArchiveDestination:(id)sender_
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanCreateDirectories:YES];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setTitle:@"Create a folder to store Archives"];
	
	// If I've set the archive directory once, use it
	// Otherwise base off of the Backup Source
	if ([[m_archiveDestinationTextField stringValue] length] > 0)
	{
		[openPanel setDirectory: [m_archiveDestinationTextField toolTip]];
	}
	else
	{
		// The tooltip contains the full path, use it as the source
		// Set the initial directory to be the parent directory of the backup destination
		NSString *sourceFolder = [m_backupSourceTextField toolTip];
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
            [m_archiveDestinationTextField setStringValue:
                [folder lastPathComponent]];
            
            // Set the tooltip as the full path
            [m_archiveDestinationTextField setToolTip:folder];
			
			// Enabled the next button since the controlTextDidChange
			// notification will not be sent
			[m_nextButton setEnabled:YES];
		}
	}    
}


- (IBAction)wmUrlButtonClicked:(id)sender_
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.watchmanmonitoring.com/backupminder"]];
}

- (void)clearSelection
{	
    // Clear the textFields
    [m_nameTextField setStringValue:@""];
    [m_backupSourceTextField setStringValue:@""];  
	[m_backupSourceTextField setToolTip:@""];
    [m_archiveDestinationTextField setStringValue:@""];
	[m_archiveDestinationButton setToolTip:@""];
    [m_nameContainsTextField setStringValue:@""];
    [m_backupsToLeaveTextField setStringValue:kBackupsToLeaveDefault];
    [m_warnDaysTextField setStringValue:kWarnDaysDefault];
	
	m_currentPage = 0;
	[self updateWizardPage];
}

- (void)updateWizardPage
{
	// If the current page is the first page, disable the Back button
	[m_backButton setEnabled:m_currentPage != 0];
	
	// If the current page is the last page, show the Add button and hide the Next button
	[m_addButton setHidden:m_currentPage != ([m_wizardTabView numberOfTabViewItems] - 1)];
	[m_nextButton setHidden:m_currentPage == ([m_wizardTabView numberOfTabViewItems] - 1)];
	
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

@end
