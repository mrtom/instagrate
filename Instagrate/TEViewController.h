//
//  TEViewController.h
//  Instagrate
//
//  Created by Tom Elliott on 27/03/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TEViewController : UIViewController
    <UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate, UIDocumentInteractionControllerDelegate>
{
    IBOutlet UITextView *textView;
    IBOutlet UIImageView *imageView;
    IBOutlet UIButton *takePhotoButton;
    IBOutlet UIButton *shareToInstagramButton;
    
    UIPopoverController *photoPickerPopover;
    UIDocumentInteractionController *docInteractionController;
}

@property (nonatomic, retain) UIDocumentInteractionController *docInteractionController;

- (IBAction)takePhoto:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (IBAction)passToInstagram:(id)sender;

@end
