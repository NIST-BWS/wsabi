//
//  BiometricData.h
//  wsabi
//
//  Created by Matt Aronoff on 10/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BiometricCollection;

@interface BiometricData : NSManagedObject

@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSNumber * originalCaptureType;
@property (nonatomic, retain) NSDate * timestampModified;
@property (nonatomic, retain) NSData * annotations;
@property (nonatomic, retain) NSString * contentType;
@property (nonatomic, retain) NSDate * timestampCaptured;
@property (nonatomic, retain) NSNumber * positionInCollection;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSNumber * captureType;
@property (nonatomic, retain) NSNumber * notTaken;
@property (nonatomic, retain) BiometricCollection *collection;

@end
