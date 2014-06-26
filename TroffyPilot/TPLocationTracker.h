//
//  TPLocationTracker.h
//  TroffyPilot
//
//  Created by student on 6/12/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TPLocationTrackerDelegate.h"

@class TPLocationsStorage;

@interface TPLocationTracker : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id <TPLocationTrackerDelegate> delegate;
@property (nonatomic, strong) CLLocation *trackingLocation;

- (CLLocation *)generateLocation;

@end
