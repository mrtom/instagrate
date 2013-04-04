//
//  TECameraOverlayViewController.m
//  Instagrate
//
//  This class provides the camera controls and a mask to make it look like
//  our camera is square (Instagram style)
//
//  Created by Tom Elliott on 04/04/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import "TECameraOverlayViewController.h"

#import <QuartzCore/QuartzCore.h>

#define backgroundColor [UIColor blackColor]

@interface TECameraOverlayViewController ()

@end

@implementation TECameraOverlayViewController {
    UIButton *activateShutterButton;
    UIButton *cancelCameraButton;
}

@synthesize delegate;

- (void)viewDidLoad
{
    // TODO: Run this on an iPhone 5. I suspect it won't layout properly at the moment, but I don't have
    // one to test with (and we don't load the camera in the simulator).
    // I should be using autolayout here instead of dumping things down by hand
    [super viewDidLoad];
    
    self.view.frame = [[UIScreen mainScreen] bounds];    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    UIView *maskView = [[UIView alloc] initWithFrame:self.view.frame];
    UIImage *maskingImage = [UIImage imageNamed:@"mask.png"];
    CALayer *maskingLayer = [CALayer layer];
    maskingLayer.frame = self.view.bounds;
    [maskingLayer setContents:(id)[maskingImage CGImage]];
    [maskView.layer setMask:maskingLayer];
    [maskView setBackgroundColor:backgroundColor];
    [self.view addSubview:maskView];
    
    activateShutterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [activateShutterButton setBackgroundColor:[UIColor whiteColor]];
    [activateShutterButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];

    [activateShutterButton addTarget:self
                              action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
    activateShutterButton.frame = CGRectMake(130, 380, 60, 60);
    [activateShutterButton.layer setCornerRadius:30];
    [activateShutterButton.layer setBorderWidth:4.0];
    [activateShutterButton.layer setBorderColor:backgroundColor.CGColor];    
    [self.view addSubview:activateShutterButton];
    
    cancelCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelCameraButton addTarget:self
                           action:@selector(cancelCamera:) forControlEvents:UIControlEventTouchUpInside];
    cancelCameraButton.frame = CGRectMake(10, self.view.bounds.size.height - 10 - 40, 80, 40);
    [cancelCameraButton setBackgroundColor:backgroundColor];
    [cancelCameraButton.layer setCornerRadius:5.0];
    [cancelCameraButton.layer setBorderWidth:2.0];
    [cancelCameraButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [cancelCameraButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.view addSubview:cancelCameraButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)takePicture:(id)sender
{
    if (delegate) {
        [delegate activateShutter];
    }
}

- (void)cancelCamera:(id)sender
{
    if (delegate) {
        [delegate cancelCamera];
    }
}

@end
