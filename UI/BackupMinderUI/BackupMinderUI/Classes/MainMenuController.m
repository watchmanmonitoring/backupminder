//
//  MainMenuController.m
//  BackupMinderUI
//
//  Created by Christopher Thompson on 8/8/12.
//

#import "MainMenuController.h"
#import "Definitions.h"
#import "BackupManager.h"
#import "FileUtilities.h"

@implementation MainMenuController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    
    if (self)
    {        
        // Initialize the Add/Edit pansl
        m_addPanel = [[AddPanelController alloc] init];
        m_editPanel = [[AddPanelController alloc] initWithMode:EDIT_PANEL_MODE];
        
        // Initialize the error alert
        m_errorAlert = [[NSAlert alloc] init];
        NSString *iconPath = [[NSBundle bundleForClass:[self class]] 
                              pathForResource:@"BackupMinder" ofType:@"icns"];
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:iconPath];
        [m_errorAlert setIcon:image];
        [m_errorAlert addButtonWithTitle:@"OK"];
        [m_errorAlert setMessageText:@"Error"];
        [m_errorAlert setAlertStyle:NSCriticalAlertStyle];
        NSArray *buttons = [m_errorAlert buttons];
        NSButton *okButton = [buttons objectAtIndex:0];
        [okButton setKeyEquivalent:@""];
        [okButton setKeyEquivalent:@"\r"];
        
        // Initialize the "Are you sure?" alert
        m_removeAlert = [[NSAlert alloc] init];
        // Icon is the same
        [m_removeAlert setIcon:[[NSImage alloc] initWithContentsOfFile:iconPath]];
        [m_removeAlert addButtonWithTitle:@"Yes"];
        [m_removeAlert addButtonWithTitle:@"Cancel"];
        [m_removeAlert setMessageText:@"Are you sure?"];
        [m_removeAlert setAlertStyle:NSCriticalAlertStyle];
        [m_removeAlert setInformativeText:@"This will permenantly remove the backup "
         "from Backup Minder.  Are you sure?"];
        buttons = [m_removeAlert buttons];
        NSButton *uninstallButton = [buttons objectAtIndex:0];
        NSButton *cancelButton = [buttons objectAtIndex:1];
        [uninstallButton setKeyEquivalent:@""];
        [cancelButton setKeyEquivalent:@"\r"];
    }
    
    return self;
}

- (void)dealloc
{
    [m_addPanel release];
    [m_editPanel release];
    [m_errorAlert release];
    [m_removeAlert release];
    
    [super dealloc];   
}

- (void)setAuthorized:(BOOL)authorized_
{
    [m_addButton setEnabled:authorized_];
    [m_backupsTableView setEnabled:authorized_];
    
    //Unselect the row to disable remove/edit buttons
    [m_backupsTableView deselectAll:nil];    
}

#pragma mark -
#pragma mark Button methods

- (IBAction)addBackupObject:(id)sender_
{
    [NSApp beginSheet:[m_addPanel window] 
	   modalForWindow:[self window]
		modalDelegate:self 
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
    
    [m_backupsTableView reloadData];
}

- (IBAction)removeBackupObject:(id)sender_
{
	[m_removeAlert beginSheetModalForWindow:[self window] modalDelegate:self 
                             didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
                                contextInfo:nil];    
}

- (IBAction)editBackupObject:(id)sender_
{
    NSDictionary *backupObject = [BackupManager backupObjectAtIndex:
                                  [m_backupsTableView selectedRow]];
    
    if (backupObject == nil)
        return;
    
    [NSApp beginSheet:[m_editPanel window]
	   modalForWindow:[self window]
		modalDelegate:self
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
    
    //Set the backup dictionary information
    [m_editPanel setBackupDictionary:backupObject];
}

#pragma mark -
#pragma mark Table Data Source Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView_;
{
	return [[BackupManager backups] count];
}

- (id)tableView:(NSTableView *)tableView_ objectValueForTableColumn:
(NSTableColumn *)tableColumn_ row:(NSInteger)row_;
{
    if (tableColumn_ == nil)
    {
        return nil;
    }
    
    NSDictionary *backup = [[BackupManager backups] objectAtIndex:row_];
    
    if ([[[tableColumn_ headerCell] stringValue] compare:kColumnEnabled] == 
        NSOrderedSame)
    {
        return [NSNumber numberWithBool:
                ! [[backup objectForKey:kDisabled] boolValue]];
    }
    else
    {
        return [[backup objectForKey: kLabel] substringFromIndex: 
                [kLaunchDaemonPrefix length]];
    }
}

- (void)tableView:(NSTableView *)tableView_ setObjectValue:(id)object_ 
   forTableColumn:(NSTableColumn *)tableColumn_ row:(NSInteger)row_
{
    if (tableColumn_ == nil)
    {
        return;
    }
    
    if ([[[tableColumn_ headerCell] stringValue] compare:kColumnEnabled] == 
        NSOrderedSame)
    {
        //Get Dictionary
		NSMutableDictionary *backup = 
        [[BackupManager backups] objectAtIndex:row_];
        
		if (backup == nil)
		{
#ifdef DEBUG
            NSLog (@"AppDelegate::setObjectValue: backup object is nil");
#endif //DEBUG
            [m_errorAlert setInformativeText:@"Cannot modify the backup."];
            [m_errorAlert runModal];
			return;
		}
        
        [backup setObject:[NSNumber numberWithBool:! [object_ boolValue]] 
                   forKey:kDisabled];
        
        if (! [BackupManager editBackupObject:backup])
        {
            [m_errorAlert setMessageText:@"Error"];
            [m_errorAlert setInformativeText:[BackupManager lastError]];
            [m_errorAlert runModal];
        }
        
        [m_backupsTableView reloadData];
    }    
}

#pragma mark -
#pragma mark Table Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification_;
{
    NSInteger index = [m_backupsTableView selectedRow];
    
    // If nothing is selected, disable the Edit and Remove buttons,
    // clear the text fields, and bail
    if (index < 0)
    {
        [m_removeButton setEnabled:NO];
        [m_editButton setEnabled:NO];
        
        [m_nameTextField setStringValue:@""];
        [m_backupSourceTextField setStringValue:@""];
        [m_archiveDestinationTextField setStringValue:@""];
        [m_nameContainsTextField setStringValue:@""];
        [m_backupsToLeaveTextField setStringValue:@""];
        [m_warnDaysTextField setStringValue:@""];
        return;
    }
    
    // Otherwise, enable the Edit and Remove buttons
    [m_removeButton setEnabled:YES];
    [m_editButton setEnabled:YES];
    
    // Get the associated backup object
    NSDictionary *backupObject = [BackupManager backupObjectAtIndex:index];
    
    if (backupObject == nil)
    {
#ifdef DEBUG
        NSLog (@"AppDelegate::tableViewSelectionDidChange: object is nil");
#endif //DEBUG
        [m_errorAlert setInformativeText:@"There does not appear to be a backup"
         " associated with your selection"];
        [m_errorAlert runModal];
        return;
    }    
    
    [m_nameTextField setStringValue:[[backupObject objectForKey: kLabel] 
                                     substringFromIndex: [kLaunchDaemonPrefix length]]];
    
    NSArray *arguments = [backupObject objectForKey:kProgramArguments];
    
    if (arguments == nil)
    {
#ifdef DEBUG
        NSLog (@"AppDelegate::tableViewSelectionDidChange: arguments is nil");
#endif //DEBUG
        [m_errorAlert setInformativeText:@"The backup object does not appear to"
         " contain the proper arguments"];
        [m_errorAlert runModal];
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
                [m_backupSourceTextField setStringValue:
                 [arguments objectAtIndex: i + 1]];
            }
        }
        else if ([[arguments objectAtIndex:i] isEqual:kArchiveDestination])
        {
            if (i + 1 < [arguments count])
            {
                [m_archiveDestinationTextField setStringValue:
                 [arguments objectAtIndex: i + 1]];
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

- (NSCell *)tableView:(NSTableView *)tableView_ 
dataCellForTableColumn:(NSTableColumn *)tableColumn_ row:(NSInteger)row_
{
    if (tableColumn_ == nil)
    {
        return nil;
    }
    
    if ([[[tableColumn_ headerCell] stringValue] compare:kColumnEnabled] == 
        NSOrderedSame)
	{
        NSButtonCell *cell = [[NSButtonCell new] autorelease];
        [cell setTitle:@""];
        [cell setButtonType:NSSwitchButton];
        [cell setImagePosition:NSImageOverlaps];
        [cell setImageScaling:NSImageScaleProportionallyDown];
        [cell setTarget:self];
        return cell;
    }
    
    return [NSTextFieldCell new];
}

#pragma mark -
#pragma mark NSAlert Delegate Methods

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode 
        contextInfo:(void *)contextInfo;
{
    // The "Are you sure?" alert
    if (alert == m_removeAlert && returnCode == NSAlertFirstButtonReturn)
	{
        NSDictionary *backupObject = [BackupManager backupObjectAtIndex:
                                      [m_backupsTableView selectedRow]];
        
        if (backupObject == nil)
        {
#ifdef DEBUG
            NSLog (@"AppDelegate::removeBackupObject: Cannot remove nil object");
#endif //DEBUG   
            return;
        }
        
        if (! [BackupManager removeBackupObject:backupObject])
        {
#ifdef DEBUG
            NSLog (@"AppDelegate::removeBackupObject: Error deleting object");
#endif //DEBUG
            [m_errorAlert setInformativeText:[BackupManager lastError]];
            [m_errorAlert runModal];
            return;
        }
        
        [m_backupsTableView reloadData];
    }
}

#pragma mark -
#pragma mark Sheet Delegate Methods

- (void)sheetDidEnd:(NSWindow *)sheet_ returnCode:(NSInteger)returnCode_
        contextInfo:(void *)contextInfo_
{
    [m_backupsTableView reloadData];
}

@end
