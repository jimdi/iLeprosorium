//
//  LepraPostRatingCell.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 24.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraPostRatingCell.h"

@interface LepraPostRatingCell()

@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftOffsetConstraint;
@property (weak, nonatomic) IBOutlet UIView *leftOffsetView;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentsLabelHeight;
@property (weak, nonatomic) IBOutlet UILabel *unreadCommentsLabel;


@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerDateConstraint;

@property (strong, nonatomic) LepraPost *post;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSArray *pluralizedArray;
@property (strong, nonatomic) NSArray *unreadPluralizedArray;

@end

@implementation LepraPostRatingCell

+ (CGFloat)cellHeight
{
	return 45.0;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self.plusButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"plus_post"] withColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
	[self.plusButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"plus_post"] withColor:[LepraGeneralHelper redColor]] forState:UIControlStateDisabled];
	
	[self.minusButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"minus_post"] withColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
	[self.minusButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"minus_post"] withColor:[LepraGeneralHelper redColor]] forState:UIControlStateDisabled];
	
	[self.leftOffsetView setBackgroundColor:[LepraGeneralHelper tableViewColor]];
	
	self.dateFormatter = [[NSDateFormatter alloc] init];
	[self.dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"ru"]];
	[self.dateFormatter setDateFormat:@"d MMMM yyyy kk.mm"];
	
	self.pluralizedArray = @[@"комментарий", @"комментария", @"комментариев"];
	self.unreadPluralizedArray = @[@"новый комментарий", @"новых комментария", @"новых комментариев"];
}

- (void)setPost:(LepraPost *)post
{
	_post = post;
	[self setPost:post offset:@(0)];
}

- (void)setPost:(LepraPost *)post offset:(NSNumber *)offset
{
	_post = post;
	
	[self.dateLabel setText:[self.dateFormatter stringFromDate:post.postDate]];
	
	if ([post isKindOfClass:[LepraPost class]]) {
		self.centerDateConstraint.priority = 1;
		if ([LepraGeneralHelper isNull:post.commentsCount] && [LepraGeneralHelper isNull:post.commentsNewCount]) {
			[self.commentsLabel setHidden:NO];
			[self.commentsLabel setText:@"Нет комментариев"];
			[self.unreadCommentsLabel setHidden:YES];
		} else {
			if (![LepraGeneralHelper isNull:post.commentsCount]) {
				[self.commentsLabel setHidden:NO];
				[self.commentsLabel setText:[NSString stringWithFormat:@"%zd %@", post.commentsCount.integerValue, [self.pluralizedArray objectAtIndex:[LepraGeneralHelper effectiveIndexFromIndex:post.commentsCount.integerValue]]]];
			} else {
				[self.commentsLabel setHidden:YES];
			}
			
			if (![LepraGeneralHelper isNull:post.commentsNewCount]) {
				[self.unreadCommentsLabel setHidden:NO];
				[self.unreadCommentsLabel setText:[NSString stringWithFormat:@"%zd %@", post.commentsNewCount.integerValue, [self.unreadPluralizedArray objectAtIndex:[LepraGeneralHelper effectiveIndexFromIndex:post.commentsNewCount.integerValue]]]];
			} else {
				[self.unreadCommentsLabel setHidden:YES];
			}
		}
	} else {
		[self.commentsLabel setHidden:YES];
		[self.unreadCommentsLabel setHidden:YES];
		
		self.centerDateConstraint.priority = 999;
	}
	
	if (self.commentsLabel.hidden) {
		self.commentsLabelHeight.constant = 0.0;
	} else {
		self.commentsLabelHeight.constant = 12.5;
	}
	
	self.plusButton.hidden = [LepraGeneralHelper isNull:post.plusEnabled];
	self.plusButton.enabled = !post.plusEnabled.boolValue;
	
	self.minusButton.hidden = [LepraGeneralHelper isNull:post.minusEnabled];
	self.minusButton.enabled = !post.minusEnabled.boolValue;
	
	if ([post isKindOfClass:[LepraComment class]]) {
		if ([[(LepraComment*)post authorUserName] isEqualToString:DEFAULTS_OBJ(DEF_KEY_USER)]) {
			self.plusButton.hidden = YES;
			self.minusButton.hidden = YES;
		}
	}
	
	[self.ratingLabel setText:post.rating];
	self.leftOffsetConstraint.constant = MIN(5, offset.integerValue) * 8;
	
	
	[self.contentView layoutIfNeeded];
}

- (IBAction)minusButtonTap:(id)sender
{
	if ([self.post isKindOfClass:[LepraPost class]]) {
		[self.cellDelegate cellAskToVoteMinusForPost:self.post];
	} else {
		[self.cellDelegate cellAskToVoteMinusForComment:(LepraComment*)self.post];
	}
}
- (IBAction)plusButtonTap:(id)sender
{
	if ([self.post isKindOfClass:[LepraPost class]]) {
		[self.cellDelegate cellAskToVotePlusForPost:self.post];
	} else {
		[self.cellDelegate cellAskToVotePlusForComment:(LepraComment*)self.post];
	}
}

@end
