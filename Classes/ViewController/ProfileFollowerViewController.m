//
//  ProfileFollowerViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/23/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "UserFollowTableViewCell.h"
#import "ProfileFollowerViewController.h"
#import "AttributedLabelCustomHeader.h"
#import "ImageDetailViewController.h"

@interface ProfileFollowerViewController ()<UserFollowTableViewCellDelegate>

@property (nonatomic, retain) NSMutableArray *usersArray;
@property (nonatomic, retain) PaginationModel *currentPagination;
@property (nonatomic, assign) FollowMode currentFollowMode;
@property (nonatomic, assign) BOOL isReloading;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlayView;
@property (nonatomic, assign) int currentPage;

@end

@implementation ProfileFollowerViewController
@synthesize currentUser, userImageView, userNameLabel, delegate;
@synthesize usersArray, currentPagination, currentPage, currentFollowMode, isReloading, isTableEmpty;



-(id)initWithUser:(User *)user withMode:(FollowMode)mode{
    if(self=[super init]){
        self.currentUser = user;
        self.usersArray = [NSMutableArray new];
        self.currentFollowMode = mode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self configureView];
    [self reloadData];
    [self getDataFromServer];
    

    __weak typeof(self) weakSelf = self;
    [self.myTableView addPullToRefreshWithActionHandler:^{
        weakSelf.currentPage = 0;
        [weakSelf.usersArray removeAllObjects];
        [weakSelf.myTableView reloadData]; // before load new content, clear the existing table list
        [weakSelf getDataFromServer]; // load new data
        [weakSelf.myTableView.pullToRefreshView stopAnimating]; // clear the animation
        weakSelf.myTableView.showsInfiniteScrolling = YES;
    }];
    
    // load more content when scroll to the bottom most
    [self.myTableView addInfiniteScrollingWithActionHandler:^{
        if(weakSelf.currentPage && weakSelf.currentPage > 0){
            [weakSelf getDataFromServer];
        }else{
            weakSelf.myTableView.showsInfiniteScrolling = NO;
            [weakSelf.myTableView.pullToRefreshView stopAnimating];
            [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        }
    }];

    
}

-(void)getDataFromServer{
    if(!isReloading){
        [self.myTableView startLoader:YES disableUI:YES];
        self.loadingOverlayView.hidden = NO;
        if(currentFollowMode == FollowModeFollower){
            self.isReloading = YES;
            [User getUserFollowersForUserId:currentUser.user_id withAccesToken:ACCESS_TOKEN() andPageNumber:@(currentPage) success:^(RKObjectRequestOperation *operation, NSArray *objectArray) {
                NSData *responseData = operation.HTTPRequestOperation.responseData;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
                int currentRow = (int)[self.usersArray count];
                [self.usersArray addObjectsFromArray:objectArray];
                self.currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
                self.currentPage = currentPagination.nextPage;
                
                
                if(currentRow == 0){
                    self.isTableEmpty = self.usersArray.count == 0;
                    [self.myTableView reloadData];
                }else{
                    [self reloadTableView:currentRow];
                }
                [self.myTableView startLoader:NO disableUI:NO];
                self.loadingOverlayView.hidden = YES;
                [self.myTableView.pullToRefreshView stopAnimating];
                [self.myTableView.infiniteScrollingView stopAnimating];
                self.isReloading = NO;
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                WRITE_LOG(error.localizedDescription);
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
            
            
            
        }else if(currentFollowMode == FollowModeFollowing){
            self.isReloading = YES;
            [User getUserFollowingForUserID:currentUser.user_id withAccesToken:ACCESS_TOKEN() andPageNumber:@(currentPage) success:^(RKObjectRequestOperation *operation, NSArray *objectArray) {
                NSData *responseData = operation.HTTPRequestOperation.responseData;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
                int currentRow = (int)[self.usersArray count];
                [self.usersArray addObjectsFromArray:objectArray];
                self.currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
                self.currentPage = currentPagination.nextPage;
                
                if(currentRow == 0){
                    self.isTableEmpty = self.usersArray.count == 0;
                    [self.myTableView reloadData];
                }else{
                    [self reloadTableView:currentRow];
                }
                [self.myTableView startLoader:NO disableUI:NO];
                self.loadingOverlayView.hidden = YES;
                [self.myTableView.pullToRefreshView stopAnimating];
                [self.myTableView.infiniteScrollingView stopAnimating];
                self.isReloading = NO;

            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                WRITE_LOG(error.localizedDescription);
                [self.myTableView.pullToRefreshView stopAnimating];
                [self.myTableView.infiniteScrollingView stopAnimating];
                self.isReloading = NO;
                [self.myTableView startLoader:NO disableUI:NO];
                self.loadingOverlayView.hidden = YES;
                
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
    int endingRow = (int)self.usersArray.count;
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (; startingRow < endingRow; startingRow++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:startingRow inSection:0]];
    }
    
    [self.myTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
}

-(void)configureView{
    [self.myTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    if([currentUser.user_id isEqualToString: CURRENT_USER_ID()]){
        self.editButton.hidden = YES;
    }else{
        self.editButton.hidden = NO;
        [self.editButton setTitle:@"follow" forState:UIControlStateNormal];
    }
   [self.myTableView registerNib:[UINib nibWithNibName:[UserFollowTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[UserFollowTableViewCell reuseIdentifier]];
    [self.myTableView registerNib:[UINib nibWithNibName:[AttributedLabelCustomHeader reuseIdentifier] bundle:nil] forHeaderFooterViewReuseIdentifier:[AttributedLabelCustomHeader reuseIdentifier]];
    [self.myTableView registerNib:[UINib nibWithNibName:[EmptyLabelTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[EmptyLabelTableViewCell reuseIdentifier]];
    self.userImageView.layer.cornerRadius = CGRectGetHeight(self.userImageView.frame)/2;
    self.userImageView.layer.masksToBounds = YES;
    [TheInterfaceManager addBorderViewForImageView:self.userImageView withBorderWidth:5.0 andBorderColor:nil];
    UIButton *lButton = [TheAppDelegate createButtonWithTitle:nil imageName:@"leftArrow" highlightedImageName:@"leftArrowHighlight" forLeftButton:YES];
    [lButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.title = @"Profile";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:InterfaceStr(@"default_font_bold") size:17]}];
    
    self.editButton.layer.cornerRadius = 1.0;
    self.editButton.layer.masksToBounds = YES;
    self.editButton.layer.borderColor = [self.editButton.titleLabel.textColor CGColor];
    self.editButton.layer.borderWidth = 1.0;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [self.userCoverImageView setUserInteractionEnabled:YES];
    [self.userCoverImageView addGestureRecognizer:tapGestureRecognizer];
    
    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped:)];
    [self.userImageView setUserInteractionEnabled:YES];
    [self.userImageView addGestureRecognizer:tapGestureRecognizer2];
    
}

- (void)avatarTapped:(UITapGestureRecognizer *)recognizer {
    ImageDetailViewController *vc = [[ImageDetailViewController alloc] initWithImageURL:self.currentUser.user_avatar.avatar_original];
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)backgroundTapped:(UITapGestureRecognizer *)recognizer{
    ImageDetailViewController *vc = [[ImageDetailViewController alloc] initWithImageURL:self.currentUser.user_cover_image.cover_image_original];

    [self presentViewController:vc animated:YES completion:nil];
}

-(void)reloadData{
    [self.userCoverImageView sd_setImageWithURL:[NSURL URLWithString:currentUser.user_cover_image.cover_image_640]];
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:currentUser.user_avatar.avatar_thumbnail]];
    self.userNameLabel.text = currentUser.user_name;
    [self.myTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewCell delegate
////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.isTableEmpty){
        return 1;
    }
    return usersArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isTableEmpty){
        return 57.0;
    }
    return 44.0;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.isTableEmpty){
        EmptyLabelTableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:[EmptyLabelTableViewCell reuseIdentifier]];
        
        emptyCell.emptyLabel.text = self.currentFollowMode == FollowModeFollower ? [NSString stringWithFormat:@"%@ belum memiliki follower.",[currentUser.user_id isEqualToString:CURRENT_USER_ID()]? @"Anda" : currentUser.user_name] : [NSString stringWithFormat:@"%@ belum mengikuti siapapun.",[currentUser.user_id isEqualToString:CURRENT_USER_ID()]? @"Anda" : currentUser.user_name];
        return emptyCell;
    }
    
    User *aUser = [self.usersArray objectAtIndex:indexPath.row];
    UserFollowTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:[UserFollowTableViewCell reuseIdentifier]];
    [aCell setCanFollow:YES];
    aCell.delegate = self;
    [aCell fillCellWithUser:aUser];
    return aCell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(isTableEmpty)
        return nil;
    AttributedLabelCustomHeader *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[AttributedLabelCustomHeader reuseIdentifier]];
    [headerView fillWithFormattedString:[NSString stringWithFormat:@"<b>%@</b> %@",currentUser.user_name, currentFollowMode == FollowModeFollowing ? @"Following" : @"Followers"]];
   
    return headerView;
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(isTableEmpty)
        return 0;
    return 40.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(isTableEmpty)
        return;
    User *aUser = [usersArray objectAtIndex:indexPath.row];
    ProfileViewController *vc = [[ProfileViewController alloc] initWithUser:aUser];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isTableEmpty){
        self.myTableView.backgroundColor = [UIColor clearColor];
        self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }else{
        self.myTableView.backgroundColor = [UIColor whiteColor];
        self.myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UserFollowCell delegate
-(void)successToFollowOrUnfollowWithUser:(User *)obj{
    
    if([obj.user_socialization.socialization_following boolValue]){
        //unfollow
        if([delegate respondsToSelector:@selector(didUnfollowUser:)]){
            [delegate didUnfollowUser:obj];
        }
    }else{
        //follow
        if([delegate respondsToSelector:@selector(didFollowUser:)]){
            [delegate didFollowUser:obj];
        }
    }
}

-(void)failedToFollowOrUnfollowWithErrorString:(NSString *)errorString{
    [self showLocalValidationError:errorString];
}

@end

