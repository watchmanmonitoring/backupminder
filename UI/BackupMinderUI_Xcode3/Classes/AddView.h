//
//  AddView.h
//  BackupMinderUI
//
//  Created by Matt Butch on 7/5/15.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>

enum addViewTypes { k_name=1, k_monitor, k_archive, k_filename, k_copies, k_summary};

@interface AddView : NSView 
{
    IBOutlet AddView *previousView;
    IBOutlet AddView *nextView;
    
    IBOutlet NSButton *nextButton;
    IBOutlet NSButton *previousButton;
	
	NSNumber *viewID;
	
}

@property(retain) AddView *previousView, *nextView;
@property(retain) NSNumber* viewID;

@end
