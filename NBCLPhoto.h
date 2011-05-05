//
//  NBCLPhoto.h
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


//NOTE: Based on code from http://www.raywenderlich.com/1430/how-to-use-the-three20-photo-viewer

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>

@interface NBCLPhoto : NSObject <TTPhoto> {

    NSString *_caption;
    NSString *_urlLarge;
    NSString *_urlSmall;
    NSString *_urlThumb;
    id <TTPhotoSource> _photoSource;
    CGSize _size;
    NSInteger _index;
}

@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSString *urlLarge;
@property (nonatomic, copy) NSString *urlSmall;
@property (nonatomic, copy) NSString *urlThumb;
@property (nonatomic, assign) id <TTPhotoSource> photoSource;
@property (nonatomic) CGSize size;
@property (nonatomic) NSInteger index;

- (id)initWithCaption:(NSString *)caption urlLarge:(NSString *)urlLarge urlSmall:(NSString *)urlSmall urlThumb:(NSString *)urlThumb size:(CGSize)size;

@end