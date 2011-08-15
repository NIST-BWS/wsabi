//
//  WsabiSensorController_iPad.m
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


#import "WsabiSensorController_iPad.h"


@implementation WsabiSensorController_iPad
@synthesize tableView, selectedModalities, sortedParams, isNewSensor, delegate, managedObjectContext;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		self.selectedModalities = [[NSMutableArray alloc] initWithCapacity:kModalityOther+1];
		for (int i = 0; i <= kModalityOther; i++) {
			[self.selectedModalities addObject:[NSNumber numberWithBool:NO]];
		}
				
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.editing = YES;
	self.tableView.allowsSelectionDuringEditing = YES;


	//create and work on a new sensor if one wasn't specified before now.
	if (self.sensor == nil) {
		Sensor *newSensor = [NSEntityDescription insertNewObjectForEntityForName:@"Sensor" inManagedObjectContext:self.managedObjectContext];
		NSDate *now = [NSDate date];
        newSensor.name = @"New Sensor";
		newSensor.timestampCreated = now;
		newSensor.timestampModified = now;
		//by default, use fingerprint modality.
		SensorModality *fingerprintModality = [NSEntityDescription insertNewObjectForEntityForName:@"SensorModality" inManagedObjectContext:self.managedObjectContext];
		fingerprintModality.type = [NSNumber numberWithInt:kModalityFinger];
		[newSensor addModalitiesObject:fingerprintModality];
		
		self.sensor = newSensor;
		self.isNewSensor = YES;
	}
	else {
		//TODO: Fill this from the data model!
	}

		
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (BOOL)findAndResignFirstResonder: (UIView*) theView
{
    if (theView.isFirstResponder) {
        [theView resignFirstResponder];
        return YES;     
    }
    for (UIView *subView in theView.subviews) {
        if ([self findAndResignFirstResonder: theView])
            return YES;
    }
    return NO;
}

//This is a solution to the non-dismissal of the keyboard when this controller
//is presented as a form sheet. This is, apparently, the desired behavior from Apple,
//but I think it's a bug and so do all the users :-).
- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

#pragma mark -
#pragma mark Core Data interactions
-(Sensor*) sensor
{
	return sensor;
}

-(void) setSensor:(Sensor *)newSensor
{
	sensor = newSensor;
	
	//set the modality selector from the existing sensor modalities.
	for (SensorModality *mod in sensor.modalities) {
		//take the id of the listed modality and use it as an index into the "selectedModalities" array,
		//which is used to drive the selector section of the table view.
		[self.selectedModalities replaceObjectAtIndex:[mod.type intValue] withObject:[NSNumber numberWithBool:YES]];
	}
	
	//Sort the existing parameters into an array for use by the table view
	NSSortDescriptor *orderSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:orderSortDescriptor];
	
	self.sortedParams = [[sensor.params sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
	
	//reload the table data to take new values into account.
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Button	Action methods
-(IBAction) cancelButtonPressed:(id)sender
{
	//TODO: If this is a new sensor, remove it. Otherwise, undo the changes to the object.
	if (self.isNewSensor) {
		[self.managedObjectContext deleteObject:self.sensor];
	}
	else {
		//this will scrap everything back to the last commit.
		[self.managedObjectContext rollback];
	}

	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction) saveButtonPressed:(id)sender
{

	//fill the sensor with the data from this form.
	//Name
	UITextField *tempField = (UITextField*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kSensorSectionName]]
											viewWithTag:kTextFieldTag];
	self.sensor.name = tempField.text;

	//Address
	tempField = (UITextField*)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kSensorSectionNetwork]]
							   viewWithTag:kTextFieldTag];
    //if the user hasn't entered "http://" or the local camera prefix at the start of the string, make sure we fix it.
    if (![tempField.text hasPrefix:@"http://"] && ![tempField.text hasPrefix:kLocalCameraURLPrefix] && tempField.text) {
        self.sensor.uri = [[@"http://" stringByAppendingString:tempField.text] retain];
    }
    else {
        self.sensor.uri = tempField.text;
	}
    
	if (self.isNewSensor) {
		[delegate didAddSensor:self.sensor];
	}
	else {
		[delegate didModifySensor:self.sensor];
	}
	
	//modalities -- remove the old ones, add our new ones.
	[self.sensor removeModalities:self.sensor.modalities];
	for (int i = 0; i < [self.selectedModalities count]; i++) {
		//if this modality is selected, add it.
		if ([[self.selectedModalities objectAtIndex:i] boolValue]) {
			SensorModality *modality = [NSEntityDescription insertNewObjectForEntityForName:@"SensorModality" inManagedObjectContext:self.managedObjectContext];
			modality.type = [NSNumber numberWithInt:i]; //this will match kModality*
			[self.sensor addModalitiesObject: modality];
		}

	}
	
    //save the context here.
    [(AppDelegate_Shared*)[[UIApplication sharedApplication] delegate] saveContext];
    
	[self dismissModalViewControllerAnimated:YES];

}

//-(void) tableBackgroundPressed:(UITapGestureRecognizer*)recog
//{
//	//FIXME: This fires on ANY touch within the bounds of the table view (that is, the cells don't swallow the touch event)
//	//so this doesn't quite do what we need.
//	//	if (recog.view == self.tableView) {
////		[self findAndResignFirstResonder:self.tableView];
////	}
//}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case kSensorSectionName:
			return @"Sensor name";
			break;
		case kSensorSectionNetwork:
			return @"Network Address";
			break;
		case kSensorSectionModality:
			return @"Modality";
			break;
		case kSensorSectionParameters:
			return @"Parameters";
			break;
		default:
			break;
	}
	return @"";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case kSensorSectionName:
			return 1;
			break;			
		case kSensorSectionNetwork:
			return 1;
			break;
		case kSensorSectionModality:
			return kModalityOther + 1; //the value of the last modality enum, plus 1 because we need a 1-based counter.
			break;
		case kSensorSectionParameters:
			return [self.sensor.params count] + 1;
			break;
		default:
			break;
	}
	return 0;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.section == kSensorSectionName || indexPath.section == kSensorSectionNetwork) {
		cell.textLabel.text = nil;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		UITextField *textField = (UITextField*)[cell.contentView viewWithTag:kTextFieldTag];

		if (textField == nil) {
			CGSize inset = CGSizeMake(12, 12);
			//NOTE: Manually setting the width, because contentView's width doesn't give us the numbers we want.
			textField = [[[UITextField alloc] initWithFrame:CGRectMake(cell.contentView.bounds.origin.x + inset.width, 
																					cell.contentView.bounds.origin.y + inset.height,
																					cell.contentView.bounds.size.width - (2 * inset.width),
																					cell.contentView.bounds.size.height - (2*inset.height)
																					)
									   ] autorelease];
            textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			textField.borderStyle = UITextBorderStyleNone;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
			textField.tag = kTextFieldTag;
			textField.delegate = self;
						
			[cell.contentView addSubview:textField];
			
		}
		if (indexPath.section == kSensorSectionName && self.sensor.name) {
			textField.text = self.sensor.name;
		}
		if (indexPath.section == kSensorSectionNetwork && self.sensor.uri) {
			textField.text = self.sensor.uri;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
		}
	}
	else if (indexPath.section == kSensorSectionModality)
	{
		cell.textLabel.text = [WSBDModalityMap stringForModality:indexPath.row];
	
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        if ([[self.selectedModalities objectAtIndex:indexPath.row] boolValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

	}
	else if (indexPath.section == kSensorSectionParameters) {
		
		if (indexPath.row < [self.sortedParams count]) {
			
			cell.textLabel.text = [(SensorParam*)[self.sortedParams objectAtIndex:indexPath.row] name];
			cell.detailTextLabel.text = [(SensorParam*)[self.sortedParams objectAtIndex:indexPath.row] value];
		}
		else if (indexPath.row == [self.sortedParams count])
		{
			cell.textLabel.text = @"Add New Parameter";
		}
		
	}
	else {
		//do nothing.
	}

}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *EditableIdentifier = @"EditableCell";
	static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		if (indexPath.section == kSensorSectionName || indexPath.section == kSensorSectionNetwork) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EditableIdentifier] autorelease];
		}
		else if (indexPath.section == kSensorSectionModality)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		}

    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	//   if (editingStyle == UITableViewCellEditingStyleDelete) {
	//        
	//        // Delete the managed object.
	//        NSManagedObject *objectToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
	//        if (self.detailViewController.workflow == objectToDelete) {
	//            self.detailViewController.workflow = nil;
	//        }
	//        
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
	//    }   
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath { 
	return NO; 
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	
	if (indexPath.section == kSensorSectionModality) {
		//toggle the selectedness of this modality.
		
		//	UITableViewCell *cell = [aTableView cellForRowAtIndexPath:indexPath];
		for (int i = 0; i <= kModalityOther; i++) {
			if (i == indexPath.row) {
				[self.selectedModalities replaceObjectAtIndex:i 
												   withObject:[NSNumber numberWithBool:![[self.selectedModalities objectAtIndex:i] boolValue]]];
				 [aTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				 //			 [aTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
			}

		}
		

	}
}

#pragma mark -
#pragma mark UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}



#pragma mark -
#pragma mark Memory Management

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
	[tableView release];
    [super dealloc];
}


@end
