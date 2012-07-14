//
//  PBViewController.m
//  PhotoBomber
//
//  Created by Blossom Woo on 7/14/12.
//  Copyright (c) 2012 Jawbone. All rights reserved.
//

#import <FPPicker/FPPicker.h>

#import "PBViewController.h"

@interface PBViewController ()

@end

@implementation PBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Test Overlay
    [self setupOverlay];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


- (void)setupOverlay{
    UIImage *originalImage = [UIImage imageNamed:@"phil1.jpg"];
    UIImage *noiseLayer = [UIImage imageNamed:@"Anxiety.png"];
    
    GPUImageOverlayBlendFilter *overlayBlendFilter = [[GPUImageOverlayBlendFilter alloc] init];
    GPUImagePicture *pic1 = [[GPUImagePicture alloc] initWithImage:originalImage];
    GPUImagePicture *pic2 = [[GPUImagePicture alloc] initWithImage:noiseLayer];
    
    [pic1 addTarget:overlayBlendFilter];
    [pic1 processImage];
    [pic2 addTarget:overlayBlendFilter];
    [pic2 processImage];
    
    UIImage *blendedImage = [overlayBlendFilter imageFromCurrentlyProcessedOutputWithOrientation:originalImage.imageOrientation];
    
    
}


#pragma mark - FilePicker API
// open files
- (IBAction)openFiles:(id)sender {
    FPPickerController *fpController = [[FPPickerController alloc] init];
    fpController.fpdelegate = self;
    [self presentModalViewController:fpController animated:YES];
}

#pragma mark - delegate methods
- (void)FPPickerController:(FPPickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"didFinishPickingMediaWithInfo");
}

- (void)FPPickerControllerDidCancel:(FPPickerController *)picker {
    NSLog(@"FPPickerControllerDidCancel");
}

@end
