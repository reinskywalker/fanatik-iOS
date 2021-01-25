//
//  CategoryPickerViewController.h
//  Fanatik
//
//  Created by Erick Martin on 6/3/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "CategoryPickerTableViewCell.h"

@protocol CategoryPickerViewControllerDelegate <NSObject>

-(void)didSelectSubCategoryArray:(NSArray *)arrayOfSelectedSubCategory;
-(void)didSelectSubCategory:(ClipSubCategoryModel *)clipSubCat;
-(void)didSelectCategory:(ClipCategoryModel *)clipCat;

@end

@interface CategoryPickerViewController : ParentViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, retain) IBOutlet UITableView *categoryTableView;
@property(nonatomic, retain) NSMutableArray *categoryArray;
@property(nonatomic, assign) id <CategoryPickerViewControllerDelegate> delegate;
@property(nonatomic, retain) NSMutableSet *selectedSubCategorySet;


@end
