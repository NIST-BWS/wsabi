//
//  SensorModality.h
//  Wsabi
//
//  Created by Matt Aronoff on 4/6/11.
//  Copyright (c) 2011 NIST. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Sensor;

@interface SensorModality : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) Sensor * sensor;

@end
