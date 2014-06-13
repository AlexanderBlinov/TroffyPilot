//
//  TPLocationTracker.m
//  TroffyPilot
//
//  Created by student on 6/12/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import "TPLocationTracker.h"

extern const double kDistanceFilter;

static const double kHeadingFilter = 15.0;

@interface TPLocationTracker ()

@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) double distance;
@property (nonatomic) double direction;
@property (nonatomic) double relativeDirection;

@end

@implementation TPLocationTracker

- (id)init
{
    self = [super self];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kDistanceFilter;
        self.locationManager.headingFilter = kHeadingFilter;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locations = [NSMutableArray array];
    }
    return self;
}

- (void)setTrackingLocation:(CLLocation *)trackingLocation
{
    if (self.trackingLocation) {
        [self.locationManager stopUpdatingLocation];
        [self.locationManager stopUpdatingHeading];
    }
    _trackingLocation = trackingLocation;
    self.relativeDirection = 0.0;
    if (trackingLocation == nil) return;
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
    }
    if ([CLLocationManager headingAvailable]) {
        [self.locationManager startUpdatingHeading];
    }
}

 - (void)addLocation
{
    if ([CLLocationManager locationServicesEnabled]) {
        CLLocation *location = [self.locationManager location];
        [self.locations addObject:location];
        self.trackingLocation = location;
    }
}

#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    self.distance = [newLocation distanceFromLocation:self.trackingLocation];
    double dir = atan(abs((newLocation.coordinate.longitude - self.trackingLocation.coordinate.longitude) / (newLocation.coordinate.latitude - self.trackingLocation.coordinate.latitude))) * 180.0 / M_PI;
    if (newLocation.coordinate.latitude >= self.trackingLocation.coordinate.latitude) {
        if (newLocation.coordinate.longitude >= self.trackingLocation.coordinate.longitude) {
            dir += 180.0;
        } else {
            dir = 180.0 - dir;
        }
    } else {
        if (newLocation.coordinate.longitude >= self.trackingLocation.coordinate.longitude) {
            dir = 360.0 - dir;
        }
    }
    self.relativeDirection = dir;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    self.direction = self.relativeDirection - newHeading.trueHeading;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(locationTracker:didFailWithError:)]) {
        [self.delegate locationTracker:self didFailWithError:error];
    }
}

@end
