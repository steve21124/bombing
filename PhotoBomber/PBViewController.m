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
