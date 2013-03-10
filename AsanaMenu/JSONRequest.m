//
//  JSONRequest.m
//  ;;
//
//  Created by alvinsj on 20/11/12.
//  Copyright (c) 2012 starhub. All rights reserved.
//

#import "JSONRequest.h"

@implementation JSONRequest

+ (JSONRequest *) jsonRequestWithURLString:(NSString *)url parameters:(NSDictionary *)params identifier:(NSString *)requestIdentifier delegate:(id<JSONRequestDelegate>)delegate
{
    JSONRequest *instance = [JSONRequest new];
    instance.url = url;
    instance.params = params;
    instance.requestIdentifier = requestIdentifier;
    instance.delegate = delegate;
    instance.backgroundQueue = dispatch_queue_create("com.alvinsj.AsanaMenu", NULL);
    
    return instance;
}

+ (JSONRequest *) jsonRequestWithURLPath:(NSString *)path parameters:(NSDictionary *)params identifier:(NSString *)requestIdentifier delegate:(id<JSONRequestDelegate>)delegate
{
    JSONRequest *instance = [JSONRequest new];
    instance.path = path;
    instance.params = params;
    instance.requestIdentifier = requestIdentifier;
    instance.delegate = delegate;
    instance.backgroundQueue = dispatch_queue_create("com.alvinsj.AsanaMenu", NULL);
    
    return instance;
}

- (id)withHeaders:(NSDictionary *)headers
{
    self.headers = headers;
    return self;
}

-(JSONRequest *)start
{
    return [self startWithHttpClient:nil];
}

-(JSONRequest *)startWithHttpClient:(AFHTTPClient *)client
{
    return [self startWithHttpClient:client method:@"GET"];
}

-(JSONRequest *)startWithHttpClient:(AFHTTPClient *)client method:(NSString *)method
{
    [self.delegate jsonRequest:self willStartRequestWithIdentifier:self.requestIdentifier];
    
    // 1) Add to bottom of initWithHTML:delegate
    NSString *urlString = self.url;
    NSMutableURLRequest *request;
    
    if(client && [method isEqualToString:@"GET"])
    {
        request = [client requestWithMethod:@"GET" path:self.path parameters:nil];
    }
    else if( client && ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"]) )
    {
        NSDictionary *params = [NSDictionary dictionaryWithDictionary:self.params];
        request = [client requestWithMethod:method path:self.path parameters:params];
    }
    else
    {
        urlString =  [NSString stringWithFormat:@"%@?%@",self.url, [self stringifyDictionary:self.params] ];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        request= [[NSMutableURLRequest alloc] initWithURL:url];
    }
    
    if(self.headers)
    {
        [self.headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [request setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    __block AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

        dispatch_async(self.backgroundQueue, ^(void) {
            [self.delegate jsonRequest:self processResponse:JSON identifier:self.requestIdentifier urlResponse:response urlRequest:request];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                self.error = nil;
                [self.delegate jsonRequest:self didFinishedRequestWithIdentifier:self.requestIdentifier];
            });
        });
        
        operation = nil;

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        self.error = error.localizedDescription;
        [self.delegate jsonRequest:self didFinishedRequestWithIdentifier:self.requestIdentifier];
        
        operation = nil;
    }];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        //float read = (float)totalBytesRead;
        //float expected = (float)totalBytesExpectedToRead;
        
    }];
    [operation start];
    
    request = nil;
    
    return self;
}

- (NSOperationQueue *)requestQueue{
    static NSOperationQueue *q;
    if(q == nil)
    {
        q = [NSOperationQueue new];
        [q setMaxConcurrentOperationCount:3];
    }
    return q;
}

- (NSData*)encodeDictionary:(NSDictionary*)dictionary {
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
        NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString*)stringifyDictionary:(NSDictionary*)dictionary {
    if(!dictionary)
        return @"";
    
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
        NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    return encodedDictionary;
}

@end
