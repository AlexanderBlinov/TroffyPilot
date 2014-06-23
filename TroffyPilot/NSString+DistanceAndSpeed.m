//
//  NSString+DistanceAndSpeed.m
//  TroffyPilot
//
//  Created by student on 6/11/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import "NSString+DistanceAndSpeed.h"
#import "TPDistanceTransformer.h"
#import "TPSpeedTransformer.h"

static NSString *kSpeedSuffix = @" km/h";
static NSString *kDistanceSuffix = @" km";

@implementation NSString (DistanceAndSpeed)

+ (NSString *)stringWithDistance:(double)distance
{
    TPDistanceTransformer *transformer = [[TPDistanceTransformer alloc] init];
    NSNumber *transformedDistance = [transformer transformedValue:[NSNumber numberWithDouble:distance]];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMinimumFractionDigits:3];
    [formatter setMaximumFractionDigits:3];
    NSString *result = [formatter stringFromNumber:transformedDistance];
    return [result stringByAppendingString:kDistanceSuffix];
}

+ (NSString *)stringWithSpeed:(double)speed
{
    TPSpeedTransformer *transformer = [[TPSpeedTransformer alloc] init];
    NSNumber *transformedSpeed = [transformer transformedValue:[NSNumber numberWithDouble:speed]];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setRoundingMode:NSNumberFormatterRoundCeiling];
    NSString *result = [formatter stringFromNumber:transformedSpeed];
    return [result stringByAppendingString:kSpeedSuffix];
}

@end
