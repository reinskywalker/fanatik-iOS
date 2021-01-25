//
//  VideoCategoryViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/13/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "SwipeView.h"

@interface VideoCategoryViewController : ParentViewController<SwipeViewDataSource, SwipeViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet SwipeView *horizontalMenu;
-(id)initWithId:(NSString *)objID;

-(void)showCategoryPicker;
@end
