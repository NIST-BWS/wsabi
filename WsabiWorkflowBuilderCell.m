//
//  WsabiWorkflowBuilderCell.m
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


#import "WsabiWorkflowBuilderCell.h"


@implementation WsabiWorkflowBuilderCell
@synthesize positionLabel, capView, delegate;

#define LABEL_WIDTH 50

- (id) initWithFrame: (CGRect) frame reuseIdentifier:(NSString *) reuseIdentifier
{
    self = [super initWithFrame: frame reuseIdentifier: reuseIdentifier];
    if ( self == nil )
        return ( nil );

	    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.contentView.opaque = NO;
    self.opaque = NO;
    
    self.selectionStyle = AQGridViewCellSelectionStyleNone;
    
	//Have the label span the full height of the cell along the left side.
	
	self.positionLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, LABEL_WIDTH, frame.size.height)] autorelease];
	[self.positionLabel setFont:[UIFont boldSystemFontOfSize:36]];
	[self.positionLabel setTextColor:[UIColor whiteColor]];
    self.positionLabel.shadowColor = [UIColor blackColor];
    self.positionLabel.shadowOffset = CGSizeMake(0,1);
    
	self.positionLabel.backgroundColor = [UIColor clearColor];
	self.positionLabel.textAlignment = UITextAlignmentCenter;
	[self.contentView addSubview:self.positionLabel];
	
    return ( self );
}

- (Capturer *) capturer
{
    return capturer;
}

- (void) setCapturer: (Capturer *) newCapturer
{
	if (!self.capView) {
		self.capView = [[[NSBundle mainBundle] loadNibNamed:@"WsabiWorkflowItem" owner:self options:nil] objectAtIndex:0];
		self.capView.center = CGPointMake(LABEL_WIDTH + (self.bounds.size.width - LABEL_WIDTH)/2.0, self.contentView.center.y);
        NSLog(@"Setting workflow capView's center to (%1.0f,%1.0f)",self.capView.center.x, self.capView.center.y);
		[self.contentView addSubview:self.capView];
        
        UIButton *cellDeleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cellDeleteButton setImage:[UIImage imageNamed:@"Delete_whiteBG_37"] forState:UIControlStateNormal];
        cellDeleteButton.frame = CGRectMake(self.contentView.bounds.size.width - 37,
                                            0,
                                            37, 
                                            37);
        [cellDeleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:cellDeleteButton];
	}

	//set the instance variable and refresh the data in capView and the label.
	capturer = newCapturer;
	self.capView.capturer = capturer;
	
	self.positionLabel.text = [NSString stringWithFormat:@"%d", [capturer.positionInWorkflow intValue]+1];
}

-(IBAction) deleteButtonPressed:(id)sender
{
    UIButton *cellDeleteButton = sender;
    
    //Present a confirmation sheet first.
    UIActionSheet *deleteConfirmation = [[[UIActionSheet alloc] initWithTitle:@"Remove this item from the workflow?" delegate:self 
                                                            cancelButtonTitle:@"Cancel" 
                                                       destructiveButtonTitle:@"Remove Item" 
                                                            otherButtonTitles:nil] autorelease ];
    [deleteConfirmation showFromRect:cellDeleteButton.frame inView:[cellDeleteButton superview] animated:YES];
}

#pragma mark UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //do something.
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        //notify the delegate that we'd like to be deleted.
        [delegate didRequestWorkflowDeletionAtIndex:[capturer.positionInWorkflow intValue]];
    }
}

- (void) dealloc
{
    [capView release];
    [positionLabel release];
	[super dealloc];
}


@end
