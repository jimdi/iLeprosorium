//
//  LepraCommonTableViewCell.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface LepraCommonTableViewCell : SWTableViewCell

@property (nonatomic) CGFloat cellHeight;
@property (strong, nonatomic) NSIndexPath *indexPathCellIsOn;

+ (NSString *)nibName;
+ (NSString *)cellIdentifier;
+ (CGFloat)cellHeight;

- (id<UITableViewDataSource>)tableViewController;

@end
