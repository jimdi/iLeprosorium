//
//  LepraPostDetailCommentsViewController.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 24.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraProfileCommentsViewController.h"

@interface LepraPostDetailCommentsViewController : LepraProfileCommentsViewController

@property (strong, nonatomic) NSString *postCommentLink;
@property (strong, nonatomic) LepraPost *post;

@end
