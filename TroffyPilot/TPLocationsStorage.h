//
//  TPSharedLocations.h
//  TroffyPilot
//
//  Created by student on 6/16/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TPLocationsStorage : NSObject

- (CLLocation *)locationAtIndex:(NSUInteger)index;
- (CLLocation *)lastLocation;
- (void)addLocation:(CLLocation *)location;
- (void)removeLocationAtIndex:(NSUInteger)index;
- (void)removeAllLocations;
- (NSUInteger)indexOfLocation:(CLLocation *)location;
- (NSUInteger)locationsCount;
- (void)saveLocations;
- (void)loadLocations;

@end
