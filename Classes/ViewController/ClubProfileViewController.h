//
//  ClubProfileViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/23/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "M6UniversalParallaxViewController.h"
#import "PostDialogViewController.h"

typedef enum {
    ClubModeAllThreads = 0,
    ClubModePopular,
}ClubMode;


@interface ClubProfileViewController : M6UniversalParallaxViewController<UITableViewDataSource, UITableViewDelegate, PostDialogViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *clubCoverImageView;

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) Club *currentClub;

@property (strong, nonatomic) IBOutlet UIImageView *clubImageView;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *clubNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *membersButton;
@property (strong, nonatomic) IBOutlet UIButton *threadsButton;
@property (nonatomic, assign) ClubMode currentClubMode;
@property (nonatomic, retain) IBOutlet UIButton *joinButton;

- (IBAction)membersButtonTapped:(id)sender;
- (IBAction)threadsButtonTapped:(id)sender;
- (IBAction)avatarTapped:(id)sender;
- (IBAction)joinButtonTapped:(id)sender;

-(id)initWithClub:(Club *)club;
-(id)initWithClubId:(NSString *)clubId;

@end
