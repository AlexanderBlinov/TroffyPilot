//
//  TPDistanceTracker.h
//  TroffyPilot
//
//  Created by student on 6/11/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TPDistanceTrackerDelegate.h"

@interface TPDistanceTracker : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id <TPDistanceTrackerDelegate> delegate;
@property (nonatomic) BOOL isReverse;
@property (nonatomic) BOOL isStarted;

- (void)startTracking;
- (void)stopTracking;
- (void)reset;

@end
