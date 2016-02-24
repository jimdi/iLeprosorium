//
//  LepraPostUndergroundCell.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 06.06.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonTableViewCell.h"

@interface LepraPostUndergroundCell : LepraCommonTableViewCell

+ (CGFloat)cellHeightForPost:(LepraPost*)post;

- (void)setPost:(LepraPost*)post;

@end
