//
//  Capturer.h
//  wsabi
//
//  Created by Matt Aronoff on 10/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Sensor, SensorParam, Workflow;

@interface Capturer : NSManagedObject

@property (nonatomic, retain) NSNumber * positionInWorkflow;
@property (nonatomic, retain) NSNumber * captureType;
@property (nonatomic, retain) Workflow *workflow;
@property (nonatomic, retain) Sensor *sensor;
@property (nonatomic, retain) NSSet *instanceParams;
@end

@interface Capturer (CoreDataGeneratedAccessors)

- (void)addInstanceParamsObject:(SensorParam *)value;
- (void)removeInstanceParamsObject:(SensorParam *)value;
- (void)addInstanceParams:(NSSet *)values;
- (void)removeInstanceParams:(NSSet *)values;

@end
