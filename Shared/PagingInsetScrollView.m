//
//  PagingInsetScrollView.m
//  Wsabi
//
//  Created by Matt Aronoff on 2/15/11.
//

/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


#import "PagingInsetScrollView.h"


@implementation PagingInsetScrollView

@synthesize responseInsets;

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint parentLocation = [self convertPoint:point toView:self.superview];
    CGRect responseRect = self.frame;
    responseRect.origin.x -= responseInsets.left;
    responseRect.origin.y -= responseInsets.top;
    responseRect.size.width += (responseInsets.left + responseInsets.right);
    responseRect.size.height += (responseInsets.top + responseInsets.bottom);
    
    return CGRectContainsPoint(responseRect, parentLocation);
}

@end
