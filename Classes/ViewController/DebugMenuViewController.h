//
//  DebugMenuViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 10/4/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuCell.h"
#import "ParentViewController.h"

@interface DebugMenuViewController : ParentViewController <UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) NSArray *menuOptions;

@property (nonatomic, retain) UIViewController *currentController;


@end

