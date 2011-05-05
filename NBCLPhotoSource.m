//
//  NBCLPhotoBrowserSource.m
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


#import "NBCLPhotoSource.h"

@implementation NBCLPhotoSource 

@synthesize title = _title;
@synthesize photos = _photos;

- (id) initWithTitle:(NSString *)title photos:(NSArray *)photos {
    if ((self = [super init])) {
        self.title = title;
        self.photos = photos;
        for(int i = 0; i < _photos.count; ++i) {
            NBCLPhoto *photo = [_photos objectAtIndex:i];
            photo.photoSource = self;
            photo.index = i;
        }        
    }
    return self;
}

- (void) dealloc {
    self.title = nil;
    self.photos = nil;    
    [super dealloc];
}

#pragma mark - TTModel

- (BOOL)isLoading { 
    return FALSE;
}

- (BOOL)isLoaded {
    return TRUE;
}

#pragma mark - TTPhotoSource

- (NSInteger)numberOfPhotos {
    return [_photos count];
}

- (NSInteger)maxPhotoIndex {
    return [_photos count]-1;
}

- (id<TTPhoto>)photoAtIndex:(NSInteger)photoIndex {
    if (photoIndex < [_photos count]) {
        return [_photos objectAtIndex:photoIndex];
    } else {
        return nil;
    }
}

@end
