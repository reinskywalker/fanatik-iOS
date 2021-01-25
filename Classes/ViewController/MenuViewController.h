//
//  MasterViewController.h
//  Urband Sport Finder
//
//  Created by Teguh Hidayatullah on 10/4/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuCell.h"
#import "ParentViewController.h"

@interface MenuViewController : ParentViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>


@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) NSArray *menuOptions;
@property (nonatomic, retain) User *currentUser;

@property (strong, nonatomic) IBOutlet CustomMediumButton *settingButton;
@property (nonatomic, retain) UIViewController *currentController;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet CustomBoldLabel *userNameLabel;

- (IBAction)profileButtonTapped:(id)sender;
- (IBAction)signinButtonTapped:(id)sender;

- (IBAction)gearButtonTapped:(id)sender;
- (IBAction)settingButtonTapped:(id)sender;
- (IBAction)logoutButtonTapped:(id)sender;
@end

