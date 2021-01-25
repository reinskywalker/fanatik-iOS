//
//  ClubViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/13/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "SwipeView.h"

@interface ClubViewController : ParentViewController<SwipeViewDataSource, SwipeViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet SwipeView *horizontalMenu;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *searchBarHeightConstraint;
@property (strong, nonatomic) IBOutlet CustomSemiBoldLabel *loginText;
@property (strong, nonatomic) IBOutlet CustomMediumButton *loginButton;
- (IBAction)loginTapped:(id)sender;
-(id)initWithId:(NSInteger)selectedMenu;
@end
