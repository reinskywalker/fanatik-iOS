//
//  NotificationViewController.h
//  Fanatik
//
//  Created by Erick Martin on 4/27/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "ParentViewController.h"

@interface NotificationViewController : ParentViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, retain) IBOutlet UITableView *myTableView;

@end