//
//  Workflow.h
//  wsabi
//
//  Created by Matt Aronoff on 10/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BiometricCollection, Capturer;

@interface Workflow : NSManagedObject

@property (nonatomic, retain) NSDate * timestampCreated;
@property (nonatomic, retain) NSDate * timestampModified;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *collections;
@property (nonatomic, retain) NSSet *capturers;
@end

@interface Workflow (CoreDataGeneratedAccessors)

- (void)addCollectionsObject:(BiometricCollection *)value;
- (void)removeCollectionsObject:(BiometricCollection *)value;
- (void)addCollections:(NSSet *)values;
- (void)removeCollections:(NSSet *)values;

- (void)addCapturersObject:(Capturer *)value;
- (void)removeCapturersObject:(Capturer *)value;
- (void)addCapturers:(NSSet *)values;
- (void)removeCapturers:(NSSet *)values;

@end
