//
//  WsabiWorkflowItem.m
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


#import "WsabiWorkflowItem.h"

@implementation WsabiWorkflowItem
@synthesize currentParamKeys, currentParamValues;
@synthesize modalityDisplay, paramTable, captureTypeButton, delegate;

-(id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code.
		self.currentParamKeys = [[[NSMutableArray alloc] init] autorelease];
		self.currentParamValues = [[[NSMutableArray alloc] init] autorelease];;
		[self updateParams];
        
        //adjust layer properties for this item.
        self.layer.cornerRadius = 12;
        self.layer.borderWidth = 2;
        self.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowOffset = CGSizeMake(1,2);
        self.layer.shadowRadius = 8;
        self.layer.shouldRasterize = YES;


    }
    return self;
	
}

//This is called after the NIB is initialized, so the UI objects will exist
//by the time we get here.
-(void) layoutSubviews
{
    self.captureTypeButton.layer.cornerRadius = 8;
    self.captureTypeButton.layer.borderWidth = 1;
    self.captureTypeButton.layer.borderColor = [[UIColor colorWithWhite:0.8 alpha:0.8] CGColor];

}
#pragma mark -
#pragma mark Property accessors
-(Capturer*)capturer
{
	return capturer;
}

-(void) setCapturer:(Capturer *)newCapturer
{
	capturer = newCapturer;
	
	if ([capturer.sensor.modalities count] > 1 || [capturer.sensor.modalities count] == 0) {
		//if this sensor is, itself, multimodal, just use the "other" icon.
		[self.modalityDisplay setImage:[UIImage imageNamed:@"ModalityOtherIcon_180px.png"] forState:UIControlStateNormal];
	}
	else if ([capturer.sensor.modalities count] == 1) 
	{
		switch ([[(SensorModality*)[capturer.sensor.modalities anyObject] type] intValue]) {
			case kModalityFace:
                [self.modalityDisplay setImage:[UIImage imageNamed:@"FaceIcon_180px.png"] forState:UIControlStateNormal];
				break;
			case kModalityFinger:
                [self.modalityDisplay setImage:[UIImage imageNamed:@"FingerprintIcon_180px.png"] forState:UIControlStateNormal];
				break;
			case kModalityIris:
                [self.modalityDisplay setImage:[UIImage imageNamed:@"IrisIcon_180px.png"] forState:UIControlStateNormal];
				break;
			default:
				//includes kModalityOther case
				break;
		}
	}
	else {
		//TODO: handle the "no specified modality" case
	}
    
    //set the capture type label.
    [self.captureTypeButton setTitle:[WSBDModalityMap stringForCaptureType:[capturer.captureType intValue]] forState:UIControlStateNormal];

	//reload the parameter table data.
	[self.paramTable reloadData];
}


#pragma mark -
#pragma mark Parameters
-(void) updateParams
{
}

-(void) addParamValue:(id)value forKey:(id)key
{
	[self.currentParamKeys addObject:key];
	[self.currentParamValues addObject:value];
}

-(BOOL) removeParamValueForKey:(id)key
{
	if ([self.currentParamKeys containsObject:key]) {
		int index = [self.currentParamKeys indexOfObject:key];
		[self.currentParamKeys removeObjectAtIndex:index];
		[self.currentParamValues removeObjectAtIndex:index];
		return YES;
	}
	else
		return NO;

}

-(void) clearParams
{
	[self.currentParamKeys removeAllObjects];
	[self.currentParamValues removeAllObjects];
}

-(IBAction) captureTypeButtonPressed:(id)sender
{
    [delegate didRequestCaptureTypeChangeForCapturer:self.capturer];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	//there's just the one section.
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	//always use the sensor name.
	if (self.capturer) {
		return self.capturer.sensor.name;
	}
	else return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//there's just the one section, so the full number of parameters goes in that section.
    return [self.currentParamKeys count];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
 	cell.textLabel.text = [self.currentParamKeys objectAtIndex:indexPath.row];
	cell.detailTextLabel.text = [self.currentParamValues objectAtIndex:indexPath.row];
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];		
		
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


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	[currentParamKeys release];
	[currentParamValues release];
	[modalityDisplay release];
	[paramTable release];
    [captureTypeButton release];
	[super dealloc];
}


@end
