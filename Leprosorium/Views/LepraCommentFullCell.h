//
//  LepraCommentFullCell.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 25.07.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonTableViewCell.h"

@protocol LepraCommentFullCellDelegate

- (void)cellAskForOpenProfile:(NSString*)userName;

@end

@interface LepraCommentFullCell : LepraCommonTableViewCell

@property (strong, nonatomic) LepraComment* comment;

@property (strong, nonatomic) LepraPost* post;

+ (CGFloat)heightForComment:(LepraComment*)post withWidth:(CGFloat)width;

@property (weak, nonatomic) id <LepraCommentFullCellDelegate> cellDelegate;

@property (weak, nonatomic) UIViewController *parentVC;
@end
