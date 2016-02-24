//
//  LepraLoginViewController.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonTableViewController.h"

@interface LepraLoginViewController : LepraCommonTableViewController

@property (nonatomic, copy) void(^completionBlock) (BOOL loggedIn);

@end
