//
//  Workflow+DeepCopying.m
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


//  I have not been able to find any deep copy code that works properly for this sort of Core Data object graph.
//  Among other things, the fact that Sensors appear (apparently) to be owned by Capturers when they shouldn't be,
//  means that general-purpose deep copy code fails. Therefore, we're doing the copy manually.


#import "Workflow+DeepCopying.h"


@implementation Workflow (DeepCopying)

- (Workflow*) deepCopy
{
     //Create a new object.
    Workflow *target = (Workflow*)[NSEntityDescription insertNewObjectForEntityForName:@"Workflow" inManagedObjectContext:self.managedObjectContext];
    
    //Copy the workflow's attributes.
    //NSString *entityName = [[self entity] name];
    NSArray *attKeys = [[[self entity] attributesByName] allKeys];
    NSDictionary *attributes = [self dictionaryWithValuesForKeys:attKeys];
    [target setValuesForKeysWithDictionary:attributes];
    
    //NOTE: don't copy the collections to the new object, as they no longer apply.
    
    //Copy the capturers.
    for (Capturer *c in self.capturers) {
        //create and add the capturer to the target object.
        Capturer *newCap = [self deepCopyCapturer:c];
        newCap.workflow = target;
        [target addCapturersObject:newCap];
    }
    
    //return the resulting (new) workflow
    return target;
}

- (Capturer*) deepCopyCapturer:(Capturer*)c                             
{
    //set the capturer's attributes
    Capturer *newCap = (Capturer*)[NSEntityDescription insertNewObjectForEntityForName:@"Capturer" inManagedObjectContext:self.managedObjectContext];
    NSArray *attKeys = [[[c entity] attributesByName] allKeys];
    NSDictionary *attributes = [c dictionaryWithValuesForKeys:attKeys];
    [newCap setValuesForKeysWithDictionary:attributes];
    
    //the new capturer should point to the same sensor as the old one.
    newCap.sensor = c.sensor;
    
    //NOTE: This does NOT set the workflow reference; that needs to be set in the main deepCopy method.
    
    //copy the capturers instance parameters.
    for (SensorParam *param in c.instanceParams) {
        SensorParam *newParam = [self deepCopySensorParam:param];
        newParam.capturer = newCap;
        [newCap addInstanceParamsObject:newParam];
    }
    
    //return the new capturer
    return newCap;
}

- (SensorParam*) deepCopySensorParam:(SensorParam*)s
{
    //set the parameter's attributes
    SensorParam *newParam = (SensorParam*)[NSEntityDescription insertNewObjectForEntityForName:@"SensorParam" inManagedObjectContext:self.managedObjectContext];
    NSArray *attKeys = [[[s entity] attributesByName] allKeys];
    NSDictionary *attributes = [s dictionaryWithValuesForKeys:attKeys];
    [newParam setValuesForKeysWithDictionary:attributes];

    //the new parameter should point to the same sensor as the old one.
    newParam.sensor = s.sensor;
    
    //NOTE: This does NOT set the capturer reference; that needs to be set in the capturer's copy method.

    
    //return the new parameter
    return newParam;
}

@end
