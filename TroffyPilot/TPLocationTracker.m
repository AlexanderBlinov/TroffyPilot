//
//  TPLocationTracker.m
//  TroffyPilot
//
//  Created by student on 6/12/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import "TPLocationTracker.h"
#import "TPSharedLocations.h"

extern const double kDistanceFilter;

static const double kHeadingFilter = 10.0;

@interface TPLocationTracker ()

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
        self.locationManager.headingOrientation = CLDeviceOrientationLandscapeLeft;
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
    self.relativeDirection = 0;
    if (trackingLocation == nil) return;
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
        if ([CLLocationManager headingAvailable]) {
            [self.locationManager startUpdatingHeading];
        }
    }
}

- (void)setDistance:(double)distance
{
    _distance = distance;
    if ([self.delegate respondsToSelector:@selector(locationTracker:didUpdateDistance:)]) {
        [self.delegate locationTracker:self didUpdateDistance:self.distance];
    }
}

- (void)setDirection:(double)direction
{
    _direction = direction;
    if ([self.delegate respondsToSelector:@selector(locationTracker:didUpdateDirection:)]) {
        [self.delegate locationTracker:self didUpdateDirection:self.direction];
    }
}

 - (void)addLocation
{
    if ([CLLocationManager locationServicesEnabled]) {
        CLLocation *location = [self.locationManager location];
        [[TPSharedLocations sharedLocations] addLocation:location];
        self.trackingLocation = location;
    }
}

#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    self.distance = [newLocation distanceFromLocation:self.trackingLocation];
    double dir = atan(abs((newLocation.coordinate.longitude - self.trackingLocation.coordinate.longitude) / (newLocation.coordinate.latitude - self.trackingLocation.coordinate.latitude)));
    if (newLocation.coordinate.latitude >= self.trackingLocation.coordinate.latitude) {
        if (newLocation.coordinate.longitude >= self.trackingLocation.coordinate.longitude) {
            dir += M_PI;
        } else {
            dir = M_PI - dir;
        }
    } else {
        if (newLocation.coordinate.longitude >= self.trackingLocation.coordinate.longitude) {
            dir = 2 * M_PI - dir;
        }
    }
    self.relativeDirection = dir;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (newHeading.headingAccuracy < 0) return;
    double theHeading = ((newHeading.trueHeading > 0) ? newHeading.trueHeading : newHeading.magneticHeading);
    theHeading *=  M_PI / 180.0;
    if (self.relativeDirection >= theHeading) {
        self.direction = self.relativeDirection - theHeading;
    } else {
        self.direction = self.relativeDirection - theHeading + 2 * M_PI;
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(locationTracker:didFailWithError:)]) {
        [self.delegate locationTracker:self didFailWithError:error];
    }
}

@end
