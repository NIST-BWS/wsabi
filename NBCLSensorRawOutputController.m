//
//  NBCLSensorRawOutputController.m
//  Wsabi
//
//  Created by Matt Aronoff on 3/18/11.
//

/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


#import "NBCLSensorRawOutputController.h"
#define CONST_textLabelFontSize     17
#define CONST_detailLabelFontSize   15
#define CONST_defaultCellHeight     44

@implementation NBCLSensorRawOutputController
@synthesize wsbdResults, wsbdOpNames, delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [wsbdResults release];
    [wsbdOpNames release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearButtonPressed:)] autorelease];
    
    self.title = @"Raw Results";
    self.tableView.allowsSelection = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSString*) getPrettyPrintedDetailStringForResult:(WSBDResult*)result
{
    //Build the detailed output.
    NSMutableString *detailString = [[[NSMutableString alloc] init] autorelease];
    
    if (result.message) {
        [detailString appendFormat:@"Message:\n%@\n",result.message];
    }
    if (result.sessionId) {
        [detailString appendFormat:@"Session ID:\n%@\n",result.sessionId];
    }
    if (result.captureIds) {
        [detailString appendString:@"Capture IDs:\n"];
        for (NSString *capId in result.captureIds) {
            [detailString appendFormat:@"%@\n"];
        }
    }
    //TODO: Fill in the missing properties (info, config params, etc.)
    if (result.contentType) {
        [detailString appendFormat:@"Content Type:\n%@\n",result.contentType];
    }

    return detailString;
}

-(IBAction) clearButtonPressed:(id)sender
{
    int oldCount = [self.wsbdResults count];
    [self.wsbdResults removeAllObjects];
    [self.wsbdOpNames removeAllObjects];
    
    [self.tableView beginUpdates];
    for (int i = 0; i < oldCount; i++) {
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    }
    [self.tableView endUpdates];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (int) heightOfCellWithTitle :(NSString*)titleText 
                   andSubtitle:(NSString*)subtitleText
{
    CGSize titleSize = {0, 0};
    CGSize subtitleSize = {0, 0};
    
    if (titleText && ![titleText isEqualToString:@""]) 
        titleSize = [titleText sizeWithFont:[UIFont systemFontOfSize:CONST_textLabelFontSize] 
                          constrainedToSize:CGSizeMake(self.tableView.contentSize.width, 4000) 
                              lineBreakMode:UILineBreakModeWordWrap];
    
    if (subtitleText && ![subtitleText isEqualToString:@""]) 
        subtitleSize = [subtitleText sizeWithFont:[UIFont systemFontOfSize:CONST_detailLabelFontSize]  
                                constrainedToSize:CGSizeMake(self.tableView.contentSize.width, 4000) 
                                    lineBreakMode:UILineBreakModeWordWrap];
    
    return titleSize.height + subtitleSize.height;
} 

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = nil;
    NSString *subtitle = nil;
    
    if ([[self.wsbdResults objectAtIndex:indexPath.row] isKindOfClass:[WSBDResult class]]) {
        title = [NSString stringWithFormat:@"(%@): %@", [self.wsbdOpNames objectAtIndex:indexPath.row],
                           [WSBDResult stringForStatusValue: [(WSBDResult*)[self.wsbdResults objectAtIndex:indexPath.row] status]]];
        
        subtitle = [self getPrettyPrintedDetailStringForResult:[self.wsbdResults objectAtIndex:indexPath.row]];
    }
    else if ([[self.wsbdResults objectAtIndex:indexPath.row] isKindOfClass:[NSError class]]) {
        title = [NSString stringWithFormat:@"(%@): Network request failed", [self.wsbdOpNames objectAtIndex:indexPath.row]];
        
        subtitle = [(NSError*)[self.wsbdResults objectAtIndex:indexPath.row] description];

    }
    
    int height = 10 + [self heightOfCellWithTitle:title andSubtitle:subtitle];
    return MAX(CONST_defaultCellHeight, height);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.wsbdResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    if ([[self.wsbdResults objectAtIndex:indexPath.row] isKindOfClass:[WSBDResult class]]) {
        WSBDResult *item = [self.wsbdResults objectAtIndex:indexPath.row];

        if (item.status == StatusSuccess) {
            cell.textLabel.textColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1.0];
        }
        else
        {
            cell.textLabel.textColor = [UIColor colorWithRed:0.5 green:0 blue:0 alpha:1.0];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"(%@): %@", [self.wsbdOpNames objectAtIndex:indexPath.row],
                       [WSBDResult stringForStatusValue: [(WSBDResult*)[self.wsbdResults objectAtIndex:indexPath.row] status]]];

        cell.detailTextLabel.text = [self getPrettyPrintedDetailStringForResult:item];

    }
    else if ([[self.wsbdResults objectAtIndex:indexPath.row] isKindOfClass:[NSError class]])
    {
        cell.textLabel.text = [NSString stringWithFormat:@"(%@): Network request failed", [self.wsbdOpNames objectAtIndex:indexPath.row]];
        cell.detailTextLabel.text = [(NSError*)[self.wsbdResults objectAtIndex:indexPath.row] description];
    }
    
    cell.detailTextLabel.numberOfLines = 0; //make sure we wrap the contents of the detail label.
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
