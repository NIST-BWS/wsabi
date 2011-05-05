//
//  WsabiCaptureTypePickerController.h
//  Wsabi
//
//  Created by Matt Aronoff on 2/10/11.
//
/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


#import <UIKit/UIKit.h>
#import "constants.h"
#import "WSBDModalityMap.h"

@protocol WsabiCaptureTypeSelectorDelegate <NSObject>

-(void) didSelectCaptureType:(int)captureType;

@end

@interface WsabiCaptureTypePickerController : UITableViewController {
    UIPopoverController *popoverController;
    SensorModalityType modality;
    SensorCaptureType submodality;
    
    id<WsabiCaptureTypeSelectorDelegate> delegate;
}

-(IBAction) doneButtonPressed:(id)sender;
//-(CGSize) minimumSizeForContent;


@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic) SensorModalityType modality;
@property (nonatomic) SensorCaptureType submodality;

@property (nonatomic, assign) id<WsabiCaptureTypeSelectorDelegate> delegate;

@end
