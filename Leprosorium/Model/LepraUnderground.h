//
//  LepraUnderground.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 02.02.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LepraUnderground : NSObject

@property (strong, nonatomic) NSString *logoLink;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *link;
@property (strong, nonatomic) NSString *ownerTitle;
@property (strong, nonatomic) NSString *authorUserName;

@property (strong, nonatomic) NSNumber *inMain;
@property (strong, nonatomic) NSNumber *inMyThings;

@property (strong, nonatomic) NSString *domainId;
@property (strong, nonatomic) NSNumber *adult;

@end
