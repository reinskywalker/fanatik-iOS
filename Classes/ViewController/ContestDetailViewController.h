//
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/14/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "VideoCategoryFooterCell.h"
#import "ContestInfoTableViewCell.h"
#import "DMMoviePlayer.h"
#import "UserFollowTableViewCell.h"

@interface ContestDetailViewController : ParentViewController<UITableViewDelegate, UITableViewDataSource, VideoCategoryFooterCellDelegate, UserFollowTableViewCellDelegate>

@property (nonatomic, retain) NSMutableArray *videoContestArray;
@property (nonatomic, retain) NSMutableArray *contestantArray;
@property (nonatomic, retain) Contest *currentContest;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UIImageView *posterView;

@property (nonatomic, retain) IBOutlet NSLayoutConstraint *imageHeightCon;
@property (nonatomic, retain) IBOutlet UIButton *uploadButton;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *imageHeightUploadButton;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *uploadButtonHeightConstraint;

@property (strong, nonatomic) IBOutlet DMMoviePlayer *playerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerAspectRationConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerBottomConstraint;

-(id)initWithContest:(Contest *)contest;
-(id)initWithContestID:(NSNumber *)contestID;
-(IBAction)uploadTapped:(id)sender;

@end
