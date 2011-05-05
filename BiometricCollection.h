//
//  BiometricCollection.h
//  Wsabi
//
//  Created by Matt Aronoff on 4/6/11.
//  Copyright (c) 2011 NIST. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BiometricData, Workflow;

@interface BiometricCollection : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * presenterId;
@property (nonatomic, retain) NSNumber * isActive;
@property (nonatomic, retain) NSNumber * isComplete;
@property (nonatomic, retain) NSNumber * totalLength;
@property (nonatomic, retain) NSDate * timestampStarted;
@property (nonatomic, retain) NSNumber * currentPosition;
@property (nonatomic, retain) NSDate * timestampCompleted;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) Workflow * workflow;
@property (nonatomic, retain) NSSet* items;

@end
