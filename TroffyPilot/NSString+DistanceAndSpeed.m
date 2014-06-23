//
//  NSString+DistanceAndSpeed.m
//  TroffyPilot
//
//  Created by student on 6/11/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import "NSString+DistanceAndSpeed.h"
#import "TPDistanceValueTransformer.h"
#import "TPSpeedValueTransformer.h"

static NSString * const kSpeedSuffix = @"km/h";
static NSString * const kDistanceSuffix = @"km";

@implementation NSString (DistanceAndSpeed)

+ (NSString *)stringWithDistance:(double)distance
{
    TPDistanceValueTransformer *transformer = [[TPDistanceValueTransformer alloc] init];
    NSNumber *transformedDistance = [transformer transformedValue:[NSNumber numberWithDouble:distance]];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMinimumFractionDigits:3];
    [formatter setMaximumFractionDigits:3];
    NSString *result = [formatter stringFromNumber:transformedDistance];
    return [result stringByAppendingString:NSLocalizedString(kDistanceSuffix, nil)];
}

+ (NSString *)stringWithSpeed:(double)speed
{
    TPSpeedValueTransformer *transformer = [[TPSpeedValueTransformer alloc] init];
    NSNumber *transformedSpeed = [transformer transformedValue:[NSNumber numberWithDouble:speed]];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setRoundingMode:NSNumberFormatterRoundCeiling];
    NSString *result = [formatter stringFromNumber:transformedSpeed];
    return [result stringByAppendingString:NSLocalizedString(kSpeedSuffix, nil)];
}

@end
