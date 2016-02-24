//
//  LepraContainerViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "LepraContainerViewController.h"
#import "LepraMenuViewController.h"
#import "LepraLoginViewController.h"
#import "LepraNewLoginViewController.h"
#import "LepraBlancViewController.h"

#import "LepraProfileViewController.h"
#import "LepraProfilePostsViewController.h"
#import "LepraProfileCommentsViewController.h"

#import "LepraMainPagePostsViewController.h"
#import "LepraUndergroundViewController.h"
#import "LepraFavoritesViewController.h"
#import "LepraMyThingsViewController.h"
#import "LepraInboxViewController.h"
#import "LepraAboutViewController.h"
#import "LepraPrefsViewController.h"

#import "LepraSwipeViewController.h"

#import "LepraUnderground.h"

@interface LepraContainerViewController () <IIViewDeckControllerDelegate, MenuDelegate>

@property (strong, nonatomic) LepraLoginViewController *loginVC;
@property (strong, nonatomic) LepraNewLoginViewController *nLoginVC;
@property (strong, nonatomic) LepraMenuViewController *menuVC;
@property (strong, nonatomic) IIViewDeckController *viewDeck;

@property (nonatomic) CGFloat lastViewDeckOffset;
@property (nonatomic) BOOL isShowingPopover;

// view controller being added to the container directly
@property (strong, nonatomic) UIViewController *centerViewController;

- (void)switchToViewController:(UIViewController *)viewController;
- (void)switchToViewController:(UIViewController *)viewController wrapInNavigationController:(BOOL)wrap;
- (void)showMainVC;

@property (nonatomic) BOOL firstAppear;

@end

@implementation LepraContainerViewController

static LepraContainerViewController *__sharedInstance;

+ (instancetype)sharedContainer
{
	return __sharedInstance;
}

//=--------------------------------------------------------------------------------------------------
#pragma mark - UIViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	__sharedInstance = self;
	
	[self resetCenterVC];
	
	SIGNUP_FOR_NOTIFICATION(UIApplicationDidBecomeActiveNotification, @selector(handleAppBecameActive));
	
	BOOL achtung = NO;
	if (NEW_BUNDLE_VERSION_MAKES_RELOGIN) {
		if (!DEFAULTS_OBJ(DEF_KEY_BUNDLE_VERSION)) {
			achtung = YES;
		}
		else if (![DEFAULTS_OBJ(DEF_KEY_BUNDLE_VERSION) isEqualToString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]]) {
			achtung = YES;
		}
	}
	
	[DEFAULTS setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] forKey:DEF_KEY_BUNDLE_VERSION];
	[DEFAULTS synchronize];
	
	if (achtung) {
		[self performSelector:@selector(achtungStart) withObject:nil afterDelay:0.01];
	}
	else {
		[self checkToResetAndSetup:YES];
	}
}

- (void)achtungStart
{
	if (![self.presentedViewController isKindOfClass:[LepraLoginViewController class]]) {
		[self logoutAnimated:NO];
	}
}

- (void)resetCenterVC
{
	self.lastViewDeckOffset = 0;
	
	LepraBlancViewController *blancVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LepraBlancViewController"];
	self.menuVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraMenuViewController storyboardID]];
	
	[self.viewDeck viewWillDisappear:NO];
	self.viewDeck = nil;
	
	self.viewDeck = [[IIViewDeckController alloc] initWithCenterViewController:blancVC leftViewController:self.menuVC];
	self.viewDeck.panningMode = IIViewDeckDelegatePanning;
	self.viewDeck.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
	
	self.viewDeck.leftSize = self.view.frame.size.width-300.;
	[self.viewDeck setDelegate:self];
	self.menuVC.menuDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self checkForPushNotification];
}

- (void)handleAppBecameActive
{
	[self checkForPushNotification];
	[self checkToResetAndSetup:NO];
}

- (void)checkToResetAndSetup:(BOOL)resetIfEverythingIsFine
{
	if ([LepraGeneralHelper userIsAuthorized]) {
		if (resetIfEverythingIsFine) {
			[self showMainVC];
		}
	}
	else {
		if (![self.presentedViewController isKindOfClass:[LepraLoginViewController class]]) {
			[self logoutAnimated:NO];
		}
	}
}

- (void)logoutAnimated:(BOOL)animated
{
	[[LepraAPIManager sharedManager] logout];
	
	// show authorization
	__weak LepraContainerViewController *weakSelf = self;
	
	self.loginVC = nil;
	self.loginVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraLoginViewController storyboardID]];
	
	self.nLoginVC = nil;
	self.nLoginVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraNewLoginViewController storyboardID]];
	
	self.nLoginVC.completionBlock = ^void(BOOL loggedIn) {
		
		if (loggedIn) {
			[weakSelf showMainVC];
			[weakSelf dismissViewControllerAnimated:YES completion:^{
				//				[weakSelf.viewDeck previewBounceView:IIViewDeckLeftSide toDistance:80.0 duration:1.75 callDelegate:NO completion:nil];
			}];
		}
		else {
			[[[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Не удалось авторизоваться" delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles:nil] show];
		}
	};
	
	[self presentViewController:self.nLoginVC animated:animated completion:^{
		[self setNeedsStatusBarAppearanceUpdate];
		[self switchToViewController:nil wrapInNavigationController:NO];
	}];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}


//=--------------------------------------------------------------------------------------------------
#pragma mark - IIVIEWDECK DELEGATE

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated
{
	self.viewDeck.panningMode = IIViewDeckFullViewPanning;
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated
{
	self.viewDeck.panningMode = IIViewDeckDelegatePanning;
}

- (void)viewDeckController:(IIViewDeckController*)viewDeckController didChangeOffset:(CGFloat)offset orientation:(IIViewDeckOffsetOrientation)orientation panning:(BOOL)panning
{
	BOOL needsStatusBarUpdate = NO;
	if ((offset == 0) || (self.lastViewDeckOffset == 0)) {
		needsStatusBarUpdate = YES;
	}
	self.lastViewDeckOffset = offset;
	if (needsStatusBarUpdate) {
		[self setNeedsStatusBarAppearanceUpdate];
	}
}

- (BOOL)viewDeckController:(IIViewDeckController *)viewDeckController shouldPan:(UIPanGestureRecognizer *)panGestureRecognizer
{
	//disable right to left pan
	CGPoint velocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
	
	if (velocity.x <= 0)   // panning left
	{
		return NO;
	}
	
	CGPoint locationInView = [panGestureRecognizer locationInView:panGestureRecognizer.view];
	if ([self.viewDeck.centerController isKindOfClass:[LepraNavigationController class]]) {
		if ([(LepraNavigationController *)self.viewDeck.centerController viewControllers].count > 1) {
			if (locationInView.x < 50) {
				return NO;
			}
		}
	}
	return YES;
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController applyShadow:(CALayer *)shadowLayer withBounds:(CGRect)rect
{
	UIBezierPath* newShadowPath = [UIBezierPath bezierPathWithRect:rect];
	shadowLayer.masksToBounds = NO;
	shadowLayer.shadowRadius = 2;
	shadowLayer.shadowOpacity = 0.1;
	shadowLayer.shadowColor = [[UIColor blackColor] CGColor];
	shadowLayer.shadowOffset = CGSizeZero;
	shadowLayer.shadowPath = [newShadowPath CGPath];
}


//=--------------------------------------------------------------------------------------------------
#pragma mark - MenuDelegate

static NSDictionary *__controllerIds;
- (void)menuControllerPickedMenuItemKey:(NSString *)key
{
	if (!__controllerIds) {
		__controllerIds = @{kMenuItemKeyProfile : [LepraProfileViewController storyboardID],
							kMenuItemKeyMain : [LepraMainPagePostsViewController storyboardID],
							kMenuItemKeyUnderground : [LepraUndergroundViewController storyboardID],
							kMenuItemKeyFavourites : [LepraFavoritesViewController storyboardID],
							kMenuItemKeyMyThings : [LepraMyThingsViewController storyboardID],
							kMenuItemKeyInbox : [LepraInboxViewController storyboardID],
							kMenuItemKeyPrefs : [LepraPrefsViewController storyboardID],
							kMenuItemKeyAbout : [LepraAboutViewController storyboardID]};
	}
	
	// switch viewdeck's center controller to the according controller
	NSString *nextControllerID = __controllerIds[key];
	if ([key isEqualToString:kMenuItemKeyProfile]) {
		
		LepraProfileViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraProfileViewController storyboardID]];
		LepraProfilePostsViewController *profilePostsVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraProfilePostsViewController storyboardID]];
		LepraProfileCommentsViewController *profileCommentsVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraProfileCommentsViewController storyboardID]];
		
		NSArray *viewControllers = @[profileVC, profilePostsVC, profileCommentsVC];
		LepraSwipeViewController *swipeController = [[LepraSwipeViewController alloc] initWithViewControllers:viewControllers];
		LepraNavigationController *navVC = [[LepraNavigationController alloc] initWithRootViewController:swipeController];
		swipeController.title = DEFAULTS_OBJ(DEF_KEY_USER)[@"login"];
		self.viewDeck.centerController = navVC;
	} else {
		NSDictionary* favoritesUnergrounds = DEFAULTS_OBJ(DEF_KEY_MENU_UNDERGROUNDS);
		if ([favoritesUnergrounds[kUndergroundItemKeyLink] containsObject:key]) {
			LepraMainPagePostsViewController *nextCenterVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraMainPagePostsViewController storyboardID]];
			nextCenterVC.pageLink = key;
			LepraNavigationController *navVC = [[LepraNavigationController alloc] initWithRootViewController:nextCenterVC];
			
			self.viewDeck.centerController = navVC;
		} else {
			UIViewController *nextCenterVC = [self.storyboard instantiateViewControllerWithIdentifier:nextControllerID];
			LepraNavigationController *navVC = [[LepraNavigationController alloc] initWithRootViewController:nextCenterVC];
			
			self.viewDeck.centerController = navVC;
		}
	}
	
	// close viewdeck
	[self.viewDeck closeLeftViewAnimated:YES];
}


//=--------------------------------------------------------------------------------------------------
#pragma mark - Switching between controllers

- (void)switchToViewController:(UIViewController *)viewController
{
	[self switchToViewController:viewController wrapInNavigationController:NO];
}

- (void)switchToViewController:(UIViewController *)viewController wrapInNavigationController:(BOOL)wrap
{
	// check to see if we need to switch at all
	if ([self.centerViewController isKindOfClass:[UINavigationController class]]) {
		if ([(UINavigationController *)self.centerViewController topViewController] == viewController) {
			return;
		}
	}
	else if (viewController && (self.centerViewController == viewController)) {
		return;
	}
	
	
	[self.centerViewController.view removeFromSuperview];
	[self.centerViewController removeFromParentViewController];
	self.centerViewController = nil;
	
	if (viewController) {
		if (wrap) {
			
			LepraNavigationController *navigationController = [[LepraNavigationController alloc] initWithRootViewController:viewController];
			
			self.centerViewController = navigationController;
			[self addChildViewController:navigationController];
			[navigationController.view setFrame:self.view.bounds];
			[navigationController viewWillAppear:NO];
			[self.view insertSubview:navigationController.view atIndex:0];
		}
		else {
			
			self.centerViewController = viewController;
			[self addChildViewController:viewController];
			[viewController.view setFrame:self.view.bounds];
			[viewController viewWillAppear:NO];
			[self.view addSubview:viewController.view];
		}
	}
	
	[self setNeedsStatusBarAppearanceUpdate];
}

- (void)showMainVC
{
	[self resetCenterVC];
	[self switchToViewController:self.viewDeck];
	
	[self menuControllerPickedMenuItemKey:kMenuItemKeyMain];
	
	[self.menuVC refreshView];
}
//=--------------------------------------------------------------------------------------------------
#pragma mark - HUD and popover

- (void)showHud
{
	[self showHudWithTitle:nil target:nil cancelSelector:nil];
}

- (void)showHudWithTitle:(NSString*)title
{
	[self showHudWithTitle:title target:nil cancelSelector:nil];
}

- (void)showHudWithTitle:(NSString*)title inView:(UIView*)view {
	[self showHudWithTitle:title target:nil cancelSelector:nil inView:view];
}

- (void)showHudWithTitle:(NSString*)title target:(id)target cancelSelector:(SEL)cancelSel
{
	[self showHudWithTitle:title target:target cancelSelector:cancelSel inView:self.view];
}

- (void)showHudWithTitle:(NSString*)title target:(id)target cancelSelector:(SEL)cancelSel inView:(UIView*)view
{
	UIView *viewToShowHudAt = self.view;
	if (view) {
		viewToShowHudAt = view;
	}
	
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	self.currentHud = hud;
	hud.mode = MBProgressHUDModeIndeterminate;
	if (![LepraGeneralHelper isEmpty:title]) {
		hud.labelText = NSLS(@"loading");
	} else {
		hud.labelText = title;
	}
	hud.detailsLabelText = NSLS(@"cancel");
	hud.dimBackground = YES;
	
	for (UIView* view in hud.subviews) {
		if ([view isKindOfClass:[UILabel class]]) {
			if ([[(UILabel*)view text] isEqualToString:hud.detailsLabelText]) {
				[view setUserInteractionEnabled:YES];
				if (target) {
					[view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:target action:cancelSel]];
				} else {
					[view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelHud)]];
				}
				break;
			}
		}
	}
}

- (void)cancelHud
{
	//	[[MAAPIManager sharedInstance] stopLastRequest];
	[self hideHud];
}

- (void)hideHud
{
	[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)hideHudInView:(UIView*)view
{
	[MBProgressHUD hideAllHUDsForView:view animated:YES];
}

//=--------------------------------------------------------------------------------------------------
#pragma mark - Push notifications business

- (void)checkForPushNotification
{
	NSDictionary *notification = DEFAULTS_OBJ(DEF_KEY_PUSH_NOTIFICATION);
	
	if (notification) { // if we do, we should show some content and clear it
		[DEFAULTS removeObjectForKey:DEF_KEY_PUSH_NOTIFICATION];
		[DEFAULTS synchronize];
	}
}

- (void)openLink:(NSString*)link
{
//	DOInternalBowserViewController* browserVC = [self.storyboard instantiateViewControllerWithIdentifier:[DOInternalBowserViewController storyboardID]];
//	browserVC.link = link;
	
//	[self.viewDeck.centerController presentViewController:[[DONavigationViewController alloc] initWithRootViewController:browserVC] animated:YES completion:nil];
}

@end
