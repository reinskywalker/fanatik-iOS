//
//  DatePickerTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/29/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "DatePickerTableViewCell.h"

@implementation DatePickerTableViewCell

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


-(CGFloat)cellHeight{
    self.datePickerHeighConstraint.constant = self.isExpanded ? [DatePickerTableViewCell pickerHeightExpanded] : 0;
    return self.datePickerHeighConstraint.constant;
}

+(CGFloat)pickerHeightExpanded{
    return 220;
}

- (void)layoutSubviews{
    [self cellHeight];
    [super layoutSubviews];
}

@end
