//
//  LepraPostHeaderCell.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 01.02.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraPostHeaderCell.h"

@interface LepraPostHeaderCell()

@property (strong, nonatomic) LepraPost* post;

@property (weak, nonatomic) IBOutlet UILabel *userPrefixLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftOffsetConstraint;
@property (weak, nonatomic) IBOutlet UIView *leftOffsetView;

@end

@implementation LepraPostHeaderCell

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self.leftOffsetView setBackgroundColor:[LepraGeneralHelper tableViewColor]];
}

+ (CGFloat)cellHeight
{
	return 50.0;
}


- (void)setPost:(LepraPost*)post
{
	[self setPost:post offset:@(0)];
}

- (void)setPost:(LepraPost *)post offset:(NSNumber *)offset
{
	_post = post;
	
    if (![post.authorPrefix hasPrefix:@"Написал"]) {
        [self.userPrefixLabel setText:[NSString stringWithFormat:@"Написал %@", post.authorPrefix]];
    } else {
        [self.userPrefixLabel setText:post.authorPrefix];
    }
	[self.usernameLabel setText:post.authorUserName];
	
	self.leftOffsetConstraint.constant = MIN(5, offset.integerValue) * 8;
	
	
	[self.contentView layoutIfNeeded];
}

- (void)setAuthorComment:(NSNumber*)authorComment
{
	if (authorComment.boolValue) {
		[self.usernameLabel setAttributedText:[[NSAttributedString alloc] initWithString:self.post.authorUserName attributes:@{NSFontAttributeName: self.usernameLabel.font, NSForegroundColorAttributeName: [UIColor blackColor], NSUnderlineColorAttributeName: [LepraGeneralHelper redColor], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle) }]];
	} else {
		[self.usernameLabel setText:self.post.authorUserName];
	}
}

@end
