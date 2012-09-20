//
//  AddPanelController.m
//  BackupMinderUI
//
//  Created by Christopher Thompson on 8/1/12.
//

#import "AddPanelController.h"
#import "Definitions.h"
#import "BackupManager.h"

const int MAX_BACKUPS_TO_LEAVE = 99;
const int MAX_WARN_DAYS_VALUE = 99;

@implementation AddPanelController

- (id) init
{
    return [self initWithMode:ADD_PANEL_MODE];
}

- (id)initWithMode:(enum panelMode_t)mode_
{
    if (! (self = [super initWithWindowNibName: @"AddPanel"]))
    {
#ifdef DEBUG
        NSLog (@"AddPanelController::initWithMode: Failed to init "
               "AddPanel.xib");
#endif // DEBUG
        return nil; 
    }
    
    // Store the panelMode_t
    m_panelMode = mode_;
        
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    // If I'm going to be an Edit panel, change the text of the Add/Edit button
    if (m_panelMode == EDIT_PANEL_MODE)
    {
        [m_nameTextField setEditable:NO];
        [m_addButton setTitle:@"Save"];
        [[self window] setTitle:@"Edit Backup"];
    }
    
    [m_nameTextField setHidden:m_panelMode == EDIT_PANEL_MODE];
    [m_nameLabel setHidden:m_panelMode == ADD_PANEL_MODE];
    
    [m_backupSourceTextField setEditable:NO];
    [m_archiveDestinationTextField setEditable:NO];
    
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
    
    // Call the cancel function to set the default values
    [self cancel:nil];
}

- (void)dealloc
{
    [m_errorAlert release];
    
    [super dealloc];   
}

- (void)setBackupDictionary:(NSMutableDictionary*)backupObject_
{    
    if (backupObject_ == nil)
    {
#ifdef DEBUG
        NSLog (@"AddPanelController::setBackupDictionary: object is nil");
#endif //DEBUG
        return;
    }
    
    [m_nameLabel setStringValue:[[backupObject_ objectForKey: kLabel] 
                                     substringFromIndex: 
                                 [kLaunchDaemonPrefix length]]];
    
    NSArray *arguments = [backupObject_ objectForKey:kProgramArguments];
    
    if (arguments == nil)
    {
#ifdef DEBUG
        NSLog (@"AppDelegate::windowDidBecomeMain: arguments is nil");
#endif //DEBUG
        return;
    }
    
    // Iterate through the arguements
    // When I match a key, the next argument should be the value
    // But check out-of-bounds just in case
    for (int i = 0; i < [arguments count]; ++i)
    {
        if ([[arguments objectAtIndex:i] isEqual:kBackupSource])
        {
            if (i + 1 < [arguments count])
            {
                NSString *folder = [arguments objectAtIndex: i + 1];
                // Only need the folder to display
                [m_backupSourceTextField setStringValue:
                    [folder lastPathComponent]];
                
                // Set the tooltip as the full path
                [m_backupSourceTextField setToolTip:folder];
            }
        }
        else if ([[arguments objectAtIndex:i] isEqual:kArchiveDestination])
        {
            if (i + 1 < [arguments count])
            {
                NSString *folder = [arguments objectAtIndex: i + 1];
                // Only need the folder to display
                [m_archiveDestinationTextField setStringValue:
                 [folder lastPathComponent]];
                
                // Set the tooltip as the full path
                [m_archiveDestinationTextField setToolTip:folder];
            }
        }
        else if ([[arguments objectAtIndex:i] isEqual:kNameContains])
        {
            if (i + 1 < [arguments count])
            {
                [m_nameContainsTextField setStringValue:
                 [arguments objectAtIndex: i + 1]];
            }
        }
        else if ([[arguments objectAtIndex:i] isEqual:kBackupsToLeave])
        {
            if (i + 1 < [arguments count])
            {
                [m_backupsToLeaveTextField setStringValue:
                 [arguments objectAtIndex: i + 1]];
            }
        }
        else if ([[arguments objectAtIndex:i] isEqual:kWarnDays])
        {
            if (i + 1 < [arguments count])
            {
                [m_warnDaysTextField setStringValue:
                 [arguments objectAtIndex: i + 1]];
            }
        }
    }
}

- (BOOL)validateInput
{
    BOOL good = YES;
    NSString *errors = [[NSString new] autorelease];
    
    // If I'm adding, make sure I add a unique name
    NSString *name = [m_nameTextField stringValue];
    if (m_panelMode == ADD_PANEL_MODE)
    {
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

- (IBAction)commit:(id)sender_
{
    if (! [self validateInput])
    {
#ifdef DEBUG
        NSLog (@"AddPanelController::commit: Failed to validate inputs");
#endif // DEBUG
        return;
    }
    
    NSString *name;
    if (m_panelMode == ADD_PANEL_MODE)
    {
        name = [m_nameTextField stringValue];
    }
    else
    {
        name = [m_nameLabel stringValue];        
    }    
    
    // Create the arguments array first
    NSArray *arguments = [NSArray arrayWithObjects:
                          kBackupMinderCommand,
                          kBackupSource,
                          [m_backupSourceTextField toolTip],
                          kArchiveDestination,
                          [m_archiveDestinationTextField toolTip],
                          kName,
                          name,
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
    NSString *label;
    
    if (m_panelMode == ADD_PANEL_MODE)
    {
        label = [NSString stringWithFormat:@"%@%@", 
                       kLaunchDaemonPrefix, [m_nameTextField stringValue]];
    }
    else
    {
        label = [NSString stringWithFormat:@"%@%@", 
                 kLaunchDaemonPrefix, [m_nameLabel stringValue]];

    }
    
    NSMutableDictionary *backupObject = 
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    label, kLabel,
                    [NSNumber numberWithBool:0], kDisabled,
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
    
    BOOL good = YES;
    if (m_panelMode == ADD_PANEL_MODE)
    {
        good = [BackupManager addBackupObject:backupObject loadDaemon:YES];
    }
    else if (m_panelMode == EDIT_PANEL_MODE)
    {
        good = [BackupManager editBackupObject:backupObject];
    }
    
    if (! good)
    {
        [m_errorAlert setMessageText:@"Error"];
        [m_errorAlert setInformativeText:[BackupManager lastError]];
        
        [m_errorAlert beginSheetModalForWindow:[self window] 
                                 modalDelegate:self 
                                didEndSelector:nil 
                                   contextInfo:nil];
        return;
    }

    [[self window] orderOut:nil];
    [NSApp endSheet:[self window]];
}

- (IBAction)cancel:(id)sender_
{
    // Clear the textFields
    [m_nameTextField setStringValue:@""];
    [m_backupSourceTextField setStringValue:@""];  
    [m_archiveDestinationTextField setStringValue:@""];
    [m_nameContainsTextField setStringValue:@""];
    [m_backupsToLeaveTextField setStringValue:kBackupsToLeaveDefault];
    [m_warnDaysTextField setStringValue:kWarnDaysDefault];
    
    [[self window] orderOut:nil];
    [NSApp endSheet:[self window]];
}

- (IBAction)selectBackupSource:(id)sender_
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setAllowsMultipleSelection:NO];
    // The tooltip contains the full path, use it as the source
	[openPanel setDirectory: [m_backupSourceTextField toolTip]];
	
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
		}
	}
}

- (IBAction)selectArchiveDestination:(id)sender_
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setAllowsMultipleSelection:NO];
    // The tooltip contains the full path, use it as the source
	[openPanel setDirectory: [m_archiveDestinationTextField toolTip]];
	
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
		}
	}    
}

@end
