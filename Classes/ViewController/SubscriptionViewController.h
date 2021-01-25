//
//  SubscriptionViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/9/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"

@interface SubscriptionViewController : ParentViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, retain) IBOutlet UITableView *myTableView;
@property(nonatomic, retain) NSMutableArray *subscriptionsArray;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *blankLabel;

@end
