//
//  TECameraOverlayViewController.m
//  Instagrate
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

    [activateShutterButton addTarget:self.delegate
                     action:@selector(activateShutter) forControlEvents:UIControlEventTouchUpInside];
    activateShutterButton.frame = CGRectMake(130, 380, 60, 60);
    [activateShutterButton.layer setCornerRadius:30];
    [activateShutterButton.layer setBorderWidth:4.0];
    [activateShutterButton.layer setBorderColor:backgroundColor.CGColor];
    
    [activateShutterButton setHidden:YES];
    [self.view addSubview:activateShutterButton];
    
    cancelCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelCameraButton addTarget:self.delegate
                           action:@selector(cancelCamera) forControlEvents:UIControlEventTouchUpInside];
    cancelCameraButton.frame = CGRectMake(10, 10, 80, 40);
    [cancelCameraButton setBackgroundColor:backgroundColor];
    [cancelCameraButton.layer setCornerRadius:5.0];
    [cancelCameraButton.layer setBorderWidth:2.0];
    [cancelCameraButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [cancelCameraButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelCameraButton setHidden:YES];
    [self.view addSubview:cancelCameraButton];
}

-(void)imagePickerPresented
{
    activateShutterButton.hidden = NO;
    cancelCameraButton.hidden = NO;
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

@end
