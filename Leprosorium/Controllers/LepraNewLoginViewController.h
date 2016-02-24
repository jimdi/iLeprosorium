//
//  LepraNewLoginViewController.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 06.06.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonViewController.h"

@interface LepraNewLoginViewController : LepraCommonViewController

@property (nonatomic, copy) void(^completionBlock) (BOOL loggedIn);

@end
