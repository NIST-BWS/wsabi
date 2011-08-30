//
//  WsabiWorkflowBuilderController_iPad.m
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


// NOTE: A pretty big chunk of this is taken from the AQGridView SpringBoard example.

#import "WsabiWorkflowBuilderController_iPad.h"

//FIXME: Obviously, defines like this suck.
#define WORKFLOW_CELL_HEIGHT 300.0

@implementation WsabiWorkflowBuilderController_iPad
@synthesize topToolbar, popoverController, sensorListActionSheet, sensorListActionIndexPath;
@synthesize noTitlePromptField, titleTextField, doneButton;
@synthesize sensorTable, sensorNavBar, workflowGrid, helpView;
@synthesize tempDraggedCapturer, tempDraggedItem, currentCapturer, dragPositionIndicator;
@synthesize workflow, capturers, fetchedResultsController, managedObjectContext;
@synthesize delegate;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Configure the top toolbar
	
	UIBarButtonItem *flexibleSpaceButtonItem = [[UIBarButtonItem alloc]
												initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
												target:nil action:nil];
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                       target:self action:@selector(cancelButtonPressed:)];

//	self.doneButton = [[UIBarButtonItem alloc]
//										 initWithBarButtonSystemItem:UIBarButtonSystemItemDone
//										 target:self action:@selector(doneButtonPressed:)];
    
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    
    self.doneButton.enabled = NO; //start with this disabled, and only re-enable it if there's already content in the workflow.
	
	//add an editable text field to the center.
	self.titleTextField = [[[UITextField alloc] initWithFrame:CGRectMake(0, 0, 500, 26)] autorelease];
	self.titleTextField.borderStyle = UITextBorderStyleNone;
	self.titleTextField.textColor = [UIColor whiteColor];
	self.titleTextField.textAlignment = UITextAlignmentCenter;
	self.titleTextField.backgroundColor = [UIColor clearColor];
	self.titleTextField.opaque = NO;
	self.titleTextField.delegate = self;
    self.titleTextField.returnKeyType = UIReturnKeyDone;
	[self.titleTextField setFont:[UIFont boldSystemFontOfSize:22]];
	    
	//set placeholder title text.
	//self.titleTextField.placeholder = @"Tap here to name workflow";
	
	UIBarButtonItem *textFieldItem = [[UIBarButtonItem alloc] initWithCustomView:self.titleTextField];
	
	// Set our toolbar items
	self.topToolbar.items = [NSArray arrayWithObjects:
                          cancelButtonItem,
                         flexibleSpaceButtonItem,
                         textFieldItem,
                         flexibleSpaceButtonItem,
                         self.doneButton,
                         nil];
	
	//configure the sensor list's nav bar.
	//self.sensorNavBar.topItem.leftBarButtonItem = self.editButtonItem;

	//we need to fetch data so we have something to put in the table view.
    [self refetchData];
	
	_emptyCellIndex = NSNotFound;
	self.workflowGrid.backgroundColor = [UIColor clearColor];
    self.workflowGrid.opaque = NO;
    self.workflowGrid.topContentInset = 30;
    
    //create a drag position indicator for adding new workflow items.
    self.dragPositionIndicator = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.workflowGrid.bounds.size.width, 4)] autorelease];
    self.dragPositionIndicator.backgroundColor = [UIColor whiteColor];
    self.dragPositionIndicator.alpha = 0;
    [self.workflowGrid addSubview:self.dragPositionIndicator];
    
	// add our gesture recognizer to the grid view to allow rearranging capturers
    UILongPressGestureRecognizer * gr = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(moveActionGestureRecognizerStateChanged:)];
    gr.minimumPressDuration = 0.2;
    gr.delegate = self;
    [self.workflowGrid addGestureRecognizer: gr];
    [gr release];
    
 	[self refreshOrderedCapturers];

    //start with the title selected.
    [self.titleTextField becomeFirstResponder];

	//Load miscellaneous workflow info from Core Data into the UI.
	if (workflow) 
	{

        if (!workflow.name) {
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"'Workflow' MM.dd.yyyy'-'HH:mm"];

            workflow.name = [format stringFromDate:[NSDate date]]; //stamp this with the current date.
        }

		self.titleTextField.text = workflow.name;
         
        if ([workflow.capturers count] > 0) {
            //hide the help view.
            self.helpView.alpha = 0;
            //enable the done button.
            self.doneButton.enabled = YES;
        }
        else
        {
            self.helpView.alpha = 1;
        }

 	}
	

	[self.workflowGrid reloadData];
    
    //update the sensor table.
    self.sensorTable.alwaysBounceVertical = NO;
    [self.sensorTable reloadData];
    
    //clean up
    [flexibleSpaceButtonItem release];
	[textFieldItem release];
    
}


//need to override setEditing:animated: to pass the message to our custom sensor table view.
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[self.sensorTable setEditing:editing animated:animated];
	
    // pass the "editing" state up to the base class
    [super setEditing:editing animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //recalculate the dimensions of the drag position indicator
    self.dragPositionIndicator.frame = CGRectMake(0, 0, self.workflowGrid.bounds.size.width, 4);
}

-(void) refetchData
{
    //Get or update the data from Core Data.
	NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

}


-(void) refreshOrderedCapturers
{
	if ( self.capturers == nil )
    {
        self.capturers = [[[NSMutableArray alloc] init] autorelease];
	}
	else {
		[self.capturers removeAllObjects];
	}

	//Sort the existing capturers for this workflow by their stated order.
	NSSortDescriptor *orderSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"positionInWorkflow" ascending:YES selector:@selector(compare:)] autorelease];
	
    NSArray *sortDescriptors = [NSArray arrayWithObject:orderSortDescriptor];
	
	self.capturers = [[self.workflow.capturers sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
	
}

//Returns the (possibly rounded) workflow insert position given a point in the workflowGrid's
//coordinate system.
-(int) workflowIndexForInsertionPoint:(CGPoint)point
{
    //make sure we don't allow an abnormally large number here if the drop point is very far down the page.
	return MIN(round(point.y / WORKFLOW_CELL_HEIGHT), [self.capturers count]); 
}

//examine the current capturer order and update Core Data to match
-(void) updateCapturerIndices
{
	//update indices based on each capturer's position in the array.
	for (int i = 0; i < [self.capturers count]; i++) {
		((Capturer*)[self.capturers objectAtIndex:i]).positionInWorkflow = [NSNumber numberWithInt: i];
	}
}

#pragma mark -
#pragma mark Button Action methods
-(IBAction)backgroundTapped:(UITapGestureRecognizer*)recog
{
    //dismiss the title editor if it's showing.
    [self.titleTextField resignFirstResponder];
    
    [self.view removeGestureRecognizer:backgroundTap];
}

-(IBAction) addSensorButtonPressed:(id)sender
{
	//NOTE: The sensor editor makes use of Core Data's rollback method (which discards everything back to the last commit), 
	//so we need to make sure we've committed all the changes we want to keep
	//prior to opening it.
	[(AppDelegate_Shared*)[[UIApplication sharedApplication] delegate] saveContext];
	
	WsabiSensorController_iPad *sensorEditor = [[[WsabiSensorController_iPad alloc] initWithNibName:@"WsabiSensorController_iPad" bundle:nil] autorelease];

	//FIXME: There's a bug in the iOS SDK which means that the resignFirstResponder call doesn't hide
	//the keyboard when presenting a modal view as a Form Sheet (the user has to hide it manually).  However, all of the other presentation
	//styles are much too big, so we've got to stick with it until there's an alternative.
	//(http://stackoverflow.com/questions/3699868/uitextfield-resignfirstresponder-but-keybord-will-not-disappear )
	sensorEditor.modalPresentationStyle = UIModalPresentationFormSheet;
	sensorEditor.managedObjectContext = self.managedObjectContext;
	sensorEditor.delegate = self;
	//since we're not specifying a sensor to edit, the sensor editor will start working on a new sensor.
	[self presentModalViewController:sensorEditor animated:YES];
}

-(IBAction) editSensorsButtonPressed:(id)sender
{
    //edit the sensors table view (on the left)
	[self.sensorTable setEditing:!self.sensorTable.editing animated:YES];

}

-(IBAction) editButtonPressed:(id)sender
{
    //Edit the current list of capturers.
    NSLog(@"Toggling editable state of workflow grid.");
    [self.workflowGrid setEditing:!self.workflowGrid.editing];

    if (self.workflowGrid.editing) {
        ((UIBarButtonItem*)sender).title = @"Done";
        ((UIBarButtonItem*)sender).style = UIBarButtonItemStyleDone;
    }
    else
    {
        ((UIBarButtonItem*)sender).title = @"Edit";
        ((UIBarButtonItem*)sender).style = UIBarButtonItemStyleBordered;
    }
}


-(IBAction) cancelButtonPressed:(id)sender
{
	//Remove this workflow if there's nothing in it and the user presses the cancel button.
    [[self.workflow managedObjectContext] deleteObject:self.workflow];
    
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction) doneButtonPressed:(id)sender
{
	
	//make sure we've got the current workflow name (in case the title field hasn't resigned first responder)
	if (self.workflow) {
		self.workflow.name = self.titleTextField.text;
	}
	
    //if there's no workflow name, we need to prompt the user for one.
    if (!self.workflow.name || [self.workflow.name isEqualToString:@""]) {
        UIAlertView *myAlertView = [[[UIAlertView alloc] initWithTitle:@"Name the workflow"
                                                               message:@"this gets covered" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil] autorelease];
        self.noTitlePromptField = [[[UITextField alloc] initWithFrame:CGRectMake(14.0, 45.0, 256.0, 31.0)] autorelease];
        self.noTitlePromptField.borderStyle = UITextBorderStyleRoundedRect;
        self.noTitlePromptField.delegate = self;
        self.noTitlePromptField.returnKeyType = UIReturnKeyDone;
        self.noTitlePromptField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.noTitlePromptField setBackgroundColor:[UIColor clearColor]];

        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"'Workflow' MM.dd.yyyy'-'HH:mm"];
        
        self.noTitlePromptField.text = [format stringFromDate:[NSDate date]]; //stamp this with the current date.
        
        [self.noTitlePromptField becomeFirstResponder];
        
        [myAlertView addSubview:self.noTitlePromptField];
        [myAlertView show];
    }
    else {
        //Notify our delegate and close this controller.
        
        [delegate didEditWorkflow:self.workflow];
        [self dismissModalViewControllerAnimated:YES];

    }
}

-(IBAction) customAccessoryButtonTapped:(id)sender
{
    [self showEditorForSensorAtIndexPath:[NSIndexPath indexPathForRow:((UIView*)sender).tag inSection:0]];
}

-(IBAction) showEditorForSensorAtIndexPath:(NSIndexPath*)indexPath
{
    //NOTE: The sensor editor makes use of Core Data's rollback method (which discards everything back to the last commit), 
	//so we need to make sure we've committed all the changes we want to keep
	//prior to opening it.
	[(AppDelegate_Shared*)[[UIApplication sharedApplication] delegate] saveContext];
	
	WsabiSensorController_iPad *sensorEditor = [[[WsabiSensorController_iPad alloc] initWithNibName:@"WsabiSensorController_iPad" bundle:nil] autorelease];
	
	//FIXME: There's a bug in the iOS SDK which means that the resignFirstResponder call doesn't hide
	//the keyboard when presenting a modal view as a Form Sheet (the user has to hide it manually).  However, all of the other presentation
	//styles are much too big, so we've got to stick with it until there's an alternative.
	//(http://stackoverflow.com/questions/3699868/uitextfield-resignfirstresponder-but-keybord-will-not-disappear )
    
    //UPDATE: The above issue is fixed by overriding disablesAutomaticKeyboardDismissal: in the sensor controller.
	sensorEditor.modalPresentationStyle = UIModalPresentationFormSheet;
	sensorEditor.managedObjectContext = self.managedObjectContext;
	sensorEditor.delegate = self;
	
	sensorEditor.sensor = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
	
	[self presentModalViewController:sensorEditor animated:YES];

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
    
    Sensor *sensor = (Sensor*)[self.fetchedResultsController objectAtIndexPath:indexPath];
	
	if (sensor.name) {
		cell.textLabel.text = sensor.name;
	}
	else {
		cell.textLabel.text = [NSString stringWithFormat:@"Sensor %@",sensor.timestampCreated];
	}
	
	if (sensor.uri) {
		cell.detailTextLabel.text = sensor.uri;
	}
	else {
		cell.detailTextLabel.text = @"No address yet";
	}

	//cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

//    //Create a custom accessory button.
//    UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    accessoryButton.bounds = CGRectMake(0, 0, 26, 26);
//    //accessoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    [accessoryButton addTarget:self action:@selector(customAccessoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    
////    [accessoryButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
////    [accessoryButton setTitle:@"Q" forState:UIControlStateNormal]; //the one-gear configuration icon.
//    //accessoryButton.showsTouchWhenHighlighted = YES;
//    accessoryButton.alpha = 0.6;
//    [accessoryButton setImage:[UIImage imageNamed:@"19-gear"] forState:UIControlStateNormal];
//    
//    accessoryButton.tag = indexPath.row; //we'll use this to determine what to edit later.
//
//    cell.accessoryView = accessoryButton;
//    
//    //don't show standard cell selection here.
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		//add a long press listener to each cell when it's first created to handle dragging.
        UILongPressGestureRecognizer *tempDrag = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTableLongPress:)];
        //tempDrag.cancelsTouchesInView = NO; //this allows normal operation of the table.
        tempDrag.allowableMovement = 1024; //allow this to be used for drags as well.
        [cell.contentView addGestureRecognizer:tempDrag];
        [tempDrag release];
		
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//   if (editingStyle == UITableViewCellEditingStyleDelete) {
//        
//        // Delete the managed object.
//        NSManagedObject *objectToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
//        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//        [context deleteObject:objectToDelete];
//        
//        NSError *error;
//        if (![context save:&error]) {
//            /*
//             Replace this implementation with code to handle the error appropriately.
//             
//             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
//             */
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//       
//       //update the fetched results controller so that when we update the table UI, the number of results will match.
//       [self refetchData];
//       
//       //update the UI.
//       [self.sensorTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
//    }   
//}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Show an action sheet to allow the user to either add a sensor instance to the list,
    //or edit the sensor's properties.
    if (!self.sensorListActionSheet) {
        self.sensorListActionSheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add to workflow",@"Edit properties", nil] autorelease];
    }
    self.sensorListActionIndexPath = indexPath;
    [self.sensorListActionSheet showFromRect:[aTableView rectForRowAtIndexPath:indexPath] inView:aTableView animated:YES];

    //deselect the row.
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self showEditorForSensorAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.sensorListActionSheet && buttonIndex != actionSheet.cancelButtonIndex) {
 
        switch (buttonIndex) {
            case 0:
                //add to workflow
                self.helpView.alpha = 0.0;
                                
                //create a new capturer for this drag.
                Capturer *tempCapturer = [NSEntityDescription insertNewObjectForEntityForName:@"Capturer" inManagedObjectContext:self.managedObjectContext];
                tempCapturer.sensor = (Sensor*)[self.fetchedResultsController objectAtIndexPath:self.sensorListActionIndexPath]; //connect this to the sensor the user chose.
                tempCapturer.workflow = self.workflow;

                [self.workflow addCapturersObject:tempCapturer];
                
                //add the capturer to the end of the ordered array.
                NSLog(@"Should be adding new object to the end of the capturers array");
                [self.capturers addObject:tempCapturer];
                
                //update the indices in Core Data before re-fetching.
                [self updateCapturerIndices];
                
                //refetch data from Core data so that we have the correct number of capturers.
                NSError *error = nil;
                if (![self.fetchedResultsController performFetch:&error]) {
                    /*
                     Replace this implementation with code to handle the error appropriately.
                     
                     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
                     */
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                
                //refresh the list of capturers based on Core Data.
                //NOTE: This will probably be redundant most of the time,
                //because we're making manual changes to self.capturers.
                //It's basically to make sure things stay in sync.
                [self refreshOrderedCapturers];
                
                //refresh the grid.
                [self.workflowGrid reloadData];
                
                //scroll everything so that this cell is visible.
                [self.workflowGrid scrollToItemAtIndex:([self.workflow.capturers count] - 1)
                                      atScrollPosition:AQGridViewScrollPositionNone animated:YES];
                
                //enable the "Done" button in case it wasn't already.
                self.doneButton.enabled = YES;
                
                //Show the capture type selector
                [self didRequestCaptureTypeChangeForCapturer:tempCapturer];

                break;
            case 1:
                //edit properties.
                [self showEditorForSensorAtIndexPath:self.sensorListActionIndexPath];
                break;
            default:
                break;
        }
        
    }
    
    //No matter what the user clicked, we need to clear the stored index path here.
    self.sensorListActionIndexPath = nil;
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        
        if (!self.noTitlePromptField.text || [self.noTitlePromptField.text isEqualToString:@""] ) {
            UIAlertView *myAlertView = [[[UIAlertView alloc] initWithTitle:@"Name the workflow"
                                                                   message:@"this gets covered" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil] autorelease];
            self.noTitlePromptField = [[[UITextField alloc] initWithFrame:CGRectMake(14.0, 45.0, 256.0, 31.0)] autorelease];
            self.noTitlePromptField.borderStyle = UITextBorderStyleRoundedRect;
            self.noTitlePromptField.delegate = self;
            self.noTitlePromptField.returnKeyType = UIReturnKeyDone;
            self.noTitlePromptField.clearButtonMode = UITextFieldViewModeWhileEditing;
            [self.noTitlePromptField setBackgroundColor:[UIColor clearColor]];
            
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"'Workflow' MM.dd.yyyy'-'HH:mm"];
            
            self.noTitlePromptField.text = [format stringFromDate:[NSDate date]]; //stamp this with the current date.
            
            [self.noTitlePromptField becomeFirstResponder];
            
            [myAlertView addSubview:self.noTitlePromptField];
            [myAlertView show];
        }
        else {
            //update the title, notify the delegate, and dismiss this controller.
            self.workflow.name = self.noTitlePromptField.text;
            
            [delegate didEditWorkflow:self.workflow];
            [self dismissModalViewControllerAnimated:YES];

        }
    }
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Sensor" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestampCreated" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //Note that we're setting a different cache name than the root fetched results controller (in the master view controller),
	//which is fetching workflows -- this one will fetch all sensors that we've stored.
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								managedObjectContext:managedObjectContext 
																								  sectionNameKeyPath:nil cacheName:@"Sensors"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
    return fetchedResultsController;
}    



#pragma mark -
#pragma mark GridView Data Source
- (NSUInteger) numberOfItemsInGridView: (AQGridView *) gridView
{
    return [self.capturers count];
}

- (AQGridViewCell *) gridView: (AQGridView *) gridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString * EmptyIdentifier = @"EmptyIdentifier";
    static NSString * CellIdentifier = @"CellIdentifier";
    
    if ( index == _emptyCellIndex )
    {
        NSLog( @"Loading empty cell at index %u", index );
        AQGridViewCell * hiddenCell = [gridView dequeueReusableCellWithIdentifier: EmptyIdentifier];
        if ( hiddenCell == nil )
        {
            // must be the SAME SIZE AS THE OTHERS
            // Yes, this is probably a bug. Sigh. Look at -[AQGridView fixCellsFromAnimation] to fix
            hiddenCell = [[[AQGridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 508.0, WORKFLOW_CELL_HEIGHT)
                                                reuseIdentifier: EmptyIdentifier] autorelease];
        }
        
        hiddenCell.hidden = YES;
        return ( hiddenCell );
    }
    
    WsabiWorkflowBuilderCell * cell = (WsabiWorkflowBuilderCell *)[gridView dequeueReusableCellWithIdentifier: CellIdentifier];
    if ( cell == nil )
    {
        cell = [[[WsabiWorkflowBuilderCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 508.0, WORKFLOW_CELL_HEIGHT) reuseIdentifier: CellIdentifier] autorelease];
    }
    
    cell.capturer = [self.capturers objectAtIndex: index];
    //connect the delegate from the actual workflow item to ourselves, so we can respond
    //to button presses, etc. from inside the workflow item.
    cell.capView.delegate = self;
    //connect the overall cell's delegate to ourselves as well, so we can respond
    //to deletion requests.
    cell.delegate = self;
    
    return ( cell );
}

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) gridView
{
    return ( CGSizeMake(508.0, WORKFLOW_CELL_HEIGHT) );
}

#pragma mark -
#pragma mark UITextFieldDelegate methods
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.titleTextField) {
        
        //add a gesture recognizer to resign the first responder if anything besides this field is selected.
        backgroundTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)] autorelease];
        backgroundTap.numberOfTapsRequired = 1;
        [self.view addGestureRecognizer:backgroundTap];
        
        [self.titleTextField selectAll:self.titleTextField];
        [UIMenuController sharedMenuController].menuVisible = NO; //hide the cut/copy/paste menu

    }
 }

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.noTitlePromptField) {
        //don't do any additional data processing here.
    }
    else {
        //set the workflow name to match the new value.
        if (self.workflow) {
            self.workflow.name = textField.text;
        }
    }

    //If the global gesture recognizer is in place, remove it.
    if ([self.view.gestureRecognizers containsObject:backgroundTap]) {
        [self.view removeGestureRecognizer:backgroundTap];
    }
    
    [self.view removeGestureRecognizer:backgroundTap];

	
	[textField resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark UIGestureRecognizer Delegate/Actions for table dragging.
-(void) handleTableLongPress:(UILongPressGestureRecognizer*)recog
{
	if (recog.state == UIGestureRecognizerStateBegan) {
		NSIndexPath *draggedPath = [self.sensorTable indexPathForRowAtPoint:[recog locationInView:self.sensorTable]];
		
		//create a new capturer for this drag.
		self.tempDraggedCapturer = [NSEntityDescription insertNewObjectForEntityForName:@"Capturer" inManagedObjectContext:self.managedObjectContext];
		self.tempDraggedCapturer.sensor = (Sensor*)[self.fetchedResultsController objectAtIndexPath:draggedPath];
		self.tempDraggedCapturer.workflow = self.workflow;
		        
		//create a matching view.
		self.tempDraggedItem = [[[NSBundle mainBundle] loadNibNamed:@"WsabiWorkflowItem" owner:self options:nil] objectAtIndex:0];
		self.tempDraggedItem.capturer = self.tempDraggedCapturer;
				
		//fade the view in.
		[self.view addSubview:self.tempDraggedItem];
		self.tempDraggedItem.alpha = 0.0;
		CGPoint location = [recog locationInView:self.view];
		self.tempDraggedItem.frame = CGRectMake(location.x, location.y, 0, 0);
		[UIView animateWithDuration:0.3
						 animations:^{ 
							 self.tempDraggedItem.alpha = 0.6;
							 self.tempDraggedItem.bounds = CGRectMake(0, 0, 430, 270);
                             self.tempDraggedItem.transform = CGAffineTransformMakeScale(0.33, 0.33);
							 self.tempDraggedItem.center = location;
						 }
                         completion:^(BOOL completed) {
                             //make sure we haven't let go while animating.
                             if (recog.state != UIGestureRecognizerStateBegan && recog.state != UIGestureRecognizerStateChanged) {
                                 NSLog(@"Need to be hiding the dragged preview here.");
                                 //Hide the temporary object, the help view, and the drag position indicator.
                                 [UIView animateWithDuration:0.3
                                                  animations:^{ 
                                                      self.tempDraggedItem.alpha = 0.0;
                                                     self.tempDraggedItem.center = CGPointMake(-400, -WORKFLOW_CELL_HEIGHT);
                                                    
                                                      self.tempDraggedItem.transform = CGAffineTransformIdentity;
                                                      self.dragPositionIndicator.alpha = 0.0;
                                                      
                                                  }
                                                  completion:^(BOOL finished){ 
                                                      [self.tempDraggedItem removeFromSuperview];
                                                      self.tempDraggedItem = nil;
                                                      //remove the temporary capturer we created at the start of this gesture.
                                                      [self.managedObjectContext deleteObject:self.tempDraggedCapturer];
                                                  }
                                  ];

                             }
                         }
         ];
        
        self.dragPositionIndicator.hidden =  ![self.workflowGrid pointInside:[recog locationInView:self.workflowGrid] withEvent:nil];
		self.dragPositionIndicator.alpha = 1.0;
	}
	
	
	else if (recog.state == UIGestureRecognizerStateChanged) {
		//just move the temporary view.
		self.tempDraggedItem.center = [recog locationInView:self.view];
        
        //position the drag position indicator; cap it to the maximum number of cells already in the table.
        float cellHeight = [self portraitGridCellSizeForGridView:self.workflowGrid].height;
        float indicatorHeight = MIN(self.workflowGrid.topContentInset + cellHeight * [self.capturers count],self.workflowGrid.topContentInset + cellHeight * round([recog locationInView:self.workflowGrid].y/cellHeight));
        self.dragPositionIndicator.center = CGPointMake(self.dragPositionIndicator.center.x, indicatorHeight);
        
        //only show the indicator if dropping the object here is valid.
        self.dragPositionIndicator.hidden =  ![self.workflowGrid pointInside:[recog locationInView:self.workflowGrid] withEvent:nil];
	}
			
	//drop and add the new object to the workflow.
	else if (recog.state == UIGestureRecognizerStateEnded)
	{
        CGPoint location = [recog locationInView:self.view];
		//move the temporary view to the right ending spot.
		self.tempDraggedItem.center = location;
		
        //If this is over the workflow grid, allow the drop.
        BOOL validDrop = NO;
        if ([self.workflowGrid pointInside:[recog locationInView:self.workflowGrid] withEvent:nil] ) {
            validDrop = YES;
        }

        int insertionIndex = -1;
        insertionIndex = [self workflowIndexForInsertionPoint:[recog locationInView:self.workflowGrid]];

        //Hide the temporary object, the help view, and the drag position indicator.
		[UIView animateWithDuration:0.3
						 animations:^{ 
							 self.tempDraggedItem.alpha = 0.0;
							 //self.tempDraggedItem.bounds = CGRectMake(0, 0, 0, 0);
                             if (validDrop) {
                                 self.tempDraggedItem.center = CGPointMake(workflowGrid.center.x, workflowGrid.frame.origin.y + ((insertionIndex + 1) * WORKFLOW_CELL_HEIGHT) - (WORKFLOW_CELL_HEIGHT/2.0));
                             }
                             else {
                                 self.tempDraggedItem.center = CGPointMake(-400, -WORKFLOW_CELL_HEIGHT);
                             }
                                 
                             self.tempDraggedItem.transform = CGAffineTransformIdentity;
                             self.dragPositionIndicator.alpha = 0.0;
                             
						 }
						 completion:^(BOOL finished){ 
							 [self.tempDraggedItem removeFromSuperview];
							 self.tempDraggedItem = nil;
						 }
		 ];

        if (validDrop) {
            //We're going to use the temp dragged capturer as our permanent model object,
            //since it's already inserted in the context. Mark it as the "current" capturer and add it to the workflow.
            self.currentCapturer = self.tempDraggedCapturer;
            
            self.helpView.alpha = 0.0;

            [self.workflow addCapturersObject:self.currentCapturer];
            //insert the capturer manually into the ordered array.
            NSLog(@"Should be inserting new object at index %d",insertionIndex);
            [self.capturers insertObject:self.currentCapturer atIndex:insertionIndex];
            
            //update the indices in Core Data before re-fetching.
            [self updateCapturerIndices];
            
            //refetch data from Core data so that we have the correct number of capturers.
            NSError *error = nil;
            if (![self.fetchedResultsController performFetch:&error]) {
                /*
                 Replace this implementation with code to handle the error appropriately.
                 
                 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
                 */
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
            //refresh the list of capturers based on Core Data.
            //NOTE: This will probably be redundant most of the time,
            //because we're making manual changes to self.capturers.
            //It's basically to make sure things stay in sync.
            [self refreshOrderedCapturers];
            
            //refresh the grid.
            [self.workflowGrid reloadData];
            
            //scroll everything so that this cell is visible.
            [self.workflowGrid scrollToItemAtIndex:[self workflowIndexForInsertionPoint:[recog locationInView:self.workflowGrid]]
                                  atScrollPosition:AQGridViewScrollPositionNone animated:YES];
            
            //enable the "Done" button in case it wasn't already.
            self.doneButton.enabled = YES;
            
        }
        else {
            //remove the temporary capturer we created at the start of this gesture.
            [self.managedObjectContext deleteObject:self.tempDraggedCapturer];
        }
        
        
        //Show the popover containing the capture type options.
        if (validDrop && self.currentCapturer) {
            [self didRequestCaptureTypeChangeForCapturer:self.currentCapturer];
        }
         
	}
	
}

#pragma mark -
#pragma mark Capture Type Selector Delegate methods
-(void) didSelectCaptureType:(int)captureType
{
    self.currentCapturer.captureType = [NSNumber numberWithInt:captureType];
    //for now, reload the entire grid. This could be optimized to a) do something animated,
    //and b) only reload the changed cell.
    [self.workflowGrid reloadData];
}


#pragma mark -
#pragma mark Workflow Item & Item Container Delegate methods
-(void) didRequestCaptureTypeChangeForCapturer:(Capturer *)cap
{
    //set the current capturer reference to this item, so that it gets its capture type set.
    self.currentCapturer = cap;
    
    //Launch a controller to select a capture type.
    WsabiCaptureTypePickerController *capController = [[[WsabiCaptureTypePickerController alloc] initWithNibName:@"WsabiCaptureTypePickerController" bundle:nil] autorelease];
    capController.title = @"Choose Capture Type";
    UINavigationController *capNav = [[[UINavigationController alloc] initWithRootViewController:capController] autorelease];
    
    capController.delegate = self;
    
    //figure out the modality and use it to fill the capture type selector
    if ([self.currentCapturer.sensor.modalities count] > 1 || [self.currentCapturer.sensor.modalities count] == 0) {
        capController.modality = kModalityOther;
    }
    else
    {
        capController.modality = [[(SensorModality*)[self.currentCapturer.sensor.modalities anyObject] type] intValue];
        capController.submodality = [self.currentCapturer.captureType intValue];
    }
     
    if (!self.popoverController) {
        self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:capNav] autorelease];
    }
    else {
        self.popoverController.contentViewController = capNav;
    }
    
    //size the popover appropriately
    CGSize originalSize = [capController.view sizeThatFits:capController.view.bounds.size];
    self.popoverController.popoverContentSize = CGSizeMake(originalSize.width, originalSize.height + 34);
    
    capController.popoverController = self.popoverController; //make sure we can dismiss the popover.
    
  
    int capIndex = [self.capturers indexOfObject:self.currentCapturer];
    CGSize tempSize = [self portraitGridCellSizeForGridView:self.workflowGrid];
    CGRect launchRect = CGRectMake(self.workflowGrid.frame.origin.x + (3 * tempSize.width / 4.0),
                                   MAX(100, self.workflowGrid.frame.origin.y + (tempSize.height * capIndex) + (tempSize.height/2.0) - self.workflowGrid.contentOffset.y),
                                   100,100);
    [self.popoverController presentPopoverFromRect:launchRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void) didRequestWorkflowDeletionAtIndex:(int)index
{
    WsabiWorkflowBuilderCell *cellToRemove = (WsabiWorkflowBuilderCell*) [self.workflowGrid cellForItemAtIndex:index];

    if (!cellToRemove ) {
        return; //can't remove a nonexistent cell, so just return;
    }
    
    //Because the deleted cell will probably be reused immediately, store its old bounds
    //and restore them during the reload process -- that way, we don't have to set
    //each cell's bounds manually as a failsafe in the creation/reuse method.
    //CGRect storedFrame = cellToRemove.frame;

    [self.workflow removeCapturersObject:(Capturer*)[self.capturers objectAtIndex:index]];
    [self refreshOrderedCapturers]; //fill the local capturers array with the updated data.
    [self updateCapturerIndices];
    
    [self.workflowGrid deleteItemsAtIndices:[NSIndexSet indexSetWithIndex:index] withAnimation:AQGridViewItemAnimationRight];
    //if there's anything after the deleted cell, reload it.
    int remainingCount = ([self.capturers count] - index) - 1;
    if (remainingCount > 0) 
    {
        [self.workflowGrid reloadItemsAtIndices:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index+1, [self.capturers count] - index - 1)] withAnimation:AQGridViewItemAnimationBottom];
    }
    
    //if there isn't anything left in this workflow, disable the done button.
    if ([self.capturers count] <= 0) {
        self.doneButton.enabled = NO;
    }
}

#pragma mark -
#pragma mark UIGestureRecognizer Delegate/Actions for workflow ordering

- (BOOL) gestureRecognizerShouldBegin: (UIGestureRecognizer *) gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView: self.workflowGrid];
    if ( [self.workflowGrid indexForItemAtPoint: location] < [self.capturers count] )
        return ( YES );
    
    // touch is outside the bounds of any icon cells, so don't start the gesture
    return ( NO );
}

- (void) moveActionGestureRecognizerStateChanged: (UIGestureRecognizer *) recognizer
{
    switch ( recognizer.state )
    {
        default:
        case UIGestureRecognizerStateFailed:
            // do nothing
            break;
            
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateCancelled:
        {
            [self.workflowGrid beginUpdates];
            
            if ( _emptyCellIndex != _dragOriginIndex )
            {
                [self.workflowGrid moveItemAtIndex: _emptyCellIndex toIndex: _dragOriginIndex withAnimation: AQGridViewItemAnimationFade];
            }
            
            _emptyCellIndex = _dragOriginIndex;
            
            // move the cell back to its origin
            [UIView beginAnimations: @"SnapBack" context: NULL];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
            [UIView setAnimationDuration: 0.5];
            [UIView setAnimationDelegate: self];
            [UIView setAnimationDidStopSelector: @selector(finishedSnap:finished:context:)];
            
            CGRect f = _draggingCell.frame;
            f.origin = _dragOriginCellOrigin;
            _draggingCell.frame = f;
            _draggingCell.positionLabel.hidden = NO; //show the position label again.
            
            [UIView commitAnimations];
            
            [self.workflowGrid endUpdates];

            break;
        }
            
        case UIGestureRecognizerStateEnded:
        {
            
//            if ([self.trashButton pointInside:[recognizer locationInView: self.trashButton] withEvent:nil]) {
//                NSLog(@"Dropped this item in the trash.");
//                
//                [UIView animateWithDuration:kFlipAnimationDuration 
//                                 animations:^(void) {
//                                     CGPoint adjustedCenter = [self.view convertPoint:self.trashButton.center fromView:self.trashButton.superview];
//                                     _draggingCell.transform = CGAffineTransformMakeRotation(-M_PI);
//                                     _draggingCell.frame = CGRectMake(adjustedCenter.x, adjustedCenter.y, 0, 0);
//                                 }
//                                 completion:^(BOOL completed) {
//                                      self.trashButton.highlighted = NO; //close the trash can.
//                                 }
//                 ];
//                
//                //remove the empty cell, the matching data item and reload data.
//                [self.workflowGrid beginUpdates];
//                _emptyCellIndex = NSNotFound;
//                [self.workflow removeCapturersObject:(Capturer*)[self.capturers objectAtIndex:_dragOriginIndex]];
//                [self refreshOrderedCapturers]; //fill the local capturers array with the updated data.
//                [self updateCapturerIndices];
//
//                NSLog(@"After removal, capturers now has %d items",[self.capturers count]);
//                [self.workflowGrid endUpdates];
//               // [self.workflowGrid reloadItemsAtIndices:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.capturers count])] withAnimation:AQGridViewItemAnimationFade];
//                [self.workflowGrid reloadData];
//
//                return;
//            }

            CGPoint p = [recognizer locationInView: self.workflowGrid];
            NSUInteger index = [self.workflowGrid indexForItemAtPoint: p];
			if ( index == NSNotFound )
			{
				// index is the last available location
				index = [self.capturers count] - 1;
			}
            
            // update the data store
            id obj = [[self.capturers objectAtIndex: _dragOriginIndex] retain];
            [self.capturers removeObjectAtIndex: _dragOriginIndex];
            [self.capturers insertObject: obj atIndex: index];
			//make sure the changes get passed to core data
			[self updateCapturerIndices];
            [obj release];
            
            if ( index != _emptyCellIndex )
            {
                [self.workflowGrid beginUpdates];
                [self.workflowGrid moveItemAtIndex: _emptyCellIndex toIndex: index withAnimation: AQGridViewItemAnimationFade];
                _emptyCellIndex = index;
                [self.workflowGrid endUpdates];
            }
            
            // move the real cell into place
            [UIView beginAnimations: @"SnapToPlace" context: NULL];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
            [UIView setAnimationDuration: 0.5];
            [UIView setAnimationDelegate: self];
            [UIView setAnimationDidStopSelector: @selector(finishedSnap:finished:context:)];
            
            CGRect r = [self.view convertRect:[self.workflowGrid rectForItemAtIndex: _emptyCellIndex] fromView:self.workflowGrid];
            CGRect f = _draggingCell.frame;
            f.origin.x = r.origin.x + floorf((r.size.width - f.size.width) * 0.5);
            f.origin.y = r.origin.y + floorf((r.size.height - f.size.height) * 0.5);
            NSLog( @"Gesture ended-- moving to %@", NSStringFromCGRect(f) );
            _draggingCell.frame = f;
            
            _draggingCell.transform = CGAffineTransformIdentity;
            _draggingCell.alpha = 1.0;
            _draggingCell.positionLabel.hidden = NO; //show the position label again.
            
            [UIView commitAnimations];
            
            break;
        }
            
        case UIGestureRecognizerStateBegan:
        {
            NSUInteger index = [self.workflowGrid indexForItemAtPoint: [recognizer locationInView: self.workflowGrid]];
            _emptyCellIndex = index;    // we'll put an empty cell here now
            
            // find the cell at the current point and copy it into our main view, applying some transforms
            AQGridViewCell * sourceCell = [self.workflowGrid cellForItemAtIndex: index];
            CGRect frame = [self.view convertRect: sourceCell.frame fromView: self.workflowGrid];
            _draggingCell = [[WsabiWorkflowBuilderCell alloc] initWithFrame: frame reuseIdentifier: @""];
            _draggingCell.capturer = [self.capturers objectAtIndex: index];
            _draggingCell.positionLabel.hidden = YES; //don't show the (now obsolete) position label while dragging.
            [self.view addSubview: _draggingCell];
            
            // grab some info about the origin of this cell
            _dragOriginCellOrigin = frame.origin;
            _dragOriginIndex = index;
            
            [UIView beginAnimations: @"" context: NULL];
            [UIView setAnimationDuration: 0.2];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
            
            // transformation-- larger, slightly transparent
            _draggingCell.transform = CGAffineTransformMakeScale( 1.2, 1.2 );
            _draggingCell.alpha = 0.7;
            
            // also make it center on the touch point
            _draggingCell.center = [recognizer locationInView: self.view];
            
            [UIView commitAnimations];
            
            // reload the grid underneath to get the empty cell in place
            [self.workflowGrid reloadItemsAtIndices: [NSIndexSet indexSetWithIndex: index]
                              withAnimation: AQGridViewItemAnimationNone];
            
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            // update draging cell location
            _draggingCell.center = [recognizer locationInView: self.view];
                        
            // don't do anything with content if grid view is in the middle of an animation block
            if ( self.workflowGrid.isAnimatingUpdates )
                break;
            
            // update empty cell to follow, if necessary
            NSUInteger index = [self.workflowGrid indexForItemAtPoint: [recognizer locationInView: self.workflowGrid]];
			
			// don't do anything if it's over an unused grid cell
			if ( index == NSNotFound )
			{
				// snap back to the last possible index
				index = [self.capturers count] - 1;
			}
			
            if ( index != _emptyCellIndex )
            {
                NSLog( @"Moving empty cell from %u to %u", _emptyCellIndex, index );
                
                // batch the movements
                [self.workflowGrid beginUpdates];
                
                // move everything else out of the way
                if ( index < _emptyCellIndex )
                {
                    for ( NSUInteger i = index; i < _emptyCellIndex; i++ )
                    {
                        NSLog( @"Moving %u to %u", i, i+1 );
                        [self.workflowGrid moveItemAtIndex: i toIndex: i+1 withAnimation: AQGridViewItemAnimationFade];
                    }
                }
                else
                {
                    for ( NSUInteger i = index; i > _emptyCellIndex; i-- )
                    {
                        NSLog( @"Moving %u to %u", i, i-1 );
                        [self.workflowGrid moveItemAtIndex: i toIndex: i-1 withAnimation: AQGridViewItemAnimationFade];
                    }
                }
                
                [self.workflowGrid moveItemAtIndex: _emptyCellIndex toIndex: index withAnimation: AQGridViewItemAnimationFade];
                _emptyCellIndex = index;
                
                [self.workflowGrid endUpdates];
            }
            
            break;
        }
    }
}

- (void) finishedSnap: (NSString *) animationID finished: (NSNumber *) finished context: (void *) context
{
    //scroll the workflow grid to show the dropped cell.
    [self.workflowGrid scrollToItemAtIndex:_emptyCellIndex atScrollPosition:AQGridViewScrollPositionNone animated:YES];

    NSIndexSet * indices = [[NSIndexSet alloc] initWithIndex: _emptyCellIndex];
    _emptyCellIndex = NSNotFound;
    
    // load the moved cell into the grid view
    //[self.workflowGrid reloadItemsAtIndices: indices withAnimation: AQGridViewItemAnimationNone];
    
	//reload the entire grid (non-modified cells may have had their indices changed by the drag operation.
	[self.workflowGrid reloadData];
	
    // dismiss our copy of the cell
    [_draggingCell removeFromSuperview];
    [_draggingCell release];
    _draggingCell = nil;
    
    [indices release];
}

#pragma mark -
#pragma mark Sensor Editor Delegate Methods
-(void) didAddSensor:(Sensor*)newSensor
{
    //we need to fetch data so we know what to put in the sensor table
    [self refetchData];
    
    //update the sensor table, etc.
	[self.sensorTable reloadData];
	[self.workflowGrid reloadData];
}

-(void) didModifySensor:(Sensor*)modifiedSensor
{
	[self.sensorTable reloadData];
	[self.workflowGrid reloadData];
}


#pragma mark -
#pragma mark Memory management
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [helpView release];
    [popoverController release];
    [sensorListActionSheet release];
    [sensorListActionIndexPath release];
	[topToolbar release];
    [doneButton release];
    [noTitlePromptField release];
	[titleTextField release];
	[tempDraggedItem release];
	[capturers release];
	[sensorTable release];
	[sensorNavBar release];
	[workflowGrid release];
    [dragPositionIndicator release];
	[fetchedResultsController release];
	[managedObjectContext release];
    [super dealloc];
}


@end
