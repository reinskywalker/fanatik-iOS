//
//  SettingsViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/27/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "SwitchTableViewCell.h"

@interface SettingsViewController : ParentViewController<UITableViewDataSource, UITableViewDelegate, SwitchTableViewCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *editCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *passCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *packageCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *privacyCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *logoutCell;

@end
