//
//  PackageListViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/4/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"

@protocol PackageListViewControllerDelegate <NSObject>
-(void)didClosePackageList;
@end

@interface PackageListViewController : ParentViewController

@property (nonatomic, assign) id <PackageListViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, assign) BOOL shouldPresent;

@end
