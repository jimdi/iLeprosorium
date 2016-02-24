//
//  LepraComment.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 30.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LepraComment : NSObject

@property (strong, nonatomic) NSString *commentId;
@property (strong, nonatomic) NSArray *textObjects;
@property (strong, nonatomic) NSArray *textLinks;
@property (strong, nonatomic) NSString *rating;
@property (strong, nonatomic) NSNumber *commentOffset;

@property (strong, nonatomic) NSNumber *minusEnabled;
@property (strong, nonatomic) NSNumber *plusEnabled;

@property (strong, nonatomic) NSString *authorUserName;
@property (strong, nonatomic) NSString *authorPrefix;
@property (strong, nonatomic) NSDate *postDate;

@property (strong, nonatomic) NSNumber *isNew;

@property (strong, nonatomic) NSNumber *postAuthor;

@end
