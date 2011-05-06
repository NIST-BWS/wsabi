//
//  NBCLPhotoBrowserSource.h
//  
//
//  Created by Matt Aronoff on 4/18/11.
//
/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


#import <Foundation/Foundation.h>
#import "Three20/Three20.h"
#import "NBCLPhoto.h"

@interface NBCLPhotoSource : TTURLRequestModel <TTPhotoSource> {
    NSString *_title;
    NSArray *_photos;
}

- (id) initWithTitle:(NSString *)title photos:(NSArray *)photos;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) NSArray *photos;
    
@end