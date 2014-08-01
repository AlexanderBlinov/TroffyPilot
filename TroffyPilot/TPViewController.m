//
//  TPViewController.m
//  TroffyPilot
//
//  Created by student on 6/3/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import "TPViewController.h"
#import "TPLocationsCollectionViewDataSource.h"
#import "TPDistanceTracker.h"
#import "TPSpeedTracker.h"
#import "TPDistanceValueTransformer.h"
#import "TPSpeedValueTransformer.h"
#import "TPLocationTracker.h"
#import "TPLocationsStorage.h"
#import "TPLocationCell.h"
#import "NSString+DistanceAndSpeed.h"

static NSString * const kLocationCellIdentifier = @"LocationCell";
static NSString * const kAnimateDirection = @"animateDirection";
static NSString * const kReverseOn = @"ReverseOn";
static NSString * const kReverseOff = @"ReverseOff";
static NSString * const kStart = @"Start";
static NSString * const kStop = @"Stop";
static NSString * const kDirection = @"Direction";
static const double kStartDistanceValue = 0.0;
static const double kStartSpeedValue = 0.0;
static const NSInteger kDeleteSheet = 1;
static const NSInteger kErrorAlert = -1;
static double previousDirection = 0;

@interface TPViewController ()

@property (nonatomic, strong) TPLocationsStorage *locationsStorage;
@property (nonatomic, strong) TPDistanceTracker *primaryTracker;
@property (nonatomic, strong) TPDistanceTracker *secondaryTracker;
@property (nonatomic, strong) TPSpeedTracker *speedTracker;
@property (nonatomic, strong) TPLocationTracker *locationTracker;
@property (nonatomic, strong) NSIndexPath *indexPathToBeDeleted;
@property (nonatomic, strong) CALayer *directionLayer;
@property (nonatomic, strong) TPLocationsCollectionViewDataSource *locationsDataSource;

@property (nonatomic, weak) IBOutlet UILabel *speedLabel;
@property (nonatomic, weak) IBOutlet UILabel *primaryDistanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *secondaryDistanceLabel;
@property (nonatomic, weak) IBOutlet UIButton *primaryStateButton;
@property (nonatomic, weak) IBOutlet UIButton *secondaryStateButton;
@property (nonatomic, weak) IBOutlet UIButton *primaryReverseButton;
@property (nonatomic, weak) IBOutlet UIButton *secondaryReverseButton;
@property (nonatomic, weak) IBOutlet UICollectionView *locationsCollectionView;
@property (nonatomic, weak) IBOutlet UILabel *trackingDistance;
@property (nonatomic, weak) IBOutlet UIImageView *directionImage;

- (IBAction)changeStatePrimary:(id)sender;
- (IBAction)changeStateSecondary:(id)sender;
- (IBAction)reversePrimary:(id)sender;
- (IBAction)reverseSecondary:(id)sender;
- (IBAction)resetPrimary:(id)sender;
- (IBAction)resetSecondary:(id)sender;
- (IBAction)trackLocation:(id)sender;
- (IBAction)didLongPressCellToDelete:(id)sender;

- (void)changeTrackerState:(TPDistanceTracker *)tracker withButton:(UIButton *)button;
- (void)changeTrackerReverse:(TPDistanceTracker *)tracker withButton:(UIButton *)button;
- (void)resetTracker:(TPDistanceTracker *)tracker;
- (void)rotateDirectionLayerToDirection:(double)direction;
- (void)deleteAllLocations;
- (void)deleteLocationAtIndexPath:(NSIndexPath *)indexPath;
- (void)selectLocationAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation TPViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.locationsStorage = [[TPLocationsStorage alloc] init];
        self.primaryTracker = [[TPDistanceTracker alloc] init];
        self.primaryTracker.isReversed = NO;
        self.primaryTracker.delegate = self;
        self.secondaryTracker = [[TPDistanceTracker alloc] init];
        self.secondaryTracker.isReversed = NO;
        self.secondaryTracker.delegate = self;
        self.speedTracker = [[TPSpeedTracker alloc] init];
        self.speedTracker.delegate = self;
        [self.speedTracker startTracking];
        self.locationTracker = [[TPLocationTracker alloc] init];
        self.locationTracker.delegate = self;
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
    self.trackingDistance.text = [NSString stringWithDistance:kStartDistanceValue];
    
    self.locationsDataSource = [[TPLocationsCollectionViewDataSource alloc] initWithStorage:self.locationsStorage];
    self.locationsCollectionView.dataSource = self.locationsDataSource;
    
    [self.locationsCollectionView registerClass:[TPLocationCell class] forCellWithReuseIdentifier:kLocationCellIdentifier];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setItemSize:CGSizeMake(50, 50)];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.locationsCollectionView setCollectionViewLayout:layout];
    self.locationsCollectionView.allowsSelection = YES;
    
    self.directionLayer = [CALayer layer];
    self.directionLayer.position = CGPointMake(25.0f, 25.0f);
    self.directionLayer.bounds = CGRectMake(0, 0, 50.0f, 50.0f);
    self.directionLayer.contents = (id)[[UIImage imageNamed:kDirection] CGImage];
    [self.directionImage.layer addSublayer:self.directionLayer];
    
    if ([self.locationsStorage locationsCount] > 0) {
        NSIndexPath *indPath = [NSIndexPath indexPathForRow:[self.locationsStorage locationsCount] - 1 inSection:0];
        [self selectLocationAtIndexPath:indPath];
    }
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
    if (tracker.isReversed) {
        tracker.isReversed = NO;
        [button setImage:[UIImage imageNamed:kReverseOff] forState:UIControlStateNormal];
    } else {
        tracker.isReversed = YES;
        [button setImage:[UIImage imageNamed:kReverseOn] forState:UIControlStateNormal];
    }
}

- (void)resetTracker:(TPDistanceTracker *)tracker
{
    [tracker reset];
}

- (void)rotateDirectionLayerToDirection:(double)direction
{
    if (abs(direction - previousDirection) > abs(previousDirection + 2 * M_PI - direction)) {
        previousDirection = previousDirection + 2 * M_PI;
    }
    if (abs(direction - previousDirection) > abs(previousDirection - 2 * M_PI - direction)) {
        previousDirection = previousDirection - 2 * M_PI;
    }
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fillMode = kCAFillModeForwards;
    rotateAnimation.removedOnCompletion = NO;
    rotateAnimation.fromValue = [NSNumber numberWithDouble:previousDirection];
    rotateAnimation.toValue = [NSNumber numberWithDouble:direction];
    rotateAnimation.duration = 0.1;
    [self.directionLayer addAnimation:rotateAnimation forKey:kAnimateDirection];
    previousDirection = direction;
}

- (void)deleteAllLocations
{
    __weak TPViewController *viewController = self;
    [self.locationsCollectionView performBatchUpdates:^{
        NSMutableArray *indexPathsToDelete = [NSMutableArray array];
        for (int i = 0; i < viewController.locationsStorage.locationsCount; ++i) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        [viewController.locationsStorage removeAllLocations];
        [viewController.locationsCollectionView deleteItemsAtIndexPaths:indexPathsToDelete];
    } completion:^(BOOL finished) {
        [viewController.locationsCollectionView reloadData];
        viewController.locationTracker.trackingLocation = nil;
    }];
    [self.locationsStorage saveLocations];
}

- (void)deleteLocationAtIndexPath:(NSIndexPath *)indexPath
{
    __weak TPViewController *viewController = self;
    [self.locationsCollectionView performBatchUpdates:^{
        [viewController.locationsStorage removeLocationAtIndex:indexPath.row];
        [viewController.locationsCollectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        if (finished) {
            [viewController.locationsCollectionView reloadData];
            NSUInteger locationsCount = [self.locationsStorage locationsCount];
            if (locationsCount > 0) {
                if (locationsCount <= indexPath.row) {
                    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:locationsCount - 1 inSection:0];
                    [viewController selectLocationAtIndexPath:lastIndexPath];
                } else {
                    [viewController selectLocationAtIndexPath:indexPath];
                }
            } else {
                viewController.locationTracker.trackingLocation = nil;
            }
        }
    }];
    [self.locationsStorage saveLocations];
}

- (void)selectLocationAtIndexPath:(NSIndexPath *)indexPath
{
    [self.locationsCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionRight];
    self.locationTracker.trackingLocation = [self.locationsStorage locationAtIndex:indexPath.row];
}

#pragma mark - Target-Action

- (IBAction)didLongPressCellToDelete:(id)sender
{
    UILongPressGestureRecognizer *gesture = (UILongPressGestureRecognizer *)sender;
    CGPoint tapLocation = [gesture locationInView:self.locationsCollectionView];
    NSIndexPath *indexPath = [self.locationsCollectionView indexPathForItemAtPoint:tapLocation];
    if (indexPath && gesture.state == UIGestureRecognizerStateBegan) {
        self.indexPathToBeDeleted = indexPath;
        UIActionSheet *deleteSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"DeleteTitle", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"DeleteSelected", nil), NSLocalizedString(@"DeleteAll", nil), nil];
        deleteSheet.destructiveButtonIndex = 1;
        deleteSheet.tag = kDeleteSheet;
        [deleteSheet showInView:self.view];
    }
}

- (IBAction)changeStatePrimary:(id)sender
{
    if (self.primaryTracker.isStarted == self.secondaryTracker.isStarted) {
        [self changeTrackerState:self.secondaryTracker withButton:self.secondaryStateButton];
    }
    [self changeTrackerState:self.primaryTracker withButton:self.primaryStateButton];
    
}

- (IBAction)changeStateSecondary:(id)sender
{
    [self changeTrackerState:self.secondaryTracker withButton:self.secondaryStateButton];
}

- (IBAction)reversePrimary:(id)sender
{
    if (self.primaryTracker.isReversed == self.secondaryTracker.isReversed) {
        [self changeTrackerReverse:self.secondaryTracker withButton:self.secondaryReverseButton];
    }
    [self changeTrackerReverse:self.primaryTracker withButton:self.primaryReverseButton];
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
    CLLocation *location = [self.locationTracker generateLocation];
    if (location) {
        [self.locationsStorage addLocation:location];
        [self.locationsCollectionView reloadData];
        NSUInteger indexOfLocation = [self.locationsStorage indexOfLocation:location];
        NSIndexPath *indPath = [NSIndexPath indexPathForRow:indexOfLocation inSection:0];
        [self selectLocationAtIndexPath:indPath];
        [self.locationsStorage saveLocations];
    }
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.locationTracker.trackingLocation = [self.locationsStorage locationAtIndex:[indexPath row]];
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
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TrackerError", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    errorAlert.tag = kErrorAlert;
    [errorAlert show];
}

#pragma mark - Location tracker delegate

- (void)locationTracker:(TPLocationTracker *)tracker didUpdateDistance:(double)distance
{
    NSString *distanceResult = [NSString stringWithDistance:distance];
    if ([distanceResult length] > 0) {
        self.trackingDistance.text = distanceResult;
    }
}

- (void)locationTracker:(TPLocationTracker *)tracker didUpdateDirection:(double)direction
{
    [self rotateDirectionLayerToDirection:direction];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kErrorAlert:
            break;
        default:
            break;
    }
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case kDeleteSheet:
        {
            const NSInteger kDeleteSelectedButtonIndex = 0;
            const NSInteger kDeleteAllButtonIndex = 1;
            if (buttonIndex == kDeleteSelectedButtonIndex) {
                [self deleteLocationAtIndexPath:self.indexPathToBeDeleted];
            } else if (buttonIndex == kDeleteAllButtonIndex) {
                [self deleteAllLocations];
            } else {
                [self selectLocationAtIndexPath:self.indexPathToBeDeleted];
            }
            
        }
            break;
        default:
            break;
    }
}

@end
