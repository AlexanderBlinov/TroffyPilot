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
                /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"asfd" message:[location description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];*/
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
    self.locationPingTimer = [NSTimer timerWithTimeInterval:kMinLocationUpdateInterval target:self selector:@selector(requestNewLocation) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.locationPingTimer forMode:NSRunLoopCommonModes];
    /*CLLocation *lastUpdatedLocation = [locations objectAtIndex:[locations count] - 1];
    
    double horizontalAcccuracy;
    if (self.allowMaximumAcceptableAccuracy) {
        horizontalAcccuracy = kMaximumAcceptableHorizontalAccuracy;
    } else {
        horizontalAcccuracy = kRequiredHorizontalAccuracy;
    }
    if (lastUpdatedLocation.horizontalAccuracy >= 0 && lastUpdatedLocation.horizontalAccuracy <= horizontalAcccuracy) {
        if (lastUpdatedLocation.speed >= 0) {
            self.currentSpeed = lastUpdatedLocation.speed;
        }
        if (self.previousLocation != nil) {
            if (self.state == TPLocationManagerStartedAll) {
                self.primaryDistance += [lastUpdatedLocation distanceFromLocation:self.previousLocation] * ((self.reverse == TPLocationManagerReverseNone || self.reverse == TPLocationManagerReverseSecondary) ? 1 : -1);
                self.secondaryDistance += [lastUpdatedLocation distanceFromLocation:self.previousLocation] * ((self.reverse == TPLocationManagerReverseNone || self.reverse == TPLocationManagerReversePrimary) ? 1 : -1);
                NSLog(@"%f %f\n%f %f", [self.previousLocation coordinate].latitude, [self.previousLocation coordinate].longitude,[lastUpdatedLocation coordinate].latitude, [lastUpdatedLocation coordinate].longitude);
            }
            if (self.state == TPLocationManagerStartedPrimary) {
                self.primaryDistance += [lastUpdatedLocation distanceFromLocation:self.previousLocation] * ((self.reverse == TPLocationManagerReverseNone || self.reverse == TPLocationManagerReverseSecondary) ? 1 : -1);
            }
            if (self.state == TPLocationManagerStartedSecondary) {
                self.secondaryDistance += [lastUpdatedLocation distanceFromLocation:self.previousLocation] * ((self.reverse == TPLocationManagerReverseNone || self.reverse == TPLocationManagerReversePrimary) ? 1 : -1);
            }
        }
        self.previousLocation = lastUpdatedLocation;
    }*/
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    
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
