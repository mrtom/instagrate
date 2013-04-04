//
//  TECameraOverlayViewController.m
//  Instagrate
//
//  Created by Tom Elliott on 04/04/2013.
//  Copyright (c) 2013 Tom Elliott. All rights reserved.
//

#import "TECameraOverlayViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface TECameraOverlayViewController ()

@end

@implementation TECameraOverlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *maskingImage = [UIImage imageNamed:@"mask.png"];
    CALayer *maskingLayer = [CALayer layer];
    maskingLayer.frame = self.view.bounds;
    [maskingLayer setContents:(id)[maskingImage CGImage]];
    [self.view.layer setMask:maskingLayer];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
