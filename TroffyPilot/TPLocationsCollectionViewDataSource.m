//
//  TPLocationsCollectionViewDataSource.m
//  TroffyPilot
//
//  Created by student on 6/20/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import "TPLocationsCollectionViewDataSource.h"
#import "TPLocationCell.h"
#import "TPLocationsStorage.h"

static NSString * const kLocationCellIdentifier = @"LocationCell";

@interface TPLocationsCollectionViewDataSource ()

@property (nonatomic, strong) TPLocationsStorage *locationsStorage;

@end

@implementation TPLocationsCollectionViewDataSource

- (id)initWithStorage:(TPLocationsStorage *)locationsStorage
{
    self = [super init];
    if (self) {
        self.locationsStorage = locationsStorage;
    }
    return self;
}

#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.locationsStorage locationsCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TPLocationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kLocationCellIdentifier forIndexPath:indexPath];
    cell.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)[indexPath row]];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50.0f, 50.0f)];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:40.0f / 255.0f green:171.0f / 255.0f blue:26.0f / 255.0f alpha:1.0f];
    return cell;
}


@end
