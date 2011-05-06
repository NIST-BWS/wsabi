//
//  Capturer.h
//  Wsabi
//
//  Created by Matt Aronoff on 4/6/11.
//  Copyright (c) 2011 NIST. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Sensor, SensorParam, Workflow;

@interface Capturer : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * positionInWorkflow;
@property (nonatomic, retain) NSNumber * captureType;
@property (nonatomic, retain) Workflow * workflow;
@property (nonatomic, retain) Sensor * sensor;
@property (nonatomic, retain) NSSet* instanceParams;

@end
