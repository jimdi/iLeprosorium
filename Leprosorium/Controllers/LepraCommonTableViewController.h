//
//  LepraCommonTableViewController.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonViewController.h"

@interface LepraCommonTableViewController : LepraCommonViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)registerCellForId:(NSString*)reuseId;

@end
