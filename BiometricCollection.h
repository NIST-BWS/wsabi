//
//  BiometricCollection.h
//  wsabi
//
//  Created by Matt Aronoff on 10/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BiometricData, Workflow;

@interface BiometricCollection : NSManagedObject

@property (nonatomic, retain) NSString * presenterId;
@property (nonatomic, retain) NSNumber * isActive;
@property (nonatomic, retain) NSNumber * isComplete;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * totalLength;
@property (nonatomic, retain) NSDate * timestampStarted;
@property (nonatomic, retain) NSNumber * currentPosition;
@property (nonatomic, retain) NSDate * timestampCompleted;
@property (nonatomic, retain) Workflow *workflow;
@property (nonatomic, retain) NSSet *items;
@end

@interface BiometricCollection (CoreDataGeneratedAccessors)

- (void)addItemsObject:(BiometricData *)value;
- (void)removeItemsObject:(BiometricData *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
