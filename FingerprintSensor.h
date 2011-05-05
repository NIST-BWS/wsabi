//
//  FingerprintSensor.h
//  Wsabi
//
//  Created by Matt Aronoff on 4/6/11.
//  Copyright (c) 2011 NIST. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Sensor.h"


@interface FingerprintSensor : Sensor {
@private
}
@property (nonatomic, retain) NSNumber * supportsSingleFinger;
@property (nonatomic, retain) NSNumber * supportsTwoFinger;
@property (nonatomic, retain) NSNumber * supportsSlap;

@end
