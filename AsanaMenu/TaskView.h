//
//  TaskView.h
//  AsanaMenu
//
//  Created by alvinsj on 31/12/12.
//  Copyright (c) 2012 alvin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TaskView : NSTableCellView

@property (nonatomic, weak) IBOutlet NSButton *checkboxView;
@property (nonatomic)  IBOutlet id viewController;
-(IBAction)checkStateChange:(id)sender;
@end
