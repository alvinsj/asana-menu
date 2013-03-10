//
//  AsanaAPI.m
//  AsanaMenu
//
//  Created by alvinsj on 30/12/12.
//  Copyright (c) 2012 alvin. All rights reserved.
//

#import "AsanaAPI.h"
#import "Workspace.h"
#import "Task.h"
#import "Project.h"

@implementation AsanaAPI

+(AFHTTPClient *)httpClient
{
    static dispatch_once_t pred;
    static AFHTTPClient *client = nil;
    
    dispatch_once(&pred, ^{
        client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://app.asana.com"]];
        [client clearAuthorizationHeader];
        
        [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [client setDefaultHeader:@"Content-Type" value:@"application/json"];
        [client setParameterEncoding:AFJSONParameterEncoding];
        
    });
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs synchronize];
    NSString *apiKey = [prefs stringForKey:@"apiKey"];
    [client setAuthorizationHeaderWithUsername:[NSString stringWithFormat:@"%@", apiKey] password:@""];
    return client;
}

+ (void)getAllWorkspacesWithDelegate:(id<JSONRequestDelegate>)jsonRequestDelegate
{
    NSString *identifier = [AsanaAPI identifierForAsanaAPI:AsanaAPIMethodAllWorkspaces];
    
    [[JSONRequest jsonRequestWithURLPath:@"api/1.0/workspaces" parameters:nil identifier:identifier delegate:jsonRequestDelegate] startWithHttpClient:[AsanaAPI httpClient]];
}

+ (void)getAllTasksOfWorkspace:(Workspace *)workspace delegate:(id<JSONRequestDelegate>)jsonRequestDelegate
{
    NSString *path = [NSString stringWithFormat:@"api/1.0/workspaces/%@/tasks?assignee=me&completed=false&opt_fields=projects,name,completed", workspace.id];
    NSString *identifier = [AsanaAPI identifierForAsanaAPI:AsanaAPIMethodWorkspaceTasks];
    
    [[JSONRequest jsonRequestWithURLPath:path parameters:nil identifier:identifier delegate:jsonRequestDelegate] startWithHttpClient:[AsanaAPI httpClient]];
}

+ (void)getAllProjectsOfWorkspace:(Workspace *)workspace delegate:(id<JSONRequestDelegate>)jsonRequestDelegate
{
    NSString *path = [NSString stringWithFormat:@"api/1.0/workspaces/%@/projects?archived=false", workspace.id];
    NSString *identifier = [AsanaAPI identifierForAsanaAPI:AsanaAPIMethodWorkspaceProjects];
    
    [[JSONRequest jsonRequestWithURLPath:path parameters:nil identifier:identifier delegate:jsonRequestDelegate] startWithHttpClient:[AsanaAPI httpClient]];
}

+ (NSString *)identifierForAsanaAPI:(AsanaAPIMethod)identifier
{
    switch (identifier) {
        case AsanaAPIMethodAllWorkspaces:
            return @"workspaces";
            break;
        case AsanaAPIMethodWorkspaceProjects:
            return @"workspace:projects";
            break;
        case AsanaAPIMethodCreateTask:
            return @"workspace:tasks:create";
            break;
        case AsanaAPIMethodMarkTaskComplete:
            return @"workspace:tasks:complete";
            break;
        case AsanaAPIMethodWorkspaceTasks:
            return @"workspace:tasks";
            break;
        default:
            return @"unknown";
    }
}

+ (void)addNewTask:(NSString *)taskName project:(NSString *)projectId workspace:(NSString *)workspaceId delegate:(id<JSONRequestDelegate>)jsonRequestDelegate
{
    NSString *path = [NSString stringWithFormat:@"api/1.0/tasks", nil];
    NSDictionary *params = @{ @"data": @{@"assignee": @"me", @"name": taskName, @"projects": @[projectId], @"workspace": workspaceId }};
    NSString *identifier = [AsanaAPI identifierForAsanaAPI:AsanaAPIMethodCreateTask];
    [[JSONRequest jsonRequestWithURLPath:path parameters:params identifier:identifier delegate:jsonRequestDelegate] startWithHttpClient:[AsanaAPI httpClient] method:@"POST"];
}

+ (void)markCompletionOfTask:(NSString *)taskId delegate:(id<JSONRequestDelegate>)jsonRequestDelegate
{
    NSString *path = [NSString stringWithFormat:@"api/1.0/tasks/%@", taskId];
    NSDictionary *params = @{ @"data": @{@"completed": @YES }};
    NSString *identifier = [AsanaAPI identifierForAsanaAPI:AsanaAPIMethodMarkTaskComplete];
    [[JSONRequest jsonRequestWithURLPath:path parameters:params identifier:identifier delegate:jsonRequestDelegate] startWithHttpClient:[AsanaAPI httpClient] method:@"PUT"];
}

@end
