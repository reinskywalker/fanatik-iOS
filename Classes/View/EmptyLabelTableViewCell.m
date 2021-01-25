//
//  EmptyLabelTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/26/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "EmptyLabelTableViewCell.h"

@implementation EmptyLabelTableViewCell
@synthesize emptyLabel;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
