//
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/12/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"

@interface ContestViewController : ParentViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *contestArray;
@property (nonatomic, assign) int currentPage;

@end
