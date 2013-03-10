//
//  JSONRequest.h
//  appvisor
//
//  Created by alvinsj on 20/11/12.
//  Copyright (c) 2012 starhub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


@class JSONRequest;
@protocol JSONRequestDelegate <NSObject>

- (void)jsonRequest:(JSONRequest *)request willStartRequestWithIdentifier:(NSString *)requestIdentifier;
- (void)jsonRequest:(JSONRequest *)request didFinishedRequestWithIdentifier:(NSString *)requestIdentifier;
- (void)jsonRequest:(JSONRequest *)request processResponse:(id)jsonResponse identifier:(NSString*)identifier urlResponse:(NSHTTPURLResponse *)urlResponse urlRequest:(NSURLRequest *)urlRequest;

@end

@interface JSONRequest : NSObject

@property (nonatomic, weak) id<JSONRequestDelegate> delegate;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *path;

@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) NSDictionary *headers;

@property (nonatomic, strong) NSString *requestIdentifier;
@property (nonatomic) id progressView;
@property (nonatomic, strong) NSOperationQueue *requestQueue;
@property (nonatomic) dispatch_queue_t backgroundQueue;
@property (nonatomic, strong) NSString *error;

+ (JSONRequest *) jsonRequestWithURLString:(NSString *)url parameters:(NSDictionary *)params identifier:(NSString *)requestIdentifier delegate:(id<JSONRequestDelegate>)delegate;

+ (JSONRequest *) jsonRequestWithURLPath:(NSString *)path parameters:(NSDictionary *)params identifier:(NSString *)requestIdentifier delegate:(id<JSONRequestDelegate>)delegate;

- (JSONRequest *) start;
- (JSONRequest *) startWithHttpClient:(AFHTTPClient *)client;
- (JSONRequest *)startWithHttpClient:(AFHTTPClient *)client method:(NSString *)method;

- (id)withHeaders:(NSDictionary *)headers;


@end


