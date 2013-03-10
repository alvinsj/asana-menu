//
//  AsanaAPI.h
//  AsanaMenu
//
//  Created by alvinsj on 30/12/12.
//  Copyright (c) 2012 alvin. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "JSONRequest.h"
#import "Workspace.h"

typedef enum _AsanaAPIMethod {
    AsanaAPIMethodAllWorkspaces,
    AsanaAPIMethodWorkspaceProjects,
    AsanaAPIMethodWorkspaceTasks,
    AsanaAPIMethodCreateTask,
    AsanaAPIMethodMarkTaskComplete
} AsanaAPIMethod;

@interface AsanaAPI : NSObject

@property (nonatomic, strong) NSMutableArray *tasks;
@property (nonatomic, strong) NSMutableArray *workspaces;


+(AFHTTPClient *)httpClient;

+ (void)getAllWorkspacesWithDelegate:(id<JSONRequestDelegate>)jsonRequestDelegate;
+ (void)getAllTasksOfWorkspace:(Workspace *)workspace delegate:(id<JSONRequestDelegate>)jsonRequestDelegate;
+ (void)getAllProjectsOfWorkspace:(Workspace *)workspace delegate:(id<JSONRequestDelegate>)jsonRequestDelegate;
+ (void)addNewTask:(NSString *)taskName project:(NSString *)projectId workspace:(NSString *)workspaceId delegate:(id<JSONRequestDelegate>)jsonRequestDelegate;
+ (void)markCompletionOfTask:(NSString *)taskId delegate:(id<JSONRequestDelegate>)jsonRequestDelegate;

+ (NSString *)identifierForAsanaAPI:(AsanaAPIMethod)identifier;
@end
