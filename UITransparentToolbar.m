//
//  UITransparentToolbar.m
//  Wsabi
//
//  Created by Matt Aronoff on 11/8/10.
//

/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


#import "UITransparentToolbar.h"


@implementation UITransparentToolbar

// Override draw rect to avoid
// background coloring
- (void)drawRect:(CGRect)rect {
    // do nothing in here
}

// Set properties to make background
// translucent.
- (void) applyTranslucentBackground
{
	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
	self.translucent = YES;
}

// Override init.
- (id) init
{
	self = [super init];
	[self applyTranslucentBackground];
	return self;
}

// Override initWithFrame.
- (id) initWithFrame:(CGRect) frame
{
	self = [super initWithFrame:frame];
	[self applyTranslucentBackground];
	return self;
}

@end
