//
//  TPLocationManager.h
//  TroffyPilot
//
//  Created by student on 6/3/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class TPLocationManager;

typedef enum {
    TPLocationManagerStopedAll = 0,
    TPLocationManagerStartedSecondary,
    TPLocationManagerStartedPrimary,
    TPLocationManagerStartedAll
    
} TPLocationManagerState;

typedef enum {
    TPLocationManagerReverseNone = 0,
    TPLocationManagerReverseSecondary,
    TPLocationManagerReversePrimary,
    TPLocationManagerReverseAll
} TPLocationManagerReverse;

typedef enum {
    TPLocationManagerGPSSignalStrengthInvalid = 0,
    TPLocationManagerGPSSignalStrengthWeak,
    TPLocationManagerGPSSignalStrengthStrong
} TPLocationManagerGPSSignalStrength;

@protocol TPLocationManagerDelegate <NSObject>

@optional

- (void)locationManager:(TPLocationManager *)manager signalStrengthChanged:(TPLocationManagerGPSSignalStrength)signalStrength;
- (void)locationManagerSignalConsistentlyWeak:(TPLocationManager *)anager;
- (void)locationManager:(TPLocationManager *)manager didUpdatePrimaryDistance:(CLLocationDistance)totalDistance;
- (void)locationManager:(TPLocationManager *)manager didUpdateSecondaryDistance:(CLLocationDistance)deltaDistance;
- (void)locationManager:(TPLocationManager *)manager didUpdateCurrentSpeed:(double)currentSpeed;
- (void)locationManager:(TPLocationManager *)manager error:(NSError *)error;


@end

@interface TPLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic) TPLocationManagerState state;
@property (nonatomic) TPLocationManagerReverse reverse;

@property (nonatomic, weak) id <TPLocationManagerDelegate> delegate;

+ (TPLocationManager *)sharedLocationManager;

- (BOOL)prepareToLocatioUpdates;
- (BOOL)startLocationUpdates;
- (void)stopLocationUpdates;

- (void)resetPrimaryDistance;
- (void)resetSecondaryDistance;
- (void)resetSpeed;

@end
