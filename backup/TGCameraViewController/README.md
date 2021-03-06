<p align="center">
  <img src="http://s23.postimg.org/4psw1dtyj/TGCamera_View_Controller.png" alt="TGCameraViewController" title="TGCameraViewController">
</p>

<p align="center">
  <img src="http://s8.postimg.org/7wobboss5/TGCamera_View_Controller.png" alt="TGCameraViewController" title="TGCameraViewController">
</p>

Custom camera with AVFoundation. Beautiful, light and easy to integrate with iOS projects.

[![Build Status](https://api.travis-ci.org/tdginternet/TGCameraViewController.png)](https://api.travis-ci.org/tdginternet/TGCameraViewController.png)&nbsp;
![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)&nbsp;
[![Cocoapods](http://img.shields.io/cocoapods/v/TGCameraViewController.svg)](http://cocoapods.org/?q=on%3Aios%20tgcameraviewcontroller)&nbsp;
[![Cocoapods](http://img.shields.io/cocoapods/p/TGCameraViewController.svg)](http://cocoapods.org/?q=on%3Aios%20tgcameraviewcontroller)&nbsp;
[![Analytics](https://ga-beacon.appspot.com/UA-54929747-1/tdginternet/TGCameraViewController/README.md)](https://github.com/igrigorik/ga-beacon)

* Completely custom camera with AVFoundation
* Custom view with camera permission denied
* Easy way to access album (camera roll)
* Flash auto, off and on
* Focus
* Front and back camera
* Grid view
* Preview photo view with three filters (fast processing)
* Visual effects like Instagram iOS app
* Zoom with pinch gesture
* iPhone, iPod and iPad supported

<em>This library can be applied on devices running iOS 7.0+.</em>

---
---

### Who use it

Find out [who uses TGCameraViewController](https://github.com/tdginternet/TGCameraViewController/wiki/WHO-USES) and add your app to the list.

---
---

### Adding to your project

[CocoaPods](http://cocoapods.org) is the recommended way to add TGCameraViewController to your project.

* Add a pod entry for TGCameraViewController to your Podfile:

```
pod 'TGCameraViewController'
```

* Install the pod(s) by running:

```
pod install
```

<em>Alternatively you can directly download the [latest code version](https://github.com/tdginternet/TGCameraViewController/archive/master.zip) add  drag and drop all files at <strong>TGCameraViewController</strong> folder onto your project.</em>

---
---

### Usage

#### Take photo

```obj-c
#import "TGCameraViewController.h"

@interface TGViewController : UIViewController <TGCameraDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *photoView;

- (IBAction)takePhotoTapped;

@end



@implementation TGViewController

- (IBAction)takePhotoTapped
{
    TGCameraNavigationController *navigationController =
    [TGCameraNavigationController newWithCameraDelegate:self];

    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - TGCameraDelegate optional

- (void)cameraWillTakePhoto
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)cameraDidSavePhotoAtPath:(NSURL *)assetURL
{
    // When this method is implemented, an image will be saved on the user's device
    NSLog(@"%s album path: %@", __PRETTY_FUNCTION__, assetURL);
}

- (void)cameraDidSavePhotoWithError:(NSError *)error
{
    NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
}

#pragma mark - TGCameraDelegate required

- (void)cameraDidTakePhoto:(UIImage *)image
{
    _photoView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
```

#### Choose photo

```obj-c
#import "TGCameraViewController.h"

@interface TGViewController : UIViewController
<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *photoView;

- (IBAction)chooseExistingPhotoTapped;

@end



@implementation TGViewController

- (IBAction)chooseExistingPhotoTapped
{
    UIImagePickerController *pickerController =
    [TGAlbum imagePickerControllerWithDelegate:self];

    [self presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _photoView.image = [TGAlbum imageWithMediaInfo:info];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
```

#### Options

|Option|Type|Default|Description|
|:-:|:-:|:-:|:-:|
|kTGCameraOptionSaveImageToDevice|NSNumber (YES/NO)|YES|Save or not the photo in the camera roll|

```obj-c
#import "TGCamera.h"

@implementation UIViewController

- (void)viewDidLoad
{
    //...
    [TGCamera setOption:kTGCameraOptionSaveImageToDevice value:[NSNumber numberWithBool:YES]];
    //...
}

- (IBAction)buttonTapped
{
    //...
    BOOL saveToDevice = [[TGCamera getOption:kTGCameraOptionSaveImageToDevice] boolValue];
    //...    
}

@end
```

---
---

### Requirements

TGCameraViewController works on iOS 7.0+ version and is compatible with ARC projects. It depends on the following Apple frameworks, which should already be included with most Xcode templates:

* AssetsLibrary.framework
* AVFoundation.framework
* CoreImage.framework
* Foundation.framework
* MobileCoreServices.framework
* UIKit.framework

You will need LLVM 3.0 or later in order to build TGCameraViewController.

---
---

### Todo

* Customize layout programatically
* Add support for more languages
* Preview when user choose photo
* Landscape mode support
* Force crop

---
---

### License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).

---
---

### Change-log

A brief summary of each TGCameraViewController release can be found on the [releases](https://github.com/tdginternet/TGCameraViewController/releases).
