//
//  DashboardViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/12/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "SmallVideoTableViewCell.h"

@interface DashboardViewController : ParentViewController<UITableViewDataSource, UITableViewDelegate,LargeVideoTableViewCellDelegate, SmallVideoTableViewCellDelegate>

@property (nonatomic, retain) IBOutlet UIImageView *imgView;

@end
