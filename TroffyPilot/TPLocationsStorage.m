//
//  TPSharedLocations.m
//  TroffyPilot
//
//  Created by student on 6/16/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import "TPLocationsStorage.h"

@interface TPLocationsStorage ()

@property (strong) NSMutableArray *locations;

- (NSString *)locationsArchivePath;

@end

@implementation TPLocationsStorage

- (id)init
{
    self = [super init];
    if (self) {
        [self loadLocations];
    }
    return self;
}

- (void)addLocation:(CLLocation *)location
{
    [self.locations addObject:location];
}

- (void)removeLocationAtIndex:(NSUInteger)index
{
    [self.locations removeObjectAtIndex:index];
}

- (NSUInteger)locationsCount
{
    return [self.locations count];
}

- (CLLocation *)locationAtIndex:(NSUInteger)index
{
    return [self.locations objectAtIndex:index];
}

- (NSUInteger)indexOfLocation:(CLLocation *)location
{
    return [self.locations indexOfObject:location];
}

- (CLLocation *)lastLocation
{
    return [self.locations lastObject];
}

- (void)loadLocations
{
    self.locations = [NSKeyedUnarchiver unarchiveObjectWithFile:[self locationsArchivePath]];
    if (self.locations == nil) {
        self.locations = [NSMutableArray array];
    }
}

- (void)saveLocations
{
    [NSKeyedArchiver archiveRootObject:self.locations toFile:[self locationsArchivePath]];
}

- (NSString *)locationsArchivePath
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentPath stringByAppendingPathComponent:@"locations.archive"];
}

@end
