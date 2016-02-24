//
//  LepraFeedPrefsViewController.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 19.04.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LepraFeedPrefsViewControllerDelegate <NSObject>

- (void)needReloadFeed;

@end

@interface LepraFeedPrefsViewController : LepraCommonTableViewController

@property (strong, nonatomic) NSString* pageLink;
@property (weak, nonatomic) id <LepraFeedPrefsViewControllerDelegate> delegate;

@end
