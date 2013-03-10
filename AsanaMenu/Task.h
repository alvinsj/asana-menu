//
//  Task.h
//  AsanaMenu
//
//  Created by alvinsj on 31/12/12.
//  Copyright (c) 2012 alvin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject

@property NSString *id;
@property NSString *name;
@property NSString *projects;
@property NSString *projectId;

+ (NSArray *) tasksFromJSON:(id)JSON;
+ (Task *) taskFromJSON:(id)JSON;
@end
