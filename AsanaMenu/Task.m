//
//  Task.m
//  AsanaMenu
//
//  Created by alvinsj on 31/12/12.
//  Copyright (c) 2012 alvin. All rights reserved.
//

#import "Task.h"

@implementation Task

+ (NSArray *) tasksFromJSON:(id)JSON
{
    NSArray *data = [JSON objectForKey:@"data"];
    
    NSMutableArray *tasks = [NSMutableArray arrayWithCapacity:[data count]];
    for (NSDictionary *item in data)
    {
        NSString *name = [item objectForKey:@"name"];
        NSNumber *id = [item objectForKey:@"id"];
        NSNumber *completed = [item objectForKey:@"completed"];
        if([completed boolValue])
            continue;
        
        NSString *projectId;
        // FIXME: allow multiple projects
        if([[item objectForKey:@"projects"] count] >0)
            projectId = [[[[item objectForKey:@"projects"] objectAtIndex:0] objectForKey:@"id"] stringValue];

        
        Task *model = [Task new];
        model.id = [id stringValue];
        model.name = name;
        model.projectId = projectId;
        
        
        [tasks addObject:model];
    }
    
    return [NSArray arrayWithArray:tasks];
}

+ (Task *) taskFromJSON:(id)JSON
{
    NSDictionary *item = [JSON objectForKey:@"data"];

    NSString *name = [item objectForKey:@"name"];
    NSNumber *id = [item objectForKey:@"id"];
    
    NSString *projectId;
    // FIXME: allow multiple projects
    if([[item objectForKey:@"projects"] count] >0)
        projectId = [[[[item objectForKey:@"projects"] objectAtIndex:0] objectForKey:@"id"] stringValue];
    
    Task *model = [Task new];
    model.id = [id stringValue];
    model.name = name;
    model.projectId = projectId;
    
    return model;
}

@end
