//
//  Workspace.m
//  AsanaMenu
//
//  Created by alvinsj on 31/12/12.
//  Copyright (c) 2012 alvin. All rights reserved.
//

#import "Workspace.h"

@implementation Workspace

+ (NSArray *) workspacesFromJSON:(id)JSON
{
    NSArray *data = [JSON objectForKey:@"data"];
    
    NSMutableArray *workspaces = [NSMutableArray arrayWithCapacity:[data count]];
    for (NSDictionary *workspace in data)
    {
        NSString *name = [workspace objectForKey:@"name"];
        NSNumber *id = [workspace objectForKey:@"id"];
        
        Workspace *model = [Workspace new];
        model.id = [id stringValue];
        model.name = name;
        
        [workspaces addObject:model];
    }
    
    return [NSArray arrayWithArray:workspaces];
}

@end
