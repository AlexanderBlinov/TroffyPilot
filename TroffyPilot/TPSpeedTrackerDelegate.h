//
//  TPSpeedTrackerDelegate.h
//  TroffyPilot
//
//  Created by student on 6/11/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPSpeedTracker;

@protocol TPSpeedTrackerDelegate <NSObject>

@optional
- (void)speedTracker:(TPSpeedTracker *)tracker didUpdateSpeed:(double)speed;
- (void)speedTracker:(TPSpeedTracker *)tracker didFailWithError:(NSError *)error;

@end