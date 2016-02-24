//
//  LepraPrefsToggleCell.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 03.02.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraPrefsToggleCell.h"

@interface LepraPrefsToggleCell()

@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation LepraPrefsToggleCell

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self setBackgroundColor:[UIColor whiteColor]];
}

- (void)setOn:(BOOL)on text:(NSString*)text
{
	UIImage *image = on? [UIImage imageNamed:@"checked"] : [UIImage imageNamed:@"unchecked"];
	
	[self.checkImageView setImage:[LepraGeneralHelper tintImage:image withColor:[[LepraGeneralHelper redColor] colorWithAlphaComponent:0.5]]];
	[self.titleLabel setText:text];
	[self.titleLabel setTextColor:[UIColor darkGrayColor]];
}

@end
