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

@synthesize currentView, nameTextField, sourceTextField, destinationTextField, filenameTextField, daysTextField, copiesTextField;
@synthesize summaryNameTextField, summarySourceTextField, summaryDestinationTextField, summaryFilenameTextField, summaryCopiesTextField;
@synthesize urlButton, sourceFolderButton, destinationFolderButton, currentInstructionsView, instructionsText, nameViewNextButton, sourceViewNextButton, destinationViewNextButton, filenameViewNextButton, copiesViewNextButton;
@synthesize filesListTable, editBackup;

- (id) init
{
    if (! (self = [super initWithWindowNibName: @"AddPanel"]))
    {
        return nil; 
    }
	
    return self;
}

- (id) initWithBackup: (NSMutableDictionary*) backup
{
	if (backup==nil || ![self init])
	{
		return nil;
	}
	
	if ([backup objectForKey: kProgramArguments]==nil)
		return nil;		
	
	editBackup=backup;
	
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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:)  name:NSControlTextDidChangeNotification object:nameTextField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:)  name:NSControlTextDidChangeNotification object:sourceTextField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:)  name:NSControlTextDidChangeNotification object:destinationTextField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:)  name:NSControlTextDidChangeNotification object:filenameTextField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:)  name:NSControlTextDidChangeNotification object:copiesTextField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:)  name:NSControlTextDidChangeNotification object:daysTextField];
	
	[sourceFolderButton setImage: [[NSWorkspace sharedWorkspace] iconForFileType: NSFileTypeForHFSTypeCode (kOpenFolderIcon)]];
	[destinationFolderButton setImage: [[NSWorkspace sharedWorkspace] iconForFileType: NSFileTypeForHFSTypeCode (kOpenFolderIcon)]];
	
	filesList=[[NSMutableArray alloc] initWithCapacity:10];
	
	if (editBackup!=nil)
	{
		NSString *tempString;
		NSArray *argumentsArray=[editBackup objectForKey: kProgramArguments];
		
		[nameTextField setStringValue:[[editBackup objectForKey: kLabel] substringFromIndex: [kLaunchDaemonPrefix length]]];
		name=[[[[editBackup objectForKey: kLabel] substringFromIndex: [kLaunchDaemonPrefix length]] copy] retain];
				
		// Iterate through the arguements
		// When I match a key, the next argument should be the value
		// But check out-of-bounds just in case
		for (int i = 0; i < [argumentsArray count]; ++i)
		{
			if ([[argumentsArray objectAtIndex:i] isEqual:kBackupSource])
			{
				if (i + 1 < [argumentsArray count])
				{
					tempString = [argumentsArray objectAtIndex: i + 1];
					// Only need the folder to display
					[sourceTextField setStringValue:[tempString lastPathComponent]];
					[sourceTextField setToolTip:tempString];
					[sourceFolderButton setToolTip:tempString];
					source=[[tempString copy] retain];
				}
			}
			else if ([[argumentsArray objectAtIndex:i] isEqual:kArchiveDestination])
			{
				if (i + 1 < [argumentsArray count])
				{
					tempString = [argumentsArray objectAtIndex: i + 1];
					// Only need the folder to display
					[destinationTextField setStringValue:[tempString lastPathComponent]];
					[destinationTextField setToolTip:tempString];
					[destinationFolderButton setToolTip:tempString];
					destination=[[tempString copy] retain];
				}
			}
			else if ([[argumentsArray objectAtIndex:i] isEqual:kNameContains])
			{
				if (i + 1 < [argumentsArray count])
				{
					[filenameTextField setStringValue:[argumentsArray objectAtIndex: i + 1]];
					filename=[[[argumentsArray objectAtIndex: i + 1] copy] retain];
					
				}
			}
			else if ([[argumentsArray objectAtIndex:i] isEqual:kBackupsToLeave])
			{
				if (i + 1 < [argumentsArray count])
				{
					[copiesTextField setStringValue: [argumentsArray objectAtIndex: i + 1]];
					copies=[[argumentsArray objectAtIndex: i + 1] intValue];
				}
			}
			else if ([[argumentsArray objectAtIndex:i] isEqual:kWarnDays])
			{
				if (i + 1 < [argumentsArray count])
				{
					[daysTextField setStringValue: [argumentsArray objectAtIndex: i + 1]];
					days=[[argumentsArray objectAtIndex: i + 1] intValue];
				}
			}
		}
		[nameViewNextButton setEnabled:YES];
		[sourceViewNextButton setEnabled:YES];
		[destinationViewNextButton setEnabled:YES];
		[filenameViewNextButton setEnabled:YES];
	}

}

- (void)setCurrentView:(AddView*)newView
{
    if (!currentView) {
        currentView = newView;
        return;
    }
    NSView *contentView = [[self window] contentView];
	[currentView retain];
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
				if (editBackup==nil || [[[editBackup objectForKey: kLabel] substringFromIndex: [kLaunchDaemonPrefix length]] compare: nameText]!=NSOrderedSame)
				{
					[self showErrorDialog:@"BackupSet Names must be unique"];
					return;
				}
			}			
			
			NSString *tempString = [[NSString alloc] init];
			NSCharacterSet *illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@" ,/\\?%*:|\"<>"];
			NSScanner *scanner=[[NSScanner alloc] initWithString:nameText];
			
			[scanner setCharactersToBeSkipped:nil];
			
			if ([scanner scanUpToCharactersFromSet:illegalFileNameCharacters intoString:&tempString])
			{
				if (![scanner isAtEnd])
				{
					[self showErrorDialog:@"Name cannot use spaces or the following characters: , / \\ ? % * : | \" < >"];
					return;
				}
			}
			else 
			{
				[self showErrorDialog:@"Name cannot use spaces or the following characters: , / \\ ? % * | \" < > "];
				return;
			}
			[scanner release];
			[tempString release];

			scanner=[[NSScanner alloc] initWithString:nameText];
			tempString = [[NSString alloc] init];
			
			[scanner setCharactersToBeSkipped:nil];
			
			if ([scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&tempString])
			{
				if (![scanner isAtEnd])
				{
					[self showErrorDialog:@"Name cannot use spaces, tabs, or returns"];
					return;
				}
			}
			else 
			{
				[self showErrorDialog:@"Name cannot use spaces or the following characters: /\\?%*|\"<>"];
				return;
			}
			[scanner release];	

			name=[[nameText copy] retain];
			
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
			
			source=[[[sourceTextField toolTip] copy] retain];
			
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
			
			// Ensure I can write to the destination directory
//			if (! [[NSFileManager defaultManager] isWritableFileAtPath:[destinationTextField toolTip]])
//			{
//				[self showErrorDialog:@"Cannot write to destination. Please check permissions or select a different folder."];
//				return; 
//			}
			
			// Ensure source and destination aren't the same
			if ([[destinationTextField toolTip] compare:source]==NSOrderedSame)
			{
				[self showErrorDialog:@"Source and Destination directories cannot be the same. Please select a different folder."];
				return;
			}
			
			destination=[[[destinationTextField toolTip] copy] retain];
			
			[self updateFileList];
			
			break;
		}
		case k_filename:
		{
			NSString *fileNameText = [filenameTextField stringValue];
			
			//[filenameTextField resignFirstResponder];
			
			if (fileNameText==nil || [fileNameText length]==0)
			{
				[self showErrorDialog:@"Filename is empty and is a required field"];
				return;
			}
			[copiesViewNextButton setEnabled:YES];
			
			filename=[[fileNameText copy] retain];
			
			break;	
		}
		case k_copies:
		{
			NSString *copiesText = [copiesTextField stringValue];

			if (copiesText==nil || [copiesText length]==0)
			{
				[self showErrorDialog:@"Copies is empty and is a required field"];
				return;
			}
			
			int copiesInt = [copiesTextField intValue];
			if (copiesInt <= 0 || copiesInt > MAX_BACKUPS_TO_LEAVE)
			{
				[self showErrorDialog:[NSString stringWithFormat: @"Copies must be between 1 and %d", MAX_BACKUPS_TO_LEAVE]];
				return;
			}
			
			copies=copiesInt;

			[summaryNameTextField setStringValue:name];
			[summarySourceTextField setStringValue:[source lastPathComponent]];
			[summarySourceTextField setToolTip:source];
			[summaryDestinationTextField setStringValue:[destination lastPathComponent]];
			[summaryDestinationTextField setToolTip:destination];
			[summaryFilenameTextField setStringValue:filename];
			[summaryCopiesTextField setIntValue:copies];
			
			break;
		}
		default:
			break;
	}
	
    [transition setSubtype:kCATransitionFromRight];
    [self setCurrentView:[[self currentView] nextView]];
	
	switch ([[[self currentView] viewID] intValue]) 
	{
		case k_monitor:
			if (editBackup==nil && source==nil)
				[self selectBackupSource:self];
			break;
		case k_archive:
			if (editBackup==nil && destination==nil)
				[self selectArchiveDestination:self];
			break;
		case k_filename:
			[[self window] makeFirstResponder:filenameTextField];
			break;
		case k_copies:
			[[self window] makeFirstResponder:copiesTextField];
			break;
		default:
			break;
	}			
}

- (IBAction)previousView:(id)sender;
{
    if (![[self currentView] previousView]) return;
    [transition setSubtype:kCATransitionFromLeft];
    [self setCurrentView:[[self currentView] previousView]];
	
	switch ([[[self currentView] viewID] intValue]) 
	{
		case k_filename:
			[self updateFileList];
			[[self window] makeFirstResponder:filenameTextField];
			break;
		case k_copies:
			[[self window] makeFirstResponder:copiesTextField];
			break;
		default:
			break;
	}			
	
}

- (IBAction)finish:(id)sender
{
	NSString *daysText = [daysTextField stringValue];
	if (daysText==nil || [daysText length]==0)
	{
		daysText=@"7";
	}
	
	int daysInt = [daysTextField intValue];
	if (daysInt <= 0 || daysInt > MAX_WARN_DAYS_VALUE)
	{
		daysInt=7;
	}
	
	days=daysInt;
	
	// Create the arguments array first
    NSArray *arguments = [NSArray arrayWithObjects:
                          kBackupMinderCommand,
                          kBackupSource,
                          source,
                          kArchiveDestination,
                          destination,
                          kName,
                          name,
                          kNameContains,
                          filename,
                          kBackupsToLeave,
                          [NSString stringWithFormat:@"%d", copies],
						  kWarnDays,
                          [NSString stringWithFormat:@"%d", days],
						  nil];
    
    // Create an array for the WatchPath
    NSArray *watchPaths = [NSArray arrayWithObjects: 
                           source, nil];
    
    // Create the backupObject
    NSString *label = [NSString stringWithFormat:@"%@%@", 
                       kLaunchDaemonPrefix, name];
    
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
	if (editBackup==nil)
	{
		if (! [BackupManager addBackupObject:backupObject loadDaemon:YES])
		{
			[self showErrorDialog:@"Error adding object. Please contact support."];
		}
		else 
		{
			[[self window] orderOut:nil];
			[NSApp endSheet:[self window]];
		}
	}
	else
	{		
		if (! [BackupManager editBackupObject:editBackup withObject: backupObject])
		{
			[self showErrorDialog:@"Error adding object. Please contact support."];
		}
		else 
		{
			[[self window] orderOut:nil];
			[NSApp endSheet:[self window]];
		}		
	}
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
	[openPanel setPrompt:@"Select"];
	[openPanel setDirectoryURL: [NSURL fileURLWithPath :@"/"]];
//	[openPanel setMessage:@"Select the folder where repeated backup files are created"];
	[instructionsText setStringValue:@"Select the folder where repeated backup files are created"];
	[openPanel setAccessoryView:currentInstructionsView];
	
	[openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) 
		{
			if(result == NSFileHandlingPanelOKButton)
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
					
					[sourceFolderButton setToolTip:folder];
					
					source=[[folder copy] retain];
					
					[sourceViewNextButton setEnabled:YES];

				}
			}
		}];
}

- (IBAction)selectArchiveDestination:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanCreateDirectories:YES];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setTitle:@"Select a folder to store archives"];
	[openPanel setPrompt:@"Select"];
//	[openPanel setMessage:@"Select a folder to store archives"];
	[instructionsText setStringValue:@"Select a folder to store archives"];
	[openPanel setAccessoryView:currentInstructionsView];

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

	[openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) 
		{
			if(result == NSFileHandlingPanelOKButton)
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

					[destinationFolderButton setToolTip:folder];
					
					destination=[[folder copy] retain];
					
					[destinationViewNextButton setEnabled:YES];

				}
			}    
		}];
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
	
	[errorAlert setMessageText:@"Error in entry"];
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

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	return [filesList objectAtIndex:rowIndex];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if ([filesList count]<10)
		return [filesList count];
	return 10;
}

- (void)updateFileList
{
	int current=0, oldLocation=0;;
	NSFileManager *fileManager=[NSFileManager defaultManager];
	NSArray *allFiles=[fileManager contentsOfDirectoryAtPath:source error:nil];
	NSScanner *scanner;
	NSString *scanString;
	[filesList removeAllObjects];
	BOOL isDir;
	
	// If there aren't any files, no need to process
	if ([allFiles count]==0)
		return;
	
	// Process file list and remove directories
	for (current;current<[allFiles count]-1;current++)
	{
		if ([fileManager fileExistsAtPath:[source stringByAppendingPathComponent: [allFiles objectAtIndex:current]] isDirectory:&isDir] && !isDir)
		{
			scanner=[[NSScanner alloc] initWithString:[[allFiles objectAtIndex:current] lastPathComponent]];
			
			if (![[scanner string] hasPrefix:@"."])
			{
				if (filename!=nil)
				{
					oldLocation=[scanner scanLocation];
					if([scanner scanUpToString:filename intoString:&scanString])
					{
						if ([scanner scanLocation]!=[[scanner string] length])
						{
							[filesList addObject:[scanner string]];
						}
						
					}
					else 
					{
						if (oldLocation==[scanner scanLocation])
						{
							[filesList addObject:[scanner string]];
						}
					}
					
				}
				else 
				{
					[filesList addObject:[scanner string]];
				}
				
			}
			[scanner release];
		}
	}
	[filesListTable reloadData];
	
}

- (void)textDidChange:(NSNotification *)notification
{
	NSText *countText = [[notification userInfo] objectForKey:@"NSFieldEditor"];
    NSTextField *countTextField = [notification object];
	
	if ([countText string]==nil || [[countText string] isEqual:@""] || [[countText string] length]==0)
	{
		if ([countTextField isEqual:nameTextField])
			[nameViewNextButton setEnabled:NO];
		if ([countTextField isEqual:sourceTextField])
			[sourceViewNextButton setEnabled:NO];
		if ([countTextField isEqual:destinationTextField])
			[destinationViewNextButton setEnabled:NO];
		if ([countTextField isEqual:filenameTextField])
		{
			[filenameViewNextButton setEnabled:NO];
			filename=nil;
			[self updateFileList];
		}
		if ([countTextField isEqual:copiesTextField])
			[copiesViewNextButton setEnabled:NO];
		if ([countTextField isEqual:daysTextField])
			[copiesViewNextButton setEnabled:NO];
		return;
	}
	else 
	{
		if ([countTextField isEqual:nameTextField])
			[nameViewNextButton setEnabled:YES];
		if ([countTextField isEqual:sourceTextField])
			[sourceViewNextButton setEnabled:YES];
		if ([countTextField isEqual:destinationTextField])
			[destinationViewNextButton setEnabled:YES];
		if ([countTextField isEqual:filenameTextField])
			[filenameViewNextButton setEnabled:YES];
		if ([countTextField isEqual:copiesTextField])
			[copiesViewNextButton setEnabled:YES];
		if ([countTextField isEqual:daysTextField])
			[copiesViewNextButton setEnabled:YES];
	}

	
	if ([countTextField isEqual:copiesTextField] || [countTextField isEqual:daysTextField])
	{
		NSScanner *scanner;
		NSString *scanString;
		NSMutableString *returnString;
		int maxValue=1000;
		
		returnString=[[NSMutableString alloc] initWithCapacity:10];
		scanner=[[NSScanner alloc] initWithString:[countText string]];
		
		if ([countTextField isEqual:copiesTextField])
			maxValue=MAX_BACKUPS_TO_LEAVE;
		if ([countTextField isEqual:daysTextField])
			maxValue=MAX_WARN_DAYS_VALUE;
		
		do
		{
			scanString=nil;
			[scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&scanString];
			if (scanString!=nil && ![scanString isEqual:@""] && [scanString length]!=0)
				[returnString appendString:scanString];
			if (![scanner isAtEnd])
				[scanner setScanLocation:([scanner scanLocation]+1)];
		}while(![scanner isAtEnd]);
		
		if ([returnString intValue]<0)
			[returnString setString:@"0"];
		if ([returnString intValue]>maxValue)
			[returnString setString:[NSString stringWithFormat: @"%d", maxValue]];
		if ([returnString length]==0)
			[returnString setString:@"0"];
		[countTextField setStringValue:returnString];
		[returnString release];
		[scanner release];
	}
	
	if ([countTextField isEqual:filenameTextField])
	{
		filename=[filenameTextField stringValue];
		[self updateFileList];
	}
}

@end
