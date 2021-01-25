//
//  LargeVideoTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/12/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "SmallMoreVideoCollectionView.h"
#import "Thumbnail+functionality.h"
#import "Video+functionality.h"
#import "ClipStats+functionality.h"

@implementation SmallMoreVideoCollectionView


+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}


@end
