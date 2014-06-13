//
//  TPViewController.m
//  TroffyPilot
//
//  Created by student on 6/3/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import "TPViewController.h"
#import "TPDistanceTracker.h"
#import "TPSpeedTracker.h"
#import "TPDistanceTransformer.h"
#import "TPSpeedTransformer.h"
#import "NSString+DistanceAndSpeed.h"

static NSString * const kReverseOn = @"ReverseOn.png";
static NSString * const kReverseOff = @"ReverseOff.png";
static NSString * const kStart = @"Start.png";
static NSString * const kStop = @"Stop.png";
static NSString * const kTrackerErrorTitle = @"Unable to determine location";
static const double kStartDistanceValue = 0.0;
static const double kStartSpeedValue = 0.0;

@interface TPViewController ()

@property (nonatomic, strong) TPDistanceTracker *primaryTracker;
@property (nonatomic, strong) TPDistanceTracker *secondaryTracker;
@property (nonatomic, strong) TPSpeedTracker *speedTracker;

@property (nonatomic, weak) IBOutlet UILabel *speedLabel;
@property (nonatomic, weak) IBOutlet UILabel *primaryDistanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *secondaryDistanceLabel;
@property (nonatomic, weak) IBOutlet UIButton *primaryStateButton;
@property (nonatomic, weak) IBOutlet UIButton *secondaryStateButton;
@property (nonatomic, weak) IBOutlet UIButton *primaryReverseButton;
@property (nonatomic, weak) IBOutlet UIButton *secondaryReverseButton;

- (IBAction)changeStatePrimary:(id)sender;
- (IBAction)changeStateSecondary:(id)sender;
- (IBAction)reversePrimary:(id)sender;
- (IBAction)reverseSecondary:(id)sender;
- (IBAction)resetPrimary:(id)sender;
- (IBAction)resetSecondary:(id)sender;
- (IBAction)trackLocation:(id)sender;

- (void)changeTrackerState:(TPDistanceTracker *)tracker withButton:(UIButton *)button;
- (void)changeTrackerReverse:(TPDistanceTracker *)tracker withButton:(UIButton *)button;
- (void)resetTracker:(TPDistanceTracker *)tracker;

@end

@implementation TPViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.primaryTracker = [[TPDistanceTracker alloc] init];
        self.primaryTracker.isReverse = NO;
        self.primaryTracker.delegate = self;
        self.secondaryTracker = [[TPDistanceTracker alloc] init];
        self.secondaryTracker.isReverse = NO;
        self.secondaryTracker.delegate = self;
        self.speedTracker = [[TPSpeedTracker alloc] init];
        self.speedTracker.delegate = self;
        [self.speedTracker startTracking];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.primaryDistanceLabel.text = [NSString stringWithDistance:kStartDistanceValue];
    self.secondaryDistanceLabel.text = [NSString stringWithDistance:kStartDistanceValue];
    self.speedLabel.text = [NSString stringWithSpeed:kStartSpeedValue];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)changeTrackerState:(TPDistanceTracker *)tracker withButton:(UIButton *)button
{
    if (tracker.isStarted) {
        [tracker stopTracking];
        [button setImage:[UIImage imageNamed:kStart] forState:UIControlStateNormal];
    } else {
        [tracker startTracking];
        [button setImage:[UIImage imageNamed:kStop] forState:UIControlStateNormal];
    }
}

- (void)changeTrackerReverse:(TPDistanceTracker *)tracker withButton:(UIButton *)button
{
    if (tracker.isReverse) {
        tracker.isReverse = NO;
        [button setImage:[UIImage imageNamed:kReverseOff] forState:UIControlStateNormal];
    } else {
        tracker.isReverse = YES;
        [button setImage:[UIImage imageNamed:kReverseOn] forState:UIControlStateNormal];
    }
}

- (void)resetTracker:(TPDistanceTracker *)tracker
{
    [tracker reset];
}

#pragma mark - Target-Action

- (IBAction)changeStatePrimary:(id)sender
{
    [self changeTrackerState:self.primaryTracker withButton:self.primaryStateButton];
    [self changeTrackerState:self.secondaryTracker withButton:self.secondaryStateButton];
}

- (IBAction)changeStateSecondary:(id)sender
{
    [self changeTrackerState:self.secondaryTracker withButton:self.secondaryStateButton];
}

- (IBAction)reversePrimary:(id)sender
{
    [self changeTrackerReverse:self.primaryTracker withButton:self.primaryReverseButton];
    [self changeTrackerReverse:self.secondaryTracker withButton:self.secondaryReverseButton];
}

- (IBAction)reverseSecondary:(id)sender
{
    [self changeTrackerReverse:self.secondaryTracker withButton:self.secondaryReverseButton];
}

- (IBAction)resetPrimary:(id)sender
{
    [self resetTracker:self.primaryTracker];
    [self resetTracker:self.secondaryTracker];
}

- (IBAction)resetSecondary:(id)sender
{
    [self resetTracker:self.secondaryTracker];
}

- (IBAction)trackLocation:(id)sender
{
    
}

#pragma mark - Distance tracker delegate

- (void)distanceTracker:(TPDistanceTracker *)tracker didUpdateDistance:(double)distance
{
    NSString *distanceResult = [NSString stringWithDistance:distance];
    if ([distanceResult length] > 0) {
        if (tracker == self.primaryTracker) {
            self.primaryDistanceLabel.text = distanceResult;
        } else if (tracker == self.secondaryTracker) {
            self.secondaryDistanceLabel.text = distanceResult;
        }
    }
}

#pragma mark - Speed tracker delegate

- (void)speedTracker:(TPSpeedTracker *)tracker didUpdateSpeed:(double)speed
{
    NSString *speedResult = [NSString stringWithSpeed:speed];
    if ([speedResult length] > 0) {
        self.speedLabel.text = speedResult;
    }
}

- (void)speedTracker:(TPSpeedTracker *)tracker error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kTrackerErrorTitle message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Location tracker delegate

- (void)locationTracker:(TPLocationTracker *)tracker didUpdateDistance:(double)distance
{
    
}

- (void)locationTracker:(TPLocationTracker *)tracker didUpdateDirection:(double)direction
{
    
}

@end
