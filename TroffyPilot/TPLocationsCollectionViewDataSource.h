//
//  TPLocationsCollectionViewDataSource.h
//  TroffyPilot
//
//  Created by student on 6/20/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPLocationsStorage;

@interface TPLocationsCollectionViewDataSource : NSObject <UICollectionViewDataSource>

- (id)initWithStorage:(TPLocationsStorage *)locationsStorage;

@end
