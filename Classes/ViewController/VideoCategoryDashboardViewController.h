//
//  VideoCategoryDashboardViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 5/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"

@interface VideoCategoryDashboardViewController : ParentViewController<UITableViewDataSource, UITableViewDelegate>


-(id)initWithCategoryID:(NSString *)catID andLayoutID:(int)idx;
-(void)showCategoryPicker;
@end
