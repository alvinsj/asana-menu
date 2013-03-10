//
//  ClickableTextView.m
//  AsanaMenu
//
//  Created by alvinsj on 8/1/13.
//  Copyright (c) 2013 alvin. All rights reserved.
//

#import "ClickableTextView.h"
#import "PanelController.h"
@implementation ClickableTextView

- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    PanelController *panel = [[self window] windowController];
    [panel refresh:self];
}

@end
