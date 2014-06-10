//
//  TPDistanceTransformer.m
//  TroffyPilot
//
//  Created by student on 6/5/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import "TPDistanceTransformer.h"

@implementation TPDistanceTransformer

+ (Class)transformedValueClass
{
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    if (value == nil) return nil;
    double distanceInput;
    double distanceOutput;
    if ([value respondsToSelector:@selector(doubleValue)]) {
        distanceInput = [value doubleValue];
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Value (%@) does not respond to - doubleValue", [value class]];
    }
    distanceOutput = distanceInput / 1000.0;
    return [NSNumber numberWithDouble:distanceOutput];
}

@end
