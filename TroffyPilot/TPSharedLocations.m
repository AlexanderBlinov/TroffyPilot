//
//  TPSharedLocations.m
//  TroffyPilot
//
//  Created by student on 6/16/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import "TPSharedLocations.h"

@interface TPSharedLocations ()

@property (strong) NSMutableArray *locations;

- (NSString *)locationsArchivePath;

@end

@implementation TPSharedLocations

static TPSharedLocations *sharedInstance = nil;

+ (TPSharedLocations *)sharedLocations
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
        [sharedInstance loadLocations];
    });
    return sharedInstance;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [[self class] sharedLocations];
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
