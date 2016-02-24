//
//  LepraCommonTableViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonTableViewController.h"

@interface LepraCommonTableViewController ()

@end

@implementation LepraCommonTableViewController

- (void)dealloc
{
	[self.tableView setDataSource:nil];
	[self.tableView setDelegate:nil];
}

- (void)registerCellForId:(NSString*)reuseId
{
	[self.tableView registerNib:[UINib nibWithNibName:reuseId bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reuseId];
}

//------------------------------------------------------------------------------------------
#pragma mark - Setters

- (void)setTableView:(UITableView *)tableView
{
	_tableView = tableView;
	
	_tableView.dataSource = self;
	_tableView.delegate = self;
	
	_tableView.scrollsToTop = YES;
	for (NSLayoutConstraint *constraint in _tableView.superview.constraints) {
		if ([constraint.secondItem isKindOfClass:[UITableView class]] && constraint.secondAttribute==NSLayoutAttributeBottom) {
			self.bottomConstraintToShrinkWhenKeyboardAppears = constraint;
		}
	}
}


//------------------------------------------------------------------------------------------
#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSLog(@"%@ tableView:numberOfRowsInSection: must be reimplemented in subclasses! NOW IT RETURNES 0", self);
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"%@ tableView:cellForRowAtIndexPath: must be reimplemented in subclasses! NOW IT RETURNES NOTHING", self);
	return [[UITableViewCell alloc] init];
}

@end
