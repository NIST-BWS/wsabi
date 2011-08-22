//
//  WsabiCollectionCell.m
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

#define BADGE_TAG 1001

#import "WsabiCollectionCell.h"

@implementation WsabiCollectionCell

@synthesize collection, sortedItems, cellGrid, delegate;

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        // Initialization code.
//    }
//    return self;
//}
//

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


#pragma mark -
#pragma mark Core Data interaction
- (void) setCollection:(BiometricCollection *)newCollection
{
	collection = newCollection;
	
    //configure the grid view here, since this will be called before viewing this cell.
    self.cellGrid.scrollEnabled = NO;
    
    //sort the data items by their position in the collection, then create a sub-cell for each one.
    NSSortDescriptor *orderSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"positionInCollection" ascending:YES selector:@selector(compare:)] autorelease];

    NSArray *sortDescriptors = [NSArray arrayWithObject:orderSortDescriptor];

    self.sortedItems = [collection.items sortedArrayUsingDescriptors:sortDescriptors];

    [self.cellGrid reloadData];

}

#pragma mark -
#pragma mark GridView Data Source
- (NSUInteger) numberOfItemsInGridView: (AQGridView *) gridView
{
    if (self.collection) {
        return [self.sortedItems count];
    }
    else return 0;
}

- (AQGridViewCell *) gridView: (AQGridView *) gridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString * CellIdentifier = @"CellIdentifier";
    
    WsabiCollectionItemCell * cell = (WsabiCollectionItemCell*)[gridView dequeueReusableCellWithIdentifier: CellIdentifier];
    if ( cell == nil )
    {
        cell = [[[WsabiCollectionItemCell alloc] initWithFrame: CGRectMake(0, 0, kCollectionCellSize.width, kCollectionCellSize.height) reuseIdentifier: CellIdentifier] autorelease];
    }
    else
    {
        //remove any existing cellView.
        for (UIView *v in self.contentView.subviews) {
            if ([v isKindOfClass:[WsabiCollectionItemCell class]]) {
                [v removeFromSuperview];
            }
        }

    }
        
    //FIXME: figure out whether the item that matches this target position
    //has any data. If so, fill the cell from that item. If not, use a placeholder image.
    
    BiometricData *item = [sortedItems objectAtIndex:index];
    
    if (item) {
      //  NSLog(@"data item's captureType is %d",[item.captureType intValue]);
        int capType = [item.captureType intValue];

        if (capType == kCaptureTypeNotSet || capType > kCaptureTypeFace3d) {
            cell.placeholderImage = [UIImage imageNamed:@"CollectionDataBackground_Other"];
        }
        //Fingerprint
        else if (capType < kCaptureTypeLeftIris) {
            cell.placeholderImage = [UIImage imageNamed:@"CollectionDataBackground_Finger"];
        }
        //Iris
        else if (capType == kCaptureTypeFace2d) {
            cell.placeholderImage = [UIImage imageNamed:@"CollectionDataBackground_Face"];
        }
        //Face
        else {
            cell.placeholderImage = [UIImage imageNamed:@"CollectionDataBackground_Iris"];
        }
        
        
        if (item.thumbnail) {
            cell.isFilled = YES;
            cell.dataImage = [UIImage imageWithData:item.thumbnail];
        }
        else {
            cell.isFilled = NO;
            cell.dataImage = nil;
        }
        
    }
    
    //add a shadow to the cell view, and make sure it rasterizes (this allows for decent performance).
//    cellView.layer.shadowColor = [[UIColor blackColor] CGColor];
//    cellView.layer.shadowOpacity = 0.4;
//    cellView.layer.shadowOffset = CGSizeMake(2, 2);
//    cellView.layer.shadowRadius = 5;
//    cellView.layer.shouldRasterize = YES;
    
    //set the cell's tag so that we can let our delegate know which item was pressed later.
    cell.tag = index;
    
    //attach a double-tap gesture recognizer to this cell
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemButtonDoublePressed:)];
    doubleTap.numberOfTapsRequired = 2;
    [cell addGestureRecognizer:doubleTap];
    [doubleTap release];

    //attach a reverse-pinch gesture recognizer to this cell
    UIPinchGestureRecognizer *reversePinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(itemReversePinched:)];
    [cell addGestureRecognizer:reversePinch];
    [reversePinch release];
    
    //attach a tap gesture recognizer to this cell.
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemButtonPressed:)];
    singleTap.numberOfTapsRequired = 1;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [cell addGestureRecognizer:singleTap];
    [singleTap release];

    //if the cell has annotations, add a badge.
    NSMutableDictionary *annotations = [NSKeyedUnarchiver unarchiveObjectWithData:item.annotations];
    if (annotations) {
        int badgeCount = 0;
                
        for (NSNumber *key in annotations) {
            //NOTE: Because we're getting spurious calls to annotationValueChanged that set the value of the
            //0-keyed entry, we need to make sure that we're looking at a valid entry before updating the badge.
            if ([key intValue] > 0 && [[annotations objectForKey:key] intValue] > 0) {
                badgeCount++;
            }    
        }

        if (badgeCount > 0) {
            //if there isn't already a badge, create one. Otherwise, update it.
            UIButton *badge = nil;
            if (![cell viewWithTag:BADGE_TAG]) {
                badge = [UIButton buttonWithType:UIButtonTypeCustom];
                badge.frame = CGRectMake(cell.contentView.bounds.size.width - 23, -5, 29, 29);
                badge.userInteractionEnabled = NO;
                [badge setBackgroundImage:[UIImage imageNamed:@"BadgeBackground"] forState:UIControlStateNormal];
                badge.titleLabel.textColor = [UIColor whiteColor];
                badge.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                [badge setTitleEdgeInsets:UIEdgeInsetsMake(-1, 0, 1, 0)];
                badge.alpha = 0.8;
                badge.tag = BADGE_TAG;
                [cell.contentView addSubview:badge];
            }
            else
            {
                badge = (UIButton*)[cell viewWithTag:BADGE_TAG];
            }
           [badge setTitle:[NSString stringWithFormat:@"%d",badgeCount] forState:UIControlStateNormal];
        }
        else {
            //remove the badge.
            if ([cell viewWithTag:BADGE_TAG]) {
                [[cell viewWithTag:BADGE_TAG] removeFromSuperview];
            }
        }
    }
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionGlowColor = [UIColor colorWithRed:0 green:0.5 blue:1.0 alpha:0.2];
    cell.selectionGlowShadowRadius = 6;
    //cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CollectionDataItemSelectedBackground"]] autorelease];
    
    //if the cell should be selected, select it.
    if([self.collection.currentPosition intValue] == index && [self.collection.isActive boolValue])
    {
        [self.cellGrid selectItemAtIndex:index animated:YES scrollPosition:AQGridViewScrollPositionNone];
    }
    
    
    return ( cell );
}

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) gridView
{
    return  CGSizeMake(kCollectionCellSize.width + (2 * kCollectionCellOffset.width), kCollectionCellSize.height + (2 * kCollectionCellOffset.height));
}

#pragma mark -
#pragma mark Gesture Recognizer Methods
-(void) itemButtonPressed:(UITapGestureRecognizer*)recog
{
    //mark this item as the current collection position.
    self.collection.currentPosition = [NSNumber numberWithInt:recog.view.tag];
    
    //reload this cell.
    [self.cellGrid reloadData];
    
    //figure out which cell was pressed and notify our delegate.
    [delegate didSelectItemAtIndex:recog.view.tag fromCollectionCell:self];
}

-(void) itemButtonDoublePressed:(UITapGestureRecognizer*)recog
{

    //mark this item as the current collection position.
    self.collection.currentPosition = [NSNumber numberWithInt:recog.view.tag];
    
    //figure out which cell was pressed and notify our delegate.
    [delegate didRequestLargeViewOfItemAtIndex:recog.view.tag fromCollectionCell:self];
}

-(void) itemReversePinched:(UIPinchGestureRecognizer *)recog
{
    NSLog(@"Pinch velocity is %f",recog.velocity);
    if (recog.velocity > 3) {
        //mark this item as the current collection position.
        self.collection.currentPosition = [NSNumber numberWithInt:recog.view.tag];
        
        //figure out which cell was pressed and notify our delegate.
        [delegate didRequestLargeViewOfItemAtIndex:recog.view.tag fromCollectionCell:self];

    }

}


-(void) selectItemAtIndex:(int)index
{
    //mark this item as the current collection position.
    self.collection.currentPosition = [NSNumber numberWithInt:index];
    
    //reload this cell.
    [self.cellGrid reloadData];

}

-(void) clearSelection
{
    NSUInteger index = [self.cellGrid indexOfSelectedItem];
    if (index != NSNotFound) {
        [self.cellGrid deselectItemAtIndex:index animated:YES];
    }
}


- (void)dealloc {
    [sortedItems release];
    [cellGrid release];
    [super dealloc];
}


@end
