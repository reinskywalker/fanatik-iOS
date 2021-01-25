//
//  SearchViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/10/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"

@interface SearchViewController : ParentViewController<SearchClipTableViewCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *searchTextContainerView;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet CustomBoldButton *videoButton;
@property (strong, nonatomic) IBOutlet CustomBoldButton *userButton;
@property (strong, nonatomic) IBOutlet CustomBoldButton *playlistButton;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *emptyLabel;
@property (strong, nonatomic) IBOutlet UIView *tabView;

- (IBAction)tabButtonTapped:(CustomBoldButton *)sender;


@end
