//
//  WsabiWorkflowBuilderCell.h
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


#import <UIKit/UIKit.h>
#import "AQGridViewCell.h"
#import "WsabiBaseGridCell.h"
#import "WsabiWorkflowItem.h"
#import "Capturer.h"

@protocol WsabiWorkflowBuilderCellDelegate <NSObject>
-(void) didRequestWorkflowDeletionAtIndex:(int)index;
@end

@interface WsabiWorkflowBuilderCell : WsabiBaseGridCell <UIActionSheetDelegate> {

	Capturer *capturer;
	UILabel *positionLabel;
	WsabiWorkflowItem *capView;
    
    id<WsabiWorkflowBuilderCellDelegate> delegate;
}

-(IBAction) deleteButtonPressed:(id)sender;

@property (nonatomic, assign) Capturer *capturer;
@property (nonatomic, retain) IBOutlet UILabel *positionLabel;
@property (nonatomic, retain) IBOutlet WsabiWorkflowItem *capView;

@property (nonatomic, assign) id<WsabiWorkflowBuilderCellDelegate> delegate;

@end
