//
//  AccountPreferencesViewController.h
//  AsanaMenu
//
//  Created by alvinsj on 11/1/13.
//  Copyright (c) 2013 alvin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AccountPreferencesViewController : NSViewController
@property (weak) IBOutlet NSTextField *apiKeyTextField;
@property (nonatomic, strong) NSString *apiKey;
@end
