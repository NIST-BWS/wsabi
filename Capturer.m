//
//  Capturer.m
//  Wsabi
//
//  Created by Matt Aronoff on 4/6/11.
//  Copyright (c) 2011 NIST. All rights reserved.
//

#import "Capturer.h"
#import "Sensor.h"
#import "SensorParam.h"
#import "Workflow.h"


@implementation Capturer
@dynamic positionInWorkflow;
@dynamic captureType;
@dynamic workflow;
@dynamic sensor;
@dynamic instanceParams;



- (void)addInstanceParamsObject:(SensorParam *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"instanceParams" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"instanceParams"] addObject:value];
    [self didChangeValueForKey:@"instanceParams" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeInstanceParamsObject:(SensorParam *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"instanceParams" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"instanceParams"] removeObject:value];
    [self didChangeValueForKey:@"instanceParams" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addInstanceParams:(NSSet *)value {    
    [self willChangeValueForKey:@"instanceParams" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"instanceParams"] unionSet:value];
    [self didChangeValueForKey:@"instanceParams" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeInstanceParams:(NSSet *)value {
    [self willChangeValueForKey:@"instanceParams" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"instanceParams"] minusSet:value];
    [self didChangeValueForKey:@"instanceParams" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
