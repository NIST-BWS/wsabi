//
//  SensorParam.h
//  Wsabi
//
//  Created by Matt Aronoff on 4/6/11.
//  Copyright (c) 2011 NIST. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Capturer, Sensor;

@interface SensorParam : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * readOnly;
@property (nonatomic, retain) NSNumber * boolData;
@property (nonatomic, retain) NSString * stringData;
@property (nonatomic, retain) NSDate * dateData;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * floatData;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * binaryData;
@property (nonatomic, retain) Capturer * capturer;
@property (nonatomic, retain) Sensor * sensor;

@end
