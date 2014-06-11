//
//  TPLocationManager.m
//  TroffyPilot
//
//  Created by student on 6/3/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import "TPLocationManager.h"

static const NSUInteger kDistanceFilter = 1;
static const NSUInteger kHeadingFilter = 5;
static const CGFloat kRequiredHorizontalAccuracy = 20.0;
static const CGFloat kMaximumAcceptableHorizontalAccuracy = 70.0;
static const NSUInteger kMinLocationUpdateInterval = 10;
static const NSTimeInterval kValidUpdateTimeInterval = 3;
static const NSUInteger kGPSRefinmentIntereval = 15;


@interface TPLocationManager ()

@property (nonatomic, strong) NSMutableArray *markedLocations;
@property (nonatomic, weak) CLLocation *monitoredLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationDistance primaryDistance;
@property (nonatomic) CLLocationDistance secondaryDistance;
@property (nonatomic) CLHeading *deviceHeading;
@property (nonatomic) double currentSpeed;
@property (nonatomic, strong) NSTimer *locationPingTimer;
@property (nonatomic, strong) CLLocation *previousLocation;
@property (nonatomic) BOOL allowMaximumAcceptableAccuracy;
@property (nonatomic) BOOL checkingSignalStrength;
@property (nonatomic) TPLocationManagerGPSSignalStrength signalStrength;
@property (nonatomic, readonly) CLLocationDistance distanceToMonitoredLocation;
@property (nonatomic, readonly) CLLocationDirection directionToMonitoredLocation;

- (void)checkSignalStrength;
- (void)requestNewLocation;

@end



@implementation TPLocationManager


static TPLocationManager *locationManagerInstance = nil;

+ (TPLocationManager *)sharedLocationManager
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        locationManagerInstance = [[super allocWithZone:NULL] init];
    });
    return locationManagerInstance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [[self class] sharedLocationManager];
}

- (id)init
{
    self = [super init];
    if (self) {
        if ([CLLocationManager locationServicesEnabled]) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.distanceFilter = kDistanceFilter;
            self.locationManager.headingFilter = kHeadingFilter;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            self.state = TPLocationManagerStopedAll;
            self.reverse = TPLocationManagerReverseNone;
            self.allowMaximumAcceptableAccuracy = NO;
            self.markedLocations = [NSMutableArray array];
            self.monitoredLocation = nil;
        }
    }
    return self;
}

- (BOOL)prepareToLocatioUpdates
{
    if ([CLLocationManager locationServicesEnabled]) {
        self.signalStrength = TPLocationManagerGPSSignalStrengthInvalid;
        self.allowMaximumAcceptableAccuracy = NO;
        [self.locationManager startUpdatingLocation];
        [self.locationManager startUpdatingHeading];
        [self checkSignalStrength];
        return YES;
    } else {
        return NO;
    }

}

- (BOOL)startLocationUpdates
{
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
        NSLog(@"%f %f", [[self.locationManager location] coordinate].latitude, [[self.locationManager location ] coordinate].longitude);
        return YES;
    } else {
        return NO;
    }
    
}

- (void)stopLocationUpdates
{
    [self.locationManager stopUpdatingLocation];
    [self resetSpeed];
    [self.locationPingTimer invalidate];
    NSLog(@"%f %f", [[self.locationManager location] coordinate].latitude, [[self.locationManager location] coordinate].longitude);
    self.previousLocation = nil;
    
}

- (void)checkSignalStrength
{
    if (!self.checkingSignalStrength) {
        self.checkingSignalStrength = YES;
        double delayInSeconds = kGPSRefinmentIntereval;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.checkingSignalStrength = NO;
            if (self.signalStrength == TPLocationManagerGPSSignalStrengthWeak) {
                self.allowMaximumAcceptableAccuracy = YES;
                if ([self.delegate respondsToSelector:@selector(locationManagerSignalConsistentlyWeak:)]) {
                    [self.delegate locationManagerSignalConsistentlyWeak:self];
                }
            } else if (self.signalStrength == TPLocationManagerGPSSignalStrengthInvalid) {
                self.allowMaximumAcceptableAccuracy = YES;
                self.signalStrength = TPLocationManagerGPSSignalStrengthWeak;
                if ([self.delegate respondsToSelector:@selector(locationManagerSignalConsistentlyWeak:)]) {
                    [self.delegate locationManagerSignalConsistentlyWeak:self];
                }
            }
        });
    }
}

- (void)requestNewLocation
{
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startUpdatingLocation];
}

- (void)resetPrimaryDistance
{
    self.primaryDistance = 0;
}

- (void)resetSecondaryDistance
{
    self.secondaryDistance = 0;
}

- (void)resetSpeed
{
    self.currentSpeed = 0;
}

- (void)addMarkedLocation
{
    CLLocation *location = [self.locationManager location];
    [self.markedLocations addObject:location];
    self.monitoredLocation = location;
}

#pragma mark - Getters

- (CLLocationDistance)distanceToMonitoredLocation
{
    return [[self.locationManager location] distanceFromLocation:self.monitoredLocation];
}

- (CLLocationDirection)directionToMonitoredLocation
{
    CLLocation *currentLocation = [self.locationManager location];
    CLLocationDirection alpha = atan(abs((currentLocation.coordinate.latitude - self.monitoredLocation.coordinate.latitude) / (currentLocation.coordinate.longitude - self.monitoredLocation.coordinate.longitude)));
    CLLocationDirection result = 0.0;
    if (currentLocation.coordinate.longitude > self.monitoredLocation.coordinate.longitude) {
        result += 180.0;
    }
    result += (currentLocation.coordinate.longitude > self.monitoredLocation.coordinate.longitude) ? 180.0 : 0.0;
    if (currentLocation.coordinate.longitude > self.monitoredLocation.coordinate.longitude) {
        result += alpha * ((currentLocation.coordinate.latitude > self.monitoredLocation.coordinate.latitude) ? 1.0  : -1.0);
    } else {
        result += alpha * ((currentLocation.coordinate.latitude > self.monitoredLocation.coordinate.latitude) ? -1.0  : 1.0);
    }
    return result;
}

#pragma mark - Setters

- (void)setSignalStrength:(TPLocationManagerGPSSignalStrength)signalStrength {
    BOOL needToUpdateDelegate = NO;
    if (_signalStrength != signalStrength) {
        needToUpdateDelegate = YES;
    }
    _signalStrength = signalStrength;
    if (self.signalStrength == TPLocationManagerGPSSignalStrengthStrong) {
        self.allowMaximumAcceptableAccuracy = NO;
    } else if (self.signalStrength == TPLocationManagerGPSSignalStrengthWeak) {
        [self checkSignalStrength];
    }
    if (needToUpdateDelegate) {
        if ([self.delegate respondsToSelector:@selector(locationManager:signalStrengthChanged:)]) {
            [self.delegate locationManager:self signalStrengthChanged:self.signalStrength];
        }
    }
}

- (void)setPrimaryDistance:(CLLocationDistance)primaryDistance
{
    _primaryDistance = primaryDistance;
    if ([self.delegate respondsToSelector:@selector(locationManager:didUpdatePrimaryDistance:)]) {
        [self.delegate locationManager:self didUpdatePrimaryDistance:self.primaryDistance];
    }
}

- (void)setSecondaryDistance:(CLLocationDistance)secondaryDistance
{
    _secondaryDistance = secondaryDistance;
    if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateSecondaryDistance:)]) {
        [self.delegate locationManager:self didUpdateSecondaryDistance:self.secondaryDistance];
    }
}

- (void)setCurrentSpeed:(double)currentSpeed
{
    _currentSpeed = currentSpeed;
    if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateCurrentSpeed:)]) {
        [self.delegate locationManager:self didUpdateCurrentSpeed:self.currentSpeed];
    }
}

- (void)setMonitoredLocation:(CLLocation *)monitoredLocation
{
    _monitoredLocation = monitoredLocation;
    if (monitoredLocation) {
        [self.locationManager startUpdatingHeading];
    } else {
        [self.locationManager stopUpdatingHeading];
    }
}

#pragma mark - Locationmanager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationPingTimer invalidate];
    if ([[locations lastObject] horizontalAccuracy] <= kRequiredHorizontalAccuracy) {
        self.signalStrength = TPLocationManagerGPSSignalStrengthStrong;
    } else {
        self.signalStrength = TPLocationManagerGPSSignalStrengthWeak;
    }
    
    double horizontalAccuracy;
    if (self.allowMaximumAcceptableAccuracy) {
        horizontalAccuracy = kMaximumAcceptableHorizontalAccuracy;
    } else {
        horizontalAccuracy = kRequiredHorizontalAccuracy;
    }

    CLLocation *bestLocation = nil;
    CGFloat bestAccuracy = horizontalAccuracy;
    for (CLLocation *location in locations) {
        if ([NSDate timeIntervalSinceReferenceDate] - [location.timestamp timeIntervalSinceReferenceDate] <= kValidUpdateTimeInterval) {
            NSLog(@"%f", [NSDate timeIntervalSinceReferenceDate]);
            NSLog(@"%f", [location.timestamp timeIntervalSinceReferenceDate]);
            if (location.horizontalAccuracy <= bestAccuracy && location != self.previousLocation) {
                bestAccuracy = location.horizontalAccuracy;
                bestLocation = location;
            }
        }
    }
    if (bestLocation != nil) {
        if (self.previousLocation != nil) {
            if (bestLocation.speed >= 0) {
                self.currentSpeed = bestLocation.speed;
            }
            if (self.previousLocation != nil) {
                if (self.state == TPLocationManagerStartedAll) {
                    self.primaryDistance += [bestLocation distanceFromLocation:self.previousLocation] * ((self.reverse == TPLocationManagerReverseNone || self.reverse == TPLocationManagerReverseSecondary) ? 1 : -1);
                    self.secondaryDistance += [bestLocation distanceFromLocation:self.previousLocation] * ((self.reverse == TPLocationManagerReverseNone || self.reverse == TPLocationManagerReversePrimary) ? 1 : -1);
                    NSLog(@"%f %f\n%f %f", [self.previousLocation coordinate].latitude, [self.previousLocation coordinate].longitude,[bestLocation coordinate].latitude, [bestLocation coordinate].longitude);
                }
                if (self.state == TPLocationManagerStartedPrimary) {
                    self.primaryDistance += [bestLocation distanceFromLocation:self.previousLocation] * ((self.reverse == TPLocationManagerReverseNone || self.reverse == TPLocationManagerReverseSecondary) ? 1 : -1);
                }
                if (self.state == TPLocationManagerStartedSecondary) {
                    self.secondaryDistance += [bestLocation distanceFromLocation:self.previousLocation] * ((self.reverse == TPLocationManagerReverseNone || self.reverse == TPLocationManagerReversePrimary) ? 1 : -1);
                }
            }
        }
        self.previousLocation = bestLocation;
    }
    if (self.monitoredLocation) {
        if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateDistanceToMonitoredLocation:)]) {
            [self.delegate locationManager:self didUpdateDistanceToMonitoredLocation:self.distanceToMonitoredLocation];
        }
    }
    self.locationPingTimer = [NSTimer timerWithTimeInterval:kMinLocationUpdateInterval target:self selector:@selector(requestNewLocation) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.locationPingTimer forMode:NSRunLoopCommonModes];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (self.monitoredLocation) {
        CLLocationDirection direction = self.directionToMonitoredLocation + newHeading.trueHeading;
        if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateDirectionToMonitoredLocation:)]) {
            [self.delegate locationManager:self didUpdateDirectionToMonitoredLocation:direction];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied) {
        if ([self.delegate respondsToSelector:@selector(locationManager:error:)]) {
            [self.delegate locationManager:self error:error];
        }
        [self stopLocationUpdates];
    }
}

@end
