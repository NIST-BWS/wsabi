//
//  Sensor.m
//  Wsabi
//
//  Created by Matt Aronoff on 4/6/11.
//  Copyright (c) 2011 NIST. All rights reserved.
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
@dynamic params;
@dynamic modalities;
@dynamic usedInCapturers;

- (void)addParamsObject:(SensorParam *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"params" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"params"] addObject:value];
    [self didChangeValueForKey:@"params" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeParamsObject:(SensorParam *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"params" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"params"] removeObject:value];
    [self didChangeValueForKey:@"params" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addParams:(NSSet *)value {    
    [self willChangeValueForKey:@"params" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"params"] unionSet:value];
    [self didChangeValueForKey:@"params" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeParams:(NSSet *)value {
    [self willChangeValueForKey:@"params" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"params"] minusSet:value];
    [self didChangeValueForKey:@"params" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addModalitiesObject:(SensorModality *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"modalities" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"modalities"] addObject:value];
    [self didChangeValueForKey:@"modalities" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeModalitiesObject:(SensorModality *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"modalities" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"modalities"] removeObject:value];
    [self didChangeValueForKey:@"modalities" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addModalities:(NSSet *)value {    
    [self willChangeValueForKey:@"modalities" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"modalities"] unionSet:value];
    [self didChangeValueForKey:@"modalities" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeModalities:(NSSet *)value {
    [self willChangeValueForKey:@"modalities" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"modalities"] minusSet:value];
    [self didChangeValueForKey:@"modalities" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addUsedInCapturersObject:(Capturer *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"usedInCapturers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"usedInCapturers"] addObject:value];
    [self didChangeValueForKey:@"usedInCapturers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeUsedInCapturersObject:(Capturer *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"usedInCapturers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"usedInCapturers"] removeObject:value];
    [self didChangeValueForKey:@"usedInCapturers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addUsedInCapturers:(NSSet *)value {    
    [self willChangeValueForKey:@"usedInCapturers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"usedInCapturers"] unionSet:value];
    [self didChangeValueForKey:@"usedInCapturers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeUsedInCapturers:(NSSet *)value {
    [self willChangeValueForKey:@"usedInCapturers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"usedInCapturers"] minusSet:value];
    [self didChangeValueForKey:@"usedInCapturers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
