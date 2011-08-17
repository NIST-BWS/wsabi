//
//  WsabiDeviceView.h
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


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "constants.h"
#import "WSBDModalityMap.h"
#import "Capturer.h"
#import "BiometricData.h"
#import "Sensor.h"

#import "NBCLSensorLink.h"

#import "AVCamDemoCaptureManager.h"

@protocol WsabiDeviceViewDelegate <NSObject>
-(void) didBeginAnnotating:(id)sender;
-(void) didEndAnnotating:(id)sender;
-(void) didRequestConnection:(id)sender atNewUri:(NSString*)newUri;
-(void) didRequestCapture:(id)sender;
-(void) didRequestCancelCapture:(id)sender;
-(void) didRequestClearData:(id)sender;
@end

@interface WsabiDeviceView_iPad : UIView <UIActionSheetDelegate>
{

    //Front View
    UIView *frontView;
	UILabel *nameLabel;
	UILabel *modalityLabel;
	UIImageView *modalityIconView;
	UIImageView *resultImageView;
	
    UIView *reconnectView;
    UIButton *reconnectButton;
    UITextField *reconnectTextField;
    UIActivityIndicatorView *reconnectActivity;
    	
	UIButton *annotationButton;
    UIButton *annotationBadge;
    NSMutableDictionary *annotations;
    
	UIButton *captureButton;
    UIButton *cancelCaptureButton;

    UIActivityIndicatorView *captureActivity;
    
    //Preview stuff
    UIView *livePreviewView;
    BOOL hasLivePreview;

    //Back View
    UIView *backView;
    UIBarButtonItem *doneButton;
	UIBarButtonItem *titleBarItem;
    
    UILabel *annotationLabel1;
    UILabel *annotationLabel2;
    UILabel *annotationLabel3;
    UILabel *annotationLabel4;
    
	UISegmentedControl *annotation1;
    UISegmentedControl *annotation2;
    UISegmentedControl *annotation3;
    UISegmentedControl *annotation4;

    //Common and data
    BOOL frontVisible;
    BOOL sensorAvailable;
	Capturer *capturer;
    BiometricData *data;
    
    BOOL reconnectOptionsEnabled;
	
	//delegate
	id<WsabiDeviceViewDelegate> delegate;

}

-(void) refreshAnnotationBadge;

-(IBAction) annotateButtonPressed:(id)sender;
-(IBAction) captureButtonPressed:(id)sender;
-(IBAction) cancelCaptureButtonPressed:(id)sender;
-(IBAction) captureCompleted; //this will be called, most likely, by the delegate object once capture & download are complete.
-(IBAction) reconnectButtonPressed:(id)sender;
-(IBAction) reconnectCompleted:(BOOL)success; //this will be called, most likely, by the delegate once reconnection either succeeds or fails.

-(IBAction) annotationValueChanged:(id)sender;

//Front View
@property (nonatomic, retain) IBOutlet UIView *frontView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *modalityLabel;
@property (nonatomic, retain) IBOutlet UIImageView *modalityIconView;
@property (nonatomic, retain) IBOutlet UIImageView *resultImageView;

@property (nonatomic, retain) IBOutlet UIView *reconnectView;
@property (nonatomic, retain) IBOutlet UIButton *reconnectButton;
@property (nonatomic, retain) IBOutlet UITextField *reconnectTextField;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *reconnectActivity;

@property (nonatomic, retain) IBOutlet UIButton *annotationButton;
@property (nonatomic, retain) IBOutlet UIButton *annotationBadge;
@property (nonatomic, retain) NSMutableDictionary *annotations;

@property (nonatomic, retain) IBOutlet UIButton *captureButton;
@property (nonatomic, retain) IBOutlet UIButton *cancelCaptureButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *captureActivity;

//Preview stuff
@property (nonatomic, retain) IBOutlet UIView *livePreviewView;
@property (nonatomic) BOOL hasLivePreview;


//Back View

-(IBAction) doneButtonPressed:(id)sender;

@property (nonatomic, retain) IBOutlet UIView *backView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *titleBarItem;

@property (nonatomic, retain) IBOutlet UILabel *annotationLabel1;
@property (nonatomic, retain) IBOutlet UILabel *annotationLabel2;
@property (nonatomic, retain) IBOutlet UILabel *annotationLabel3;
@property (nonatomic, retain) IBOutlet UILabel *annotationLabel4;

@property (nonatomic, retain) IBOutlet UISegmentedControl *annotation1;
@property (nonatomic, retain) IBOutlet UISegmentedControl *annotation2;
@property (nonatomic, retain) IBOutlet UISegmentedControl *annotation3;
@property (nonatomic, retain) IBOutlet UISegmentedControl *annotation4;

//Common and data
-(IBAction) flipToFront;
-(IBAction) flipToBack;

@property (nonatomic) BOOL sensorAvailable;
@property (nonatomic, assign) Capturer *capturer;
@property (nonatomic, assign) BiometricData *data;

@property (nonatomic) BOOL reconnectOptionsEnabled;

@property (nonatomic, assign) id<WsabiDeviceViewDelegate> delegate;

@end
