//
//  WsabiWorkflowItem.h
//  Wsabi
//
//  Created by Matt Aronoff on 1/3/11.
//
/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>

#import "Capturer.h"
#import "Sensor.h"
#import "constants.h"
#import "WSBDModalityMap.h"

#import "UIView+UserTesting.h"

@protocol WsabiWorkflowItemDelegate <NSObject>
-(void) didRequestCaptureTypeChangeForCapturer:(Capturer*)cap;

@end


@interface WsabiWorkflowItem : UIView <UITableViewDelegate, UITableViewDataSource> {
	Capturer *capturer;
	NSMutableArray *currentParamKeys;
	NSMutableArray *currentParamValues;
	
	UIButton *modalityDisplay;
	UITableView *paramTable;
    
    UIButton *captureTypeButton;
    
    id<WsabiWorkflowItemDelegate> delegate;
}

-(void) updateParams;
-(void) addParamValue:(id)value forKey:(id)key;
-(BOOL) removeParamValueForKey:(id)key;
-(void) clearParams;

-(IBAction) captureTypeButtonPressed:(id)sender;

@property (nonatomic, assign) Capturer *capturer;
@property (nonatomic, retain) NSMutableArray *currentParamKeys;
@property (nonatomic, retain) NSMutableArray *currentParamValues;

@property (nonatomic, retain) IBOutlet UIButton *modalityDisplay;
@property (nonatomic, retain) IBOutlet UITableView *paramTable;
@property (nonatomic, retain) IBOutlet UIButton *captureTypeButton;

@property (nonatomic, assign) id<WsabiWorkflowItemDelegate> delegate;

@end
