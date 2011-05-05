//
//  WsabiMasterViewController_iPad.h
//  Wsabi
//
//  Created by Matt Aronoff on 10/20/10.
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

#import "Workflow.h"
#import "AppDelegate_iPad.h"
#import "WsabiWorkflowBuilderController_iPad.h"

@class WsabiDetailViewController_iPad;

@interface WsabiMasterViewController_iPad : UITableViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate, WsabiWorkflowEditorDelegate> {

	UIPopoverController *popoverController;
	UINavigationBar *collectionsNavBar;
	
    WsabiDetailViewController_iPad *detailViewController;
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    
    NSIndexPath *indexPathOfWorkflowToCopy;
}

@property (nonatomic, retain) IBOutlet WsabiDetailViewController_iPad *detailViewController;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UINavigationBar *collectionsNavBar;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)insertNewObject:(id)sender;
- (void)loadWorkflowAtIndexPath:(NSIndexPath*)indexPath;
- (void) editWorkflowAtIndexPath:(NSIndexPath*)indexPath copyFirst:(BOOL)copy;

-(IBAction) customAccessoryButtonTapped:(id)sender;

@end
