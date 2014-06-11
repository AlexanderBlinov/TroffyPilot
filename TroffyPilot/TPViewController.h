//
//  TPViewController.h
//  TroffyPilot
//
//  Created by student on 6/3/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPLocationManager.h"

@interface TPViewController : UIViewController <TPLocationManagerDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *speedLabel;
@property (nonatomic, weak) IBOutlet UILabel *primaryDistanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *secondaryDistanceLabel;

@property (nonatomic, weak) IBOutlet UIButton *primaryStateButton;
@property (nonatomic, weak) IBOutlet UIButton *secondaryStateButton;
@property (nonatomic, weak) IBOutlet UIButton *primaryReverseButton;
@property (nonatomic, weak) IBOutlet UIButton *secondaryReverseButton;

- (IBAction)changeStateAll:(id)sender;
- (IBAction)changeStateSecondary:(id)sender;
- (IBAction)reverseAll:(id)sender;
- (IBAction)reverseSecondary:(id)sender;
- (IBAction)resetAll:(id)sender;
- (IBAction)resetSecondary:(id)sender;

@end
