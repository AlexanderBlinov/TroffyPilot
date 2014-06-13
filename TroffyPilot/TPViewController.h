//
//  TPViewController.h
//  TroffyPilot
//
//  Created by student on 6/3/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPDistanceTrackerDelegate.h"
#import "TPSpeedTrackerDelegate.h"
#import "TPLocationTrackerDelegate.h"

@interface TPViewController : UIViewController <TPDistanceTrackerDelegate, TPSpeedTrackerDelegate, TPLocationTrackerDelegate>



@end
