//
//  VideoCategoryPickerCell.m
//  Fanatik
//
//  Created by Erick Martin on 5/20/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "VideoCategoryPickerCell.h"

@implementation VideoCategoryPickerCell

@synthesize categoryNameLabel;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

-(void)setItem:(ClipCategory *)cat{
    self.categoryNameLabel.text = cat.clip_category_name;
}

-(void)setCategoryNameStr:(NSString *)name{
    self.categoryNameLabel.text = name;
}


@end
