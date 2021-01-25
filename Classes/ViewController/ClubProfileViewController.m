//
//  ClubProfileViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/23/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ClubProfileViewController.h"
#import "HorizontalMenuHeader.h"
#import "ThreadListTableViewCell.h"
#import "ImageDetailViewController.h"
#import "ThreadDetailsViewController.h"
#import "ClubJoinDialogViewController.h"

@interface ClubProfileViewController ()<UIScrollViewDelegate, HorizontalMenuHeaderDelegate>

@property (nonatomic, assign) int allThreadsCurrentPage;
@property (nonatomic, assign) int popularThreadsCurrentPage;
@property (nonatomic, retain) NSMutableArray *allThreadsArray;
@property (nonatomic, retain) NSMutableArray *popularThreadsArray;
@property (nonatomic, assign) BOOL isReloading;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlayView;
@property (nonatomic, copy) NSString *currentClubId;

@end

@implementation ClubProfileViewController
@synthesize allThreadsCurrentPage, popularThreadsCurrentPage, currentClubMode, isReloading, allThreadsArray, popularThreadsArray, currentClub, membersButton, threadsButton, currentClubId, joinButton;

-(id)initWithClubId:(NSString *)clubId{
    if(self=[super init]){
        self.currentClubId = clubId;
        self.allThreadsArray = [NSMutableArray new];
        self.popularThreadsArray = [NSMutableArray new];
    }
    return self;
}

-(id)initWithClub:(Club *)club{
    if(self=[super init]){
        self.currentClub = club;
        self.allThreadsArray = [NSMutableArray new];
        self.popularThreadsArray = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentPageCode = MenuPageClubDetail;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self configureView];
    [self reloadData];
    [self getDataFromServer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(threadDeletedNotificationResponse:) name:kThreadDeleted object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(threadCreatedNotificationResponse:) name:kThreadCreated object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(threadUpdatedNotificationResponse:) name:kThreadUpdated object:nil];
    
    __weak typeof(self) weakSelf = self;
    [self.myTableView addPullToRefreshWithActionHandler:^{
        switch (weakSelf.currentClubMode) {
            case 0:{
                weakSelf.allThreadsCurrentPage = 0;
                [weakSelf.allThreadsArray removeAllObjects];
            }
                break;
            case 1:{
                weakSelf.popularThreadsCurrentPage = 0;
                [weakSelf.popularThreadsArray removeAllObjects];
            }
                break;
                
            default:
                break;
        }
        [weakSelf.myTableView reloadData]; // before load new content, clear the existing table list
        [weakSelf getDataFromServer]; // load new data
        [weakSelf.myTableView.pullToRefreshView stopAnimating]; // clear the animation
        weakSelf.myTableView.showsInfiniteScrolling = YES;
    }];
    
    // load more content when scroll to the bottom most
    [self.myTableView addInfiniteScrollingWithActionHandler:^{
        
        int myPage = weakSelf.currentClubMode == 0 ? weakSelf.allThreadsCurrentPage : weakSelf.popularThreadsCurrentPage;
        
        if(myPage && myPage > 0){
            [weakSelf getDataFromServer];
        }else{
            weakSelf.myTableView.showsInfiniteScrolling = NO;
            [weakSelf.myTableView.pullToRefreshView stopAnimating];
            [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        }
    }];
    

}

-(void)viewWillAppear:(BOOL)animated{
    self.pageObjectName = self.currentClub.club_name;
    [super viewWillAppear:animated];
}

-(void)getDataFromServer{
    if(!isReloading){
        
        NSString *clubId = currentClubId?currentClubId:currentClub.club_id;
        
        if(currentClubId){
            [Club getClubWithClubId:currentClubId withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Club *result) {
                self.currentClub = result;
                [self reloadData];
                
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                }
            }];
        }
        
        [self.myTableView startLoader:YES disableUI:NO];
        self.loadingOverlayView.hidden = NO;
        if(currentClubMode == ClubModeAllThreads){
            self.isReloading = YES;
            [Thread getAllThreadWithClubId:clubId andPageNumber:@(allThreadsCurrentPage) withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *resultsArray) {
                NSData *responseData = operation.HTTPRequestOperation.responseData;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
                int currentRow = (int)[self.allThreadsArray count];
                [self.allThreadsArray addObjectsFromArray:resultsArray];
                PaginationModel *currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
                self.allThreadsCurrentPage = currentPagination.nextPage;
                
                
                if(currentRow == 0){
                    [self.myTableView reloadData];
                }else{
                    [self reloadTableView:currentRow];
                }
                [self.myTableView startLoader:NO disableUI:NO];
                self.loadingOverlayView.hidden = YES;
                [self.myTableView.pullToRefreshView stopAnimating];
                [self.myTableView.infiniteScrollingView stopAnimating];
                self.isReloading = NO;
                [self reloadData];

            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [self.myTableView.pullToRefreshView stopAnimating];
                [self.myTableView.infiniteScrollingView stopAnimating];
                self.isReloading = NO;
                [self.myTableView startLoader:NO disableUI:NO];
                
                NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                }
            }];
            
            
        }else{
            self.isReloading = YES;
            [Thread getPopularThreadWithClubId:clubId andPageNumber:@(popularThreadsCurrentPage) withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *resultsArray) {
                NSData *responseData = operation.HTTPRequestOperation.responseData;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
                int currentRow = (int)[self.popularThreadsArray count];
                [self.popularThreadsArray addObjectsFromArray:resultsArray];
                PaginationModel *currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
                self.popularThreadsCurrentPage = currentPagination.nextPage;
                
                
                if(currentRow == 0){
                    [self.myTableView reloadData];
                }else{
                    [self reloadTableView:currentRow];
                }
                [self.myTableView startLoader:NO disableUI:NO];
                self.loadingOverlayView.hidden = YES;
                [self.myTableView.pullToRefreshView stopAnimating];
                [self.myTableView.infiniteScrollingView stopAnimating];
                self.isReloading = NO;
                [self reloadData];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [self.myTableView.pullToRefreshView stopAnimating];
                [self.myTableView.infiniteScrollingView stopAnimating];
                self.isReloading = NO;
                [self.myTableView startLoader:NO disableUI:NO];
                
                NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                }
            }];
        }
    }
}

- (void)reloadTableView:(int)startingRow;
{
    // the last row after added new items
    int endingRow = currentClubMode == ClubModeAllThreads ? (int)allThreadsArray.count : (int)popularThreadsArray.count;
    

    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (; startingRow < endingRow; startingRow++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:startingRow inSection:0]];
    }
    
    [self.myTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
}

-(void)configureView{
    [self.myTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];


    [self.myTableView registerNib:[UINib nibWithNibName:[HorizontalMenuHeader reuseIdentifier] bundle:nil] forHeaderFooterViewReuseIdentifier:[HorizontalMenuHeader reuseIdentifier]];
    [self.myTableView registerNib:[UINib nibWithNibName:[ThreadListTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[ThreadListTableViewCell reuseIdentifier]];
    
    self.clubImageView.layer.cornerRadius = CGRectGetHeight(self.clubImageView.frame)/2;
    self.clubImageView.layer.masksToBounds = YES;

    
    UIButton *lButton = [TheAppDelegate createButtonWithTitle:nil imageName:@"leftArrow" highlightedImageName:@"leftArrowHighlight" forLeftButton:YES];
    [lButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    self.navigationItem.leftBarButtonItem = backButton;

}

-(void)reloadData{

    [self.clubCoverImageView sd_setImageWithURL:[NSURL URLWithString:currentClub.club_avatar_url]];
    [self.clubImageView setImage:nil];
    [self.clubImageView sd_setImageWithURL:[NSURL URLWithString:currentClub.club_cover_image_url]];
    self.clubNameLabel.text = currentClub.club_name;
    
    [membersButton setTitle:[NSString stringWithFormat:@"%@ anggota",currentClub.club_stats.stats_member] forState:UIControlStateNormal];
    [threadsButton setTitle:[NSString stringWithFormat:@"%@ threads",currentClub.club_stats.stats_thread] forState:UIControlStateNormal];
    
    if([self.currentClub.club_membership.membership_joined boolValue]){
        [self.joinButton setImage:[UIImage imageNamed:@"minicheck"] forState:UIControlStateNormal];
        [self.joinButton setImageEdgeInsets:UIEdgeInsetsMake(0, -7, 0, 0)];
        [self.joinButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        
        [self.joinButton setTitle:@"Joined" forState:UIControlStateNormal];
        [self.joinButton.titleLabel setTextColor:[UIColor whiteColor]];
        [self.joinButton setBackgroundColor:HEXCOLOR(0x1563f3FF)];
        self.joinButton.layer.borderColor = [HEXCOLOR(0x1563f3FF) CGColor];
        
        UIButton *rButton = [TheAppDelegate createButtonWithTitle:nil imageName:@"btnReport" highlightedImageName:@"btnReportHighlight" forLeftButton:NO];
        [rButton addTarget:self action:@selector(clubMoreButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithCustomView:rButton];
        self.navigationItem.rightBarButtonItem = moreButton;
    }else{
        [self.joinButton setImage:nil forState:UIControlStateNormal];
        [self.joinButton setTitle:@"Join" forState:UIControlStateNormal];
        [self.joinButton.titleLabel setTextColor:[UIColor whiteColor]];
        [self.joinButton setBackgroundColor:[UIColor clearColor]];
        self.joinButton.layer.borderColor = [UIColor whiteColor].CGColor;

        self.navigationItem.rightBarButtonItem = nil;
    }
    
    self.joinButton.layer.cornerRadius = 2.0;
    self.joinButton.layer.masksToBounds = YES;
    self.joinButton.layer.borderWidth = 1.0;
    
    [self.myTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PostDialogViewController delegate
-(void)dialogDidCancel:(PostDialogViewController *)dialog{
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

-(void)dialogDidPost:(PostDialogViewController *)dialog withString:(NSString *)content{
    if([dialog.title isEqualToString:@"report club"]){
//        [Club reportUserThreadsWithId:self.currentThread.thread_id andMessage:content withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *resultsArray) {
//            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
//                [self showAlertWithMessage:@"Laporan berhasil dikirimkan"];
//                [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
//            }];
//        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//            [self showAlertWithMessage:@"Laporan gagal dikirim"];
//        }];
    }
}

#pragma mark - IBActions
- (IBAction)joinButtonTapped:(UIButton *)sender{
    
    if ([sender.titleLabel.text isEqualToString:@"Join"]) {
    
        [self.view startLoader:YES disableUI:NO];
        [Club joinClubWithID:self.currentClub.club_id andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result){
            [self.view startLoader:NO disableUI:NO];
            self.currentClub.club_membership.membership_joined = @(YES);
            [self getDataFromServer];
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self.view startLoader:NO disableUI:NO];
            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
            }
        }];
        
    }else{
    
        NSString *title = [NSString stringWithFormat:@"Tinggalkan %@",currentClub.club_name];
        NSString *msg = [NSString stringWithFormat:@"Kamu yakin mau meninggalkan %@ ? :'(", currentClub.club_name];
        
        [UIAlertView showWithTitle:title
                           message:msg
                 cancelButtonTitle:@"Tidak"
                 otherButtonTitles:@[@"Ya"]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex != [alertView cancelButtonIndex]) {
                                  
                                  [self.view startLoader:YES disableUI:NO];
                                  [Club leaveClubWithID:self.currentClub.club_id withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                                      [self.view startLoader:NO disableUI:NO];
                                      self.currentClub.club_membership.membership_joined = @(NO);
                                      [self reloadData];
                                      
                                  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                      [self.view startLoader:NO disableUI:NO];
                                      
                                      NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                                      if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                                          
                                          NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                                          [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                                      }
                                  }];
                                  
                              }
                          }];
    }
    
}

- (IBAction)membersButtonTapped:(id)sender{
    
}

- (IBAction)threadsButtonTapped:(id)sender{
    
}

- (IBAction)avatarTapped:(id)sender {
    ImageDetailViewController *vc = [[ImageDetailViewController alloc] initWithImageURL:self.currentClub.club_user.user_avatar.avatar_original];
    [self presentViewController:vc animated:YES completion:nil];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewCell delegate
////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return currentClubMode == ClubModeAllThreads ? allThreadsArray.count : popularThreadsArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90.0;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ThreadListTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:[ThreadListTableViewCell reuseIdentifier]];
    Thread *aThread = currentClubMode == ClubModeAllThreads ? allThreadsArray[indexPath.row] : popularThreadsArray[indexPath.row];
    [aCell fillWithThread:aThread];
    return aCell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    HorizontalMenuHeader * headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[HorizontalMenuHeader reuseIdentifier]];
    CGRect destFrame = headerView.frame;
    destFrame.size.width = self.myTableView.frame.size.width;
    headerView.frame = destFrame;
    headerView.selectedIndex = currentClubMode;
    [headerView setupMenuWithArray:@[@"SEMUA THREADS", @"TERPOPULER"]];
    headerView.delegate = self;
    return headerView;
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 37.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Thread *aThread = currentClubMode == ClubModeAllThreads ? allThreadsArray[indexPath.row] : popularThreadsArray[indexPath.row];
    NSLog(@"restriction open?: %d",[aThread.thread_restriction.thread_restriction_open boolValue]);
    
    if([aThread.thread_restriction.thread_restriction_open boolValue]) {
        ThreadDetailsViewController *vc = [[ThreadDetailsViewController alloc] initWithThread:aThread];

        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self showAlertWithMessage:@"Anda harus bergabung ke Klub ini untuk mengakses Thread."];
        return;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    

    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark - HeaderDelegate
-(void)didSelectButtonAtIndex:(int)idx{
    self.currentClubMode = idx;
    self.isReloading = NO;
    BOOL shouldRequestData = NO;
    switch (self.currentClubMode) {
        case ClubModeAllThreads:{
            if (self.allThreadsArray.count == 0) {
                shouldRequestData = YES;
            }
        }
            break;
        case ClubModePopular:{
            if (self.popularThreadsArray.count == 0) {
                shouldRequestData = YES;
            }
        }
            break;
        default:
            break;
    }
    if (shouldRequestData) {
        [self getDataFromServer];
    }else{
        [self.myTableView reloadData];
    }
}

-(void)clubMoreButtonTapped{
    [self moreButtonTappedForClub:self.currentClub];
}

#pragma mark - Notification Listener
-(void)threadDeletedNotificationResponse:(NSNotification *)notif{
    [self.myTableView triggerPullToRefresh];
}

-(void)threadUpdatedNotificationResponse:(NSNotification *)notif{
    [self.myTableView triggerPullToRefresh];
}

-(void)threadCreatedNotificationResponse:(NSNotification *)notif{
    [self.myTableView triggerPullToRefresh];
    if(notif.object && [notif.object isKindOfClass:[Thread class]])
    {
        Thread *aThread = notif.object;
        ThreadDetailsViewController *vc = [[ThreadDetailsViewController alloc] initWithThread:aThread];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end

