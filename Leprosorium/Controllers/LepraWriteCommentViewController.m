//
//  LepraWriteCommentViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 03.02.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraWriteCommentViewController.h"
#import <TGCameraViewController.h>
#import <TGCamera.h>

@interface LepraWriteCommentViewController () <UITextViewDelegate, TGCameraDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *placeHolderLabel;

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *mediaId;

@property (nonatomic) BOOL imageLoading;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIProgressView *photoProgressView;

@end

@implementation LepraWriteCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Новый коммент";
	
	self.bottomConstraintToShrinkWhenKeyboardAppears = self.photoButtonBottomConstraint;
	
	[self.view setBackgroundColor:[LepraGeneralHelper tableViewColor]];
	
	if (![LepraGeneralHelper isNull:self.comment]) {
		[self.inputTextView setText:[NSString stringWithFormat:@"%@, ", self.comment.authorUserName]];
	}
	
	[self.photoImageView.layer setCornerRadius:5.0];
	self.mediaId = @"";
	
	[self.photoButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"camera"] withColor:[UIColor whiteColor]] forState:UIControlStateNormal];
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self configureNavigationBarWithColor:[LepraGeneralHelper blueColor] titleColor:[UIColor whiteColor]];
	
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Отпр." style:UIBarButtonItemStylePlain target:self action:@selector(sendComment)]];
	[self.navigationItem.rightBarButtonItem setEnabled:NO];
	[self textViewDidChange:self.inputTextView];
}


- (void)sendComment
{
	NSString* text = self.inputTextView.text;
	if (![LepraGeneralHelper isEmpty:text]) {
		if (self.inbox) {
			[[LepraAPIManager sharedManager] sendInboxCommentWithText:text forPost:self.post forComment:self.comment mediaId:self.mediaId success:^{
				POST_NOTIFICATION(NOTIFICATION_NEED_RELOAD_COMMENTS);
				[self.navigationController popViewControllerAnimated:YES];
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			}];
		} else {
			[[LepraAPIManager sharedManager] sendPostCommentWithText:text forPost:self.post forComment:self.comment mediaId:self.mediaId success:^{
				POST_NOTIFICATION(NOTIFICATION_NEED_RELOAD_COMMENTS);
				[self.navigationController popViewControllerAnimated:YES];
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			}];
		}
	}
}

- (IBAction)photoButtonTap:(id)sender
{
	[self showPhotoSelect];
}

- (void)showPhotoSelect
{
	UIImagePickerController *pickerController =
	[TGAlbum imagePickerControllerWithDelegate:self];
	
	[self presentViewController:pickerController animated:YES completion:nil];
}

//----------------------------------------------------------------------
#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	self.image = [TGAlbum imageWithMediaInfo:info];
	[self dismissViewControllerAnimated:YES completion:nil];
	
	self.imageLoading = YES;
	[self.photoButton setHidden:YES];
	[self.photoImageView setHidden:NO];
	[self.photoImageView setImage:self.image];
	[self.photoProgressView setHidden:NO];
	[self.photoProgressView setProgress:0.0];
	
	[self textViewDidChange:self.inputTextView];
	[[LepraAPIManager sharedManager] uploadPhoto:self.image progressBlock:^(long long totalBytesWritten, long long totalBytesExpectedToWrite) {
		[self.photoProgressView setProgress:(float)totalBytesWritten/(float)totalBytesExpectedToWrite];
	} success:^(NSString *mediaId) {
		self.mediaId = mediaId;
		self.imageLoading = NO;
		[self.photoProgressView setHidden:YES];
		[self textViewDidChange:self.inputTextView];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		self.imageLoading = NO;
		[self.photoProgressView setHidden:YES];
		[self.photoButton setHidden:NO];
		[self.photoImageView setHidden:YES];
		[self textViewDidChange:self.inputTextView];
	}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:YES completion:nil];
}


- (void)textViewDidChange:(UITextView *)textView
{
	[self.placeHolderLabel setHidden:![LepraGeneralHelper isEmpty:textView.text]];
	[self.navigationItem.rightBarButtonItem setEnabled:self.placeHolderLabel.hidden && !self.imageLoading];
}

@end
