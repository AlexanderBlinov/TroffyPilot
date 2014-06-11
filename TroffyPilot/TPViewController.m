//
//  TPViewController.m
//  TroffyPilot
//
//  Created by student on 6/3/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import "TPViewController.h"
#import "TPLocationManager.h"
#import "TPDistanceTransformer.h"
#import "TPSpeedTransformer.h"

static const CLLocationDistance startDistanceValue = 0.0;
static const double startSpeedValue = 0.0;

static NSString * const kDistanceSuffix = @" km";
static NSString * const kSpeedSuffix = @" km/h";

@interface TPViewController ()

@property (strong, nonatomic) CLLocationManager *manager;

@end

@implementation TPViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        TPLocationManager *locationManager = [TPLocationManager sharedLocationManager];
        locationManager.delegate = self;
        locationManager.state = TPLocationManagerStopedAll;
        locationManager.reverse = TPLocationManagerReverseNone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.primaryDistanceLabel.text = [self stringFromDistance:startDistanceValue];
    self.secondaryDistanceLabel.text = [self stringFromDistance:startDistanceValue];
    self.speedLabel.text = [self stringFromSpeed:startSpeedValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Target-Action

- (void)changeStateAll:(id)sender
{
    TPLocationManager *manager = [TPLocationManager sharedLocationManager];
    switch (manager.state) {
        case TPLocationManagerStopedAll:
            manager.state = TPLocationManagerStartedAll;
            [manager startLocationUpdates];
            [self.primaryStateButton setImage:[UIImage imageNamed:@"Stop.png"] forState:UIControlStateNormal];
            [self.secondaryStateButton setImage:[UIImage imageNamed:@"Stop.png"] forState:UIControlStateNormal];
            break;
        case TPLocationManagerStartedAll:
            manager.state = TPLocationManagerStopedAll;
            [self.primaryStateButton setImage:[UIImage imageNamed:@"Start.png"] forState:UIControlStateNormal];
            [self.secondaryStateButton setImage:[UIImage imageNamed:@"Start.png"] forState:UIControlStateNormal];
            [manager stopLocationUpdates];
            break;
        case TPLocationManagerStartedPrimary:
            manager.state = TPLocationManagerStopedAll;
            [self.primaryStateButton setImage:[UIImage imageNamed:@"Start.png"] forState:UIControlStateNormal];
            [manager stopLocationUpdates];
            break;
        case TPLocationManagerStartedSecondary:
            manager.state = TPLocationManagerStartedAll;
            [self.secondaryStateButton setImage:[UIImage imageNamed:@"Stop.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)changeStateSecondary:(id)sender
{
    TPLocationManager *manager = [TPLocationManager sharedLocationManager];
    switch (manager.state) {
        case TPLocationManagerStartedAll:
            manager.state = TPLocationManagerStartedPrimary;
            [self.secondaryStateButton setImage:[UIImage imageNamed:@"Start.png"] forState:UIControlStateNormal];
            break;
        case TPLocationManagerStopedAll:
            manager.state = TPLocationManagerStartedSecondary;
            [self.secondaryStateButton setImage:[UIImage imageNamed:@"Stop.png"] forState:UIControlStateNormal];
            [manager startLocationUpdates];
            break;
        case TPLocationManagerStartedSecondary:
            manager.state = TPLocationManagerStopedAll;
            [self.secondaryStateButton setImage:[UIImage imageNamed:@"Start.png"] forState:UIControlStateNormal];
            [manager stopLocationUpdates];
            break;
        case TPLocationManagerStartedPrimary:
            manager.state = TPLocationManagerStartedAll;
            [self.secondaryStateButton setImage:[UIImage imageNamed:@"Stop.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)reverseAll:(id)sender
{
    TPLocationManager *manager = [TPLocationManager sharedLocationManager];
    switch (manager.reverse) {
        case TPLocationManagerReverseNone:
            manager.reverse = TPLocationManagerReverseAll;
            [self.primaryReverseButton setImage:[UIImage imageNamed:@"ReverseOn.png"] forState:UIControlStateNormal];
            [self.secondaryReverseButton setImage:[UIImage imageNamed:@"ReverseOn.png"] forState:UIControlStateNormal];
            break;
        case TPLocationManagerReverseAll:
            manager.reverse = TPLocationManagerReverseNone;
            [self.primaryReverseButton setImage:[UIImage imageNamed:@"ReverseOff.png"] forState:UIControlStateNormal];
            [self.secondaryReverseButton setImage:[UIImage imageNamed:@"ReverseOff.png"] forState:UIControlStateNormal];
            break;
        case TPLocationManagerReversePrimary:
            manager.reverse = TPLocationManagerReverseNone;
            [self.primaryReverseButton setImage:[UIImage imageNamed:@"ReverseOff.png"] forState:UIControlStateNormal];
            break;
        case TPLocationManagerReverseSecondary:
            manager.reverse = TPLocationManagerReverseAll;
            [self.primaryReverseButton setImage:[UIImage imageNamed:@"ReverseOn.png"] forState:UIControlStateNormal];
        default:
            break;
    }
}

- (void)reverseSecondary:(id)sender
{
    TPLocationManager *manager = [TPLocationManager sharedLocationManager];
    switch (manager.reverse) {
        case TPLocationManagerReverseNone:
            manager.reverse = TPLocationManagerReverseSecondary;
            [self.secondaryReverseButton setImage:[UIImage imageNamed:@"ReverseOn.png"] forState:UIControlStateNormal];
            break;
        case TPLocationManagerReverseAll:
            manager.reverse = TPLocationManagerReversePrimary;
            [self.secondaryReverseButton setImage:[UIImage imageNamed:@"ReverseOff.png"] forState:UIControlStateNormal];
            break;
        case TPLocationManagerReversePrimary:
            manager.reverse = TPLocationManagerReverseAll;
            [self.secondaryReverseButton setImage:[UIImage imageNamed:@"ReverseOn.png"] forState:UIControlStateNormal];
            break;
        case TPLocationManagerReverseSecondary:
            manager.reverse = TPLocationManagerReverseNone;
            [self.secondaryReverseButton setImage:[UIImage imageNamed:@"ReverseOff.png"] forState:UIControlStateNormal];
        default:
            break;
    }
}

- (void)resetAll:(id)sender
{
    TPLocationManager *manager = [TPLocationManager sharedLocationManager];
    [manager resetPrimaryDistance];
    [manager resetSecondaryDistance];
}

- (void)resetSecondary:(id)sender
{
    TPLocationManager *manager = [TPLocationManager sharedLocationManager];
    [manager resetSecondaryDistance];
}

- (NSString *)stringFromDistance:(CLLocationDistance)distance
{
    TPDistanceTransformer *transformer = [[TPDistanceTransformer alloc] init];
    NSNumber *transformedDistance = [transformer transformedValue:[NSNumber numberWithDouble:distance]];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMinimumFractionDigits:3];
    [formatter setMaximumFractionDigits:3];
    NSString *result = [[formatter stringFromNumber:transformedDistance] stringByAppendingString:kDistanceSuffix];
    return result;
}

- (NSString *)stringFromSpeed:(double)speed
{
    TPSpeedTransformer *transformer = [[TPSpeedTransformer alloc] init];
    NSNumber *transformedSpeed = [transformer transformedValue:[NSNumber numberWithDouble:speed]];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setRoundingMode:NSNumberFormatterRoundCeiling];
    NSString *result = [[formatter stringFromNumber:transformedSpeed] stringByAppendingString:kSpeedSuffix];
    return result;
}

#pragma mark - Location manager delegate

- (void)locationManager:(TPLocationManager *)manager didUpdatePrimaryDistance:(CLLocationDistance)primaryDistance
{
    NSString *distanceResult = [self stringFromDistance:primaryDistance];
    if (distanceResult != nil) {
        self.primaryDistanceLabel.text = distanceResult;
    }
}

- (void)locationManager:(TPLocationManager *)manager didUpdateCurrentSpeed:(double)currentSpeed
{
    NSString *speedResult = [self stringFromSpeed:currentSpeed];
    if (speedResult != nil) {
        self.speedLabel.text = speedResult;
    }
}

- (void)locationManager:(TPLocationManager *)manager didUpdateSecondaryDistance:(CLLocationDistance)secondaryDistance
{
    NSString *distanceResult = [self stringFromDistance:secondaryDistance];
    if (distanceResult != nil) {
        self.secondaryDistanceLabel.text = distanceResult;
    }
}

- (void)locationManager:(TPLocationManager *)manager error:(NSError *)error
{
    
}


@end
