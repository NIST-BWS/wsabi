//
//  NBCLPhoto.m
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


#import "NBCLPhoto.h"


@implementation NBCLPhoto

@synthesize caption = _caption;
@synthesize urlLarge = _urlLarge;
@synthesize urlSmall = _urlSmall;
@synthesize urlThumb = _urlThumb;
@synthesize photoSource = _photoSource;
@synthesize size = _size;
@synthesize index = _index;

- (id)initWithCaption:(NSString *)caption urlLarge:(NSString *)urlLarge urlSmall:(NSString *)urlSmall urlThumb:(NSString *)urlThumb size:(CGSize)size {
    if ((self = [super init])) {
        self.caption = caption;
        self.urlLarge = urlLarge;
        self.urlSmall = urlSmall;
        self.urlThumb = urlThumb;
        self.size = size;
        self.index = NSIntegerMax;
        self.photoSource = nil;
    }
    return self;
}

- (void) dealloc {
    self.caption = nil;
    self.urlLarge = nil;
    self.urlSmall = nil;
    self.urlThumb = nil;    
    [super dealloc];
}

#pragma mark TTPhoto

- (NSString*)URLForVersion:(TTPhotoVersion)version {
    switch (version) {
        case TTPhotoVersionLarge:
            return _urlLarge;
        case TTPhotoVersionMedium:
            return _urlLarge;
        case TTPhotoVersionSmall:
            return _urlSmall;
        case TTPhotoVersionThumbnail:
            return _urlThumb;
        default:
            return nil;
    }
}

@end
