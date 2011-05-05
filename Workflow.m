//
//  Workflow.m
//  Wsabi
//
//  Created by Matt Aronoff on 4/6/11.
//  Copyright (c) 2011 NIST. All rights reserved.
//

#import "Workflow.h"
#import "BiometricCollection.h"
#import "Capturer.h"


@implementation Workflow
@dynamic timestampCreated;
@dynamic timestampModified;
@dynamic name;
@dynamic collections;
@dynamic capturers;

- (void)addCollectionsObject:(BiometricCollection *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"collections" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"collections"] addObject:value];
    [self didChangeValueForKey:@"collections" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeCollectionsObject:(BiometricCollection *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"collections" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"collections"] removeObject:value];
    [self didChangeValueForKey:@"collections" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addCollections:(NSSet *)value {    
    [self willChangeValueForKey:@"collections" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"collections"] unionSet:value];
    [self didChangeValueForKey:@"collections" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeCollections:(NSSet *)value {
    [self willChangeValueForKey:@"collections" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"collections"] minusSet:value];
    [self didChangeValueForKey:@"collections" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addCapturersObject:(Capturer *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"capturers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"capturers"] addObject:value];
    [self didChangeValueForKey:@"capturers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeCapturersObject:(Capturer *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"capturers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"capturers"] removeObject:value];
    [self didChangeValueForKey:@"capturers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addCapturers:(NSSet *)value {    
    [self willChangeValueForKey:@"capturers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"capturers"] unionSet:value];
    [self didChangeValueForKey:@"capturers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeCapturers:(NSSet *)value {
    [self willChangeValueForKey:@"capturers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"capturers"] minusSet:value];
    [self didChangeValueForKey:@"capturers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
