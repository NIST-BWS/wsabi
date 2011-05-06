//
//  WsabiDeviceView.m
//  Wsabi
//
//  Created by Matt Aronoff on 11/8/10.
//
/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


#import "WsabiDeviceView_iPad.h"

#define CAPTURE_BUTTON_ALPHA 0.4
#define CANCEL_BUTTON_ALPHA 0.8

@implementation WsabiDeviceView_iPad
@synthesize frontView, backView;
@synthesize livePreviewView, hasLivePreview;
@synthesize nameLabel, modalityLabel, modalityIconView, resultImageView;
@synthesize reconnectView, reconnectButton, reconnectTextField, reconnectActivity, captureButton, cancelCaptureButton, captureActivity;
@synthesize annotationLabel1,annotationLabel2,annotationLabel3,annotationLabel4;
@synthesize annotationButton, annotationBadge;
@synthesize annotations;

@synthesize annotation1,annotation2,annotation3,annotation4;

@synthesize capturer, data, delegate, sensorAvailable, titleBarItem, doneButton;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code.
//}


- (void)layoutSubviews
{
	self.layer.shouldRasterize = YES;
	
	//Configure the basic layer appearance stuff we can't to in Interface Builder.
	self.layer.shadowColor = [[UIColor blackColor] CGColor];
	self.layer.shadowRadius = 7;
	self.layer.shadowOffset = CGSizeMake(2, 3);
	self.layer.shadowOpacity = 0.5;
	
    self.frontView.layer.cornerRadius = 12;
	self.frontView.layer.borderColor = [[UIColor grayColor] CGColor];
	self.frontView.layer.borderWidth = 2;
    
    self.backView.layer.cornerRadius = 12;
	self.backView.layer.borderColor = [[UIColor grayColor] CGColor];
	self.backView.layer.borderWidth = 2;

	self.annotationButton.layer.cornerRadius = 4;
    
	self.resultImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
	self.resultImageView.layer.borderWidth = 1.0;
	self.resultImageView.layer.cornerRadius = 4;
    
    //round the reconnect view to match the result view.
    self.reconnectView.layer.cornerRadius = self.resultImageView.layer.cornerRadius;
    
    //round the preview view to match the result view.
    self.livePreviewView.layer.cornerRadius = self.resultImageView.layer.cornerRadius;
    
    //set the images for the reconnect button.
    [self.reconnectButton setBackgroundImage:[[UIImage imageNamed:@"BlueButtonGlossy_Stretchable"] stretchableImageWithLeftCapWidth:16 topCapHeight:0] forState:UIControlStateNormal];
    [self.reconnectButton setBackgroundImage:[[UIImage imageNamed:@"BlueButtonGlossy_StretchableSelected"] stretchableImageWithLeftCapWidth:16 topCapHeight:0] forState:UIControlStateHighlighted];
    
    //put a light shadow behind the capture button
    self.captureButton.layer.shouldRasterize = YES;
    self.captureButton.layer.shadowColor = [[UIColor whiteColor] CGColor];
	self.captureButton.layer.shadowRadius = 3;
	self.captureButton.layer.shadowOffset = CGSizeMake(1, 2);
	self.captureButton.layer.shadowOpacity = 0.8;

}

- (void)dealloc {
	[nameLabel release];
	[modalityLabel release];
	[modalityIconView release];
	[resultImageView release];
    [reconnectView release];
    [reconnectButton release];
    [reconnectActivity release];
    [reconnectTextField release];
    
    [livePreviewView release];
	[annotationButton release];
    [annotationBadge release];
    
	[captureButton release];
    [cancelCaptureButton release];
    [captureActivity release];
    
    [annotation1 release];
    [annotation2 release];
    [annotation3 release];
    [annotation4 release];
    [annotationLabel1 release];
    [annotationLabel2 release];
    [annotationLabel3 release];
    [annotationLabel4 release];
    
    [annotations release];
    
    [frontView release];
    [backView release];
    
    [super dealloc];
}



#pragma mark - Property accessors

-(void) setCapturer:(Capturer *)newCap
{
	capturer = newCap;
	
	if (capturer) {
		//set up the UI.
		self.nameLabel.text = capturer.sensor.name;
		
		if ([capturer.sensor.modalities count] > 1 || [capturer.sensor.modalities count] == 0) {
			//if this sensor is, itself, multimodal, just use the "other" icon.
			self.modalityIconView.image = [UIImage imageNamed:@"ModalityOtherIcon_50px"];
		}
		else
		{
			switch ([[(SensorModality*)[capturer.sensor.modalities anyObject] type] intValue]) {
				case kModalityFace:
					self.modalityLabel.text = [WSBDModalityMap stringForModality:kModalityFace];
					self.modalityIconView.image = [UIImage imageNamed:@"FaceIcon_50px"];
					break;
				case kModalityFinger:
					self.modalityLabel.text = [WSBDModalityMap stringForModality:kModalityFinger];
					self.modalityIconView.image = [UIImage imageNamed:@"FingerprintIcon_50px"];
					break;
				case kModalityIris:
					self.modalityLabel.text = [WSBDModalityMap stringForModality:kModalityIris];
					self.modalityIconView.image = [UIImage imageNamed:@"IrisIcon_50px"];
					break;
				default:
					//includes kModalityOther case
                    self.modalityLabel.text = [WSBDModalityMap stringForModality:kModalityOther];

					break;
			}
		}

        self.modalityLabel.text = [WSBDModalityMap stringForCaptureType:[capturer.captureType intValue]];

        //put the sensor's URI in the reconnect text field.
        self.reconnectTextField.text = capturer.sensor.uri;
        
        //set up the Back View UI.
        NSString *typeString = [WSBDModalityMap stringForCaptureType:[capturer.captureType intValue]];

        if (typeString) {
            self.titleBarItem.title = [NSString stringWithFormat:@"Annotating %@",typeString];
        }
        else {
            self.titleBarItem.title = @"Annotating";
        }

        //start with the front visible
        frontVisible = YES;
	}
}

-(void) setData:(BiometricData *)newData
{
    data = newData;
    if (!self.capturer) {
        NSLog(@"WsabiDeviceView trying to set data without a capturer, which means we're missing critical data to build the UI.");
        return;
    }
    
    //update the preview view with the contents of this data item.
    self.resultImageView.image = [UIImage imageWithContentsOfFile:data.filePath];
    
    //if we successfully loaded an image, hide the capture button's guide image.
//    if (self.resultImageView.image) {
//        [captureButton setImage:[UIImage imageNamed:@"ClearImage"] forState:UIControlStateNormal];
//    }
//    else
//    {
    [captureButton setImage:[UIImage imageNamed:@"singleTap"] forState:UIControlStateNormal];
//    }
    
    //start off with certain things visible.
    self.annotationLabel1.hidden = NO;
    self.annotationLabel2.hidden = NO;
    self.annotationLabel3.hidden = NO;
    self.annotationLabel4.hidden = NO;
    
    self.annotation1.hidden = NO;
    self.annotation2.hidden = NO;
    self.annotation3.hidden = NO;
    self.annotation4.hidden = NO;
    
    int capType = [self.capturer.captureType intValue];
    
    //FIXME: This relies on there being a single annotation for each capture type. (It won't fail otherwise,
    //but we may get unexpected results.) That's pretty brittle, and should probably be changed.
    
    //figure out which annotation selectors should be shown, and what their labels should be.
    
    self.annotations = [NSKeyedUnarchiver unarchiveObjectWithData:data.annotations];
    //if there aren't any stored annotations, create an empty dictionary.
    if (!self.annotations) {
        self.annotations = [[[NSMutableDictionary alloc] initWithCapacity:4] autorelease];
    }
    
    switch (capType) {
        case kCaptureTypeLeftSlap:
            self.annotationLabel1.text = [WSBDModalityMap stringForCaptureType:kCaptureTypeLeftIndexFlat];
            self.annotation1.selectedSegmentIndex = [[self.annotations objectForKey:[NSNumber numberWithInt:kCaptureTypeLeftIndexFlat]] intValue];
            
            self.annotationLabel2.text = [WSBDModalityMap stringForCaptureType:kCaptureTypeLeftMiddleFlat];
            self.annotation2.selectedSegmentIndex = [[self.annotations objectForKey:[NSNumber numberWithInt:kCaptureTypeLeftMiddleFlat]] intValue];
            
            self.annotationLabel3.text = [WSBDModalityMap stringForCaptureType:kCaptureTypeLeftRingFlat];
            self.annotation3.selectedSegmentIndex = [[self.annotations objectForKey:[NSNumber numberWithInt:kCaptureTypeLeftRingFlat]] intValue];
            
            self.annotationLabel4.text = [WSBDModalityMap stringForCaptureType:kCaptureTypeLeftLittleFlat];
            self.annotation4.selectedSegmentIndex = [[self.annotations objectForKey:[NSNumber numberWithInt:kCaptureTypeLeftLittleFlat]] intValue];
            
            //set object tags so we can retrieve the data later.
            self.annotation1.tag = kCaptureTypeLeftIndexFlat;
            self.annotation2.tag = kCaptureTypeLeftMiddleFlat;
            self.annotation3.tag = kCaptureTypeLeftRingFlat;
            self.annotation4.tag = kCaptureTypeLeftLittleFlat;
            
            break;
        case kCaptureTypeRightSlap:
            self.annotationLabel1.text = [WSBDModalityMap stringForCaptureType:kCaptureTypeRightIndexFlat];
            self.annotation1.selectedSegmentIndex = [[self.annotations objectForKey:[NSNumber numberWithInt:kCaptureTypeRightIndexFlat]] intValue];
            
            self.annotationLabel2.text = [WSBDModalityMap stringForCaptureType:kCaptureTypeRightMiddleFlat];
            self.annotation2.selectedSegmentIndex = [[self.annotations objectForKey:[NSNumber numberWithInt:kCaptureTypeRightMiddleFlat]] intValue];
            
            self.annotationLabel3.text = [WSBDModalityMap stringForCaptureType:kCaptureTypeRightRingFlat];
            self.annotation3.selectedSegmentIndex = [[self.annotations objectForKey:[NSNumber numberWithInt:kCaptureTypeRightRingFlat]] intValue];
            
            self.annotationLabel4.text = [WSBDModalityMap stringForCaptureType:kCaptureTypeRightLittleFlat];
            self.annotation4.selectedSegmentIndex = [[self.annotations objectForKey:[NSNumber numberWithInt:kCaptureTypeRightLittleFlat]] intValue];
            
            //set object tags so we can retrieve the data later.
            self.annotation1.tag = kCaptureTypeRightIndexFlat;
            self.annotation2.tag = kCaptureTypeRightMiddleFlat;
            self.annotation3.tag = kCaptureTypeRightRingFlat;
            self.annotation4.tag = kCaptureTypeRightLittleFlat;
            
            break;
            
        case kCaptureTypeThumbsSlap:
            self.annotationLabel1.text = [WSBDModalityMap stringForCaptureType:kCaptureTypeRightThumbFlat];
            self.annotation1.selectedSegmentIndex = [[self.annotations objectForKey:[NSNumber numberWithInt:kCaptureTypeRightThumbFlat]] intValue];
            
            self.annotationLabel2.text = [WSBDModalityMap stringForCaptureType:kCaptureTypeLeftThumbFlat];
            self.annotation2.selectedSegmentIndex = [[self.annotations objectForKey:[NSNumber numberWithInt:kCaptureTypeLeftThumbFlat]] intValue];
            
            self.annotationLabel3.hidden = YES;
            self.annotationLabel4.hidden = YES;
            
            self.annotation3.hidden = YES;
            self.annotation4.hidden = YES;
            
            //set object tags so we can retrieve the data later.
            self.annotation1.tag = kCaptureTypeRightThumbFlat;
            self.annotation2.tag = kCaptureTypeLeftThumbFlat;
            
            break;
        default:
            //just display the single annotation for whatever the listed capture type is.
            self.annotationLabel1.text = [WSBDModalityMap stringForCaptureType:capType];
            
            self.annotationLabel2.hidden = YES;
            self.annotation2.hidden = YES;
            
            self.annotationLabel3.hidden = YES;
            self.annotation3.hidden = YES;
            
            self.annotationLabel4.hidden = YES;
            self.annotation4.hidden = YES;
            
            self.annotation1.selectedSegmentIndex = [[self.annotations objectForKey:self.capturer.captureType] intValue];
            
            //set object tags so we can retrieve the data later.
            self.annotation1.tag = capType;
            
            break;
    } 
    
    //update the annotations UI on the device front.
    [self refreshAnnotationBadge];
}

-(void) setSensorAvailable:(BOOL)isAvailable
{
    [UIView animateWithDuration:kFlipAnimationDuration 
                     animations:^{
                         //show or hide the reconnect view.
                         self.reconnectView.alpha = isAvailable ? 0 : 1;
                     }
     ];
    self.captureButton.enabled = isAvailable;

    //stop the connection spinner.
    [self.reconnectActivity stopAnimating];
    
    sensorAvailable = isAvailable;
}

//-(void) setHasLivePreview:(BOOL)prev
//{
//    hasLivePreview = prev;
//    
//    self.livePreviewView.hidden = !hasLivePreview;
//}

//-(void) setLivePreviewActive:(BOOL)isActive
//{
//     if (isActive) {
//        //we're making the view visible -- do setup as necessary.
//        //Create a capture manager.
//        NSError *error = nil;
//        AVCamDemoCaptureManager *captureManager = [[[AVCamDemoCaptureManager alloc] init] autorelease];
//        if ([captureManager setupSessionWithPreset:AVCaptureSessionPresetPhoto error:&error]) {
//            [self setCaptureManager:captureManager];
//            
//            AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[captureManager session]];
//            UIView *view = [self livePreviewView];
//            CALayer *viewLayer = [view layer];
//            [viewLayer setMasksToBounds:YES];
//            
//            [captureVideoPreviewLayer setFrame:self.livePreviewView.bounds];
//            
//            if ([captureVideoPreviewLayer isOrientationSupported]) {
//                [captureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
//            }
//            
//            [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
//            
//            [self setCaptureVideoPreviewLayer:captureVideoPreviewLayer];
//            
//            if ([[captureManager session] isRunning]) {
//                [captureManager setDelegate:self];
//                
//                //           NSUInteger cameraCount = [captureManager cameraCount];
//                //            if (cameraCount < 1) {
//                //                [[self hudButton] setEnabled:NO];
//                //                [[self cameraToggleButton] setEnabled:NO];
//                //                [[self stillImageButton] setEnabled:NO];
//                //                [[self gravityButton] setEnabled:NO];
//                //            } else if (cameraCount < 2) {
//                //                [[self cameraToggleButton] setEnabled:NO];
//                //            }
//                //            
//                //            if (cameraCount < 1 && [captureManager micCount] < 1) {
//                //                [[self recordButton] setEnabled:NO];
//                //            }
//                
//                [viewLayer insertSublayer:captureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
//                
//                [captureVideoPreviewLayer release];
//                
//            } else {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failure"
//                                                                    message:@"Failed to start session."
//                                                                   delegate:nil
//                                                          cancelButtonTitle:@"Okay"
//                                                          otherButtonTitles:nil];
//                [alertView show];
//                [alertView release];
//            }
//        } else {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Input Device Init Failed"
//                                                                message:[error localizedDescription]
//                                                               delegate:nil
//                                                      cancelButtonTitle:@"Okay"
//                                                      otherButtonTitles:nil];
//            [alertView show];
//            [alertView release];        
//        }
//        
//
//    }
//    else
//    {
//        self.livePreviewView.layer.sublayers = nil;
//        [self.captureManager.session stopRunning];
//        self.captureManager = nil;
//    }
//    //show/hide the live preview view.
//    self.livePreviewView.hidden = !isActive;
//
//}

#pragma mark Action methods

//NOTE: This flip code is pretty brittle (i.e., it relies on the two views being flipped being the first ones in the subviews
//array). Otherwise, it works fine :-). Taken from http://stackoverflow.com/questions/2644797/darkening-uiview-while-flipping-over-using-uiviewanimationtransitionflipfromright
- (IBAction)flip:(id)sender
{
    UIView* viewOne = [self.subviews objectAtIndex:0];
    UIView* viewTwo = [self.subviews objectAtIndex:1];
    
    viewOne.hidden = YES;
    
    CATransform3D matrix = CATransform3DMakeRotation (M_PI / 2, 0.0, 1.0, 0.0);
    CATransform3D matrix2 = CATransform3DMakeRotation (-M_PI / 2 , 0.0, 1.0, 0.0);
    matrix = CATransform3DScale (matrix, 1.0, 0.975, 1.0);
    matrix.m34 = 1.0 / -500;
    
    matrix2 = CATransform3DScale (matrix2, 1.0, 0.975, 1.0);
    matrix2.m34 = 1.0 / -500;
    
    viewOne.layer.transform = matrix2;
    
    [UIView beginAnimations:@"FlipAnimation1" context:self];
    [UIView setAnimationDuration:kFlipAnimationDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationPartOneDone)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    viewTwo.layer.transform = matrix;
    
    [UIView commitAnimations];    
}

-(void)animationPartOneDone
{   
    UIView* viewOne = [self.subviews objectAtIndex:0];
    UIView* viewTwo = [self.subviews objectAtIndex:1];
    
    
    viewOne.hidden = NO;
    viewTwo.hidden = YES;
    
    CATransform3D matrix = CATransform3DMakeRotation (2 * M_PI, 0.0, 1.0, 0.0);
    
    matrix = CATransform3DScale (matrix, 1.0, 1.0, 1.0);
    
    [UIView beginAnimations:@"FlipAnimation2" context:self];
    [UIView setAnimationDuration:kFlipAnimationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    viewOne.layer.transform = matrix;
    
    [UIView commitAnimations];    
    
    [self exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
    
}

-(IBAction) flipToFront
{
    //first, reload the annotation data so that the badge has the correct info.
    
    if(!frontVisible) {
        [self flip:nil];
    }
    frontVisible = YES;
}

-(IBAction) flipToBack
{
//    if (frontVisible) {
////        [UIView transitionFromView:self.frontView 
////                            toView:self.backView 
////                          duration:kFlipAnimationDuration 
////                           options:UIViewAnimationOptionTransitionFlipFromRight
////                        completion:nil];
//
//        [UIView animateWithDuration:kFlipAnimationDuration delay:0 options:UIViewAnimationTransitionFlipFromRight 
//                         animations:^{
//                             [self exchangeSubviewAtIndex:[self.subviews indexOfObject:self.frontView] withSubviewAtIndex:[self.subviews indexOfObject:self.backView]];
//                         }
//                         completion:^(BOOL completed){}
//         ];
//    }
    if(frontVisible) {
        [self flip:nil];
    }

    frontVisible = NO;
}


#pragma mark -
#pragma mark Button action methods

-(IBAction) annotateButtonPressed:(id)sender
{
    //flip this over to the back.
    [self flipToBack];
    
	//notify the delegate that we're starting annotation
	[delegate didBeginAnnotating:self];
}

-(IBAction) captureButtonPressed:(id)sender
{
    //ask the delegate to start capture.
    [delegate didRequestCapture:self];
    
    //hide the capture button, show the cancel capture button.
    [UIView animateWithDuration:kFadeAnimationDuration animations:^{
        self.captureButton.alpha = 0.0;
        self.cancelCaptureButton.alpha = CANCEL_BUTTON_ALPHA;
    }];
    
    [self.captureActivity startAnimating];    
}

-(IBAction) cancelCaptureButtonPressed:(id)sender
{
    //cancel the current operation.
    [delegate didRequestCancelCapture:self];

    //hide the cancel capture button, show the capture button.
    [UIView animateWithDuration:kFadeAnimationDuration animations:^{
        self.captureButton.alpha = CAPTURE_BUTTON_ALPHA;
        self.cancelCaptureButton.alpha = 0;
    }];

    [self.captureActivity stopAnimating];
}

-(IBAction) captureCompleted
{
    [UIView animateWithDuration:kFadeAnimationDuration animations:^{
        self.captureButton.alpha = CAPTURE_BUTTON_ALPHA;
        self.cancelCaptureButton.alpha = 0.0;
    }];
    
    [self.captureActivity stopAnimating];

}

-(IBAction) reconnectButtonPressed:(id)sender
{
    self.reconnectActivity.hidden = NO;
    [self.reconnectActivity startAnimating];
    [delegate didRequestConnection:self atNewUri:self.reconnectTextField.text];
}

-(IBAction) reconnectCompleted:(BOOL)success
{
    [self.reconnectActivity stopAnimating];
    self.sensorAvailable = success;
}


-(IBAction) doneButtonPressed:(id)sender
{
    if (self.data) {
        
        self.data.annotations = [NSKeyedArchiver archivedDataWithRootObject:self.annotations]; //store the dictionary in the BiometricData object.
        
    }
    
    //update the annotations UI on the device front.
    [self refreshAnnotationBadge];
    
    //flip this to the front again.
    [self flipToFront];
    
	//notify the delegate that we're done annotating.
	[delegate didEndAnnotating:self];
}

#pragma mark - Annotation control methods
-(IBAction) annotationValueChanged:(id)sender
{
    UISegmentedControl *s = (UISegmentedControl*)sender;
    
   // NSLog(@"Setting annotation %d to value %d",s.tag,s.selectedSegmentIndex);
    if (s.tag > 0) {
        //NOTE: This seems to get called prior to setting the tag value (to be checked out later).
        //In order to avoid unexpected dictionary entries, make sure the tag value is greater than 0.
        [self.annotations setObject:[NSNumber numberWithInt:s.selectedSegmentIndex] forKey:[NSNumber numberWithInt:s.tag]];  
    }
    
}

-(void) refreshAnnotationBadge
{
    if (!self.annotations) {
        return; //nothing to reload.
    }
    
    int badgeCount = 0;
    
    NSLog(@"Annotations dict is %@",self.annotations);
    
    for (NSNumber *key in self.annotations) {
        //NOTE: Because we're getting spurious calls to annotationValueChanged that set the value of the
        //0-keyed entry, we need to make sure that we're looking at a valid entry before updating the badge.
        if ([key intValue] > 0 && [[self.annotations objectForKey:key] intValue] > 0) {
            badgeCount++;
        }    
    }
                
    if (badgeCount > 0) {
        self.annotationBadge.hidden = NO;
        self.annotationBadge.titleLabel.text = [NSString stringWithFormat:@"%d",badgeCount];
    }
    else {
        self.annotationBadge.hidden = YES;
    }
            
}

@end
