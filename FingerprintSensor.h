//
//  FingerprintSensor.h
//  wsabi
//
//  Created by Matt Aronoff on 10/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Sensor.h"


@interface FingerprintSensor : Sensor

@property (nonatomic, retain) NSNumber * supportsSingleFinger;
@property (nonatomic, retain) NSNumber * supportsTwoFinger;
@property (nonatomic, retain) NSNumber * supportsSlap;

@end
