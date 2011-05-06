//
//  WsabiSensorController_iPad.h
//  Wsabi
//
//  Created by Matt Aronoff on 1/4/11.
//
/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


#import <UIKit/UIKit.h>
#import "Sensor.h"
#import "SensorModality.h"
#import "NBCLSensorLinkConstants.h"
#import "constants.h"
#import "WSBDModalityMap.h"

#import "AppDelegate_Shared.h"

#define kTextFieldTag 1001

#define kSensorSectionName 0
#define kSensorSectionNetwork 1
#define kSensorSectionModality 2
#define kSensorSectionParameters 3

@protocol WsabiSensorControllerDelegate <NSObject>
-(void) didAddSensor:(Sensor*)newSensor;
-(void) didModifySensor:(Sensor*)modifiedSensor;
@end

@interface WsabiSensorController_iPad : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {

	UITableView *tableView;
	
	NSMutableArray *selectedModalities;
	NSMutableArray *sortedParams;

	NSManagedObjectContext *managedObjectContext;
	
	Sensor *sensor;
	BOOL isNewSensor;
	
	//delegate
	id<WsabiSensorControllerDelegate> delegate;
}

- (BOOL)findAndResignFirstResonder: (UIView*) theView;

-(IBAction) cancelButtonPressed:(id)sender;
-(IBAction) saveButtonPressed:(id)sender;
//-(void) tableBackgroundPressed:(UITapGestureRecognizer*)recog;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *selectedModalities;
@property (nonatomic, retain) NSMutableArray *sortedParams;

@property (nonatomic, assign) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) Sensor *sensor;

//this is only true when we're creating a sensor on the fly inside this object.
//It affects which delegate method is called.
@property (nonatomic) BOOL isNewSensor;

@property (nonatomic, assign) id<WsabiSensorControllerDelegate> delegate;
@end
