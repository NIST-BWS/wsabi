//
//  SensorModality.h
//  wsabi
//
//  Created by Matt Aronoff on 10/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Sensor;

@interface SensorModality : NSManagedObject

@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) Sensor *sensor;

@end
