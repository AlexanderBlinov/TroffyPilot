//
//  TPSpeedTracker.h
//  TroffyPilot
//
//  Created by student on 6/11/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TPSpeedTrackerDelegate.h"

@interface TPSpeedTracker : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id <TPSpeedTrackerDelegate> delegate;

- (void)startTracking;
- (void)stopTracking;

@end
