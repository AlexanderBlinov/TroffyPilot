//
//  TPLocationTracker.m
//  TroffyPilot
//
//  Created by student on 6/12/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import "TPLocationTracker.h"
#import "TPLocationsStorage.h"

extern const double kDistanceFilter;
static const double kHeadingFilter = 6.0;

@interface TPLocationTracker ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) double distance;
@property (nonatomic) double direction;
@property (nonatomic) double relativeDirection;
@property (nonatomic, getter = isFaceDown) BOOL faceDown;

- (void)deviceDidCahngeOrientation:(NSNotification *)notification;
- (void)resetHeadingUpdates;

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

- (void)setHeadingOrientation:(CLDeviceOrientation)deviceOrientation
{
    self.locationManager.headingOrientation = deviceOrientation;
    [self resetHeadingUpdates];
}

- (void)setTrackingLocation:(CLLocation *)trackingLocation
{
    if (self.trackingLocation) {
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        [self.locationManager stopUpdatingLocation];
        [self.locationManager stopUpdatingHeading];
    }
    _trackingLocation = trackingLocation;
    self.relativeDirection = 0;
    if (trackingLocation == nil) {
        self.direction = 0;
        self.distance = 0;
        return;
    }
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
        if ([CLLocationManager headingAvailable]) {
            [self.locationManager startUpdatingHeading];
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidCahngeOrientation:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
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

- (void)setRelativeDirection:(double)relativeDirection
{
    _relativeDirection = relativeDirection;
    if (![CLLocationManager headingAvailable]) {
        self.direction = relativeDirection;
    }
}

- (void)setFaceDown:(BOOL)faceDown
{
    _faceDown = faceDown;
    [self resetHeadingUpdates];
}

- (CLLocation *)generateLocation
{
    if ([CLLocationManager locationServicesEnabled]) {
        CLLocation *location = [self.locationManager location];
        return location;
    }
    return nil;
}

- (void)deviceDidCahngeOrientation:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == 6 && !self.isFaceDown) {
        [self setFaceDown:YES];
    }
    if (orientation == 5 && self.isFaceDown) {
        [self setFaceDown:NO];
        
    }
}

- (void)resetHeadingUpdates
{
    [self.locationManager stopUpdatingHeading];
    if ([CLLocationManager headingAvailable]) {
        [self.locationManager startUpdatingHeading];
    }
}

#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    double distance = [newLocation distanceFromLocation:self.trackingLocation];
    if (distance >= kDistanceFilter) {
        self.distance = distance;
    }
    double dir;
    if (newLocation.coordinate.longitude == self.trackingLocation.coordinate.longitude && newLocation.coordinate.latitude == self.trackingLocation.coordinate.latitude) {
        dir = 0;
    } else {
        dir = atan(abs((newLocation.coordinate.longitude - self.trackingLocation.coordinate.longitude) / (newLocation.coordinate.latitude - self.trackingLocation.coordinate.latitude)));
        if (newLocation.coordinate.latitude >= self.trackingLocation.coordinate.latitude) {
            if (newLocation.coordinate.longitude > self.trackingLocation.coordinate.longitude) {
                dir += M_PI;
            } else {
                dir = M_PI - dir;
            }
        } else {
            if (newLocation.coordinate.longitude > self.trackingLocation.coordinate.longitude) {
                dir = 2 * M_PI - dir;
            }
        }
    }
    self.relativeDirection = dir;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (newHeading.headingAccuracy < 0) return;
    double theHeading = ((newHeading.trueHeading > 0) ? newHeading.trueHeading : newHeading.magneticHeading);
    theHeading *=  M_PI / 180.0;
    if (self.isFaceDown) {
        if (theHeading < M_PI) {
            theHeading = M_PI - theHeading;
        } else {
            theHeading = 3 * M_PI - theHeading;
        }
        theHeading = 2 * M_PI - theHeading;
    }
    if (self.relativeDirection < theHeading) {
        theHeading -= 2 * M_PI;
        
    }
    theHeading *= self.isFaceDown ? -1 : 1;
    self.direction = self.relativeDirection - theHeading;
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(locationTracker:didFailWithError:)]) {
        [self.delegate locationTracker:self didFailWithError:error];
    }
}

@end
