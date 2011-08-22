//
//  WsabiMasterTableViewCell.m
//  wsabi
//
//  Created by Matt Aronoff on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WsabiMasterTableViewCell.h"

@implementation WsabiMasterTableViewCell

@synthesize workflow;
@synthesize workflowTitleField, workflowDetailLabel;
@synthesize editButtonsView, renameButton, editWorkflowButton;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    //if we haven't already set the background images for the buttons, do it here.
    if (![self.renameButton backgroundImageForState:UIControlStateNormal]) {
        //set the images for the rename button.
        [self.renameButton setBackgroundImage:[[UIImage imageNamed:@"PurchaseButtonBlue"] stretchableImageWithLeftCapWidth:3 topCapHeight:0] forState:UIControlStateNormal];
        [self.renameButton setBackgroundImage:[[UIImage imageNamed:@"PurchaseButtonBluePressed"] stretchableImageWithLeftCapWidth:3 topCapHeight:0] forState:UIControlStateHighlighted];
        [self.renameButton setBackgroundImage:[[UIImage imageNamed:@"PurchasedAlready"] stretchableImageWithLeftCapWidth:3 topCapHeight:0] forState:UIControlStateDisabled];
    }
    if (![self.editWorkflowButton backgroundImageForState:UIControlStateNormal]) {
        //set the images for the rename button.
        [self.editWorkflowButton setBackgroundImage:[[UIImage imageNamed:@"PurchaseButtonBlue"] stretchableImageWithLeftCapWidth:3 topCapHeight:0] forState:UIControlStateNormal];
        [self.editWorkflowButton setBackgroundImage:[[UIImage imageNamed:@"PurchaseButtonBluePressed"] stretchableImageWithLeftCapWidth:3 topCapHeight:0] forState:UIControlStateHighlighted];
        [self.editWorkflowButton setBackgroundImage:[[UIImage imageNamed:@"PurchasedAlready"] stretchableImageWithLeftCapWidth:3 topCapHeight:0] forState:UIControlStateDisabled];
    }
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    //set the buttons' view's visibility.
    [UIView animateWithDuration:kFadeAnimationDuration animations:^{
        self.editButtonsView.alpha = editing ? 1.0 : 0.0;
    }];
    
    //make sure the text field isn't editable if we stop editing the cells altogether.
    //(Note that we don't automatically make the text field editable when starting to edit,
    //as that requires a secondary action)
    if (!editing) {
        self.workflowTitleField.enabled = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setWorkflow:(Workflow *)newWorkflow 
{
    //set properties based on the new workflow.
    workflow = newWorkflow;
}

#pragma mark - Button Action Methods
-(IBAction)renameButtonPressed:(id)sender;
{
    //make the title editable and give it focus.
    self.workflowTitleField.enabled = YES;
    [self.workflowTitleField becomeFirstResponder];
    
    self.renameButton.enabled = NO;
}

-(IBAction)editWorkflowButtonPressed:(id)sender
{
    BOOL shouldCopy = ([workflow.collections count] > 0);
    
    [delegate didRequestModificationForWorkflow:workflow copyFirst:shouldCopy];
}

#pragma mark UITextField delegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    //save the result in the workflow.
    if (textField == self.workflowTitleField && self.workflow) {
        self.workflow.name = textField.text;
        
        //disable the text field.
        self.workflowTitleField.enabled = NO;
        
        //re-enable the rename button.
        self.renameButton.enabled = YES;

        //notify the delegate
        [delegate didRenameWorkflow:workflow];
    }
        
    [textField resignFirstResponder];
    return YES;
}

-(void) dealloc
{
    [super dealloc];
    [workflowTitleField release];
    [workflowDetailLabel release];
    [editButtonsView release];
    [renameButton release];
    [editWorkflowButton release];
}


@end
