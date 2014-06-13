//
//  TPLocationTrackerDelegate.h
//  TroffyPilot
//
//  Created by student on 6/12/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPLocationTracker;

@protocol TPLocationTrackerDelegate <NSObject>

@optional
- (void)locationTracker:(TPLocationTracker *)tracker didUpdateDistance:(double)distance;
- (void)locationTracker:(TPLocationTracker *)tracker didUpdateDirection:(double)direction;
- (void)locationTracker:(TPLocationTracker *)tracker didFailWithError:(NSError *)error;

@end
