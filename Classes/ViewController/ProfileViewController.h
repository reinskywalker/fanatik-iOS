//
//  ProfileViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/23/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "M6UniversalParallaxViewController.h"
#import "SearchClipTableViewCell.h"
#import "UploadClipTableViewCell.h"
#import <UIKit/UIKit.h>

typedef enum {
    ProfileModeVideo = 0,
    ProfileModePlaylist = 1,
    ProfileModeActivity = 2,
    ProfileModeModerasi = 3
}ProfileMode;


@interface ProfileViewController : M6UniversalParallaxViewController<UITableViewDataSource, UITableViewDelegate, SearchClipTableViewCellDelegate, UploadClipTableViewCellDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *userCoverImageView;

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) User *currentUser;

@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *userNameLabel;
@property (strong, nonatomic) IBOutlet CustomBoldButton *userNameButton;
@property (strong, nonatomic) IBOutlet UIButton *editButton;

@property (strong, nonatomic) IBOutlet CustomBoldLabel *followingCountLabel;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *followersCountLabel;
@property (nonatomic, assign) ProfileMode currentProfileMode;

@property (nonatomic, retain) IBOutlet UITableViewCell *progressCell;
@property (nonatomic, retain) IBOutlet UILabel *totalProgressLabel;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet CustomMediumButton *viewCoverButton;

- (IBAction)editButtonTapped:(id)sender;
- (IBAction)followingButtonTapped:(id)sender;
- (IBAction)followersButtonTapped:(id)sender;
- (IBAction)avatarTapped:(id)sender;
- (IBAction)viewCoverTapped:(id)sender;

-(id)initWithUser:(User *)user;
-(id)initWithUserId:(NSString *)userId;
@end
