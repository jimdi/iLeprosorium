//
//  LepraHTTPClient.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "AFHTTPClient.h"

@interface LepraHTTPClient : AFHTTPClient

+ (instancetype)sharedClient;
+ (void)updateBaseURLAndSharedInstance;

//- (void)updateTokenHeader;

@end
