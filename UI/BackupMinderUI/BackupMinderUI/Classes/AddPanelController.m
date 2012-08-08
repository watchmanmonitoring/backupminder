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
        NSLog (@"AddPanelController::initWithMode: Failed to init AddPanel.xib");
#endif // DEBUG
        return nil; 
    }
    
    // Store the panelMode_t
    m_panelMode = mode_;
    
    // Initialize the backupObject, even if we won't use it
    m_backupObject = [NSDictionary new];
    
    return self;
}

- (void)windowDidLoad
{
    // If I'm going to be an Edit panel, change the text of the Add/Edit button
    if (m_panelMode == EDIT_PANEL_MODE)
    {
        [m_nameTextField setEditable:NO];
        [m_addButton setTitle:@"Edit"];
        [[self window] setTitle:@"Edit Backup"];
    }
    
    // Initialize the error alert
    m_errorAlert = [[NSAlert alloc] init];
    NSString *iconPath = [[NSBundle bundleForClass:[self class]] 
                          pathForResource:@"BackupMinder" ofType:@"icns"];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:iconPath];
    [m_errorAlert setIcon:image];
    [m_errorAlert addButtonWithTitle:@"OK"];
    [m_errorAlert setAlertStyle:NSCriticalAlertStyle];
    NSArray *buttons = [m_errorAlert buttons];
    NSButton *okButton = [buttons objectAtIndex:0];
    [okButton setKeyEquivalent:@""];
    [okButton setKeyEquivalent:@"\r"];
    
    // Initialize the map between the argument name and the textField it will
    // be displayed in
    m_textFieldsMap = [[NSDictionary alloc] initWithObjectsAndKeys:
                     m_backupSourceTextField, kBackupSource,
                     m_archiveDestinationTextField,kArchiveDestination,  
                     m_nameContainsTextField, kNameContains, 
                     m_backupsToLeaveTextField, kBackupsToLeave, 
                     m_warnDaysTextField, kWarnDays, nil];
    
    [super windowDidLoad];
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
    // When the window is about to show
    // If I am in Add mode, clear the textFields
    // If I am in Edit mode, populate the textFields
    
    if (m_panelMode == ADD_PANEL_MODE)
    {
        [m_nameTextField setStringValue:@""];
        for (NSTextField *textField in [m_textFieldsMap allValues])
        {
            [textField setStringValue:@""];
        }
    }
    else if (m_panelMode == EDIT_PANEL_MODE)
    {
        [m_nameTextField setStringValue:[[m_backupObject objectForKey: kLabel] 
                                         substringFromIndex: 
                                            [kLaunchDaemonPrefix length]]];
        
        NSArray *arguments = [m_backupObject objectForKey:kProgramArguments];
        
        if (arguments == nil)
        {
#ifdef DEBUG
            NSLog (@"AppDelegate::windowDidBecomeMain: arguments is nil");
#endif //DEBUG
            return;
        }
        
        NSInteger index;
        for (int i = 0; i < [[m_textFieldsMap allKeys] count]; i++)
        {
            NSString *key = [[m_textFieldsMap allKeys] objectAtIndex:i];
            
            index = [arguments indexOfObject: key];
            if (index++ < [arguments count])
            {
                [[m_textFieldsMap objectForKey:key] setStringValue:
                 [arguments objectAtIndex:index]];
            }
        }
    }
}

- (void)dealloc
{
    [m_backupObject release];
    [m_errorAlert release];
    [m_textFieldsMap release];
    
    [super dealloc];   
}

- (BOOL)validateInput
{
    BOOL good = YES;
    NSString *errors = [NSString new];
    
    // Ensure backupSource exists
    NSString *path = [m_backupSourceTextField stringValue];
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
    path = [m_archiveDestinationTextField stringValue];
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
        [m_errorAlert runModal];
        [errors release];
		return NO;
    }
           
    return YES;
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
                          kBackupSource,
                          [m_backupSourceTextField stringValue], 
                          kArchiveDestination,
                          [m_archiveDestinationTextField stringValue], 
                          kNameContains,
                          [m_nameContainsTextField stringValue], 
                          kBackupsToLeave,
                          [m_backupsToLeaveTextField stringValue], 
                           kWarnDays, 
                          [m_warnDaysTextField stringValue], nil];
    
    // Create the backupObject
    NSString *label = [NSString stringWithFormat:@"%@%@", 
                       kLaunchDaemonPrefix,[m_nameTextField stringValue]];
    NSDictionary *backupObject = [NSDictionary dictionaryWithObjectsAndKeys:
                    label, kLabel,
                    [NSNumber numberWithBool:
                        [m_enabledSegmentControl selectedSegment] == 1], 
                            kDisabled,
                    arguments, kProgramArguments,
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
        good = [BackupManager addBackupObject:backupObject];
    }
    else if (m_panelMode == EDIT_PANEL_MODE)
    {
        good = [BackupManager editBackupObject:backupObject];
    }
    
    if (! good)
    {
        [m_errorAlert setMessageText:@"Error"];
        [m_errorAlert setInformativeText:[BackupManager lastError]];
        [m_errorAlert runModal];        
        return;
    }
    
    [NSApp stopModal];
}

- (IBAction)cancel:(id)sender_
{
    [NSApp abortModal];
}

- (void)setBackupDictionary:(NSDictionary*)backupObject_
{    
    if (backupObject_ == nil)
    {
#ifdef DEBUG
        NSLog (@"AddPanelController::setBackupDictionary: object is nil");
#endif //DEBUG
        return;
    }
    
    m_backupObject = backupObject_;
}

- (IBAction)selectBackupSource:(id)sender_
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setDirectory: [m_backupSourceTextField stringValue]];
	
	// Get the return value
	NSInteger returnValue = [openPanel runModal]; 
	if(returnValue == NSOKButton)
	{
		// Make sure the user selected something
		NSArray *urls = [openPanel URLs];
		if ([urls count] > 0)
		{
            [m_backupSourceTextField setStringValue:
                                    [[urls objectAtIndex:0] path]];
		}
	}
}

- (IBAction)selectArchiveDestination:(id)sender_
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setDirectory: [m_archiveDestinationTextField stringValue]];
	
	// Get the return value
	NSInteger returnValue = [openPanel runModal]; 
	if(returnValue == NSOKButton)
	{
		// Make sure the user selected something
		NSArray *urls = [openPanel URLs];
		if ([urls count] > 0)
		{
            [m_archiveDestinationTextField setStringValue:
                [[urls objectAtIndex:0] path]];
		}
	}    
}

@end
