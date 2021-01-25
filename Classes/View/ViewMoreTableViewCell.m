//
//  EventInfoTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ViewMoreTableViewCell.h"

@implementation ViewMoreTableViewCell

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    // iOS 8.3 bug, where contentView's x position isnt aligned with self's x position...
    // So we add a constraint to do the obvious...
    [self.contentView sdc_alignEdgesWithSuperview:UIRectEdgeAll];
}

@end
