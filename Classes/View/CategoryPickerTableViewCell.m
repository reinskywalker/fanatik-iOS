//
//  CategoryPickerTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 6/3/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "CategoryPickerTableViewCell.h"

@implementation CategoryPickerTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)setItem:(ClipSubCategoryModel *)subCat{
    self.titleLabel.text = subCat.clip_subcategory_name;
}

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

@end
