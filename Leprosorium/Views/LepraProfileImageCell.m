//
//  LepraProfileImageCell.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 12.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraProfileImageCell.h"
#import <UIImageView+UIActivityIndicatorForSDWebImage.h>

@interface LepraProfileImageCell()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *gifLabel;

@property (strong, nonatomic) NSURL* imageUrl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftOffsetConstraint;
@property (weak, nonatomic) IBOutlet UIView *leftOffsetView;

@end

@implementation LepraProfileImageCell

- (UIEdgeInsets)layoutMargins
{
	return UIEdgeInsetsMake(0, 5000, 0, 0);
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self.gifLabel.layer setCornerRadius:10.0];
	[self.profileImageView setUserInteractionEnabled:YES];
	[self.profileImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap)]];
	[self.leftOffsetView setBackgroundColor:[LepraGeneralHelper tableViewColor]];
}

+ (CGFloat)cellHeightForImageUrl:(NSURL *)imageURL
{
	return [self cellHeightForImageUrl:imageURL offset:@(0)];
}

+ (CGFloat)cellHeightForImageUrl:(NSURL *)imageURL offset:(NSNumber *)offset
{
	if (![DEFAULTS_OBJ(DEF_KEY_PREFS_LOAD_IMAGE) boolValue]) {
		return 60.0;
	}
	UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageURL.absoluteString];
	if (image) {
		CGFloat cellWidth = [UIScreen mainScreen].bounds.size.width - 16.0;
		cellWidth -= MIN(5, offset.integerValue) * 8;
		
		CGFloat delta = image.size.width / cellWidth;
		if (delta>1.0) {
			return (image.size.height / delta) + 10.0;
		}
		return image.size.height + 10.0;
	} else {
		return 110.0;
	}
}

- (void)setImageUrl:(NSURL *)imageURL
{
	[self setImageUrl:imageURL offset:@(0)];
}

- (void)setImageUrl:(NSURL *)imageURL offset:(NSNumber *)offset
{
	_imageUrl = imageURL;
	if (![DEFAULTS_OBJ(DEF_KEY_PREFS_LOAD_IMAGE) boolValue]) {
		[self.profileImageView setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"disabled_image"] withColor:[LepraGeneralHelper blueColor]]];
	} else {
		[self.profileImageView setImageWithURL:imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
				if (image.images.count>0) {
					[self.gifLabel setHidden:NO];
					[self.profileImageView setAlpha:0.4];
					[self.profileImageView setImage:[image.images firstObject]];
				} else {
					[self.gifLabel setHidden:YES];
					[self.profileImageView setAlpha:1.0];
				}
				
				if (!image) {
					[self.profileImageView setImage:[UIImage imageNamed:@"error"]];
				}
				if (cacheType == SDImageCacheTypeNone && image) {
					[self.cellDelegate imageLoadedForCell:self withImageUrl:self.imageUrl];
				}
		} usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	}
	self.leftOffsetConstraint.constant = (MIN(5, offset.integerValue) * 8);
	[self.contentView layoutIfNeeded];
	
	[self setSeparatorInset:UIEdgeInsetsMake(0, 5000, 0, 0)];
}

- (void)imageTap
{
    if (!self.gifLabel.hidden) {
        [self.profileImageView setImageWithURL:self.imageUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [self.gifLabel setHidden:YES];
            [self.profileImageView setAlpha:1.0];
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    } else {
        if ([LepraGeneralHelper isEmpty:self.tapLink]) {
            NSArray *galleryData = @[[[MHGalleryItem alloc] initWithURL:self.imageUrl.absoluteString galleryType:MHGalleryTypeImage]];
            
            MHGalleryController *gallery = [MHGalleryController galleryWithPresentationStyle:MHGalleryViewModeImageViewerNavigationBarShown];
            gallery.galleryItems = galleryData;
            gallery.presentingFromImageView = self.profileImageView;
            gallery.UICustomization.showOverView = NO;
            gallery.presentationIndex = 0;
            gallery.transitionCustomization.dismissWithScrollGestureOnFirstAndLastImage = NO;
            __weak MHGalleryController *blockGallery = gallery;
            
            gallery.finishedCallback = ^(NSUInteger currentIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveTransition, MHGalleryViewMode viewMode){
                
                [blockGallery dismissViewControllerAnimated:YES dismissImageView:nil completion:^{
                }];
            };
            [self.cellDelegate cellAskForOpenGallery:gallery];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.tapLink]];
        }
    }
}

@end
