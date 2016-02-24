//
//  LepraPostRatingCell.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 24.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonTableViewCell.h"
#import "LepraPost.h"
#import "LepraComment.h"

@protocol LepraPostRatingCellDelegate <NSObject>

- (void)cellAskToVotePlusForPost:(LepraPost*)post;
- (void)cellAskToVoteMinusForPost:(LepraPost*)post;

- (void)cellAskToVotePlusForComment:(LepraComment*)comment;
- (void)cellAskToVoteMinusForComment:(LepraComment*)comment;

@end

@interface LepraPostRatingCell : LepraCommonTableViewCell

- (void)setPost:(LepraPost*)post;
- (void)setPost:(LepraPost*)post offset:(NSNumber*)offset;

@property (weak, nonatomic) id<LepraPostRatingCellDelegate> cellDelegate;

@end
