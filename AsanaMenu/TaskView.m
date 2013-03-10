//
//  TaskView.m
//  AsanaMenu
//
//  Created by alvinsj on 31/12/12.
//  Copyright (c) 2012 alvin. All rights reserved.
//

#import "TaskView.h"
#import "Task.h"
#import "PanelController.h"

@implementation TaskView


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [self.checkboxView setEnabled:YES];
    [self.checkboxView setState:NSOffState];

}

-(IBAction)checkStateChange:(id)sender
{
    if([sender state] == NSOnState){
        PanelController *panelController  = [[self window] windowController];
        [panelController markTaskAsComplete:[self.objectValue id]];
        [sender setEnabled:NO];
    }

}

@end
