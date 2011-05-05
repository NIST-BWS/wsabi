//
//  BiometricCollection.m
//  Wsabi
//
//  Created by Matt Aronoff on 4/6/11.
//  Copyright (c) 2011 NIST. All rights reserved.
//

#import "BiometricCollection.h"
#import "BiometricData.h"
#import "Workflow.h"


@implementation BiometricCollection
@dynamic presenterId;
@dynamic isActive;
@dynamic isComplete;
@dynamic totalLength;
@dynamic timestampStarted;
@dynamic currentPosition;
@dynamic timestampCompleted;
@dynamic notes;
@dynamic workflow;
@dynamic items;


- (void)addItemsObject:(BiometricData *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"items" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"items"] addObject:value];
    [self didChangeValueForKey:@"items" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeItemsObject:(BiometricData *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"items" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"items"] removeObject:value];
    [self didChangeValueForKey:@"items" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addItems:(NSSet *)value {    
    [self willChangeValueForKey:@"items" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"items"] unionSet:value];
    [self didChangeValueForKey:@"items" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeItems:(NSSet *)value {
    [self willChangeValueForKey:@"items" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"items"] minusSet:value];
    [self didChangeValueForKey:@"items" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
