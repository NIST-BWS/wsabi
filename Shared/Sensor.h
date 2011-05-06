//
//  Sensor.h
//  Wsabi
//
//  Created by Matt Aronoff on 4/6/11.
//  Copyright (c) 2011 NIST. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Capturer, SensorModality, SensorParam;

@interface Sensor : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * timestampCreated;
@property (nonatomic, retain) NSDate * timestampModified;
@property (nonatomic, retain) NSNumber * connected;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSSet* params;
@property (nonatomic, retain) NSSet* modalities;
@property (nonatomic, retain) NSSet* usedInCapturers;

@end
