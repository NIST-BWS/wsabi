//
//  WSBDModalityMap.h
//  Wsabi
//
//  Created by Matt Aronoff on 2/10/11.
//

#import <Foundation/Foundation.h>
#import "constants.h"

@interface WSBDModalityMap : NSObject {
    
}

//Returns a pretty name for this capture type
+(NSString*) stringForCaptureType:(SensorCaptureType)captureType;

//Returns the parameter name (for use in setting configurations) for this capture type
+(NSString*) parameterNameForCaptureType:(SensorCaptureType)captureType;

+(NSString*) stringForModality:(SensorModalityType)modalityType;

+(NSArray*) captureTypesForModality:(SensorModalityType)modality;

@end
