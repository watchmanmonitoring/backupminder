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
	[authView setAuthorizationRights:&rights];
	authView.delegate = self;
	[authView updateStatus:nil];
    
    // Initialize the Add/Edit pansl
    addPanel = [[AddPanelController alloc] init];
    editPanel = [[AddPanelController alloc] initWithMode:EDIT_PANEL_MODE];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender_
{
    // We want to close the program when the user exits the main window
    return YES;
}

- (void)dealloc
{
    [addPanel release];
    [editPanel release];
    
    [super dealloc];   
}

- (IBAction)addBackupObject:(id)sender_
{
    [NSApp runModalForWindow:[addPanel window]];
    [[addPanel window] orderOut: self];
    
    [backupsTableView reloadData];
}

- (IBAction)removeBackupObject:(id)sender_
{
    NSString *name = [window title];
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    //TODO: Fil in the icon later
	//NSString *iconPath = [[NSBundle bundleForClass:[self class]] 
    //                      pathForResource:@"MonitoringClient" ofType:@"icns"];
	//[alert setIcon:[[NSImage alloc] initWithContentsOfFile:iconPath]];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert setMessageText:[NSString stringWithFormat:@"Are you sure?", name]];
	[alert setAlertStyle:NSCriticalAlertStyle];
	[alert setInformativeText:@"This will permenantly remove the backup "
        "from Backup Minder.  Are you sure?"];
	
	// setup buttons
	NSArray *buttons = [alert buttons];
	NSButton *uninstallButton = [buttons objectAtIndex:0];
	NSButton *cancelButton = [buttons objectAtIndex:1];
	[uninstallButton setKeyEquivalent:@""];
	[cancelButton setKeyEquivalent:@"\r"];
	[alert beginSheetModalForWindow:window modalDelegate:self 
                     didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
                        contextInfo:nil];    
}

- (IBAction)editBackupObject:(id)sender_
{
    NSDictionary *backupObject = [BackupManager backupObjectAtIndex:
                                  [backupsTableView selectedRow]];
    
    if (backupObject == nil)
        return;

    [editPanel setBackupDictionary:backupObject];
    [NSApp runModalForWindow:[editPanel window]];    
    [[editPanel window] orderOut: self];
    
    [backupsTableView reloadData];
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
    return [[[BackupManager backups] objectAtIndex:row_] objectForKey:
            kBackupName];
}

#pragma mark -
#pragma mark Table Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification_;
{
    NSInteger index = [backupsTableView selectedRow];
    
    // If nothing is selected, disable the Edit and Remove buttons,
    // clear the text fields, and bail
    if (index < 0)
    {
        [removeButton setEnabled:NO];
        [editButton setEnabled:NO];
        
        [nameTextField setStringValue:@""];
        [backupSourceTextField setStringValue:@""];
        [archiveDestinationTextField setStringValue:@""];
        [nameContainsTextField setStringValue:@""];
        [backupsToLeaveTextField setStringValue:@""];
        [warnDaysTextField setStringValue:@""];
        return;    
    }
    
    // Otherwise, enable the Edit and Remove buttons
    [removeButton setEnabled:YES];
    [editButton setEnabled:YES];
    
    // Get the associated backup object
    NSDictionary *backupObject = [BackupManager backupObjectAtIndex:index];
    
    if (backupObject == nil)
    {
#ifdef DEBUG
        NSLog (@"AppDelegate::tableViewSelectionDidChange: object is nil");
#endif //DEBUG
        return;
    }    
    
    [nameTextField setStringValue:[backupObject objectForKey:
                                   kBackupName]];
    
    [backupSourceTextField setStringValue:[backupObject objectForKey:
                                           kBackupSource]];
    
    [archiveDestinationTextField setStringValue:[backupObject objectForKey:
                                                 kArchiveDestination]];
    
    [nameContainsTextField setStringValue:[backupObject objectForKey:
                                           kNameContains]];
    
    [backupsToLeaveTextField setStringValue:[backupObject objectForKey:
                                             kBackupsToLeave]];
    
    [warnDaysTextField setStringValue:[backupObject objectForKey:
                                       kWarnDays]];
}

#pragma mark -
#pragma mark SFAuthorizationView Methods

- (void)authorizationViewDidAuthorize:(SFAuthorizationView *)view
{
    [addButton setEnabled:YES];
    [backupsTableView setEnabled:YES];
    
    [FileUtilities setAuthorizationRef:
        [[authView authorization] authorizationRef]];
}

- (void)authorizationViewDidDeauthorize:(SFAuthorizationView *)view
{
    //Unselect the row to disable remove/edit buttons
    [backupsTableView deselectAll:nil];
    
    [addButton setEnabled:NO];
    [backupsTableView setEnabled:NO];
    
    [FileUtilities setAuthorizationRef:nil];
}

#pragma mark -
#pragma mark NSAlert Delegate Methods

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode 
        contextInfo:(void *)contextInfo;
{
    if (returnCode == NSAlertFirstButtonReturn)
	{
        NSDictionary *backupObject = [BackupManager backupObjectAtIndex:
                                      [backupsTableView selectedRow]];
        
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
            return;
        }
        
        [backupsTableView reloadData];
    }
}

@end
