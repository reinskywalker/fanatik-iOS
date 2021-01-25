//
//  EventViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 11/16/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventGroupSmallTableViewCell.h"

@interface EventViewController : ParentViewController <UITableViewDataSource, UITableViewDelegate, EventGroupSmallTableViewCellDelegate>

@property(nonatomic, retain) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *blankLabel;

@end
