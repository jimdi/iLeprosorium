//
//  LepraProfileInfoCell.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 10.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraProfileInfoCell.h"

@interface LepraProfileInfoCell()

@property (weak, nonatomic) IBOutlet UIImageView *userpicImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *invitedByLabel;
@property (weak, nonatomic) IBOutlet UILabel *postsAndCommentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *carmaLabel;

@property (weak, nonatomic) IBOutlet UIButton *leftPlusButton;
@property (weak, nonatomic) IBOutlet UIButton *rightPlusButton;
@property (weak, nonatomic) IBOutlet UIButton *leftMinusButton;
@property (weak, nonatomic) IBOutlet UIButton *rightMinusButton;


@property (strong, nonatomic) LepraProfile *profile;

@property (nonatomic) CAGradientLayer *gradient;

@end

@implementation LepraProfileInfoCell

- (UIEdgeInsets)layoutMargins
{
	return UIEdgeInsetsZero;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	self.gradient.frame = self.contentView.bounds;
}


- (void)awakeFromNib
{
	[super awakeFromNib];
	[self.leftPlusButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"plus"] withColor:[LepraGeneralHelper blueColor]] forState:UIControlStateDisabled];
	[self.leftPlusButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"plus"] withColor:[[LepraGeneralHelper blueColor] colorWithAlphaComponent:0.6]] forState:UIControlStateNormal];
	
	[self.rightPlusButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"plus"] withColor:[LepraGeneralHelper blueColor]] forState:UIControlStateDisabled];
	[self.rightPlusButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"plus"] withColor:[[LepraGeneralHelper blueColor] colorWithAlphaComponent:0.6]] forState:UIControlStateNormal];
	
	[self.leftMinusButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"minus"] withColor:[LepraGeneralHelper blueColor]] forState:UIControlStateDisabled];
	[self.leftMinusButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"minus"] withColor:[[LepraGeneralHelper blueColor] colorWithAlphaComponent:0.6]] forState:UIControlStateNormal];
	
	[self.rightMinusButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"minus"] withColor:[LepraGeneralHelper blueColor]] forState:UIControlStateDisabled];
	[self.rightMinusButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"minus"] withColor:[[LepraGeneralHelper blueColor] colorWithAlphaComponent:0.6]] forState:UIControlStateNormal];
	
	self.gradient = [CAGradientLayer layer];
	self.gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.8 alpha:1.0] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
	self.gradient.locations = @[@(0.0), @(1.0)];
	[self.contentView.layer insertSublayer:self.gradient atIndex:0];
}

- (void)setProfile:(LepraProfile*)profile
{
	_profile = profile;
	[self.userpicImageView sd_setImageWithURL:[NSURL URLWithString:profile.userpicLink]];
	[self.userpicImageView setClipsToBounds:YES];
	[self.userpicImageView.layer setCornerRadius:5.0];
	[self.userpicImageView setBackgroundColor:[LepraGeneralHelper blueColor]];
	
	[self.fullNameLabel setText:profile.fullName];
	[self.locationLabel setText:profile.location];
	[self.invitedByLabel setText:[NSString stringWithFormat:@"invited by %@", [LepraGeneralHelper coalesce:profile.invitedBy with:@"/dev/null"]]];
	[self.postsAndCommentsLabel setText:profile.posts];
	
	[self.carmaLabel setText:profile.carma];
	
	
	self.leftPlusButton.hidden = [LepraGeneralHelper isNull:profile.leftPlusEnabled];
	self.leftPlusButton.enabled = !profile.leftPlusEnabled.boolValue;
	
	self.rightPlusButton.hidden = [LepraGeneralHelper isNull:profile.rightPlusEnabled];
	self.rightPlusButton.enabled = !profile.rightPlusEnabled.boolValue;
	
	
	self.leftMinusButton.hidden = [LepraGeneralHelper isNull:profile.leftMinusEnabled];
	self.leftMinusButton.enabled = !profile.leftMinusEnabled.boolValue;

	self.rightMinusButton.hidden = [LepraGeneralHelper isNull:profile.rightMinusEnabled];
	self.rightMinusButton.enabled = !profile.rightMinusEnabled.boolValue;
}

- (IBAction)leftPlusButtonTap:(id)sender
{
	[self.cellDelegate cellAskForLeftPlusForProfile:self.profile];
}

- (IBAction)rightPlusButtonTap:(id)sender
{
	[self.cellDelegate cellAskForRightPlusForProfile:self.profile];
}

- (IBAction)leftMinusButtonTap:(id)sender
{
	[self.cellDelegate cellAskForLeftMinusForProfile:self.profile];
}

- (IBAction)rightMinusButtonTap:(id)sender
{
	[self.cellDelegate cellAskForRightMinusForProfile:self.profile];
}

@end
