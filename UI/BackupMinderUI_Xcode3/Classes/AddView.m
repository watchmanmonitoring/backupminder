//
//  AddView.m
//  BackupMinderUI
//
//  Created by Matt Butch on 7/5/15.
//

#import "AddView.h"


@implementation AddView

@synthesize  previousView, nextView, viewID;

- (void)awakeFromNib
{
    [self setWantsLayer:YES];
    [previousButton setEnabled:(previousView != nil)];
    //[nextButton setEnabled:(nextView != nil)];
	[nextButton setEnabled:NO];
}

@end
