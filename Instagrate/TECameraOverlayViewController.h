//
//  TECameraOverlayViewController.h
//  Instagrate
//
//  Created by Tom Elliott on 04/04/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TECameraOverlayViewControllerDelegate
- (void)activateShutter;
- (void)cancelCamera;
@end

@interface TECameraOverlayViewController : UIViewController {
    id <TECameraOverlayViewControllerDelegate> delegate;
}

@property (nonatomic, retain) id<TECameraOverlayViewControllerDelegate> delegate;

-(void)imagePickerPresented;

@end
