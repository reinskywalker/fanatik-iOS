//
//  CategoryPickerTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 6/3/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClipSubCategoryModel.h"

@interface CategoryPickerTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet CustomRegularLabel *titleLabel;
@property (nonatomic, retain) ClipSubCategoryModel *currentSubCategory;

+(NSString *)reuseIdentifier;
-(void)setItem:(ClipSubCategoryModel *)subCat;

@end

