//
//  TEViewController.m
//  Instagrate
//
//  Created by Tom Elliott on 27/03/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import "TEViewController.h"

#import <QuartzCore/QuartzCore.h>

#define KEY @"photo.igo"
#define INSTA_UTI @"com.instagram.photo"
#define INSTA_CAPTION_KEY @"InstagramCaption"

@interface TEViewController ()

@end

@implementation TEViewController

@synthesize docInteractionController;

bool hasImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setHasImage:NO];
    
    textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textView.layer.borderWidth = 1.0f;
    textView.layer.cornerRadius = 5.0;
    textView.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    
    NSDictionary *annotation = [[NSDictionary alloc] initWithObjectsAndKeys:textView.text, INSTA_CAPTION_KEY, nil];
    self.docInteractionController.annotation = annotation;
}

- (void)setHasImage:(BOOL)imageSet
{
    hasImage = imageSet;
    takePhotoButton.hidden = imageSet;
    shareToInstagramButton.hidden = !imageSet;
    removePhotoButton.hidden = !imageSet;
}

- (IBAction)takePhoto:(id)sender
{
    if ([photoPickerPopover isPopoverVisible]) {
        [photoPickerPopover dismissPopoverAnimated:YES];
        photoPickerPopover = nil;
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // Check camera is available (i.e. not simulator/iPod touch)
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        // OK, so we're on a device, and we have a camera. Awesome.
        [imagePicker setDelegate:self];
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else {
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

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Remove old image first, if necessary
    if (hasImage) {
        [self removePhoto:nil];
    }
    
    // Save the new image
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [imageView setImage:image];
    
    NSData *d = UIImageJPEGRepresentation(image, 1.0);
    [d writeToFile:[self imagePath] atomically:YES];
    
    [self setHasImage:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)imagePath
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:KEY];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {    
    UITouch *touch = [[event allTouches] anyObject];
    if ([textView isFirstResponder] && [touch view] != textView) {
        [textView resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)passToInstagram:(id)sender
{
    NSURL* fileURL = [NSURL fileURLWithPath:[self imagePath]];
    [self setupDocumentControllerWithURL:fileURL];
    [self.docInteractionController presentOpenInMenuFromRect:self.view.bounds inView:self.view animated:YES];
}

#pragma mark UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}

@end
