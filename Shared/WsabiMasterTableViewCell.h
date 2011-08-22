//
//  WsabiMasterTableViewCell.h
//  wsabi
//
//  Created by Matt Aronoff on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Workflow.h"
#import "constants.h"

@protocol WsabiMasterTableViewCellDelegate <NSObject>
-(void) didRenameWorkflow:(Workflow*)w;
-(void) didRequestModificationForWorkflow:(Workflow*)w copyFirst:(BOOL)shouldCopy;
@end


@interface WsabiMasterTableViewCell : UITableViewCell <UITextFieldDelegate> {

    Workflow *workflow;
    
    UITextField *workflowTitleField;
    UILabel *workflowDetailLabel;
    UIView *editButtonsView;
    UIButton *renameButton;
    UIButton *editWorkflowButton;
    
    id<WsabiMasterTableViewCellDelegate> delegate;
}

-(IBAction)renameButtonPressed:(id)sender;
-(IBAction)editWorkflowButtonPressed:(id)sender;

@property (nonatomic, assign) Workflow *workflow;

@property (nonatomic, retain) IBOutlet UITextField *workflowTitleField;
@property (nonatomic, retain) IBOutlet UILabel *workflowDetailLabel;
@property (nonatomic, retain) IBOutlet UIView *editButtonsView;
@property (nonatomic, retain) IBOutlet UIButton *renameButton;
@property (nonatomic, retain) IBOutlet UIButton *editWorkflowButton;

@property (nonatomic, assign) id<WsabiMasterTableViewCellDelegate> delegate;

@end
