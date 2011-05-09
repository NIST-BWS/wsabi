/*
 *  constants.h
 *  Wsabi
 *
 *  Created by Matt Aronoff on 3/8/10.
 *
 */

/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */

#define DEGREES_TO_RADIANS( degrees ) ( degrees * M_PI / 180 )

#define kFingerprintCellMargin CGPointMake(6,6)

#define kPolaroidExpansionDuration 0.3

#define kThumbnailImageMaxSize 128
#define kDownloadImageMaxSize 640

#define kFlipAnimationDuration 0.3
#define kFadeAnimationDuration 0.2

#define kFlashInAnimationDuration 0.3
#define kFlashOutAnimationDuration 0.8
#define kFlashOpacity 0.93

#define kCollectionCellSize CGSizeMake(128, 128)

#define kCollectionCellOffset CGSizeMake(12, 12)

#define kLocalCameraURLPrefix @"cam://"

//Modality types
typedef enum {
	kModalityFace = 0,
    kModalityIris,
	kModalityFinger,
    kModalityEar,
    kModalityVein,
    kModalityRetina,
    kModalityFoot,
	kModalityOther,
    kModality_COUNT
} SensorModalityType;

//Capture types
typedef enum {
    kCaptureTypeNotSet = 0,
    
    //Finger
	kCaptureTypeRightThumbRolled,
	kCaptureTypeRightIndexRolled,
	kCaptureTypeRightMiddleRolled,
	kCaptureTypeRightRingRolled,
	kCaptureTypeRightLittleRolled,
	
    kCaptureTypeRightThumbFlat,
	kCaptureTypeRightIndexFlat,
	kCaptureTypeRightMiddleFlat,
	kCaptureTypeRightRingFlat,
	kCaptureTypeRightLittleFlat,
    
	kCaptureTypeLeftThumbRolled,
	kCaptureTypeLeftIndexRolled,
	kCaptureTypeLeftMiddleRolled,
	kCaptureTypeLeftRingRolled,
	kCaptureTypeLeftLittleRolled,
    
    kCaptureTypeLeftThumbFlat,
	kCaptureTypeLeftIndexFlat,
	kCaptureTypeLeftMiddleFlat,
	kCaptureTypeLeftRingFlat,
	kCaptureTypeLeftLittleFlat,
	
	kCaptureTypeLeftSlap,
	kCaptureTypeRightSlap,
    kCaptureTypeThumbsSlap,
    
    //Iris
	kCaptureTypeLeftIris,
	kCaptureTypeRightIris, 
	kCaptureTypeBothIrises, 

    //Face
    kCaptureTypeFace2d,
    kCaptureTypeFace3d,
    
    //Ear
    kCaptureTypeLeftEar,
	kCaptureTypeRightEar, 
	kCaptureTypeBothEars, 

    //Vein
    kCaptureTypeLeftVein,
	kCaptureTypeRightVein, 
	kCaptureTypePalm, 
    kCaptureTypeBackOfHand,
    kCaptureTypeWrist,
    
    //Retina
    kCaptureTypeLeftRetina,
    kCaptureTypeRightRetina,
    kCaptureTypeBothRetinas,
    
    //Foot
    kCaptureTypeLeftFoot,
    kCaptureTypeRightFoot,
    kCaptureTypeBothFeet,

    //Single items
    kCaptureTypeScent,
    kCaptureTypeDNA,
    kCaptureTypeHandGeometry,
    kCaptureTypeVoice,
    kCaptureTypeGait,
    kCaptureTypeKeystroke,
    kCaptureTypeLipMovement,
    kCaptureTypeSignatureSign,
    
    kCaptureType_COUNT
} SensorCaptureType;

//Annotation types -- this is defined in section 19.1.18 of ANSI/NIST-ITL 1-2007
typedef enum {
    kAnnotationNone = 0,
    kAnnotationUnprintable,
    kAnnotationAmputated,
    kAnnotation_COUNT
} AnnotationType;