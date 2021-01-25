//
//  ProfileFollowerViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/23/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "M6UniversalParallaxViewController.h"

typedef enum {
    FollowModeFollower = 0,
    FollowModeFollowing,
}FollowMode;

@protocol ProfileFollowerViewControllerDelegate <NSObject>

-(void)didFollowUser:(User *)obj;
-(void)didUnfollowUser:(User *)obj;

@end

@interface ProfileFollowerViewController : M6UniversalParallaxViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *userCoverImageView;

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) User *currentUser;

@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *editButton;

@property (nonatomic, weak) id <ProfileFollowerViewControllerDelegate> delegate;


-(id)initWithUser:(User *)user withMode:(FollowMode)mode;

@end
