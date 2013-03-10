//
//  AccountPreferencesViewController.m
//  AsanaMenu
//
//  Created by alvinsj on 11/1/13.
//  Copyright (c) 2013 alvin. All rights reserved.
//

#import "AccountPreferencesViewController.h"

@interface AccountPreferencesViewController ()

@end

@implementation AccountPreferencesViewController

- (void)awakeFromNib
{
    [super awakeFromNib];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs synchronize];
    NSString *apiKey = [prefs stringForKey:@"apiKey"];
    if(apiKey){
        self.apiKey = apiKey;
        [self.apiKeyTextField setStringValue:apiKey];
    }

}

-(NSString *)identifier{
    return @"Account";
}

-(NSImage *)toolbarItemImage{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

-(NSString *)toolbarItemLabel{
    return @"Account";
}

- (void)setApiKey:(NSString *)apiKey
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs synchronize];
    [prefs setObject:apiKey forKey:@"apiKey"];
    [prefs synchronize];
}

@end
