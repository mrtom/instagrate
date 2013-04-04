//
//  TEViewController.m
//  Instagrate
//
//  Our main view controller. Uses a UIImagePickerController to allow the user to take a photo, and then
//  uses the document interaction APIs to pass this on to Instagram, along with a custom message typed by
//  the user, and our own hashtag.
//
//  In a real app, you'd be better off using an AVCaptureSession than the UIImagePickerController method,
//  but it's simpler to understand what's going on this way IMO. Seeing as a snazzy looking camera is
//  not the point of this example, I've stuck with UIImagePickerController
//
//  Created by Tom Elliott on 27/03/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import "TEViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <math.h>

#define KEY @"photo.igo"
#define INSTA_UTI @"com.instagram.photo"
#define INSTA_CAPTION_KEY @"InstagramCaption"

@interface TEViewController ()

@end

@implementation TEViewController {
    UIImagePickerController *imagePicker;
    TECameraOverlayViewController *overlayViewController;
}

@synthesize docInteractionController;

bool hasImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setHasImage:NO];
    
    textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textView.layer.borderWidth = 1.0f;
    textView.layer.cornerRadius = 8.0;
    textView.clipsToBounds = YES;    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (hasImage) {
        UIImage *image = [UIImage imageWithContentsOfFile:[self imagePath]];
        [imageView setImage:image];
    }
}

// Setup the document controller to force Instagram to take control of the image
- (void)setupDocumentControllerWithURL:(NSURL *)url
{
    if (self.docInteractionController == nil)
    {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docInteractionController.delegate = self;
        self.docInteractionController.UTI = INSTA_UTI;
    }
    else
    {
        self.docInteractionController.URL = url;
    }
    
    NSDictionary *annotation = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@ %@", textView.text, @"#instagrate"], INSTA_CAPTION_KEY, nil];
    self.docInteractionController.annotation = annotation;
}

- (void)setHasImage:(BOOL)imageSet
{
    hasImage = imageSet;
    takePhotoButton.hidden = imageSet;
    shareToInstagramButton.hidden = !imageSet;
    removePhotoButton.hidden = !imageSet;
}

// Use a UIImagePickerController to take a photo, and save it to disk
// We then pass this photo to Instagram
- (IBAction)takePhoto:(id)sender
{
    if ([photoPickerPopover isPopoverVisible]) {
        [photoPickerPopover dismissPopoverAnimated:YES];
        photoPickerPopover = nil;
        return;
    }
    
    imagePicker = [[UIImagePickerController alloc] init];
    
    // Check camera is available (i.e. not simulator/iPod touch)
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        // OK, so we're on a device, and we have a camera. Awesome.
        [imagePicker setDelegate:self];
        
        imagePicker.showsCameraControls = NO;
        overlayViewController = [[TECameraOverlayViewController alloc] init];
        [overlayViewController setDelegate:self];
        
        [imagePicker.cameraOverlayView addSubview:overlayViewController.view];
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else {
        // When we don't have a camera, use a sample image
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Woah there!" message:@"You can't open a camera on the simulator. So I'll just put in a stock picture of my friend Claudia." delegate:nil cancelButtonTitle:@"Thanks kiddo!" otherButtonTitles:nil];
        [alert show];
        [imageView setImage:[UIImage imageNamed:@"sample.jpg"]];
        [self setHasImage:YES];
    }    
}

- (IBAction)removePhoto:(id)sender
{
    [[NSFileManager defaultManager] removeItemAtPath:[self imagePath] error:NULL];
    [imageView setImage:nil];
    [self setHasImage:NO];
}

// Make the image square, so it's better for Instagram.
// TODO: This code can almost certainly be simplified for this our case
- (UIImage *)cropImage:(UIImage *)originalImage
{
    // TODO: This should be made more efficient by removing the
    // intermediate croppedImage. CGContextClipToRect can probably
    // help here, but the maths gets a bit tricky
    
    CGFloat imageSide = MIN(originalImage.size.width, originalImage.size.height);
    
    CGFloat xcrop = (originalImage.size.width - imageSide)/2;
    CGFloat ycrop = (originalImage.size.height - imageSide)/2;
    
    CGRect selectionRect = CGRectMake(xcrop, ycrop, imageSide, imageSide);
    CGRect transformedRect = TransformCGRectForUIImageOrientation(selectionRect, originalImage.imageOrientation, originalImage.size);
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(originalImage.CGImage, transformedRect);
    UIImage *croppedImage = [[UIImage alloc] initWithCGImage:croppedImageRef];
    CGImageRelease(croppedImageRef);
    
    UIGraphicsBeginImageContext(transformedRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    switch (originalImage.imageOrientation) {
        case UIImageOrientationLeft:
            CGContextRotateCTM(context, M_PI+M_PI_2);
            CGContextTranslateCTM(context, -ycrop-imageSide, 0);
            break;
        case UIImageOrientationDown:
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSide-xcrop, -imageSide);
            break;
        case UIImageOrientationRight:
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, -ycrop, -imageSide);
            break;
        case UIImageOrientationUp:
            CGContextTranslateCTM(context, -xcrop, 0);
            break;
        default:
            // Do nothing
            break;
    }

    // Fix for Quartz 2D's different coord system
    CGContextTranslateCTM(context, 0, imageSide);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Draw the image
    CGContextDrawImage(context, transformedRect, croppedImage.CGImage);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRelease(context);
    
    return resultImage;
}

// Thanks to http://www.niftybean.com/2009/10/selecting-regions-from-rotated-exif-images-on-iphone/
CGRect TransformCGRectForUIImageOrientation(CGRect source, UIImageOrientation orientation, CGSize imageSize) {
    switch (orientation) {
        case UIImageOrientationLeft: { // EXIF #8
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,M_PI_2);
            return CGRectApplyAffineTransform(source, txCompound);
        }
        case UIImageOrientationDown: { // EXIF #3
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,M_PI);
            return CGRectApplyAffineTransform(source, txCompound);
        }
        case UIImageOrientationRight: { // EXIF #6
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,M_PI + M_PI_2);
            return CGRectApplyAffineTransform(source, txCompound);
        }
        case UIImageOrientationUp: // EXIF #1 - do nothing
        default: // EXIF 2,4,5,7 - ignore
            return source;
    }
}

// Get an image path to save the image to
- (NSString *)imagePath
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:KEY];
}

// Boilerplate. Remove the keyboard when you touch outside of the text input
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {    
    UITouch *touch = [[event allTouches] anyObject];
    if ([textView isFirstResponder] && [touch view] != textView) {
        [textView resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

// Actually perform the interaction to pass the image to Instagram
- (IBAction)passToInstagram:(id)sender
{
    NSURL* fileURL = [NSURL fileURLWithPath:[self imagePath]];
    [self setupDocumentControllerWithURL:fileURL];
    [self.docInteractionController presentOpenInMenuFromRect:self.view.bounds inView:self.view animated:YES];
}

# pragma mark UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Remove old image first, if necessary
    if (hasImage) {
        [self removePhoto:nil];
    }
    
    // Save the new image
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *image = [self cropImage:originalImage];
    
    [imageView setImage:image];
    NSData *d = UIImageJPEGRepresentation(image, 1.0);
    [d writeToFile:[self imagePath] atomically:YES];
    
    [self setHasImage:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIDocumentInteractionControllerDelegate methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}

#pragma mark TECameraOverlayViewControllerDelegate methods

- (void)activateShutter
{
    [imagePicker takePicture];
}

- (void)cancelCamera
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
