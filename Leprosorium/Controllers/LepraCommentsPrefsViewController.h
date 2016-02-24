//
//  LepraCommentsPrefsViewController.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 15.06.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraFeedPrefsViewController.h"

@protocol LepraCommentsPrefsViewControllerDelegate <NSObject>

- (void)needReloadCommentsWithParams:(NSDictionary*)params;

@end

@interface LepraCommentsPrefsViewController : LepraFeedPrefsViewController

@property (weak, nonatomic) id <LepraCommentsPrefsViewControllerDelegate> delegate;

@end
