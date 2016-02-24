//
//  LepraPost.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 30.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LepraPost : NSObject

@property (strong, nonatomic) NSArray *textObjects;
@property (strong, nonatomic) NSArray *textLinks;
@property (strong, nonatomic) NSString *rating;
@property (strong, nonatomic) NSString *link;
@property (strong, nonatomic) NSNumber *myThings;
@property (strong, nonatomic) NSNumber *favourites;

@property (strong, nonatomic) NSNumber *minusEnabled;
@property (strong, nonatomic) NSNumber *plusEnabled;

@property (strong, nonatomic) NSString *authorUserName;
@property (strong, nonatomic) NSString *authorPrefix;
@property (strong, nonatomic) NSDate *postDate;
@property (strong, nonatomic) NSString *undergroundLink;

@property (strong, nonatomic) NSNumber *commentsCount;
@property (strong, nonatomic) NSNumber *commentsNewCount;

@property (strong, nonatomic) NSNumber *remoteId;

@end
