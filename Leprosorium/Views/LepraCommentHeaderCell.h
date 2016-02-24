//
//  LepraCommentHeaderCell.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 02.02.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonTableViewCell.h"
#import "LepraComment.h"


@protocol LepraCommentHeaderCellDelegate <NSObject>

- (void)cellAskForOpenProfile:(NSString*)userName;
- (void)cellAskForAnswerComment:(LepraComment*)comment;

@end

@interface LepraCommentHeaderCell : LepraCommonTableViewCell

- (void)setComment:(LepraComment *)comment;
- (void)setComment:(LepraComment*)comment withOffset:(NSNumber*)offset;
@property (weak, nonatomic) IBOutlet UIButton *answerButton;

@property (weak, nonatomic) id<LepraCommentHeaderCellDelegate> cellDelegate;

@end