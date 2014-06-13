//
//  NSString+DistanceAndSpeed.h
//  TroffyPilot
//
//  Created by student on 6/11/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface NSString (DistanceAndSpeed)

+ (NSString *)stringWithSpeed:(double)speed;
+ (NSString *)stringWithDistance:(CLLocationDistance)distance;

@end
