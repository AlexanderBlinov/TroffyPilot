//
//  TPLocationsCollectionViewDataSource.m
//  TroffyPilot
//
//  Created by student on 6/20/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import "TPLocationsCollectionViewDataSource.h"
#import "TPLocationCell.h"
#import "TPSharedLocations.h"

@implementation TPLocationsCollectionViewDataSource

#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[TPSharedLocations sharedLocations] locationsCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TPLocationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LocationCell" forIndexPath:indexPath];
    cell.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)[indexPath row]];
    cell.selectedBackgroundView = [[UIView alloc] init];
    cell.selectedBackgroundView.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    return cell;
}


@end
