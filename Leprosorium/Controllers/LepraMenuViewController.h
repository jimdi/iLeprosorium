//
//  LepraMenuViewController.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonTableViewController.h"

@protocol MenuDelegate  <NSObject>
@required
- (void)menuControllerPickedMenuItemKey:(NSString *)key;
@end

@interface LepraMenuViewController : LepraCommonTableViewController

@property (weak, nonatomic) id<MenuDelegate>menuDelegate;

- (void)refreshView;

@end
