//
//  AppDelegate.m
//  BackupMinderUI
//
//  Created by Christopher Thompson on 7/31/12.
//

#import "AppDelegate.h"
#import "BackupManager.h"
#import "Definitions.h"
#import "AddPanelController.h"
#import "FileUtilities.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Query to initialize
    [BackupManager backups];
    
    // Setup security.
	AuthorizationItem items = {kAuthorizationRightExecute, 0, NULL, 0};
	AuthorizationRights rights = {1, &items};
	[m_authView setAuthorizationRights:&rights];
	[m_authView setDelegate:self];
	[m_authView updateStatus:nil];
    
    // Initialize the Add/Edit pansl
    m_addPanel = [[AddPanelController alloc] init];
    m_editPanel = [[AddPanelController alloc] initWithMode:EDIT_PANEL_MODE];
    
    // Initialize the map between the argument name and the textField it will
    // be displayed in
    m_textFieldsMap = [[NSDictionary alloc] initWithObjectsAndKeys:
                     m_backupSourceTextField, kBackupSource,
                     m_archiveDestinationTextField,kArchiveDestination,  
                     m_nameContainsTextField, kNameContains, 
                     m_backupsToLeaveTextField, kBackupsToLeave, 
                     m_warnDaysTextField, kWarnDays, nil];
    
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

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender_
{
    // We want to close the program when the user exits the main window
    return YES;
}

- (void)dealloc
{
    [m_addPanel release];
    [m_editPanel release];
    [m_textFieldsMap release];
    [m_errorAlert release];
    [m_removeAlert release];
    
    [super dealloc];   
}

- (IBAction)addBackupObject:(id)sender_
{
    [NSApp runModalForWindow:[m_addPanel window]];
    [[m_addPanel window] orderOut: self];
    
    [m_backupsTableView reloadData];
}

- (IBAction)removeBackupObject:(id)sender_
{
	[m_removeAlert beginSheetModalForWindow:m_window modalDelegate:self 
                     didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
                        contextInfo:nil];    
}

- (IBAction)editBackupObject:(id)sender_
{
    NSDictionary *backupObject = [BackupManager backupObjectAtIndex:
                                  [m_backupsTableView selectedRow]];
    
    if (backupObject == nil)
        return;

    [m_editPanel setBackupDictionary:backupObject];
    [NSApp runModalForWindow:[m_editPanel window]]; 
    [[m_editPanel window] orderOut: self];
    
    [m_backupsTableView reloadData];
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
    return [[[[BackupManager backups] objectAtIndex:row_] objectForKey: kLabel] 
                                            substringFromIndex: 
                                            [kLaunchDaemonPrefix length]];
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
        [m_errorAlert setInformativeText:@"There does not appear to be a backup "
            "associated with your selection"];
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
        [m_errorAlert setInformativeText:@"The backup object does not appear to "
            "contain the proper arguments"];
        [m_errorAlert runModal];
        return;
    }
    
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
    
    // If the disabled flag is true, we set enabled to Off
    [m_enabledSegmentControl setSelectedSegment:
        [[backupObject objectForKey:kDisabled] boolValue] ? 0 : 1];
}

#pragma mark -
#pragma mark SFAuthorizationView Methods

- (void)authorizationViewDidAuthorize:(SFAuthorizationView *)view
{
    [m_addButton setEnabled:YES];
    [m_backupsTableView setEnabled:YES];
    
    [FileUtilities setAuthorizationRef:
        [[m_authView authorization] authorizationRef]];
}

- (void)authorizationViewDidDeauthorize:(SFAuthorizationView *)view
{
    //Unselect the row to disable remove/edit buttons
    [m_backupsTableView deselectAll:nil];
    
    [m_addButton setEnabled:NO];
    [m_backupsTableView setEnabled:NO];
    
    [FileUtilities setAuthorizationRef:nil];
}

#pragma mark -
#pragma mark NSAlert Delegate Methods

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode 
        contextInfo:(void *)contextInfo;
{
    // THe "Are you sure?" alert
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

@end
