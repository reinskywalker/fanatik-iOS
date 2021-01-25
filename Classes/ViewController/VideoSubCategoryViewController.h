//
//  VideoSubCategoryViewController.h
//  Fanatik
//
//  Created by Erick Martin on 5/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "SwipeView.h"
#import "SearchClipTableViewCell.h"
#import "VideoSubCategoryLayout.h"
#import "VideoCategoryFooterCell.h"
@class VideoSubCategoryViewController;


@interface VideoSubCategoryViewController : ParentViewController <UITableViewDataSource, UITableViewDelegate, SwipeViewDataSource, SwipeViewDelegate, SearchClipTableViewCellDelegate, VideoSubCategoryLayoutDelegate, VideoCategoryFooterCellDelegate>

@property (nonatomic, retain) IBOutlet SwipeView *horizontalMenu;
@property (nonatomic, retain) IBOutlet UITableView *subCategoryTableView;
@property (nonatomic, retain) IBOutlet UIView *subCategoryBannerView;
@property (nonatomic, retain) NSMutableArray *clipGroupsArray;

@property (nonatomic, retain) NSMutableArray *subCategoriesArray;
@property (nonatomic, retain) NSMutableArray *subCategoryNamesArray; //for swipeView

@property(nonatomic, retain) ClipCategory *currentCategory;
@property(nonatomic, assign) NSInteger selectedMenuIndex;
@property(nonatomic, copy) NSString *currentCategoryID;
@property(nonatomic, assign) int visibleItems;
@property(nonatomic, retain) VideoSubCategoryLayout *layoutSubView;

@property (nonatomic, retain) IBOutlet NSLayoutConstraint *heightOfHorizontalMenu;

-(id)initWithCategory:(ClipCategory *)cat;

@end
