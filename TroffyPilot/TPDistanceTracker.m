//
//  TPDistanceTracker.m
//  TroffyPilot
//
//  Created by student on 6/11/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import "TPDistanceTracker.h"

extern const double kDistanceFilter;

@interface TPDistanceTracker ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastUpdatedLocation;
@property (nonatomic) double distance;

@end

@implementation TPDistanceTracker

- (id)init
{
    self = [super self];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kDistanceFilter;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return self;
}

- (void)setDistance:(double)distance
{
    _distance = distance;
    if ([self.delegate respondsToSelector:@selector(distanceTracker:didUpdateDistance:)]) {
        [self.delegate distanceTracker:self didUpdateDistance:self.distance];
    }
}

- (void)startTracking
{
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
        self.isStarted = YES;
    }
}

- (void)stopTracking
{
    [self.locationManager stopUpdatingLocation];
    self.isStarted = NO;
    
}

- (void)reset
{
    self.distance = 0.0;
}

#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    if (self.lastUpdatedLocation != nil) {
        double distance = [newLocation distanceFromLocation:self.lastUpdatedLocation];
        if (distance >= kDistanceFilter) {
            self.distance += distance * (self.isReversed ? -1 : 1);
        }
    }
    self.lastUpdatedLocation = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(distanceTracker:didFailWithError:)]) {
        [self.delegate distanceTracker:self didFailWithError:error];
    }
}

@end
