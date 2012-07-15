//
//  PBViewController.m
//  PhotoBomber
//
//  Created by Blossom Woo on 7/14/12.
//  Copyright (c) 2012 Jawbone. All rights reserved.
//

#import <FPPicker/FPPicker.h>
#import <Sincerely/Sincerely.h>

#import "PBViewController.h"
#import "AFPhotoEditorController.h"

@interface PBViewController ()

@end

@implementation PBViewController
@synthesize popoverController;
@synthesize image;
@synthesize image1;
@synthesize image2;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Test Overlay
//    [self setupOverlay];
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

- (void)displayEditorForImage:(UIImage *)imageToEdit
{
    AFPhotoEditorController *editorController = [[AFPhotoEditorController alloc] initWithImage:imageToEdit];
    [editorController setDelegate:self];
    [self presentModalViewController:editorController animated:YES];
}

- (IBAction)setupOverlay:(id)sender {
    UIImage *originalImage = self.image1.image;
    UIImage *noiseLayer = self.image2.image;
    
    GPUImageOverlayBlendFilter *overlayBlendFilter = [[GPUImageOverlayBlendFilter alloc] init];
    GPUImagePicture *pic1 = [[GPUImagePicture alloc] initWithImage:originalImage];
    GPUImagePicture *pic2 = [[GPUImagePicture alloc] initWithImage:noiseLayer];
    
    [pic1 addTarget:overlayBlendFilter];
    [pic1 processImage];
    [pic2 addTarget:overlayBlendFilter];
    [pic2 processImage];
    
    UIImage *blendedImage = [overlayBlendFilter imageFromCurrentlyProcessedOutputWithOrientation:originalImage.imageOrientation];
    
    [self displayEditorForImage:blendedImage];
//    self.image.image = blendedImage;    
}


#pragma mark - IBActions
- (IBAction)pickerAction: (id) sender {
    
    
    /*
     * Create the object
     */
    FPPickerController *fpController = [[FPPickerController alloc] init];
    
    /*
     * Set the delegate
     */
    fpController.fpdelegate = self;
    
    /*
     * Ask for specific data types. (Optional) Default is all files.
     */
    fpController.dataTypes = [NSArray arrayWithObjects:@"image/*", nil];
    //fpController.dataTypes = [NSArray arrayWithObjects:@"image/*", @"video/quicktime", nil];
    
    /*
     * Select and order the sources (Optional) Default is all sources
     */
    //fpController.sourceNames = [[NSArray alloc] initWithObjects: FPSourceImagesearch, nil];
    
    /*
     * Display it.
     */
    UIPopoverController *popoverControllerA = [UIPopoverController alloc];
    self.popoverController = [popoverControllerA initWithContentViewController:fpController];
    popoverController.popoverContentSize = CGSizeMake(320, 520);
    [popoverController presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)pickerModalAction: (id) sender {
    
    
    /*
     * Create the object
     */
    FPPickerController *fpController = [[FPPickerController alloc] init];
    
    /*
     * Set the delegate
     */
    fpController.fpdelegate = self;
    
    /*
     * Ask for specific data types. (Optional) Default is all files.
     */
    fpController.dataTypes = [NSArray arrayWithObjects:@"image/*", nil];
    //fpController.dataTypes = [NSArray arrayWithObjects:@"image/*", @"video/quicktime", nil];
    
    /*
     * Select and order the sources (Optional) Default is all sources
     */
    //fpController.sourceNames = [[NSArray alloc] initWithObjects: FPSourceImagesearch, nil];
    
    /*
     * Display it.
     */
    [self presentModalViewController:fpController animated:YES];
}

- (IBAction)savingAction: (id) sender {
    
    if (image.image == nil){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Nothing to Save"
                                                          message:@"Select an image first."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
        return;
    }
    
    NSData *imgData = UIImagePNGRepresentation(image.image);
    
    /*
     * Create the object
     */
    FPSaveController *fpSave = [[FPSaveController alloc] init];
    
    /*
     * Set the delegate
     */
    fpSave.fpdelegate = self;
    
    /*
     * Select and order the sources (Optional) Default is all sources
     */
    //fpSave.sourceNames = [[NSArray alloc] initWithObjects: FPSourceDropbox, FPSourceFacebook, FPSourceBox, nil];
    
    /*
     * Set the data and data type to be saved.
     */
    fpSave.data = imgData;
    fpSave.dataType = @"image/png";
    
    /*
     * Display it.
     */
    UIPopoverController *popoverControllerA = [UIPopoverController alloc];    
    self.popoverController = [popoverControllerA initWithContentViewController:fpSave];
    popoverController.popoverContentSize = CGSizeMake(320, 520);
    [popoverController presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

- (IBAction)reset:(id)sender {
    self.image1.image = nil;
    self.image2.image = nil;
    self.image.image = nil;
}

- (IBAction)publish:(id)sender {
    if (!self.image.image) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Publishing Error" message:@"Please create an image first" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil]; 
        [alertView show];
        return;
    }
    
    SYSincerelyController *controller = [[SYSincerelyController alloc] initWithImages:[NSArray arrayWithObject:self.image.image]
                                                                              product:SYProductTypePostcard
                                                                       applicationKey:@"5CR3PSEXU4WK7IHYHF54CI7B3ECQPNQW2SIJ8PEI"
                                                                             delegate:self];
    
    if (controller) {
        [self presentModalViewController:controller animated:YES];
//        [controller release];
    }
}


#pragma mark - FPPickerControllerDelegate Methods

- (void)FPPickerController:(FPPickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"FILE CHOSEN: %@", info);
    
//    image.image = [info objectForKey:@"FPPickerControllerOriginalImage"];
    if (!self.image1.image) {
        self.image1.image = [info objectForKey:@"FPPickerControllerOriginalImage"];
    } else {
        self.image2.image = [info objectForKey:@"FPPickerControllerOriginalImage"];
    }
    
    [popoverController dismissPopoverAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
    
}
- (void)FPPickerControllerDidCancel:(FPPickerController *)picker
{
    NSLog(@"FP Cancelled Open");
    [popoverController dismissPopoverAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - FPSaveControllerDelegate Methods

- (void)FPSaveController:(FPSaveController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"FILE SAVED: %@", info);
    
    [popoverController dismissPopoverAnimated:YES];
    
}
- (void)FPSaveControllerDidCancel:(FPSaveController *)picker {
    NSLog(@"FP Cancelled Save");
    
    [popoverController dismissPopoverAnimated:YES];
}

#pragma mark - SYSincerelyControllerDelegate methods
- (void)sincerelyControllerDidFinish:(SYSincerelyController *)controller {
    /*
     * Here I know that the user made a purchase and I can do something with it
     */
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)sincerelyControllerDidCancel:(SYSincerelyController *)controller {
    /*
     * Here I know that the user hit the cancel button and they want to leave the Sincerely controller
     */
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)sincerelyControllerDidFailInitiationWithError:(NSError *)error {
    /*
     * Here I know that incorrect inputs were given to initWithImages:product:applicationKey:delegate;
     */
    
    NSLog(@"Error: %@", error);
}    

#pragma mark - Aviary Methods
- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
   // [[self imageView] setImage:image];
    self.image.image = image;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self dismissModalViewControllerAnimated:YES];
}


@end
