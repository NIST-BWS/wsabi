//
//  WsabiBaseGridCell.h
//  
//
//  Created by Matt Aronoff on 2/18/11.
//

/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


#import <UIKit/UIKit.h>
#import "constants.h"
#import "AQGridViewCell.h"
#import "UIView+UserTesting.h"

@protocol WsabiBaseGridCellDelegate <NSObject>

-(void) didRequestCellDeletion:(id)sender;

@end

@interface WsabiBaseGridCell : AQGridViewCell {
    UIButton *deleteButton;        

    id<WsabiBaseGridCellDelegate> deletionDelegate;
}

-(IBAction) deleteButtonPressed:(id)sender;

@property (nonatomic, retain) IBOutlet UIButton *deleteButton;

@property (nonatomic, assign) id<WsabiBaseGridCellDelegate> deletionDelegate;
@end
