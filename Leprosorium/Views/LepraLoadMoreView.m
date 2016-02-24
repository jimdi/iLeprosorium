//
//  LepraLoadMoreView.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 24.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraLoadMoreView.h"

@interface LepraLoadMoreView()

@property (weak, nonatomic) IBOutlet UILabel *allLoadedLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end

@implementation LepraLoadMoreView

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self setBackgroundColor:[LepraGeneralHelper tableViewColor]];
}

- (void)startLoad
{
	[self.loadingIndicator startAnimating];
	[self.allLoadedLabel setHidden:YES];
}
- (void)stopLoad
{
	[self.loadingIndicator stopAnimating];
	[self.allLoadedLabel setHidden:YES];
}
- (void)allLoaded
{
	[self.loadingIndicator stopAnimating];
	[self.allLoadedLabel setHidden:NO];
}

@end
