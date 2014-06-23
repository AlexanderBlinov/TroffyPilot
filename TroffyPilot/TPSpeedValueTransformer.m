//
//  TPSpeedTransformer.m
//  TroffyPilot
//
//  Created by student on 6/5/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import "TPSpeedValueTransformer.h"

@implementation TPSpeedValueTransformer

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
    double speedInput;
    double speedOutput;
    if ([value respondsToSelector:@selector(doubleValue)]) {
        speedInput = [value doubleValue];
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Value (%@) does not respond to - doubleValue", [value class]];
    }
    speedOutput = speedInput * 3.6;
    return [NSNumber numberWithDouble:speedOutput];
}

@end
