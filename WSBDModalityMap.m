//
//  WSBDModalityMap.m
//  Wsabi
//
//  Created by Matt Aronoff on 2/10/11.
//
/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


#import "WSBDModalityMap.h"


@implementation WSBDModalityMap


+(NSString*) stringForCaptureType:(SensorCaptureType)captureType
{

    switch (captureType) {
        case kCaptureTypeNotSet:
            return @"Capture Type Not Set";
            break;
            
        //Finger
        case kCaptureTypeRightThumbRolled:
            return @"Right Thumb (Rolled)";
            break;
        case kCaptureTypeRightIndexRolled:
            return @"Right Index (Rolled)";
            break;
        case kCaptureTypeRightMiddleRolled:
            return @"Right Middle (Rolled)";
            break;
        case kCaptureTypeRightRingRolled:
            return @"Right Ring (Rolled)";
            break;
        case kCaptureTypeRightLittleRolled:
            return @"Right Little (Rolled)";
            break;
            
        case kCaptureTypeRightThumbFlat:
            return @"Right Thumb";
            break;
        case kCaptureTypeRightIndexFlat:
            return @"Right Index";
            break;
        case kCaptureTypeRightMiddleFlat:
            return @"Right Middle";
            break;
        case kCaptureTypeRightRingFlat:
            return @"Right Ring";
            break;
        case kCaptureTypeRightLittleFlat:
            return @"Right Little";
            break;

        case kCaptureTypeLeftThumbRolled:
            return @"Left Thumb (Rolled)";
            break;
        case kCaptureTypeLeftIndexRolled:
            return @"Left Index (Rolled)";
            break;
        case kCaptureTypeLeftMiddleRolled:
            return @"Left Middle (Rolled)";
            break;
        case kCaptureTypeLeftRingRolled:
            return @"Left Ring (Rolled)";
            break;
        case kCaptureTypeLeftLittleRolled:
            return @"Left Little (Rolled)";
            break;
            
        case kCaptureTypeLeftThumbFlat:
            return @"Left Thumb";
            break;
        case kCaptureTypeLeftIndexFlat:
            return @"Left Index";
            break;
        case kCaptureTypeLeftMiddleFlat:
            return @"Left Middle";
            break;
        case kCaptureTypeLeftRingFlat:
            return @"Left Ring";
            break;
        case kCaptureTypeLeftLittleFlat:
            return @"Left Little";
            break;

        case kCaptureTypeLeftSlap:
            return @"Left Slap";
            break;
        case kCaptureTypeRightSlap:
            return @"Right Slap";
            break;
        case kCaptureTypeThumbsSlap:
            return @"Thumbs Slap";
            break;
            
        //Iris
        case kCaptureTypeLeftIris:
            return @"Left Iris";
            break;
        case kCaptureTypeRightIris:
            return @"Right Iris";
            break;
        case kCaptureTypeBothIrises:
            return @"Both Irises";
            break;
            
        //Face
        case kCaptureTypeFace2d:
            return @"Face";
            break;
        case kCaptureTypeFace3d:
            return @"Face (3D)";
            break;
  
        //Ear
        case kCaptureTypeLeftEar:
            return @"Left Ear";
            break;
        case kCaptureTypeRightEar:
            return @"Right Ear";
            break;
        case kCaptureTypeBothEars:
            return @"Both Ears";
            break;
    
        //Vein
        case kCaptureTypeLeftVein:
            return @"Left Vein";
            break;
        case kCaptureTypeRightVein:
            return @"Right Vein";
            break;
        case kCaptureTypePalm:
            return @"Palm";
            break;
        case kCaptureTypeBackOfHand:
            return @"Back of Hand";
            break;
        case kCaptureTypeWrist:
            return @"Wrist";
            break;

        //Retina
        case kCaptureTypeLeftRetina:
            return @"Left Retina";
            break;
        case kCaptureTypeRightRetina:
            return @"Right Retina";
            break;
        case kCaptureTypeBothRetinas:
            return @"Both Retinas";
            break;
            
        //Foot
        case kCaptureTypeLeftFoot:
            return @"Left Foot";
            break;
        case kCaptureTypeRightFoot:
            return @"Right Foot";
            break;
        case kCaptureTypeBothFeet:
            return @"Both Feet";
            break;

        //Single items
        case kCaptureTypeScent:
            return @"Scent";
            break;
        case kCaptureTypeDNA:
            return @"DNA";
            break;
        case kCaptureTypeHandGeometry:
            return @"Hand Geometry";
            break;
        case kCaptureTypeVoice:
            return @"Voice";
            break;
        case kCaptureTypeGait:
            return @"Gait";
            break;
        case kCaptureTypeKeystroke:
            return @"Keystroke";
            break;
        case kCaptureTypeLipMovement:
            return @"Lip Movement";
            break;
        case kCaptureTypeSignatureSign:
            return @"Signature";
            break;
            
        default:
            break;
    }
    return @"";
}

+(NSString*) parameterNameForCaptureType:(SensorCaptureType)captureType
{
    switch (captureType) {
        case kCaptureTypeNotSet:
            return @"";
            break;
            
            //Finger
        case kCaptureTypeRightThumbRolled:
            return @"rightThumbRolled";
            break;
        case kCaptureTypeRightIndexRolled:
            return @"rightIndexRolled";
            break;
        case kCaptureTypeRightMiddleRolled:
            return @"rightMiddleRolled";
            break;
        case kCaptureTypeRightRingRolled:
            return @"rightRingRolled";
            break;
        case kCaptureTypeRightLittleRolled:
            return @"rightLittleRolled";
            break;
            
        case kCaptureTypeRightThumbFlat:
            return @"rightLittleFlat";
            break;
        case kCaptureTypeRightIndexFlat:
            return @"rightIndexFlat";
            break;
        case kCaptureTypeRightMiddleFlat:
            return @"rightMiddleFlat";
            break;
        case kCaptureTypeRightRingFlat:
            return @"rightRingFlat";
            break;
        case kCaptureTypeRightLittleFlat:
            return @"rightLittleFlat";
            break;

        case kCaptureTypeLeftThumbRolled:
            return @"leftThumbRolled";
            break;
        case kCaptureTypeLeftIndexRolled:
            return @"leftIndexRolled";
            break;
        case kCaptureTypeLeftMiddleRolled:
            return @"leftMiddleRolled";
            break;
        case kCaptureTypeLeftRingRolled:
            return @"leftRingRolled";
            break;
        case kCaptureTypeLeftLittleRolled:
            return @"leftLittleRolled";
            break;
            
        case kCaptureTypeLeftThumbFlat:
            return @"leftLittleFlat";
            break;
        case kCaptureTypeLeftIndexFlat:
            return @"leftIndexFlat";
            break;
        case kCaptureTypeLeftMiddleFlat:
            return @"leftMiddleFlat";
            break;
        case kCaptureTypeLeftRingFlat:
            return @"leftRingFlat";
            break;
        case kCaptureTypeLeftLittleFlat:
            return @"leftLittleFlat";
            break;

            
        case kCaptureTypeLeftSlap:
            return @"leftSlap";
            break;
        case kCaptureTypeRightSlap:
            return @"rightSlap";
            break;
        case kCaptureTypeThumbsSlap:
            return @"thumbsSlap";
            break;
            
            //Iris
        case kCaptureTypeLeftIris:
            return @"leftIris";
            break;
        case kCaptureTypeRightIris:
            return @"rightIris";
            break;
        case kCaptureTypeBothIrises:
            return @"bothIrises";
            break;
            
            //Face
        case kCaptureTypeFace2d:
            return @"face2d";
            break;
        case kCaptureTypeFace3d:
            return @"face3d";
            break;
            
            //Ear
        case kCaptureTypeLeftEar:
            return @"leftEar";
            break;
        case kCaptureTypeRightEar:
            return @"rightEar";
            break;
        case kCaptureTypeBothEars:
            return @"bothEars";
            break;
            
            //Vein
        case kCaptureTypeLeftVein:
            return @"leftVein";
            break;
        case kCaptureTypeRightVein:
            return @"rightVein";
            break;
        case kCaptureTypePalm:
            return @"palm";
            break;
        case kCaptureTypeBackOfHand:
            return @"backOfHand";
            break;
        case kCaptureTypeWrist:
            return @"wrist";
            break;
            
            //Retina
        case kCaptureTypeLeftRetina:
            return @"leftRetina";
            break;
        case kCaptureTypeRightRetina:
            return @"rightRetina";
            break;
        case kCaptureTypeBothRetinas:
            return @"bothRetinas";
            break;
            
            //Foot
        case kCaptureTypeLeftFoot:
            return @"leftFoot";
            break;
        case kCaptureTypeRightFoot:
            return @"rightFoot";
            break;
        case kCaptureTypeBothFeet:
            return @"bothFeet";
            break;
            
            //Single items
        case kCaptureTypeScent:
            return @"scent";
            break;
        case kCaptureTypeDNA:
            return @"dna";
            break;
        case kCaptureTypeHandGeometry:
            return @"handGeometry";
            break;
        case kCaptureTypeVoice:
            return @"voice";
            break;
        case kCaptureTypeGait:
            return @"gait";
            break;
        case kCaptureTypeKeystroke:
            return @"keystroke";
            break;
        case kCaptureTypeLipMovement:
            return @"lipMovement";
            break;
        case kCaptureTypeSignatureSign:
            return @"signature";
            break;
            
        default:
            break;
    }
    return @"";
}


+(NSString*) stringForModality:(SensorModalityType)modalityType
{
    switch (modalityType) {
        case kModalityFace:
            return @"Face";
            break;
         case kModalityIris:
            return @"Iris";
            break;       
        case kModalityFinger:
            return @"Finger";
            break;
        case kModalityEar:
            return @"Ear";
            break;
        case kModalityVein:
            return @"Vein";
            break;
        case kModalityRetina:
            return @"Retina";
            break;
        case kModalityFoot:
            return @"Foot";
            break;
         case kModalityOther:
            return @"Other";
            break;
    
        default:
            break;
    }
    return @"";
}

+(NSArray*) captureTypesForModality:(SensorModalityType)modality
{
    switch (modality) {
        case kModalityFace:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:kCaptureTypeFace2d],
                    [NSNumber numberWithInt:kCaptureTypeFace3d],
                    nil];
            break;
        case kModalityIris:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:kCaptureTypeLeftIris],
                    [NSNumber numberWithInt:kCaptureTypeRightIris],
                    [NSNumber numberWithInt:kCaptureTypeBothIrises],
                    nil];
            
            break;

        case kModalityFinger:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:kCaptureTypeLeftSlap],
                    [NSNumber numberWithInt:kCaptureTypeRightSlap],
                    [NSNumber numberWithInt:kCaptureTypeThumbsSlap],

                    [NSNumber numberWithInt:kCaptureTypeLeftThumbFlat],
                    [NSNumber numberWithInt:kCaptureTypeLeftIndexFlat],
                    [NSNumber numberWithInt: kCaptureTypeLeftMiddleFlat],
                    [NSNumber numberWithInt:kCaptureTypeLeftRingFlat],
                    [NSNumber numberWithInt:kCaptureTypeLeftLittleFlat],

                    [NSNumber numberWithInt:kCaptureTypeRightThumbFlat],
                    [NSNumber numberWithInt:kCaptureTypeRightIndexFlat],
                    [NSNumber numberWithInt: kCaptureTypeRightMiddleFlat],
                    [NSNumber numberWithInt:kCaptureTypeRightRingFlat],
                    [NSNumber numberWithInt:kCaptureTypeRightLittleFlat],
                    
                    [NSNumber numberWithInt:kCaptureTypeLeftThumbRolled],
                    [NSNumber numberWithInt:kCaptureTypeLeftIndexRolled],
                    [NSNumber numberWithInt: kCaptureTypeLeftMiddleRolled],
                    [NSNumber numberWithInt:kCaptureTypeLeftRingRolled],
                    [NSNumber numberWithInt:kCaptureTypeLeftLittleRolled],
                    
                    [NSNumber numberWithInt:kCaptureTypeRightThumbRolled],
                    [NSNumber numberWithInt:kCaptureTypeRightIndexRolled],
                    [NSNumber numberWithInt: kCaptureTypeRightMiddleRolled],
                    [NSNumber numberWithInt:kCaptureTypeRightRingRolled],
                    [NSNumber numberWithInt:kCaptureTypeRightLittleRolled],

                    nil];

            break;
        case kModalityEar:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:kCaptureTypeLeftEar],
                    [NSNumber numberWithInt:kCaptureTypeRightEar],
                    [NSNumber numberWithInt:kCaptureTypeBothEars],
                    nil];

            break;
        case kModalityVein:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:kCaptureTypeLeftVein],
                    [NSNumber numberWithInt:kCaptureTypeRightVein],
                    [NSNumber numberWithInt:kCaptureTypePalm],
                    [NSNumber numberWithInt:kCaptureTypeBackOfHand],
                    [NSNumber numberWithInt:kCaptureTypeWrist],
                    nil];
            break;
        case kModalityRetina:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:kCaptureTypeLeftRetina],
                    [NSNumber numberWithInt:kCaptureTypeRightRetina],
                    [NSNumber numberWithInt:kCaptureTypeBothRetinas],
                    nil];

            break;
        case kModalityFoot:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:kCaptureTypeLeftFoot],
                    [NSNumber numberWithInt:kCaptureTypeRightFoot],
                    [NSNumber numberWithInt:kCaptureTypeBothFeet],
                    nil];

            break;

        case kModalityOther:
            //return all capture types for now.
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:kCaptureTypeScent],
                    [NSNumber numberWithInt:kCaptureTypeDNA],
                    [NSNumber numberWithInt:kCaptureTypeHandGeometry],
                    [NSNumber numberWithInt:kCaptureTypeVoice],
                    [NSNumber numberWithInt: kCaptureTypeGait],
                    [NSNumber numberWithInt:kCaptureTypeLipMovement],
                    [NSNumber numberWithInt:kCaptureTypeSignatureSign],
                    nil];
            break;
            
        default:
            break;
    }
    return nil;
}


@end
