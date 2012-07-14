//
//  PBViewController.h
//  PhotoBomber
//
//  Created by Blossom Woo on 7/14/12.
//  Copyright (c) 2012 Jawbone. All rights reserved.
//

#import <FPPicker/FPPicker.h>
#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface PBViewController : UIViewController<FPPickerDelegate, UIPopoverControllerDelegate, FPSaveDelegate> {
    IBOutlet UIButton *button;
    IBOutlet UIButton *savebutton;
    
    IBOutlet UIImageView *image1;
    IBOutlet UIImageView *image2;
    
    IBOutlet UIImageView *image;
    UIPopoverController *popoverController;
}

@property (nonatomic, retain) UIImageView *image1;
@property (nonatomic, retain) UIImageView *image2;
@property (nonatomic, retain) UIImageView *image;
@property (nonatomic, retain) UIPopoverController *popoverController;

@end
