//
//  LepraWriteCommentViewController.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 03.02.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonViewController.h"
#import "LepraPost.h"

@interface LepraWriteCommentViewController : LepraCommonViewController

@property (nonatomic) BOOL inbox;

@property (strong, nonatomic) LepraPost* post;
@property (strong, nonatomic) LepraComment* comment;

@end
