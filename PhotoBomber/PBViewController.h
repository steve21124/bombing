//
//  PBViewController.h
//  PhotoBomber
//
//  Created by Blossom Woo on 7/14/12.
//  Copyright (c) 2012 Jawbone. All rights reserved.
//

#import <FPPicker/FPPicker.h>
#import <Sincerely/Sincerely.h>
#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface PBViewController : UIViewController<FPPickerDelegate, UIPopoverControllerDelegate, FPSaveDelegate, SYSincerelyControllerDelegate,UIGestureRecognizerDelegate> {
    IBOutlet UIButton *button;
    IBOutlet UIButton *savebutton;
    
    IBOutlet UIImageView *image1;
    IBOutlet UIImageView *image2;
    
    IBOutlet UIImageView *image;
    UIPopoverController *popoverController;
    
    UIView *canvas;
    CAShapeLayer *_marque;
    CGFloat _lastScale;
    CGFloat _lastRotation;
	CGFloat _firstX;
	CGFloat _firstY; 
}

@property (nonatomic, retain) UIImageView *image1;
@property (nonatomic, retain) UIImageView *image2;
@property (nonatomic, retain) UIImageView *image;
@property (nonatomic, retain) UIPopoverController *popoverController;

@property (nonatomic, retain) IBOutlet UIView *canvas;

-(IBAction)scale:(UIGestureRecognizer *)sender;
-(IBAction)rotate:(UIGestureRecognizer *)sender;
-(IBAction)move:(UIGestureRecognizer *)sender;
-(IBAction)tapped:(UIGestureRecognizer *)sender;

- (UIImage *) imageWithView:(UIView *)view;

@end
