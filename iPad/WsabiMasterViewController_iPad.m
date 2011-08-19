//
//  WsabiMasterViewController_iPad.m
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


#import "WsabiMasterViewController_iPad.h"
#import "WsabiDetailViewController_iPad.h"

@implementation WsabiMasterViewController_iPad
@synthesize detailViewController, collectionsNavBar, fetchedResultsController, managedObjectContext;
@synthesize editActionSheet, renameActionSheet;
@synthesize popoverController;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
	
	//get a hook to the managed object context -- we can't do this in the delegate
	//itself because this object isn't instantiated until after the window is shown.
	if (managedObjectContext == nil) 
	{ 
        managedObjectContext = [(AppDelegate_iPad *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
        //NSLog(@"Connected MOC to master view controller: %@",  managedObjectContext);
	}
	
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	self.collectionsNavBar.topItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    UIBarButtonItem *addNewWorkflowButton = [[[UIBarButtonItem alloc] initWithTitle:@"+ New Workflow" style:UIBarButtonItemStyleBordered target:self action:@selector(addNewWorkflowButtonPressed:)] autorelease];
    [self setToolbarItems:[NSArray arrayWithObjects:flexSpace, addNewWorkflowButton, nil]];
    self.navigationController.toolbarHidden = NO;
}


/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.    
    return YES;
}


#pragma mark -
#pragma mark Add a new object

- (void)insertNewObject:(id)sender {
    
    NSIndexPath *currentSelection = [self.tableView indexPathForSelectedRow];
    if (currentSelection != nil) {
        [self.tableView deselectRowAtIndexPath:currentSelection animated:NO];
    }    
    
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    [newManagedObject setValue:[NSDate date] forKey:@"timestampCreated"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    NSIndexPath *insertionPath = [self.fetchedResultsController indexPathForObject:newManagedObject];
    [self.tableView selectRowAtIndexPath:insertionPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    self.detailViewController.workflow = (Workflow*)newManagedObject;
}

#pragma mark - Button action methods
-(IBAction) customAccessoryButtonTapped:(id)sender
{
    //just pass this action to the main "accessory tapped" handler.
    [self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:[NSIndexPath indexPathForRow:((UIView*)sender).tag inSection:0]];
}

-(IBAction)addNewWorkflowButtonPressed:(id)sender {
    //Load the workflow builder with a new workflow.
    WsabiWorkflowBuilderController_iPad *builder = [[[WsabiWorkflowBuilderController_iPad alloc] 
                                                     initWithNibName:@"WsabiWorkflowBuilderController_iPad" bundle:nil] 
                                                    autorelease];
    builder.managedObjectContext = self.managedObjectContext;
    builder.delegate = self;
    
    Workflow *newWorkflow = [NSEntityDescription insertNewObjectForEntityForName:@"Workflow" inManagedObjectContext:self.managedObjectContext];
    newWorkflow.timestampCreated = [NSDate date];
    newWorkflow.timestampModified = [NSDate date];
    //don't auto-set this.
    //newWorkflow.name = [NSString stringWithFormat:@"New Workflow %@",[newWorkflow.timestampCreated description]];
    builder.workflow = newWorkflow;
        
    //save the context (to make sure the new workflow is there even if there's a crash), dismiss the popover, then show the workflow builder.
    [(AppDelegate_Shared*)[[UIApplication sharedApplication] delegate] saveContext];
    
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    
    [self presentModalViewController:builder animated:YES];

}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.fetchedResultsController.fetchedObjects count]) {
		Workflow *w = (Workflow*)[self.fetchedResultsController objectAtIndexPath:indexPath];
		cell.imageView.image = nil;
		if (w.name) {
			cell.textLabel.text = w.name;
		}
		else {
			cell.textLabel.text = [NSString stringWithFormat:@"Workflow %@", w.timestampCreated];
		}
		
		if (w.timestampCreated) {
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"MM/dd/yyyy 'at' hh:mm a"];
            
			cell.detailTextLabel.text = [NSString stringWithFormat:@"Created %@\n%d collections", [format stringFromDate:w.timestampCreated], [w.collections count]];
            cell.detailTextLabel.numberOfLines = 2;
            cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
		}
		//cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        //Create a custom accessory button.
        UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        accessoryButton.bounds = CGRectMake(0, 0, cell.contentView.bounds.size.height, cell.contentView.bounds.size.height);
//        accessoryButton.titleLabel.font = [UIFont fontWithName:@"Glyphish" size:36];
        accessoryButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [accessoryButton addTarget:self action:@selector(customAccessoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
//        [accessoryButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//        [accessoryButton setTitle:@"q" forState:UIControlStateNormal]; //the one-gear configuration icon.
        //accessoryButton.showsTouchWhenHighlighted = YES;

        accessoryButton.alpha = 0.6;
        [accessoryButton setImage:[UIImage imageNamed:@"20-gear2"] forState:UIControlStateNormal];
        
        accessoryButton.tag = indexPath.row; //we'll use this to determine what to edit later.
        
        cell.accessoryView = accessoryButton;
        
	}
	else {
		//add a cell for the "Create new" action, making sure to set all other variables to match this cell style.
		cell.imageView.image = [UIImage imageNamed:@"favorites_48.png"];
		cell.textLabel.text = @"Create new workflow";
		cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
        cell.detailTextLabel.text = nil;
	}

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the managed object.
        NSManagedObject *objectToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if (self.detailViewController.workflow == objectToDelete) {
            self.detailViewController.workflow = nil;
        }
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:objectToDelete];
        
        NSError *error;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    //don't allow the user to edit the "Add new collection" cell.
    return (indexPath.row < [self.fetchedResultsController.fetchedObjects count]);

}

#pragma mark -
#pragma mark Table view delegate
- (void)loadWorkflowAtIndexPath:(NSIndexPath*)indexPath
{
	//TODO: Complete the workflow loading process.
	if (indexPath.row < [self.fetchedResultsController.fetchedObjects count]) {
		// Set the detail item in the detail view controller.
		NSManagedObject *selectedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
		self.detailViewController.workflow = (Workflow*)selectedObject;    
		
	}
	else {
		//Load the workflow builder with a new workflow.
		WsabiWorkflowBuilderController_iPad *builder = [[[WsabiWorkflowBuilderController_iPad alloc] 
														initWithNibName:@"WsabiWorkflowBuilderController_iPad" bundle:nil] 
													   autorelease];
		builder.managedObjectContext = self.managedObjectContext;
        builder.delegate = self;

		Workflow *newWorkflow = [NSEntityDescription insertNewObjectForEntityForName:@"Workflow" inManagedObjectContext:self.managedObjectContext];
		newWorkflow.timestampCreated = [NSDate date];
		newWorkflow.timestampModified = [NSDate date];
        //don't auto-set this.
		//newWorkflow.name = [NSString stringWithFormat:@"New Workflow %@",[newWorkflow.timestampCreated description]];
		builder.workflow = newWorkflow;
        
        //deselect the cell in this case.
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		//save the context (to make sure the new workflow is there even if there's a crash), dismiss the popover, then show the workflow builder.
		[(AppDelegate_Shared*)[[UIApplication sharedApplication] delegate] saveContext];
		
		if (self.popoverController) {
			[self.popoverController dismissPopoverAnimated:YES];
		}
		
		[self presentModalViewController:builder animated:YES];
        
	}

	
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self loadWorkflowAtIndexPath:indexPath];
    //dismiss the popover.
    [self.popoverController dismissPopoverAnimated:YES];
 }

//Called when the accessory button is tapped for an existing workflow
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{	
    Workflow *activeWorkflow = (Workflow*) [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([activeWorkflow.collections count] > 0) {
        //we need to copy this workflow first.
        indexPathOfWorkflowToCopy = indexPath;
        self.editActionSheet = [[[UIActionSheet alloc] initWithTitle:@"This workflow already contains data, so it can't be modified directly." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Rename",@"Edit a copy", nil] autorelease];
        [self.editActionSheet showInView:self.view];
    }
    else
        [self editWorkflowAtIndexPath:indexPath copyFirst:NO];
}

- (void) editWorkflowAtIndexPath:(NSIndexPath*)indexPath copyFirst:(BOOL)copy
{
    Workflow *activeWorkflow = (Workflow*) [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (copy) {

        Workflow *newWorkflow = [activeWorkflow deepCopy];
        activeWorkflow = newWorkflow;
    }

    
	//Load the workflow builder with this workflow loaded.
	WsabiWorkflowBuilderController_iPad *builder = [[[WsabiWorkflowBuilderController_iPad alloc] 
													initWithNibName:@"WsabiWorkflowBuilderController_iPad" bundle:nil] 
												   autorelease];
	builder.managedObjectContext = self.managedObjectContext;
	builder.delegate = self;
	
	//dismiss the popover, then show the workflow builder.
    
	activeWorkflow.timestampModified = [NSDate date]; //update the modification time for this workflow.
	builder.workflow = activeWorkflow;
	if (self.popoverController) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	
	[self presentModalViewController:builder animated:YES];

}


#pragma mark -
#pragma mark Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.editActionSheet && buttonIndex != actionSheet.cancelButtonIndex && indexPathOfWorkflowToCopy) {
        
        switch (buttonIndex) {
            case 0:
                //edit name
                
                break;
            case 1:
                //edit a copy
                //copy the managed object and load it.
                [self editWorkflowAtIndexPath:indexPathOfWorkflowToCopy copyFirst:YES];
                //clear the pointer to the copyable workflow.
                indexPathOfWorkflowToCopy = nil;
                break;
            default:
                break;
        }
     }
}

#pragma mark -
#pragma mark Workflow Editor Delegate
-(void) didEditWorkflow:(Workflow*)w
{
	//for now, just reload all the cell data.
	[self.tableView reloadData];

	//DON'T AUTOLOAD.
//	if (self.detailViewController) {
//		self.detailViewController.workflow = w; //load this workflow.
//	}
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Workflow" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestampCreated" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
    return fetchedResultsController;
}    


#pragma mark -
#pragma mark Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

-(void) viewWillDisappear:(BOOL)animated {
    //return this controller to non-editing mode.
    [self setEditing:NO];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[popoverController release];
	[detailViewController release];
	[collectionsNavBar release];
    [fetchedResultsController release];
    [managedObjectContext release];

    [editActionSheet release];
    [renameActionSheet release];
	
    [super dealloc];
}


@end

