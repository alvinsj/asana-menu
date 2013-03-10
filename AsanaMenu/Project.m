//
//  Project.m
//  AsanaMenu
//
//  Created by alvinsj on 31/12/12.
//  Copyright (c) 2012 alvin. All rights reserved.
//

#import "Project.h"

@implementation Project
+ (NSArray *) projectsFromJSON:(id)JSON
{
    NSArray *data = [JSON objectForKey:@"data"];
    
    NSMutableArray *projects = [NSMutableArray arrayWithCapacity:[data count]];
    for (NSDictionary *item in data)
    {
        NSString *name = [item objectForKey:@"name"];
        NSNumber *id = [item objectForKey:@"id"];
                
        Project *model = [Project new];
        model.id = [id stringValue];
        model.name = name;
        
        [projects addObject:model];
    }
    
    return [NSArray arrayWithArray:projects];
}
@end
