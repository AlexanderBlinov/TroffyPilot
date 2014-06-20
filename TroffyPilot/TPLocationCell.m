//
//  TPLocationCell.m
//  TroffyPilot
//
//  Created by student on 6/13/14.
//  Copyright (c) 2014 student. All rights reserved.
//

#import "TPLocationCell.h"

@implementation TPLocationCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"TPLocationCell" owner:self options:nil];
        if ([arrayOfViews count] < 1) return nil;
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) return nil;
        self = [arrayOfViews objectAtIndex:0];
    }
    return self;
}

@end
