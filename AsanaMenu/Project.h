//
//  Project.h
//  AsanaMenu
//
//  Created by alvinsj on 31/12/12.
//  Copyright (c) 2012 alvin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Project : NSObject

@property NSString *id;
@property NSString *name;
+ (NSArray *) projectsFromJSON:(id)JSON;
@end
