//
//  LepraPostUndergroundCell.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 06.06.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraPostUndergroundCell.h"

@interface LepraPostUndergroundCell()

@property (weak, nonatomic) IBOutlet UILabel *undergroundNameLabel;

@end

@implementation LepraPostUndergroundCell

+ (CGFloat)cellHeightForPost:(LepraPost*)post
{
	if ([LepraGeneralHelper isEmpty:post.undergroundLink]) {
		return 0.0;
	} else {
		return 35.0;
	}
}

- (void)setPost:(LepraPost*)post
{
	[self.undergroundNameLabel setText:post.undergroundLink];
}

@end
