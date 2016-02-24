//
//  LepraContainerViewController.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonViewController.h"
#import "LepraNavigationController.h"
#import <IIViewDeckController.h>
#import <MBProgressHUD.h>

@interface LepraContainerViewController : LepraCommonViewController

@property (weak, nonatomic) MBProgressHUD *currentHud;

+ (instancetype)sharedContainer;
- (void)logoutAnimated:(BOOL)animated;

- (void)openLink:(NSString*)link;

//=--------------------------------------------------------------------------------------------------
#pragma mark - HUD and popover

- (void)showHud;
- (void)showHudWithTitle:(NSString*)title;
- (void)showHudWithTitle:(NSString*)title inView:(UIView*)view;
- (void)showHudWithTitle:(NSString*)title target:(id)target cancelSelector:(SEL)cancelSel;
- (void)showHudWithTitle:(NSString*)title target:(id)target cancelSelector:(SEL)cancelSel inView:(UIView*)view;
- (void)hideHud;
- (void)hideHudInView:(UIView*)view;

@end
