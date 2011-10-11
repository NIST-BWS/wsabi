//
//  Sensor.m
//  wsabi
//
//  Created by Matt Aronoff on 10/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Sensor.h"
#import "Capturer.h"
#import "SensorModality.h"
#import "SensorParam.h"


@implementation Sensor

@dynamic timestampCreated;
@dynamic timestampModified;
@dynamic connected;
@dynamic name;
@dynamic uri;
@dynamic deleted;
@dynamic params;
@dynamic modalities;
@dynamic usedInCapturers;

@end
