//
//  AppDelegate.h
//  AsanaMenu
//
//  Created by alvinsj on 30/12/12.
//  Copyright (c) 2012 alvin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MenubarController.h"
#import "PanelController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, strong, readonly) PanelController *panelController;

- (IBAction)saveAction:(id)sender;
- (IBAction)togglePanel:(id)sender;


@end
