//
//  TPSpeedTracker.m
//  TroffyPilot
//
//  Created by student on 6/11/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import "TPSpeedTracker.h"

const double kDistanceFilter = 10.0;

@interface TPSpeedTracker ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) double speed;

@end

@implementation TPSpeedTracker

- (id)init
{
    self = [super self];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kDistanceFilter;
    }
    return self;
}

- (void)setSpeed:(double)speed
{
    if (speed < 0.0) {
        _speed = 0.0;
    } else {
        _speed = speed;
    }
    if ([self.delegate respondsToSelector:@selector(speedTracker:didUpdateSpeed:)]) {
        [self.delegate speedTracker:self didUpdateSpeed:self.speed];
    }
}

- (void)startTracking
{
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)stopTracking
{
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    self.speed = newLocation.speed;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(speedTracker:didFailWithError:)]) {
        [self.delegate speedTracker:self didFailWithError:error];
    }
}

@end
