//
//  WsabiWorkflowBuilderController_iPad.h
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
#import "AQGridView.h"
#import "AQGridViewCell.h"
#import "WsabiWorkflowBuilderCell.h"
#import "WsabiSensorController_iPad.h"
#import "WsabiCaptureTypePickerController.h"
#import "AppDelegate_Shared.h"

#import "Workflow.h"

@protocol WsabiWorkflowEditorDelegate <NSObject>
-(void) didEditWorkflow:(Workflow*)w;
@end

@interface WsabiWorkflowBuilderController_iPad : UIViewController <UITableViewDelegate, UITableViewDataSource, 
																	AQGridViewDelegate, AQGridViewDataSource, 
																	UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate,
																	UITextFieldDelegate, 
                                                                    WsabiSensorControllerDelegate, WsabiCaptureTypeSelectorDelegate,
                                                                    WsabiWorkflowItemDelegate, WsabiWorkflowBuilderCellDelegate
> 
{
	UIToolbar *topToolbar;
    UIPopoverController *popoverController;
    
	UITextField *titleTextField;
    UIBarButtonItem *doneButton;
	
	UITableView *sensorTable;
	UINavigationBar *sensorNavBar;
	AQGridView *workflowGrid;
    UIView *helpView;
        
	NSMutableArray *capturers;
	
    NSUInteger _emptyCellIndex;
    
    NSUInteger _dragOriginIndex;
    CGPoint _dragOriginCellOrigin;
    
	Capturer *tempDraggedCapturer;
    WsabiWorkflowItem *tempDraggedItem;
    UIView *dragPositionIndicator;
    Capturer *currentCapturer; //this is a pointer to allow delegates to access the proper capturer (to edit properties, etc.)
    
    WsabiWorkflowBuilderCell * _draggingCell;	
	
	NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;

	Workflow *workflow;

	//delegate
	id<WsabiWorkflowEditorDelegate> delegate;

}
-(void) refetchData;
-(void) refreshOrderedCapturers;
-(int) workflowIndexForInsertionPoint:(CGPoint)point;
-(void) updateCapturerIndices;

-(IBAction) addSensorButtonPressed:(id)sender;
-(IBAction) editSensorsButtonPressed:(id)sender;

-(IBAction) cancelButtonPressed:(id)sender;
-(IBAction) editButtonPressed:(id)sender;
-(IBAction) doneButtonPressed:(id)sender;

-(IBAction) customAccessoryButtonTapped:(id)sender;

//gesture recognizer action methods
-(void) handleTableLongPress:(UILongPressGestureRecognizer*)recog;

@property (nonatomic, retain) IBOutlet UIToolbar *topToolbar;
@property (nonatomic, retain) IBOutlet UIPopoverController *popoverController;

@property (nonatomic, retain) IBOutlet UITextField *titleTextField;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, retain) IBOutlet UITableView *sensorTable;
@property (nonatomic, retain) IBOutlet UINavigationBar *sensorNavBar;
@property (nonatomic, retain) IBOutlet AQGridView *workflowGrid;
@property (nonatomic, retain) IBOutlet UIView *helpView;

@property (nonatomic, assign) Capturer *tempDraggedCapturer;
@property (nonatomic, retain) WsabiWorkflowItem *tempDraggedItem;
@property (nonatomic, retain) UIView *dragPositionIndicator;
@property (nonatomic, assign) Capturer *currentCapturer;

@property (nonatomic, assign) Workflow *workflow;
@property (nonatomic, retain) NSMutableArray *capturers;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
//NOTE: We don't hang on to this, because it's being retained by the master view controller,
//and there are some situations in which I've had double-free issues if retaining the context
//from two views which may, in some cases (memory constraints) be destroyed and recreated at around the same time.
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, assign) id<WsabiWorkflowEditorDelegate> delegate;

@end
