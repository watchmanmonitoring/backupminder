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
    
    [NSBundle loadNibNamed:@"AddPanel" owner:self];
    
    panelMode = mode_;
    
    // If I'm going to be an Edit panel, change the text of the Add/Edit button
    if (panelMode == EDIT_PANEL_MODE)
    {
        [addButton setTitle:@"Edit"];
    }
    
    return self;
}

- (BOOL)validateInput
{
    BOOL good = YES;
    NSString *errors = [NSString new];
    
    // Ensure backupSource exists
    NSString *path = [backupSourceTextField stringValue];
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
    path = [archiveDestinationTextField stringValue];
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
    int backups = [backupsToLeaveTextField intValue];
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
    int days = [warnDaysTextField intValue];
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
        NSAlert *alert = [[NSAlert alloc] init];
        //TODO: Fil in the icon later
		//NSString *iconPath = [[NSBundle bundleForClass:[self class]] 
        //                      pathForResource:@"BackupMinder" ofType:@"icns"];
		//NSImage *image = [[NSImage alloc] initWithContentsOfFile:iconPath];
		//[alert setIcon:image];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Invalid Inputs"];
		[alert setAlertStyle:NSCriticalAlertStyle];
		[alert setInformativeText:[NSString stringWithFormat:
                                @"Failed to validate input with the following "
                                                      " errors:\n%@", errors]];
		[errors release];
		NSArray *buttons = [alert buttons];
		NSButton *okButton = [buttons objectAtIndex:0];
		[okButton setKeyEquivalent:@""];
		[okButton setKeyEquivalent:@"\r"];
		[alert beginSheetModalForWindow:[self window] modalDelegate:self 
                         didEndSelector:nil contextInfo:nil];
		return NO;
    }
           
    return YES;
}

- (IBAction)commit:(id)sender_
{
    if (! [self validateInput])
    {
#ifdef DEBUG
        NSLog (@"AddPanelController::add: Failed to validate inputs");
#endif // DEBUG
        return;
    }
    
    NSDictionary *backupObject = [NSDictionary dictionaryWithObjectsAndKeys:
                    [nameTextField stringValue], kBackupName,
                    [backupSourceTextField stringValue], kBackupSource,
                    [archiveDestinationTextField stringValue], kArchiveDestination,
                    [nameContainsTextField stringValue], kNameContains,
                    [NSNumber numberWithInt:[backupsToLeaveTextField intValue]], kBackupsToLeave,
                    [NSNumber numberWithInt:[warnDaysTextField intValue]], kWarnDays, 
                    nil];
    
    if (! backupObject)
    {
#ifdef DEBUG
        NSLog (@"AddPanelController::add: Failed to create backupObject");
#endif // DEBUG
        return;
    }
    
    BOOL good = true;
    if (panelMode == ADD_PANEL_MODE)
        good = [BackupManager addBackupObject:backupObject];
    else if (panelMode == EDIT_PANEL_MODE)
        good = [BackupManager editBackupObject:backupObject];
    
    if (! good)
    {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        //TODO: Fil in the icon later
        //NSString *iconPath = [[NSBundle bundleForClass:[self class]] 
        //                      pathForResource:@"BackupMinder" ofType:@"icns"];
        //NSImage *image = [[NSImage alloc] initWithContentsOfFile:iconPath];
        //[alert setIcon:image];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Method Failed"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setInformativeText:@"Oops, something went wrong"];
        
        // setup buttons
        NSArray *buttons = [alert buttons];
        NSButton *okButton = [buttons objectAtIndex:0];
        [okButton setKeyEquivalent:@""];
        [okButton setKeyEquivalent:@"\r"];
        [alert beginSheetModalForWindow:[self window] modalDelegate:self 
                         didEndSelector:nil contextInfo:nil];
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
    [nameTextField setStringValue:[backupObject_ objectForKey:
                                   kBackupName]];
    
    [backupSourceTextField setStringValue:[backupObject_ objectForKey:
                                           kBackupSource]];
    
    [archiveDestinationTextField setStringValue:[backupObject_ objectForKey:
                                                 kArchiveDestination]];
    
    [nameContainsTextField setStringValue:[backupObject_ objectForKey:
                                           kNameContains]];
    
    [backupsToLeaveTextField setStringValue:[backupObject_ objectForKey:
                                             kBackupsToLeave]];
    
    [warnDaysTextField setStringValue:[backupObject_ objectForKey:
                                       kWarnDays]];
}

- (IBAction)selectBackupSource:(id)sender_
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	[panel setAllowsMultipleSelection:NO];
	[panel setDirectory: [backupSourceTextField stringValue]];
	
	// Get the return value
	NSInteger returnValue = [panel runModal]; 
	if(returnValue == NSOKButton)
	{
		// Make sure the user selected something
		NSArray *urls = [panel URLs];
		if ([urls count] > 0)
		{
            [backupSourceTextField setStringValue:
                                    [[urls objectAtIndex:0] path]];
		}
	}
}

- (IBAction)selectArchiveDestination:(id)sender_
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	[panel setAllowsMultipleSelection:NO];
	[panel setDirectory: [archiveDestinationTextField stringValue]];
	
	// Get the return value
	NSInteger returnValue = [panel runModal]; 
	if(returnValue == NSOKButton)
	{
		// Make sure the user selected something
		NSArray *urls = [panel URLs];
		if ([urls count] > 0)
		{
            [archiveDestinationTextField setStringValue:
                [[urls objectAtIndex:0] path]];
		}
	}    
}

@end
