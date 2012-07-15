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
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJsonParser.h"

@interface PBViewController ()

@property (weak, nonatomic) IBOutlet UIButton *chooseImageButton;
@property (weak, nonatomic) IBOutlet UIButton *mashImagesButton;
@property (weak, nonatomic) IBOutlet UIButton *publishButton;
@property (weak, nonatomic) IBOutlet UIButton *postcardButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;

@end

@implementation PBViewController

@synthesize chooseImageButton;
@synthesize mashImagesButton;
@synthesize publishButton;
@synthesize postcardButton;
@synthesize resetButton;
@synthesize popoverController;
@synthesize image;
@synthesize image1;
@synthesize image2;

@synthesize canvas;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Test Overlay
//    [self setupOverlay];
    [self configureStep1];
}

- (void)viewDidUnload
{
    [self setChooseImageButton:nil];
    [self setMashImagesButton:nil];
    [self setPublishButton:nil];
    [self setPostcardButton:nil];
    [self setResetButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    
    image1.userInteractionEnabled = YES;
    image1.multipleTouchEnabled = YES;
    canvas.userInteractionEnabled = YES;
    canvas.multipleTouchEnabled = YES;
    
    
    // Rotate and choose image
    if (!_marque) {
        _marque = [CAShapeLayer layer];
        _marque.fillColor = [[UIColor clearColor] CGColor];
        _marque.strokeColor = [[UIColor grayColor] CGColor];
        _marque.lineWidth = 1.0f;
        _marque.lineJoin = kCALineJoinRound;
        _marque.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:10],[NSNumber numberWithInt:5], nil];
        _marque.bounds = CGRectMake(image1.frame.origin.x, image1.frame.origin.y, 0, 0);
        _marque.position = CGPointMake(image1.frame.origin.x + canvas.frame.origin.x, image1.frame.origin.y + canvas.frame.origin.y);
    }
    [[self.view layer] addSublayer:_marque];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)] init];
    [pinchRecognizer setDelegate:self];
    [self.view addGestureRecognizer:pinchRecognizer];
    
    UIRotationGestureRecognizer *rotationRecognizer = [[[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)] init];
    [rotationRecognizer setDelegate:self];
    [self.view addGestureRecognizer:rotationRecognizer];
    
    UIPanGestureRecognizer *panRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)] init];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    [canvas addGestureRecognizer:panRecognizer];
    
    UITapGestureRecognizer *tapProfileImageRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)] init];
    [tapProfileImageRecognizer setNumberOfTapsRequired:1];
    [tapProfileImageRecognizer setDelegate:self];
    [canvas addGestureRecognizer:tapProfileImageRecognizer];       
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Misc methods
- (void)displayEditorForImage:(UIImage *)imageToEdit
{
    AFPhotoEditorController *editorController = [[AFPhotoEditorController alloc] initWithImage:imageToEdit];
    [editorController setDelegate:self];
    [self presentModalViewController:editorController animated:YES];
}

- (void)configureStep1 {
    self.chooseImageButton.hidden = NO;
    self.mashImagesButton.hidden = YES;
    self.publishButton.hidden = YES;
    self.postcardButton.hidden = YES;
    self.resetButton.hidden = YES;
}

- (void)configureStep2 {
    self.chooseImageButton.hidden = YES;
    self.mashImagesButton.hidden = NO;
    self.publishButton.hidden = YES;
    self.postcardButton.hidden = YES;
    self.resetButton.hidden = YES;
}

- (void)configureStep3 {
    self.chooseImageButton.hidden = YES;
    self.mashImagesButton.hidden = YES;
    self.publishButton.hidden = NO;
    self.postcardButton.hidden = NO;
    self.resetButton.hidden = NO;
}

#pragma mark - IBActions
- (IBAction)setupOverlay:(id)sender {
    UIImage *originalImage = self.image1.image;
    UIImage *noiseLayer = self.image2.image;
    
    [self uploadFile:UIImagePNGRepresentation(noiseLayer)];
    
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

- (IBAction)savingAction: (id)sender {
    
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
//    UIPopoverController *popoverControllerA = [UIPopoverController alloc];    
//    self.popoverController = [popoverControllerA initWithContentViewController:fpSave];
//    popoverController.popoverContentSize = CGSizeMake(320, 520);
//    [popoverController presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [self presentModalViewController:fpSave animated:YES];
}

- (IBAction)reset:(id)sender {
    self.image1.image = nil;
    self.image2.image = nil;
    self.image.image = nil;

    [self configureStep1];
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
        [self configureStep2];
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
    
//    [popoverController dismissPopoverAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
}
- (void)FPSaveControllerDidCancel:(FPSaveController *)picker {
    NSLog(@"FP Cancelled Save");
    
//    [popoverController dismissPopoverAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
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
    [self configureStep3];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark Uploading file

-(void)uploadFile:(NSData *)data
{
    NSURL *url = [NSURL URLWithString:@"http://flashfotoapi.com/api/add/?privacy=public&partner_username=philster&partner_apikey=LUPbRi4fzoWpCjh3ieFVcHZbMCmlrWbs"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    
    NSURLResponse *response;
    NSError *err;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSLog(@"responseData: %@", responseData);
    NSString* newStr = [[NSString alloc] initWithData:responseData
                                              encoding:NSUTF8StringEncoding];    
    NSLog(@"newStr: %@", newStr);
}

#pragma mark UIGestureRegognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return ![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && ![gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]];
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]) {      //change it to your condition
        return NO;
    }
    return YES;
    
}

-(void)showOverlayWithFrame:(CGRect)frame {
    
    if (![_marque actionForKey:@"linePhase"]) {
        CABasicAnimation *dashAnimation;
        dashAnimation = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
        [dashAnimation setFromValue:[NSNumber numberWithFloat:0.0f]];
        [dashAnimation setToValue:[NSNumber numberWithFloat:15.0f]];
        [dashAnimation setDuration:0.5f];
        [dashAnimation setRepeatCount:HUGE_VALF];
        [_marque addAnimation:dashAnimation forKey:@"linePhase"];
    }
    
    _marque.bounds = CGRectMake(frame.origin.x, frame.origin.y, 0, 0);
    _marque.position = CGPointMake(frame.origin.x + canvas.frame.origin.x, frame.origin.y + canvas.frame.origin.y);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, frame);
    [_marque setPath:path];
    CGPathRelease(path);
    
    _marque.hidden = NO;
    
}

-(IBAction)scale:(UIGestureRecognizer *)sender {
    
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _lastScale = 1.0;
    }
    
    CGFloat scale = 1.0 - (_lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    
    CGAffineTransform currentTransform = image1.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    
    [image1 setTransform:newTransform];
    
    _lastScale = [(UIPinchGestureRecognizer*)sender scale];
    [self showOverlayWithFrame:image1.frame];
}

-(IBAction)rotate:(UIGestureRecognizer *)sender {
    
    if([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        _lastRotation = 0.0;
        return;
    }
    
    CGFloat rotation = 0.0 - (_lastRotation - [(UIRotationGestureRecognizer*)sender rotation]);
    
    CGAffineTransform currentTransform = image1.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
    
    [image1 setTransform:newTransform];
    
    _lastRotation = [(UIRotationGestureRecognizer*)sender rotation];
    [self showOverlayWithFrame:image1.frame];
}


-(IBAction)move:(UIGestureRecognizer *)sender {
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:canvas];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _firstX = [image1 center].x;
        _firstY = [image1 center].y;
    }
    
    translatedPoint = CGPointMake(_firstX+translatedPoint.x, _firstY+translatedPoint.y);
    
    [image1 setCenter:translatedPoint];
    [self showOverlayWithFrame:image1.frame];
}

-(IBAction)tapped:(UIGestureRecognizer *)sender{
    _marque.hidden = YES;
}


@end
