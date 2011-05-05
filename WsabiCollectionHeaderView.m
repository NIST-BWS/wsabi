//
//  WsabiCollectionHeaderView.m
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


#import "WsabiCollectionHeaderView.h"


@implementation WsabiCollectionHeaderView

@synthesize headerLabel, addCollectionButton, editCollectionsButton;
@synthesize selected, editing;

-(void) layoutSubviews
{
    [super layoutSubviews];
    self.layer.shouldRasterize = YES; //performance.
}

-(void) setEditing:(BOOL)isEditing
{
    self.editCollectionsButton.selected = isEditing;
    editing = isEditing;
}

-(void) setSelected:(BOOL)sel 
{
    selected = sel;
    
    //set the background color, and
    //only enable the "add new" button on a selected collection.
    if (selected) {
       // self.backgroundColor = [self selectedColor];
        self.addCollectionButton.hidden = NO;
        self.editCollectionsButton.hidden = NO;
    }
    else {
        //self.backgroundColor = [self normalColor];
        self.addCollectionButton.hidden = YES;
        self.editCollectionsButton.hidden = YES;
    }
    

}

-(UIColor*)selectedColor
{
    return [UIColor colorWithRed:0 green:0.7 blue:0 alpha:0.7];
}

-(UIColor*)normalColor
{
    return [UIColor colorWithWhite:0.4 alpha:0.7];
}

- (void)drawRect:(CGRect)rect 
{
    // Get the Render Context
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    	
    // Sets the color to draw the line
    if (self.selected) {
        CGContextSetStrokeColorWithColor(ctx, [self selectedColor].CGColor);
    }
    else
    {
        CGContextSetStrokeColorWithColor(ctx, [self normalColor].CGColor); 
    }
    
	// Line Width : make thinner or bigger if you want
    float lineWidth = 2.0;
	CGContextSetLineWidth(ctx, lineWidth);
        
	// Add Move Command to point the draw cursor to the starting point
	CGContextMoveToPoint(ctx, self.headerLabel.frame.origin.x, self.bounds.size.height - 1);
    
	// Add Command to draw a Line
	CGContextAddLineToPoint(ctx, self.headerLabel.frame.origin.x + self.headerLabel.frame.size.width, self.bounds.size.height - lineWidth);
    
	// Actually draw the line.
	CGContextStrokePath(ctx);
    
	// should be nothing, but who knows...
	[super drawRect:rect];   
}

- (void)dealloc {
	[headerLabel release];
	[addCollectionButton release];
    [editCollectionsButton release];
    [super dealloc];
}


@end
