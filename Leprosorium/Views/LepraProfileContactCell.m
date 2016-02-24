//
//  LepraProfileContactCell.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 10.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraProfileContactCell.h"

@interface LepraProfileContactCell()

@property (weak, nonatomic) IBOutlet UILabel *contactTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactInfoLabel;

@end

@implementation LepraProfileContactCell

- (UIEdgeInsets)layoutMargins
{
	return UIEdgeInsetsZero;
}

- (void)setContactType:(NSString*)contactType contact:(TFHppleElement*)contact
{
	[self.contactTitleLabel setText:contactType];
	if ([contact isKindOfClass:[NSString class]]) {
		[self.contactInfoLabel setText:(NSString*)contact];
	} else {
		[self.contactInfoLabel setText:contact.firstTextChild.content];
	}
}
@end
