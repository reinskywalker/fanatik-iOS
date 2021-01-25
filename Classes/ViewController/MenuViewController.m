//
//  MasterViewController.m
//  Urband Sport Finder
//
//  Created by Teguh Hidayatullah on 10/4/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "MenuViewController.h"
#import "TimelineViewController.h"
#import "DashboardViewController.h"
#import "PackageListViewController.h"
#import "SubscriptionViewController.h"
#import "ProfileFollowerViewController.h"
#import "VideoCategoryDashboardViewController.h"
#import "VideoCategoryViewController.h"
#import "TVChannelViewController.h"
#import "SettingsViewController.h"
#import "RightMenuViewController.h"
#import "ClubViewController.h"
#import "VideoSubCategoryViewController.h"
#import "ContestViewController.h"
#import "LiveChatViewController.h"
#import "EventViewController.h"
#import "NotificationViewController.h"

@interface MenuViewController (){
    int numRequest;
}
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *profileButton;
@property (nonatomic, retain) NSMutableArray *sideMenuArray;
@property NSMutableArray *objects;
- (IBAction)openDebugMenu:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIButton *debugButton;
@property (nonatomic, retain) IBOutlet NSLayoutConstraint *debugConstraint;
@property (strong, nonatomic) IBOutlet CustomMediumButton *logoutButton;
@property (strong, nonatomic) IBOutlet UIView *loggedInTableHeader;
@property (strong, nonatomic) IBOutlet UIView *nonLoggedInTableHeader;

@end

@implementation MenuViewController
@synthesize userImageView,userNameLabel, currentUser, sideMenuArray, loginButton;

-(instancetype)init{
    if(self = [super init]){
        self.sideMenuArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    [self setAllData];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSectionMenuFromServer) name:kLogoutCompletedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUserProfileFromServer) name:kProfileUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSectionMenuFromServer) name:kRequestSideMenuNotification object:nil];

    
    self.sideMenuArray = [NSMutableArray arrayWithArray:SIDE_MENU_ARRAY()];
    if(self.sideMenuArray.count > 0){
        [self.myTableView reloadData];
    }
    [self getSectionMenuFromServer];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.currentUser = CURRENT_USER();
    [self configureView];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setAllData];
}

-(void)viewDidUnload{
    [super viewDidUnload];
}

-(void)configureView{
    self.loginButton.layer.cornerRadius = 4.0;
    self.loginButton.layer.masksToBounds = YES;
    
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2;
    self.userImageView.layer.masksToBounds = YES;

//    if(self.currentUser)
//        self.myTableView.tableFooterView = self.footerView;
//    else
        self.myTableView.tableFooterView = nil;
    
#ifdef DEBUG
    self.debugConstraint.constant = 45.0;
    self.debugButton.hidden = NO;
#else
    self.debugConstraint.constant = 0.0;
    self.debugButton.hidden = YES;
#endif
    [self.myTableView registerNib:[UINib nibWithNibName:[SideMenuCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([SideMenuCell class])];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;

}

-(void)getUserProfileFromServer{
    if(SESSION_TOKEN() && ![SESSION_TOKEN() isEqualToString:@""]){
        [User getShowUserProfileWithAccesToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, User *user) {
            [TheSettingsManager saveCurrentUserId:user.user_id];
            self.currentUser = user;
            NSLog(@"following:%@",self.currentUser.user_user_stats.user_stats_following);
            [self setAllData];
//            [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            [self.myTableView.pullToRefreshView stopAnimating];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self.myTableView.pullToRefreshView stopAnimating];
        }];
    }else{
        self.currentUser = nil;
        [self setAllData];
//        [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [self.myTableView.pullToRefreshView stopAnimating];
    }
}

-(void)getSectionMenuFromServer{
    [self.myTableView.pullToRefreshView startAnimating];
    [SectionMenu getSectionMenuWithAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *resultArray) {
        
        NSData *responseData = operation.HTTPRequestOperation.responseData;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingAllowFragments
                              error:nil];
        [self.sideMenuArray removeAllObjects];
        for(NSDictionary *sectionDict in json[@"menus"]){
            NSMutableArray *sectionMenuArray = [NSMutableArray array];
            for(NSDictionary *rowDict in sectionDict[@"section_menu"]){
                RowMenuModel *rowMenu = [[RowMenuModel alloc] initWithDictionary:rowDict];
                [sectionMenuArray addObject:rowMenu];
            }
            [self.sideMenuArray addObject:sectionMenuArray];
        }
        [TheSettingsManager saveSideMenuArray:self.sideMenuArray];
        [self getUserProfileFromServer];

        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self.myTableView.pullToRefreshView stopAnimating];
    }];
}


-(void)setAllData{
    if([User fetchLoginUser]){
        //Logged in
        self.myTableView.tableHeaderView = self.loggedInTableHeader;
        UIView *borderView = [self.view viewWithTag:2702];
        if(!borderView || borderView == nil){
            [TheInterfaceManager addBorderViewForImageView:self.userImageView withBorderWidth:5.0 andBorderColor:nil];
        }
        [[SDImageCache sharedImageCache] removeImageForKey:currentUser.user_avatar.avatar_thumbnail fromDisk:YES withCompletion:^{
            [self.userImageView sd_setImageWithURL:[NSURL URLWithString:currentUser.user_avatar.avatar_thumbnail] placeholderImage:nil options:SDWebImageRefreshCached];
        }];
        
        self.userNameLabel.text = currentUser.user_name;
        
    }else{
        self.myTableView.tableHeaderView = self.nonLoggedInTableHeader;

//        [self.myTableView sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:self.loginButton inset:50.0];
    }
    [self.myTableView reloadData];
    
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return self.sideMenuArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sideMenuArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // example using a custom UITableViewCell
    SideMenuCell *customCell = (SideMenuCell *) [tableView dequeueReusableCellWithIdentifier:[SideMenuCell reuseIdentifier]];
    RowMenuModel *rowMenu = sideMenuArray[indexPath.section][indexPath.row];
    [customCell setCellWithRowMenu:rowMenu];
//    if([rowMenu.rowMenuPage isEqualToString:MenuPageFollowing])
//        [customCell setFollowingLabelWithStats:self.currentUser.user_user_stats];
    return customCell;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    int deviation = 1;
    if([User fetchLoginUser]){
        deviation = 0;
    }
    
    if(section < 2 - deviation){
        UIView *lineView = [UIView new];
        lineView.frame = CGRectMake(0, 0, self.myTableView.frame.size.width, 1.0);
        lineView.backgroundColor = HEXCOLOR(0xd6d6d6FF);
        return lineView;
    }else{
        UIView *sectHeaderView = [UIView new];
        sectHeaderView.frame = CGRectMake(0, 0, self.myTableView.frame.size.width, 55.0);
        sectHeaderView.backgroundColor = [UIColor clearColor];
        UIView *lineView = [UIView new];
        lineView.frame = CGRectMake(0, 15.0, self.myTableView.frame.size.width, 1);
        lineView.backgroundColor = HEXCOLOR(0xd6d6d6FF);
        [sectHeaderView addSubview:lineView];
        
        CustomBoldLabel *categoryLabel = [[CustomBoldLabel alloc] initWithFrame:CGRectMake(30.0, 30.0, self.myTableView.frame.size.width, 20.0)];
        [categoryLabel setFont:[UIFont fontWithName:InterfaceStr(@"default_font_bold") size:14.0]];
        categoryLabel.text = @"CATEGORY";
        categoryLabel.textColor = HEXCOLOR(0x666666FF);
        [sectHeaderView addSubview:categoryLabel];
        return sectHeaderView;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    int deviation = 1;
    if([User fetchLoginUser]){
        deviation = 0;
    }
    
    if(section < 2 - deviation){
        if(section == 1){
            return 1.0;
        }
        return 0.01;
    }else{
        return 55.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RowMenuModel *aRow = self.sideMenuArray[indexPath.section][indexPath.row];
    ParentViewController *controller;

    if([aRow.rowMenuName isEqualToString:@"Logout"]){
        [self doLogoutUser];
    }else{
        if([SELECTED_MENU() isEqualToString:aRow.rowMenuPage] && ![SELECTED_MENU() isEqualToString:MenuPageVideoCategory]){
            [TheAppDelegate showLeftMenu];
            return;
        }
        
        if([aRow.rowMenuPage isEqualToString:MenuPageTimeline]){
            controller = [[TimelineViewController alloc] init];
            
        }else if([aRow.rowMenuPage isEqualToString:MenuPageHome]){
            controller = [[DashboardViewController alloc] init];
        }else if([aRow.rowMenuPage isEqualToString:MenuPagePackages]){
            [TheServerManager openPackagesForContentClass:ContentClassNone withID:nil];
            return;
        }else if ([aRow.rowMenuPage isEqualToString:MenuPageMyPackages]){
            controller = [[SubscriptionViewController alloc] init];
        }else if([aRow.rowMenuPage isEqualToString:MenuPageFollowing]){
            controller =[[ProfileFollowerViewController alloc] initWithUser:[User fetchLoginUser] withMode:FollowModeFollowing];
        }else if([aRow.rowMenuPage isEqualToString:MenuPageVideoCategoryDashboard]){
            controller =[[VideoCategoryDashboardViewController alloc] initWithCategoryID:aRow.rowMenuParamsID andLayoutID:1];
        }else if([aRow.rowMenuPage isEqualToString:MenuPageVideoCategory]){
            controller = [[VideoCategoryViewController alloc] initWithId:aRow.rowMenuParamsID];
        }else if([aRow.rowMenuPage isEqualToString:MenuPagePlaylist]){
            controller = [[ProfileViewController alloc] initWithUser:[User fetchLoginUser]];
            [(ProfileViewController *)controller setCurrentProfileMode:ProfileModePlaylist];
        }else if([aRow.rowMenuPage isEqualToString:MenuPageTVChannel]){
            controller = [[TVChannelViewController alloc] init];
        }else if([aRow.rowMenuPage isEqualToString:MenuPageClub]){
            controller = [[ClubViewController alloc]initWithId:[User fetchLoginUser]? 1 : 0];
        }else if([aRow.rowMenuPage isEqualToString:MenuPageContest]){
            controller = [[ContestViewController alloc]init];
        }else if([aRow.rowMenuPage isEqualToString:MenuPageLiveChatList]){
            controller = [[LiveChatViewController alloc]init];
        }else if([aRow.rowMenuPage isEqualToString:MenuPageEventList]){
            controller = [[EventViewController alloc] init];
        }else if([aRow.rowMenuPage isEqualToString:MenuPageNotification]){
            controller = [[NotificationViewController alloc] init];
        }
        else{
            return;
        }
        [TheAppDelegate changeCenterController:controller];
    }
    [TheSettingsManager saveSelectedMenu:aRow.rowMenuPage];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}


-(void)doLogoutUser{
    [User logoutWithCompletion:^(NSString *message) {
//        [[FBSession activeSession] closeAndClearTokenInformation];
        self.logoutButton.userInteractionEnabled = YES;
        [self.view startLoader:NO disableUI:NO];
        [TheAppDelegate logoutSuccess];
        self.currentUser = nil;
        [self configureView];
        [self.myTableView setContentOffset:CGPointZero animated:YES];
    } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSUInteger statusCode = operation.response.statusCode;
        self.logoutButton.userInteractionEnabled = YES;
        [self.view startLoader:NO disableUI:NO];
        if(statusCode == StatusCodeExpired){
            [TheServerManager requestAccessTokenWithCompletion:^(NSString *accessToken) {
                [User logoutWithCompletion:^(NSString *message) {
//                    [[FBSession activeSession] closeAndClearTokenInformation];
                    self.logoutButton.userInteractionEnabled = YES;
                    [self.view startLoader:NO disableUI:NO];
                    [TheAppDelegate logoutSuccess];
                    self.currentUser = nil;
                    [self configureView];
                    [self.myTableView setContentOffset:CGPointZero animated:YES];
                    
                } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [TheAppDelegate writeLog:error.description];
                    NSUInteger statusCode = operation.response.statusCode;
                    if(statusCode == StatusCodeExpired){
                        [TheServerManager requestAccessTokenWithCompletion:^(NSString *accessToken) {
                            
                            if(numRequest<kRequestLimit){
                                numRequest++;
                                [self doLogoutUser];
                            }
                            else return;
                            
                        } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            [TheAppDelegate writeLog:error.description];
                        }];
                        
                        
                    }else if (statusCode == StatusCodeForbidden){
//                        [[FBSession activeSession] closeAndClearTokenInformation];
                        self.logoutButton.userInteractionEnabled = YES;
                        [self.view startLoader:NO disableUI:NO];
                        [TheAppDelegate logoutSuccess];
                        self.currentUser = nil;
                        [self configureView];
                        [self.myTableView setContentOffset:CGPointZero animated:YES];
                    }
                    else{
                        
                        NSUInteger statusCode = operation.response.statusCode;
                        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.responseData){
                            NSData *responseData = operation.responseData;
                            NSDictionary* json = [NSJSONSerialization
                                                  JSONObjectWithData:responseData //1
                                                  options:NSJSONReadingMutableLeaves
                                                  error:nil];
                            NSString *message = json[@"error"][@"messages"][0];
                            [self showLocalValidationError:message];
                        }
                    }
                    WRITE_LOG(operation.responseString);
                }];
            } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [TheAppDelegate writeLog:error.description];
            }];
        }else if (statusCode == StatusCodeForbidden){
//            [[FBSession activeSession] closeAndClearTokenInformation];
            self.logoutButton.userInteractionEnabled = YES;
            [self.view startLoader:NO disableUI:NO];
            [TheAppDelegate logoutSuccess];
            self.currentUser = nil;
            [self configureView];
            [self.myTableView setContentOffset:CGPointZero animated:YES];
        }
    }];
}


#pragma mark - IBActions
- (IBAction)logoutButtonTapped:(id)sender{
    [self.view startLoader:YES disableUI:NO];
    self.logoutButton.userInteractionEnabled = NO;
    if(![self connected]){
        [self showAlertWithMessage:@"Tidak ada koneksi internet"];
        return;
    }
    [self doLogoutUser];
}

- (IBAction)profileButtonTapped:(id)sender {

    _loggedInTableHeader.backgroundColor = HEXCOLOR(0xEEEEEEFF);
    [self performBlock:^{
        _loggedInTableHeader.backgroundColor = [UIColor whiteColor];
    } afterDelay:0.3];
    
    ProfileViewController *controller = [[ProfileViewController alloc] initWithUser:[User fetchLoginUser]];
    [TheAppDelegate changeCenterController:controller];
    [TheSettingsManager saveSelectedMenu:MenuPageProfile];
    
}

- (IBAction)signinButtonTapped:(id)sender {
    [TheAppDelegate goToLogin];
}

- (IBAction)gearButtonTapped:(id)sender {
}

- (IBAction)settingButtonTapped:(id)sender {
    SettingsViewController *vc = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:vc
                                         animated:YES];
}
- (IBAction)openDebugMenu:(id)sender {
    RightMenuViewController *vc = [[RightMenuViewController alloc] init];
    [self.navigationController pushViewController:vc
                                         animated:YES];
}


@end
