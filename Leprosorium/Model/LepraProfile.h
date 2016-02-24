//
//  LepraProfile.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 31.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LepraProfile : NSObject

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userpicLink;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *invitedBy;
@property (strong, nonatomic) NSString *carma;

@property (strong, nonatomic) NSString *posts;

@property (strong, nonatomic) NSMutableArray *contactsTypes;
@property (strong, nonatomic) NSMutableArray *contactsValues;

@property (strong, nonatomic) NSMutableArray *userTextObjects;
@property (strong, nonatomic) NSMutableArray *userTextLinks;

@property (strong, nonatomic) NSNumber *leftPlusEnabled;
@property (strong, nonatomic) NSNumber *rightPlusEnabled;
@property (strong, nonatomic) NSNumber *leftMinusEnabled;
@property (strong, nonatomic) NSNumber *rightMinusEnabled;

@end
