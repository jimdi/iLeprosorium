//
//  LepraBlancViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "LepraBlancViewController.h"

@interface LepraBlancViewController ()

@end

@implementation LepraBlancViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = NSLS(@"under_construction");
	[self configureNavigationBarWithColor:[UIColor blackColor]];
	
	[self addMenuButton];
}

@end
