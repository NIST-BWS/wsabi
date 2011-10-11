//
//  Sensor.h
//  wsabi
//
//  Created by Matt Aronoff on 10/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Capturer, SensorModality, SensorParam;

@interface Sensor : NSManagedObject

@property (nonatomic, retain) NSDate * timestampCreated;
@property (nonatomic, retain) NSDate * timestampModified;
@property (nonatomic, retain) NSNumber * connected;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSSet *params;
@property (nonatomic, retain) NSSet *modalities;
@property (nonatomic, retain) NSSet *usedInCapturers;
@end

@interface Sensor (CoreDataGeneratedAccessors)

- (void)addParamsObject:(SensorParam *)value;
- (void)removeParamsObject:(SensorParam *)value;
- (void)addParams:(NSSet *)values;
- (void)removeParams:(NSSet *)values;

- (void)addModalitiesObject:(SensorModality *)value;
- (void)removeModalitiesObject:(SensorModality *)value;
- (void)addModalities:(NSSet *)values;
- (void)removeModalities:(NSSet *)values;

- (void)addUsedInCapturersObject:(Capturer *)value;
- (void)removeUsedInCapturersObject:(Capturer *)value;
- (void)addUsedInCapturers:(NSSet *)values;
- (void)removeUsedInCapturers:(NSSet *)values;

@end
