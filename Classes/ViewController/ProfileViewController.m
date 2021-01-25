//
//  ProfileViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/23/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileCustomHeader.h"
#import "ProfileVideoTableViewCell.h"
#import "TimelinePlaylistTableViewCell.h"
#import "ProfileEditViewController.h"
#import "ProfileActivityTableViewCell.h"
#import "ProfileFollowerViewController.h"
#import "ImageDetailViewController.h"
#import "PlaylistDetailsViewController.h"
#import "UploadVideoDetailViewController.h"
#import <AWSS3/AWSS3.h>
#import "UploadVideoViewController.h"

@interface ProfileViewController ()<ProfileCustomHeaderDelegate, TimelinePlaylistTableViewCellDelegate, ProfileVideoTableViewCellDelegate, ProfileFollowerViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) int videoCurrentPage;
@property (nonatomic, assign) int playlistCurrentPage;
@property (nonatomic, assign) int activityCurrentPage;
@property (nonatomic, assign) int userUploadCurrentPage;
@property (nonatomic, retain) NSMutableArray *clipsArray;
@property (nonatomic, retain) NSMutableArray *playlistsArray;
@property (nonatomic, retain) NSMutableArray *activitiesArray;
@property (nonatomic, retain) NSMutableArray *userUploadsArray;
@property (nonatomic, retain) PaginationModel *currentPagination;

@property (nonatomic, assign) BOOL isReloading;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlayView;
@property (copy, nonatomic) NSString *currentUserId;
@property (nonatomic, retain) UserUploadsModel *theUUM;
@property (nonatomic, retain) AWSS3TransferUtilityUploadTask *uploadTask;
@property (nonatomic, retain) AWSS3TransferUtilityUploadExpression *expression;
@property (nonatomic, copy) AWSS3TransferUtilityUploadCompletionHandlerBlock completionHandler;

@end

@implementation ProfileViewController
@synthesize currentUser, userImageView, userNameLabel, editButton, followersCountLabel, followingCountLabel;
@synthesize videoCurrentPage, playlistCurrentPage, activityCurrentPage, currentPagination, currentProfileMode, isReloading, currentClip, currentUserId, userUploadsArray, userUploadCurrentPage;
@synthesize progressCell, progressView, totalProgressLabel, uploadTask;
@synthesize expression, completionHandler;
@synthesize userNameButton;

-(id)initWithUserId:(NSString *)userId{

    if(self=[super init]){
        self.currentUserId = userId;
        self.clipsArray = [NSMutableArray array];
        self.playlistsArray = [NSMutableArray array];
        self.activitiesArray = [NSMutableArray array];
        self.userUploadsArray = [NSMutableArray array];
        self.currentProfileMode = ProfileModeVideo;
    }
    return self;
    
}

-(id)initWithUser:(User *)user{
    if(self=[super init]){
        self.currentUser = user;
        self.clipsArray = [NSMutableArray array];
        self.playlistsArray = [NSMutableArray array];
        self.activitiesArray = [NSMutableArray array];
        self.userUploadsArray = [NSMutableArray array];
        self.currentProfileMode = ProfileModeVideo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self configureView];
    [self reloadData];
    [self getDataFromServer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileUpdated) name:kProfileUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:kRefreshProfilePage object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUploadVideoMetaFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadVideoToS3:) name:kUploadVideoMetaFinished object:nil];
    
    __weak typeof(self) weakSelf = self;
    [self.myTableView addPullToRefreshWithActionHandler:^{
        switch (weakSelf.currentProfileMode) {
            case ProfileModeVideo:{
                weakSelf.videoCurrentPage = 0;
                [weakSelf.clipsArray removeAllObjects];
            }
                break;
            case ProfileModePlaylist:{
                weakSelf.playlistCurrentPage = 0;
                [weakSelf.playlistsArray removeAllObjects];
            }
                break;
            case ProfileModeActivity:{
                weakSelf.activityCurrentPage = 0;
                [weakSelf.activitiesArray removeAllObjects];
            }
                break;
            case ProfileModeModerasi:{
                weakSelf.userUploadCurrentPage = 0;
                [weakSelf.userUploadsArray removeAllObjects];
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
        
        int myPage = 0;
        
        if(weakSelf.currentProfileMode == ProfileModeVideo)
            myPage = weakSelf.videoCurrentPage;
        else if(weakSelf.currentProfileMode == ProfileModePlaylist)
            myPage = weakSelf.playlistCurrentPage;
        else if(weakSelf.currentProfileMode == ProfileModeActivity)
            myPage = weakSelf.activityCurrentPage;
        else if(weakSelf.currentProfileMode == ProfileModeModerasi)
            myPage = weakSelf.userUploadCurrentPage;
        
        if(myPage && myPage > 0){
            [weakSelf getDataFromServer];
        }else{
            weakSelf.myTableView.showsInfiniteScrolling = NO;
            [weakSelf.myTableView.pullToRefreshView stopAnimating];
            [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        }
    }];

    
    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [transferUtility
     enumerateToAssignBlocksForUploadTask:^(AWSS3TransferUtilityUploadTask *uploadTaskLah, __autoreleasing AWSS3TransferUtilityUploadProgressBlock *uploadProgressBlockReference, __autoreleasing AWSS3TransferUtilityUploadCompletionHandlerBlock *completionHandlerReference) {
         if (uploadTaskLah.taskIdentifier == TheSettingsManager.uploadTaskIdentifier) {
              __weak typeof(self) welf = self;
             
             if (!self.expression.uploadProgress) {
                 self.expression = [AWSS3TransferUtilityUploadExpression new];
                 expression.uploadProgress = ^(AWSS3TransferUtilityTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         // Do something e.g. Update a progress bar.
                         double progress = (double)totalBytesSent / (double)totalBytesExpectedToSend;
                         
                         NSLog(@"UploadTask progress: %lf", progress);
                         
                         int in100 = progress*100;
                         welf.totalProgressLabel.text = [NSString stringWithFormat:@"Uploading %zd%%", in100];
                         [welf.progressView setProgress: progress];
                         if(in100 % 10 == 0){
                             welf.theUUM.user_upload_percentage = progress;
                             [TheDatabaseManager updateUserUploadsModel:welf.theUUM];
                         }
                         
                     });
                 };
                 
             }
             *uploadProgressBlockReference = self.expression.uploadProgress;
             completionHandler = self.completionHandler;

         }
//         NSLog(@"%lu", (unsigned long)uploadTask.taskIdentifier);
         
     }
     downloadTask:^(AWSS3TransferUtilityDownloadTask *downloadTask, __autoreleasing AWSS3TransferUtilityDownloadProgressBlock *downloadProgressBlockReference, __autoreleasing AWSS3TransferUtilityDownloadCompletionHandlerBlock *completionHandlerReference) {
    
     }];

}

-(void)viewWillAppear:(BOOL)animated{
    self.pageObjectName = self.currentUser.user_username;
    [super viewWillAppear:animated];
    [self getUserProfileFromServer];
}

-(void)refreshTableView{
    switch (self.currentProfileMode) {
        case ProfileModeVideo:{
            self.videoCurrentPage = 0;
            [self.clipsArray removeAllObjects];
        }
            break;
        case ProfileModePlaylist:{
            self.playlistCurrentPage = 0;
            [self.playlistsArray removeAllObjects];
        }
            break;
        case ProfileModeActivity:{
            self.activityCurrentPage = 0;
            [self.activitiesArray removeAllObjects];
        }
            break;
        case ProfileModeModerasi:{
            self.userUploadCurrentPage = 0;
            [self.userUploadsArray removeAllObjects];
        }
            break;
        default:
            break;
    }

    [self.myTableView reloadData]; // before load new content, clear the existing table list
    [self getDataFromServer]; // load new data
    [self.myTableView.pullToRefreshView stopAnimating]; // clear the animation
    self.myTableView.showsInfiniteScrolling = YES;

}

-(void)getUserProfileFromServer{
    [self.parallaxContainerView startLoader:YES disableUI:NO];
    
    NSString *currUserId = currentUserId?currentUserId:self.currentUser.user_id;
    
    if([currUserId isEqualToString:CURRENT_USER_ID()]){
        self.currentUser = CURRENT_USER();
        [self reloadData];
        [User getShowUserProfileWithAccesToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, User *user) {
            self.currentUser = user;
            [self configureView];
            [self reloadData];
            [self.parallaxContainerView startLoader:NO disableUI:NO];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self.parallaxContainerView startLoader:NO disableUI:NO];
            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
            }
        }];
    }else{
        [User getShowUserWithId:currUserId andAccesToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, User *user) {
            self.currentUser = user;
            [self configureView];
            [self reloadData];
            [self.parallaxContainerView startLoader:NO disableUI:NO];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self.parallaxContainerView startLoader:NO disableUI:NO];
            
            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
            }
        }];
    }
}

-(void)getDataFromServer{
    
    NSString *currUserId = currentUserId?currentUserId:self.currentUser.user_id;
    
    if(!isReloading){
        [self.myTableView startLoader:YES disableUI:NO];
        self.loadingOverlayView.hidden = NO;
        if(currentProfileMode == ProfileModeVideo){
            self.isReloading = YES;
            [Clip getClipWithUserId:currUserId andPageNumber:@(videoCurrentPage) withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *clipsArray) {
                NSData *responseData = operation.HTTPRequestOperation.responseData;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
                int currentRow = (int)[self.clipsArray count];
                [self.clipsArray addObjectsFromArray:clipsArray];
                self.currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
                self.videoCurrentPage = currentPagination.nextPage;
                
                
                if(currentRow == 0){
                    self.isTableEmpty = self.clipsArray.count == 0;
                    [self.myTableView reloadData];
                }else{
                    [self reloadTableView:currentRow];
                }
                [self.myTableView startLoader:NO disableUI:NO];
                self.loadingOverlayView.hidden = YES;
                [self.myTableView.pullToRefreshView stopAnimating];
                [self.myTableView.infiniteScrollingView stopAnimating];
                self.isReloading = NO;
                
                if(currentUserId){
                    [self reloadData];
                }
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
            
        }else if(currentProfileMode == ProfileModePlaylist){
            self.isReloading = YES;
            [Playlist getAllPlaylistWithUserId:currUserId andPageNumber:@(playlistCurrentPage) withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, NSArray *objectArray) {
                NSData *responseData = operation.HTTPRequestOperation.responseData;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
                int currentRow = (int)[self.playlistsArray count];
                [self.playlistsArray addObjectsFromArray:objectArray];
                self.currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
                self.playlistCurrentPage = currentPagination.nextPage;
                
                if(currentRow == 0){
                    if(self.playlistsArray.count > 0){
                        self.isTableEmpty = NO;
                    }
                    else{
                        self.isTableEmpty =YES;
                    }
                    [self.myTableView reloadData];
                }else{
                    [self reloadTableView:currentRow];
                }
                [self.myTableView startLoader:NO disableUI:NO];
                self.loadingOverlayView.hidden = YES;
                [self.myTableView.pullToRefreshView stopAnimating];
                [self.myTableView.infiniteScrollingView stopAnimating];
                self.isReloading = NO;
                
                if(currentUserId){
                    [self reloadData];
                }
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
        }else if (currentProfileMode == ProfileModeActivity){
            self.isReloading = YES;
            [Activity getAllActivitiesWithUserId:currUserId withAccessToken:ACCESS_TOKEN() andPageNumber:@(activityCurrentPage) success:^(RKObjectRequestOperation *operation, NSArray *objectArray) {
                NSData *responseData = operation.HTTPRequestOperation.responseData;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
                int currentRow = (int)[self.activitiesArray count];
                [self.activitiesArray addObjectsFromArray:objectArray];
                self.currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
                self.activityCurrentPage = currentPagination.nextPage;
                
                
                if(currentRow == 0){
                    if(self.activitiesArray.count > 0){
                        self.isTableEmpty = NO;
                        
                    }
                    else{
                        self.isTableEmpty =YES;
                    }
                    [self.myTableView reloadData];
                }else{
                    [self reloadTableView:currentRow];
                }
                [self.myTableView.pullToRefreshView stopAnimating];
                [self.myTableView.infiniteScrollingView stopAnimating];
                self.isReloading = NO;
                [self.myTableView startLoader:NO disableUI:NO];
                self.loadingOverlayView.hidden = YES;
                
                if(currentUserId){
                    [self reloadData];
                }
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
        }else if (currentProfileMode == ProfileModeModerasi){
            self.isReloading = YES;
            [UserUploads getAllUserUploadsWithAccessToken:ACCESS_TOKEN()
                                               andPageNum:@(userUploadCurrentPage)
                                                  success:^(RKObjectRequestOperation *operation, NSArray *resultsArray) {
                
                NSData *responseData = operation.HTTPRequestOperation.responseData;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
                int currentRow = (int)[self.userUploadsArray count];
                [self.userUploadsArray addObjectsFromArray:resultsArray];
                self.currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
                self.userUploadCurrentPage = currentPagination.nextPage;
                
                if(currentRow == 0){
                    if(self.userUploadsArray.count > 0){
                        self.isTableEmpty = NO;   
                    }
                    else{
                        self.isTableEmpty =YES;
                    }
                    [self.myTableView reloadData];
                }else{
                    [self reloadTableView:currentRow];
                }
                [self.myTableView.pullToRefreshView stopAnimating];
                [self.myTableView.infiniteScrollingView stopAnimating];
                self.isReloading = NO;
                [self.myTableView startLoader:NO disableUI:NO];
                self.loadingOverlayView.hidden = YES;
                
                if(currentUserId){
                    [self reloadData];
                }
                
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
    int endingRow = 0;
    if(self.currentProfileMode == ProfileModeVideo)
        endingRow = (int)[self.clipsArray count];
    else if(self.currentProfileMode == ProfileModePlaylist)
        endingRow = (int)[self.playlistsArray count];
    else if(self.currentProfileMode == ProfileModeActivity)
        endingRow = (int)[self.activitiesArray count];
    else if(self.currentProfileMode == ProfileModeModerasi)
        endingRow = (int)[self.userUploadsArray count];

    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (; startingRow < endingRow; startingRow++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:startingRow inSection:0]];
    }
    
    [self.myTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
}

-(void)configureView{
    self.currentPageCode = MenuPageProfile;
    [self.myTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    if([currentUser.user_id isEqualToString: CURRENT_USER_ID()]){
        [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
        self.editButton.layer.borderColor = [self.editButton.titleLabel.textColor CGColor];
    }else{
        if([self.currentUser.user_socialization.socialization_following boolValue]){
            [self.editButton setImage:[UIImage imageNamed:@"minicheck"] forState:UIControlStateNormal];
            [self.editButton setImageEdgeInsets:UIEdgeInsetsMake(0, -7, 0, 0)];
            [self.editButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
            [self.editButton setTitle:@"Following" forState:UIControlStateNormal];
            [self.editButton setBackgroundColor:HEXCOLOR(0x1563f3FF)];
            self.editButton.layer.borderColor = HEXCOLOR(0x1563f3FF).CGColor;
            
            
        }else{
            [self.editButton setImage:nil forState:UIControlStateNormal];
            [self.editButton setTitle:@"Follow" forState:UIControlStateNormal];
            [self.editButton setBackgroundColor:[UIColor clearColor]];
            self.editButton.layer.borderColor = [self.editButton.titleLabel.textColor CGColor];
        }
    }
    [self.myTableView registerNib:[UINib nibWithNibName:[ProfileCustomHeader reuseIdentifier] bundle:nil] forHeaderFooterViewReuseIdentifier:[ProfileCustomHeader reuseIdentifier]];
    [self.myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self.myTableView registerNib:[UINib nibWithNibName:[ProfileVideoTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[ProfileVideoTableViewCell reuseIdentifier]];
    [self.myTableView registerNib:[UINib nibWithNibName:[TimelinePlaylistTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[TimelinePlaylistTableViewCell reuseIdentifier]];
    [self.myTableView registerNib:[UINib nibWithNibName:[ProfileActivityTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[ProfileActivityTableViewCell reuseIdentifier]];
    [self.myTableView registerNib:[UINib nibWithNibName:[EmptyLabelTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[EmptyLabelTableViewCell reuseIdentifier]];
    [self.myTableView registerNib:[UINib nibWithNibName:[UploadClipTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[UploadClipTableViewCell reuseIdentifier]];
    
    self.userImageView.layer.cornerRadius = CGRectGetHeight(self.userImageView.frame)/2;
    self.userImageView.layer.masksToBounds = YES;
    [TheInterfaceManager addBorderViewForImageView:self.userImageView withBorderWidth:5.0 andBorderColor:nil];
    
    self.editButton.layer.cornerRadius = 2.0;
    self.editButton.layer.masksToBounds = YES;
    self.editButton.layer.borderWidth = 1.0;
    
    [self.viewCoverButton setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.85] forState:UIControlStateHighlighted];
    [self.viewCoverButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIButton *lButton = [TheAppDelegate createButtonWithTitle:nil imageName:@"leftArrow" highlightedImageName:@"leftArrowHighlight" forLeftButton:YES];
    [lButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.title = self.currentUser.user_name;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:InterfaceStr(@"default_font_bold") size:17]}];
}

- (IBAction)viewCoverTapped:(id)sender{
    ImageDetailViewController *vc = [[ImageDetailViewController alloc] initWithImageURL:self.currentUser.user_cover_image.cover_image_original];
    
    [self presentViewController:vc animated:YES completion:nil];
    
}

-(void)reloadData{

    [self.userCoverImageView setImage:nil];
    [self.userCoverImageView sd_setImageWithURL:[NSURL URLWithString:currentUser.user_cover_image.cover_image_640]];
    [self.userImageView setImage:nil];
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:currentUser.user_avatar.avatar_thumbnail]];
    [self.userNameButton setTitle:currentUser.user_name forState:UIControlStateNormal];
    [self.userNameButton setImage:currentUser.user_featured?[UIImage imageNamed:@"badges-official"]:nil forState:UIControlStateNormal];

    self.followingCountLabel.text = [currentUser.user_user_stats.user_stats_following stringValue];
    self.followersCountLabel.text = [currentUser.user_user_stats.user_stats_followers stringValue];
    [self.myTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBActions
- (IBAction)editButtonTapped:(id)sender {
    if([self.currentUser.user_id isEqualToString:CURRENT_USER_ID()]){
        ProfileEditViewController *vc = [[ProfileEditViewController alloc] initWithUser:self.currentUser];

        [self.navigationController pushViewController:vc animated:YES];
    }else{
        if([self.currentUser.user_socialization.socialization_following boolValue]){
            [UIAlertView showWithTitle:@"Unfollow" message:[NSString stringWithFormat:@"Stop following %@ ?",currentUser.user_name] cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if(buttonIndex != alertView.cancelButtonIndex){
                    self.editButton.userInteractionEnabled = NO;
                    
                    [User unfollowUserWithId:self.currentUser.user_id andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                        self.editButton.userInteractionEnabled = YES;
                        [self didUnfollowUser:self.currentUser];
                        [self getUserProfileFromServer];
                    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                            [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                        }
                        
                        self.editButton.userInteractionEnabled = YES;
                        [self.editButton setImage:[UIImage imageNamed:@"minicheck"] forState:UIControlStateNormal];
                        [self.editButton setImageEdgeInsets:UIEdgeInsetsMake(0, -7, 0, 0)];
                        [self.editButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
                        [self.editButton setTitle:@"Following" forState:UIControlStateNormal];
                        [self.editButton setBackgroundColor:HEXCOLOR(0x1563f3FF)];
                        self.editButton.layer.borderColor = HEXCOLOR(0x1563f3FF).CGColor;
                    }];
                    [self.editButton setImage:nil forState:UIControlStateNormal];
                    [self.editButton setTitle:@"Follow" forState:UIControlStateNormal];
                    [self.editButton setBackgroundColor:[UIColor clearColor]];
                    self.editButton.layer.borderColor = [self.editButton.titleLabel.textColor CGColor];
                }
            }];

        }else{
            self.editButton.userInteractionEnabled = NO;
            [User followUserWithId:self.currentUser.user_id andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                self.editButton.userInteractionEnabled = YES;
                [self didFollowUser:self.currentUser];
                [self getUserProfileFromServer];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                self.editButton.userInteractionEnabled = YES;
                NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                }
                [self.editButton setImage:nil forState:UIControlStateNormal];
                [self.editButton setTitle:@"Follow" forState:UIControlStateNormal];
                [self.editButton setBackgroundColor:[UIColor clearColor]];
                self.editButton.layer.borderColor = [self.editButton.titleLabel.textColor CGColor];
            }];
            
            [self.editButton setImage:[UIImage imageNamed:@"minicheck"] forState:UIControlStateNormal];
            [self.editButton setImageEdgeInsets:UIEdgeInsetsMake(0, -7, 0, 0)];
            [self.editButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
            [self.editButton setTitle:@"Following" forState:UIControlStateNormal];
            [self.editButton setBackgroundColor:HEXCOLOR(0x1563f3FF)];
            self.editButton.layer.borderColor = HEXCOLOR(0x1563f3FF).CGColor;
        }
    }
    
}


- (IBAction)followingButtonTapped:(id)sender {
    ProfileFollowerViewController *vc = [[ProfileFollowerViewController alloc] initWithUser:currentUser withMode:FollowModeFollowing];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)followersButtonTapped:(id)sender {
    ProfileFollowerViewController *vc = [[ProfileFollowerViewController alloc] initWithUser:currentUser withMode:FollowModeFollower];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)avatarTapped:(id)sender {
    
    ImageDetailViewController *vc = [[ImageDetailViewController alloc] initWithImageURL:self.currentUser.user_avatar.avatar_original];

    [self presentViewController:vc animated:YES completion:nil];
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
    
    int rowCount = 0;
    int uploadingCell = TheSettingsManager.userUploadModelId?1:0;
    
    if(self.currentProfileMode == ProfileModeVideo)
        rowCount = (int)[self.clipsArray count];
    else if(self.currentProfileMode == ProfileModePlaylist)
        rowCount = (int)[self.playlistsArray count];
    else if(self.currentProfileMode == ProfileModeActivity)
        rowCount = (int)[self.activitiesArray count];
    else if(self.currentProfileMode == ProfileModeModerasi)
        rowCount = (int)[self.userUploadsArray count] + uploadingCell;
    
    return rowCount;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isTableEmpty){
        return 57.0;
    }
    switch (currentProfileMode) {
        case ProfileModeVideo:{
        
            Clip *cl = [self.clipsArray objectAtIndex:indexPath.row];
            ProfileVideoTableViewCell *aCell = (ProfileVideoTableViewCell *) [tableView dequeueReusableCellWithIdentifier:[ProfileVideoTableViewCell reuseIdentifier]];
            [aCell fillWithClip:cl];
            return [aCell cellHeight];
            
            }break;
        case ProfileModePlaylist:
            return 200.0;
            break;
        case ProfileModeActivity:
            return 44.0;
            break;
        default:
            if(indexPath.row == 0 && TheSettingsManager.userUploadModelId)
                return 44.0;
            return 85.0;
            break;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.isTableEmpty){
        EmptyLabelTableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:[EmptyLabelTableViewCell reuseIdentifier]];

        if(currentProfileMode == ProfileModeActivity){
            emptyCell.emptyLabel.text = @"Aktifitas tidak ditemukan.";
        }else if(currentProfileMode == ProfileModePlaylist){
            emptyCell.emptyLabel.text = @"Playlist tidak ditemukan.";
        }else if(currentProfileMode == ProfileModeVideo){
           emptyCell.emptyLabel.text = @"Video tidak ditemukan.";
        }else{
            emptyCell.emptyLabel.text = @"Video moderasi tidak ditemukan.";
        }
        return emptyCell;
    }
    
    UITableViewCell *aCell;
    if(currentProfileMode == ProfileModeVideo){
    
        Clip *cl = [self.clipsArray objectAtIndex:indexPath.row];
        aCell = (ProfileVideoTableViewCell *) [tableView dequeueReusableCellWithIdentifier:[ProfileVideoTableViewCell reuseIdentifier]];
        [(ProfileVideoTableViewCell *)aCell setDelegate:self];
        [(ProfileVideoTableViewCell *)aCell fillWithClip:cl];
    
    }else if(currentProfileMode == ProfileModePlaylist){
        Playlist *currentPlaylist = [self.playlistsArray objectAtIndex:indexPath.row];
        aCell = (TimelinePlaylistTableViewCell *) [tableView dequeueReusableCellWithIdentifier:[TimelinePlaylistTableViewCell reuseIdentifier]];
        [(TimelinePlaylistTableViewCell *)aCell setDelegate:self];
        [(TimelinePlaylistTableViewCell *)aCell setItemWithPlayList:currentPlaylist];
        
    }else if(currentProfileMode == ProfileModeActivity){
        Activity *currentActivity = [self.activitiesArray objectAtIndex:indexPath.row];
        aCell = (ProfileActivityTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ProfileActivityTableViewCell reuseIdentifier]];
        [(ProfileActivityTableViewCell*)aCell fillWithActivity:currentActivity];
    }else{
    
        if(indexPath.row == 0 && TheSettingsManager.userUploadModelId){
            return progressCell;
        }
        
        UploadClipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UploadClipTableViewCell reuseIdentifier]];
        
        int uploadingCell = TheSettingsManager.userUploadModelId?1:0;
        
        UserUploads *uu = [self.userUploadsArray objectAtIndex:indexPath.row - uploadingCell];
        UserUploadsModel *uum = [TheDatabaseManager getUserUploadsModelById:uu.user_uploads_id];
    
        [cell fillWithUserUploads:uu andUserUploadModel:uum];
        cell.delegate = self;
        return cell;
    }
    return aCell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    ProfileCustomHeader * headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[ProfileCustomHeader reuseIdentifier]];
    CGRect destFrame = headerView.frame;
    destFrame.size.width = self.myTableView.frame.size.width;
    headerView.frame = destFrame;
    headerView.selectedIndex = currentProfileMode;
    NSLog(@"isOfficial? : %d",[currentUser.user_type isEqualToString:userTypeOfficial]? YES : NO);
    
    BOOL isModerate = NO;
    if([currentUser.user_id isEqualToString:CURRENT_USER_ID()]){
        isModerate = YES;
    }
    [headerView setupCellForModerate:isModerate];
    headerView.delegate = self;
    return headerView;
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 34.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isTableEmpty)
        return;
    if(currentProfileMode == ProfileModeVideo){
        Clip *aClip = [self.clipsArray objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:[[VideoDetailViewController alloc] initWithClip:aClip] animated:YES];
        
    }else if(currentProfileMode == ProfileModePlaylist){
        Playlist *aPlaylist = [self.playlistsArray objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:[[PlaylistDetailsViewController alloc] initWithPlaylist:aPlaylist] animated:YES];
    }else if(currentProfileMode == ProfileModeModerasi){
        
        if(indexPath.row == 0 && TheSettingsManager.userUploadModelId)
            return;
        
        int uploadingCell = TheSettingsManager.userUploadModelId?1:0;
        UserUploads *userUpload = [self.userUploadsArray objectAtIndex:indexPath.row-uploadingCell];
        
        if([userUpload.user_uploads_video_uploaded boolValue]){
            [self.navigationController pushViewController:[[UploadVideoDetailViewController alloc]initWithUserUploads:userUpload] animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isTableEmpty){
        self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }else{
        self.myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }

    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"";
//}

#pragma mark - ProfileTableViewCellDelegate
-(void)profileVideoTableViewCell:(ProfileVideoTableViewCell *)cell detailButtonTappedForClip:(Clip *)aClip{
    self.currentClip = aClip;
    [self moreButtonTappedForClip:self.currentClip];
}



#pragma mark - HeaderDelegate
-(void)didSelectButtonAtIndex:(int)idx{
    self.currentProfileMode = idx;
    self.isReloading = NO;
    BOOL shouldRequestData = NO;
    self.isTableEmpty = NO;
    switch (self.currentProfileMode) {
        case ProfileModeVideo:{
            if (self.clipsArray.count == 0) {
                self.isTableEmpty = YES;
                shouldRequestData = YES;
            }
        }
            break;
        case ProfileModePlaylist:{
            if (self.playlistsArray.count == 0) {
                self.isTableEmpty = YES;
                shouldRequestData = YES;
            }
        }
            break;
        case ProfileModeActivity:{
            if (self.activitiesArray.count == 0) {
                self.isTableEmpty = YES;
                shouldRequestData = YES;
            }
        }
            break;
            
        case ProfileModeModerasi:{
            if(self.userUploadsArray.count == 0){
                self.isTableEmpty = YES;
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



#pragma mark - TimelineTableViewCellDelegate
-(void)didSelectClip:(Clip *)aClip{
    [self.navigationController pushViewController:[[VideoDetailViewController alloc] initWithClip:aClip] animated:YES];
}

#pragma mark - ProfileVideoTableViewCellDelegate
-(void)deleteClipWithId:(NSNumber *)clipID{
    
}

#pragma mark - Search Cell Delegate
-(void)moreButtonDidTapForClip:(Clip *)clip{
    self.currentClip = clip;
    [self moreButtonTappedForClip:clip];
}

#pragma mark - Upload Cell Delegate
-(void)moreButtonDidTapForUserUpload:(UserUploads *)uu{
    [self moreButtonTappedForUserUpload:uu];
}

#pragma mark - ProfileUpdated Notification Handler
-(void)profileUpdated{
    if([self.currentUser.user_id isEqualToString:CURRENT_USER_ID()]){
        self.currentUser = CURRENT_USER();
        [self reloadData];
    }
}

#pragma mark - UploadVideoViewController Notification Handler   <-----   Ini guh
-(void)cancelToUpload{
    [self.uploadTask cancel];
    
    [self showAlertWithMessage:@"Upload dibatalkan"];
    
    totalProgressLabel.text = @"Uploading tidak berhasil";
    self.theUUM.user_uploads_status = UserUploadStatusIncomplete;
    [TheDatabaseManager updateUserUploadsModel:self.theUUM];
    [TheSettingsManager saveUserUploadModelId:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshProfilePage object:nil];

}

-(void)uploadVideoToS3:(NSNotification *)notif{
    if (self.uploadTask) {
        return;
    }
    NSDictionary *params = notif.userInfo;
    UserUploadsModel *uum = params[@"userUploadModel"];
    self.theUUM = [[UserUploadsModel alloc] init];
    self.theUUM.user_uploads_id = uum.user_uploads_id;
    self.theUUM.user_uploads_title = uum.user_uploads_title;
    self.theUUM.user_uploads_video_url_local = [params[@"videoURL"] absoluteString];
    self.theUUM.clip_category_string = params[@"categoryName"];
    self.theUUM.user_uploads_status = UseruploadStatusOnProgress;
    AWSRequestObject *aws = params[@"aws"];
    self.theUUM.user_uploads_status = UseruploadStatusOnProgress;
    
    NSLog(@"user upload model = %@", self.theUUM);
    [TheDatabaseManager updateUserUploadsModel:self.theUUM];
    
    NSURL *uploadFileURL = [NSURL URLWithString:self.theUUM.user_uploads_video_url_local];
    __weak typeof(self) welf = self;
    self.expression = [AWSS3TransferUtilityUploadExpression new];
    expression.uploadProgress = ^(AWSS3TransferUtilityTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Do something e.g. Update a progress bar.
            double progress = (double)totalBytesSent / (double)totalBytesExpectedToSend;
            
            NSLog(@"UploadTask progress: %lf", progress);
            int in100 = progress*100;
        
            welf.totalProgressLabel.text = [NSString stringWithFormat:@"Uploading %zd%%", in100];
            [welf.progressView setProgress:progress];
            
            if(in100 % 10 == 0){
                welf.theUUM.user_upload_percentage = progress;
                [TheDatabaseManager updateUserUploadsModel:welf.theUUM];
            }
            
        });
    };
    

    self.completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Do something e.g. Alert a user for transfer completion.
            // On failed uploads, `error` contains the error object.
            
            if([error.userInfo objectForKey:NSURLErrorBackgroundTaskCancelledReasonKey]){
                NSLog(@"di terminate loh");
                
                [welf cancelToUpload];
                
            }else if (!error && TheSettingsManager.userUploadModelId) {
                
                welf.totalProgressLabel.text = @"Uploading Selesai";
                NSLog(@"S3 UploadTask: %@ completed successfully", task);
                
                UserUploadsModel *uum = welf.theUUM;
                if(uum == nil){
                    uum = [TheDatabaseManager getUserUploadsModelById:TheSettingsManager.userUploadModelId];
                }
                
                [UserUploads doneUploadingVideoForUserUpload:uum withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, UserUploads *result) {
                    
                    [TheSettingsManager saveUserUploadModelId:nil];
                    uum.user_uploads_status = UserUploadStatusSuccess;
                    [TheDatabaseManager updateUserUploadsModel:uum];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshProfilePage object:nil];
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    NSLog(@"Updating META after upload failed");
                    
                    [TheSettingsManager saveUserUploadModelId:nil];
                    uum.user_uploads_status = UserUploadStatusIncomplete;
                    [TheDatabaseManager updateUserUploadsModel:uum];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshProfilePage object:nil];
                }];
            
            }else {
                
                welf.totalProgressLabel.text = @"Uploading tidak berhasil";
                welf.theUUM.user_uploads_status = UserUploadStatusIncomplete;
                [TheDatabaseManager updateUserUploadsModel:welf.theUUM];
                [TheSettingsManager saveUserUploadModelId:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshProfilePage object:nil];

                NSLog(@"S3 UploadTask: %@ completed with error: %@", task, [error localizedDescription]);
            }
            
        });
    };
    
    NSLog(@"%@",[NSString stringWithFormat:@"%@/%@",aws.aws_path, aws.aws_filename]);
    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];

    [[transferUtility uploadFile:uploadFileURL
                          bucket:aws.aws_bucket_name
                             key:[NSString stringWithFormat:@"%@/%@",aws.aws_path, aws.aws_filename]
                     contentType:@"video/quicktime"
                      expression:self.expression
                completionHander:self.completionHandler] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"Error: %@", task.error);
        }
        if (task.exception) {
            NSLog(@"Exception: %@", task.exception);
        }
        if (task.result) {
            self.uploadTask = task.result;
            NSLog(@"task identifier : %zd", self.uploadTask.taskIdentifier);
            
            TheSettingsManager.uploadTaskIdentifier = self.uploadTask.taskIdentifier;
            // Do something with uploadTask.
        }
        
        return nil;
    }];
    
}

#pragma mark - ProfileFollowViewController Delegate
-(void)didFollowUser:(User *)obj{
    NSLog(@"follow: %d",[currentUser.user_user_stats.user_stats_following intValue]);
    if([currentUser.user_id isEqualToString:CURRENT_USER_ID()]){
        self.followingCountLabel.text = [NSString stringWithFormat:@"%d",[currentUser.user_user_stats.user_stats_following intValue] + 1];
    }else{
        self.followersCountLabel.text = [NSString stringWithFormat:@"%d",[currentUser.user_user_stats.user_stats_followers intValue] + 1];
    }
}

-(void)didUnfollowUser:(User *)obj{
     NSLog(@"follo: %d",[currentUser.user_user_stats.user_stats_followers intValue]);
    if([currentUser.user_id isEqualToString:CURRENT_USER_ID()]){
        self.followingCountLabel.text = [NSString stringWithFormat:@"%d",[currentUser.user_user_stats.user_stats_following intValue] - 1];
    }else{
        self.followersCountLabel.text = [NSString stringWithFormat:@"%d",[currentUser.user_user_stats.user_stats_followers intValue] - 1];
    }
}

#pragma mark - UIAlertView Delegate
- (void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    NSString *titleButton = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([titleButton isEqualToString:@"Hapus"]){
        
        [UIAlertView showWithTitle:nil message:@"Anda yakin untuk menghapus video ini?" cancelButtonTitle:@"Tidak" otherButtonTitles:@[@"Iya"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if(buttonIndex != alertView.cancelButtonIndex){
                
                UserUploadsModel *uum = [TheDatabaseManager getUserUploadsModelById:self.currentUserUpload.user_uploads_id];
                
                if(uum.user_uploads_status == UseruploadStatusOnProgress){
                    [self cancelToUpload];
                }
                
                [UserUploads deleteUserUploadsWithUserUploads:self.currentUserUpload withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, UserUploads *result)
                 {
                     [self.view startLoader:NO disableUI:NO];
                     [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshProfilePage object:nil];
                     
                     [TheDatabaseManager deleteUserUploadsModel:self.currentUserUploadsModel];
                     
                 } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                     
                     NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                     if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                         NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                         if(jsonDict[@"error"][@"messages"][0])
                             [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                     }
                 }];
            }
        }];
        
    }else if([titleButton isEqualToString:@"Reupload"]){
        //do reupload
        [self showAlbum];
    
    }else if([titleButton isEqualToString:@"Batal Upload"]){
        [self cancelToUpload];
    }
}

@end

