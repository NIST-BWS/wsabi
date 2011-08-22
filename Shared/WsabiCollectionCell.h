//
//  WsabiCollectionCell.h
//  Wsabi
//
//  Created by Matt Aronoff on 2/3/11.
//
/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BiometricCollection.h"
#import "BiometricData.h"
#import "WsabiCollectionItemCell.h"

#import "AQGridView.h"

#import "constants.h"

@protocol WsabiCollectionDelegate <NSObject>
-(void) didSelectItemAtIndex:(int)index fromCollectionCell:(id)sender;
-(void) didRequestLargeViewOfItemAtIndex:(int)index fromCollectionCell:(id)sender;
@end

@interface WsabiCollectionCell : UITableViewCell <AQGridViewDelegate, AQGridViewDataSource> {
	    
	BiometricCollection *collection;
	NSArray *sortedItems;
    
    AQGridView *cellGrid;
    
    id<WsabiCollectionDelegate> delegate;
}

-(void) itemButtonPressed:(UITapGestureRecognizer*)recog;
-(void) itemButtonDoublePressed:(UITapGestureRecognizer*)recog;
-(void) itemReversePinched:(UIPinchGestureRecognizer*)recog;

-(void) selectItemAtIndex:(int)index;
-(void) clearSelection;

@property (nonatomic, assign) BiometricCollection *collection;

@property (nonatomic, retain) NSArray *sortedItems;
@property (nonatomic, retain) IBOutlet AQGridView *cellGrid;

@property (nonatomic, assign) id<WsabiCollectionDelegate> delegate;

@end
