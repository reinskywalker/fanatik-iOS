//
//  ProfileEditViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/23/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "M6UniversalParallaxViewController.h"
@interface ProfileEditViewController : M6UniversalParallaxViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *userCoverImageView;

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) User *currentUser;

@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *setCoverButton;
@property (strong, nonatomic) IBOutlet UIButton *setAvatarButton;



- (IBAction)setCoverButtonTapped:(id)sender;
- (IBAction)setAvatarButtonTapped:(id)sender;

-(id)initWithUser:(User *)user;

@end
