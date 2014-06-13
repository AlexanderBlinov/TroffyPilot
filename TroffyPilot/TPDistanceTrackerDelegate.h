//
//  TPDistanceTrackerDelegate.h
//  TroffyPilot
//
//  Created by student on 6/11/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPDistanceTracker;

@protocol TPDistanceTrackerDelegate <NSObject>

@optional
- (void)distanceTracker:(TPDistanceTracker *)tracker didUpdateDistance:(double)distance;
- (void)distanceTracker:(TPDistanceTracker *)tracker didFailWithError:(NSError *)error;

@end
