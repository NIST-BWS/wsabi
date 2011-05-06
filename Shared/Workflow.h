//
//  Workflow.h
//  Wsabi
//
//  Created by Matt Aronoff on 4/6/11.
//  Copyright (c) 2011 NIST. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BiometricCollection, Capturer;

@interface Workflow : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * timestampCreated;
@property (nonatomic, retain) NSDate * timestampModified;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* collections;
@property (nonatomic, retain) NSSet* capturers;

@end
