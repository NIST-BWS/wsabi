//
//  WsabiBaseGridCell.m
//  Wsabi
//
//  Created by Matt Aronoff on 3/11/11.
//
/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


#import "WsabiBaseGridCell.h"

@implementation WsabiBaseGridCell
@synthesize deleteButton, deletionDelegate;

#define DELETE_BUTTON_INSET_WIDTH 10

- (id) initWithFrame: (CGRect) frame reuseIdentifier: (NSString *) reuseIdentifier
{
    self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
	if ( self == nil )
		return ( nil );
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *deleteImage = [UIImage imageNamed:@"DeleteButton_Large"]; 
    [self.deleteButton setImage:deleteImage forState:UIControlStateNormal];
    [self.deleteButton sizeToFit];
    NSLog(@"Delete button's size is %1.0f,%1.0f",self.deleteButton.bounds.size.width, self.deleteButton.bounds.size.height);
    self.deleteButton.center = CGPointMake(frame.size.width - DELETE_BUTTON_INSET_WIDTH - self.deleteButton.bounds.size.width/2.0,
                                           self.deleteButton.bounds.size.height/2.0);
    self.deleteButton.hidden = YES;
    [self.deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.deleteButton];
    
    return self;
}

-(void) layoutSubviews
{
    //make sure the delete button is on top
    [self.contentView bringSubviewToFront:self.deleteButton];
}

#pragma mark Property accessors
- (void) setEditing: (BOOL) value
{
	[self setEditing:value animated:NO];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
    
    //Always perform this animation -- it's fast,
    //and necessary for context.
    if (editing && self.deleteButton.hidden) {
        //show the delete button
        self.deleteButton.alpha = 0;
        self.deleteButton.hidden = NO;
        //make sure it's at the front.
        [self.contentView bringSubviewToFront:self.deleteButton];
        [UIView animateWithDuration:kFadeAnimationDuration 
                         animations:^{
                             self.deleteButton.alpha = 1;
                         }
         ];
    }
    else if (!editing && !self.deleteButton.hidden) {
        //hide the delete button
        [UIView animateWithDuration:kFadeAnimationDuration 
                         animations:^{
                             self.deleteButton.alpha = 0;
                         }
                         completion:^(BOOL completed) {
                             self.deleteButton.hidden = YES;
                         }
         ];

    }
        
}


-(void) deleteButtonPressed:(id)sender
{
    [deletionDelegate didRequestCellDeletion:self];
}

-(void) dealloc
{
    [super dealloc];
    [deleteButton release];
}

@end
