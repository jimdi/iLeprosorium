//
//  LepraHTTPClient.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "LepraHTTPClient.h"
#import <AFJSONRequestOperation.h>

@implementation LepraHTTPClient

static LepraHTTPClient *__sharedInstance = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedClient
{
	dispatch_once(&onceToken, ^{
		__sharedInstance = [[LepraHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:API_BASE_URL]];
		[__sharedInstance registerHTTPOperationClass:[AFJSONRequestOperation class]];
		[__sharedInstance setDefaultHeader:@"Accept" value:@"application/json"];
		[__sharedInstance setDefaultHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
		
//		[__sharedInstance updateTokenHeader];
	});
	return __sharedInstance;
}

//- (void)updateTokenHeader
//{
//	NSString *userToken = DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN);
//	
//	if (userToken) {
//		[self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"OAuth %@", userToken]];
//		[[SDWebImageDownloader sharedDownloader] setValue:[NSString stringWithFormat:@"OAuth %@", userToken] forHTTPHeaderField:@"Authorization"];
//	}
//	else {
//		[self removeDefaultHeader:@"Authorization"];
//	}
//}

+ (void)updateBaseURLAndSharedInstance
{
	__sharedInstance = [[LepraHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:API_BASE_URL]];
	[__sharedInstance registerHTTPOperationClass:[AFJSONRequestOperation class]];
	[__sharedInstance setDefaultHeader:@"Accept" value:@"application/json"];
	[__sharedInstance setDefaultHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
	
//	[__sharedInstance updateTokenHeader];
	
	// update MAAPIManager with the new client
	[[LepraAPIManager sharedManager] setHTTPClient:__sharedInstance];
}

@end
