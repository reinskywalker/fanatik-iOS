//
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/14/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ContestDetailViewController.h"
#import "UploadVideoViewController.h"
#import "MoreVideosViewController.h"
#import "ImageDetailViewController.h"
#import "ContestVideo.h"
#import "ContestWinners.h"

#define PERCENTAGE_OF_SHRINKEDVIDEO 0.7

@interface ContestDetailViewController()<DMMoviePlayerDelegate, ContestInfoTableViewCellDelegate, SearchClipTableViewCellDelegate>

@property (nonatomic, retain) NSNumber *currentContestID;
@property (nonatomic, assign) BOOL isLongDescription;
@property (nonatomic, assign) VisibilityMode currentVisibility;
@property(nonatomic, assign) BOOL isExpanded;
@property (nonatomic, retain) UIRefreshControl *refreshControl;
@property(nonatomic, assign) int currentPage;
@property(nonatomic, retain) PaginationModel *clipPagination;
@property(nonatomic, retain) PaginationModel *userPagination;
@end

@implementation ContestDetailViewController
@synthesize currentContest, myTableView, posterView;
@synthesize videoContestArray, currentContestID, imageHeightCon, uploadButton, imageHeightUploadButton;
@synthesize isLongDescription, currentVisibility, contestantArray, playerView, refreshControl;

-(id)initWithContest:(Contest *)contest{
    if(self = [super init]){
        self.currentContest = contest;
        self.videoContestArray = [NSMutableArray array];
        self.isLongDescription = NO;
        self.contestantArray = [NSMutableArray array];
    }
    return self;
}

-(id)initWithContestID:(NSNumber *)contestID{
    if(self = [super init]){
        self.currentContestID = contestID;
        self.videoContestArray = [NSMutableArray array];
        self.isLongDescription = NO;
        self.contestantArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPageCode = MenuPageContestDetail;
    
    [self reloadVideo];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [playerView stopMovie];
}

-(void)reloadVideo{
    
    _uploadButtonHeightConstraint.constant = 45.0;
    if([currentContest.contest_expired boolValue]){
        _uploadButtonHeightConstraint.constant = 0.0;
    }
    
    if(!currentContest.contest_contest_video.contest_video_url){
        NSURL *filePath = [NSURL URLWithString:self.currentContest.contest_cover_image_url];
        UIImage *im = [UIImage imageWithData: [NSData dataWithContentsOfURL:filePath]];
        
        if(!posterView){
            posterView = [[UIImageView alloc]initWithImage:im];
            posterView.frame = CGRectMake(0, 0, TheAppDelegate.deviceWidth, TheAppDelegate.deviceWidth/16*9);
            posterView.contentMode = UIViewContentModeScaleAspectFill;
            posterView.clipsToBounds = YES;
            [self.playerView addSubview:posterView];
        }
        self.posterView.hidden = NO;
        [playerView stopMovie];
        [self.playerView bringSubviewToFront:posterView];
    }else{
        self.posterView.hidden = YES;
     
        NSURL *thumbnailURL = [NSURL URLWithString:currentContest.contest_contest_video.contest_video_thumbnail_url];
        NSURL *videoURL = [NSURL URLWithString:currentContest.contest_contest_video.contest_video_url];
        NSURL *vastURL = nil;//[NSURL URLWithString:@"http://dev.fanatik.id/test/vast.xml"];
        [playerView initializeWithContentURL:videoURL andThumbnailURL:thumbnailURL andVastURL:vastURL durationString:@"13:31"];
        self.playerView.isLive = NO;
        [playerView play];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.currentPage = 1;
    self.currentPageCode = MenuPageContestDetail;
//    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"btnShare"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(shareContent)];
//    self.navigationItem.rightBarButtonItem = shareButton;
    
    UIButton *lButton = [TheAppDelegate createButtonWithTitle:nil imageName:@"leftArrow" highlightedImageName:@"leftArrowHighlight" forLeftButton:YES];
    [lButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.myTableView registerNib:[UINib nibWithNibName:[SearchClipTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([SearchClipTableViewCell class])];
    [self.myTableView registerNib:[UINib nibWithNibName:[ContestInfoTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[ContestInfoTableViewCell reuseIdentifier]];
    [self.myTableView registerNib:[UINib nibWithNibName:[EmptyLabelTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([EmptyLabelTableViewCell class])];
   [self.myTableView registerNib:[UINib nibWithNibName:[UserFollowTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([UserFollowTableViewCell class])];
    
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(pullToRefreshTable) forControlEvents:UIControlEventValueChanged];
    [self.myTableView addSubview:refreshControl];
    
    __weak typeof(self) weakSelf = self;
    // load more content when scroll to the bottom most
    [self.myTableView addInfiniteScrollingWithActionHandler:^{
        
        weakSelf.currentPage = currentVisibility == VisibilityModeUpload ? weakSelf.clipPagination.nextPage : weakSelf.userPagination.nextPage;
        if(weakSelf.currentPage && weakSelf.currentPage > 0){
            if(currentVisibility == VisibilityModeUpload){
                [weakSelf getContestClipsWithPageNumber:@(weakSelf.currentPage)];
            }else{
                [weakSelf getContestUsersWithPageNumber:@(weakSelf.currentPage)];
            }
        }else{
            weakSelf.myTableView.showsInfiniteScrolling = NO;
            [weakSelf.myTableView.pullToRefreshView stopAnimating];
            [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        }
    }];
    
    [self getContestDetailWithPageNumber:@1];
    [self.myTableView reloadData];
}

-(void)pullToRefreshTable{
    [self.myTableView setContentOffset:CGPointMake(0, -1.0f * self.refreshControl.frame.size.height) animated:YES];
    [self.refreshControl beginRefreshing];
    self.clipPagination.currentPage = 1;
    self.userPagination.currentPage = 1;
    [self.videoContestArray removeAllObjects];
    [self.contestantArray removeAllObjects];
    [self didSelectVisibilityMode:currentVisibility];// before load new content, clear the existing table list
    [self getContestDetailWithPageNumber:@1]; // load new data
}

-(void)viewWillAppear:(BOOL)animated{
    self.pageObjectName = self.currentContest.contest_name;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTableViewIndexRow:(NSInteger)startRow
{
    // the last row after added new items
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    NSInteger totalArrayCount = 0;
    if(currentVisibility == VisibilityModeUpload){
        totalArrayCount = videoContestArray.count;
    }else{
        totalArrayCount = contestantArray.count;
    }
    
    for (; startRow < totalArrayCount; startRow++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:startRow inSection:1]];
    }

    [self.myTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

-(void)getContestClipsWithPageNumber:(NSNumber *)pageNum{
    
    NSNumber *contID = self.currentContestID?self.currentContestID:self.currentContest.contest_id;
    [Contest getContestClipsWithContestID:contID andAccessToken:ACCESS_TOKEN() andPageNum:pageNum success:^(RKObjectRequestOperation * _Nonnull operation, Contest * _Nonnull result) {
        
        NSData *responseData = operation.HTTPRequestOperation.responseData;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
        self.clipPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
        
        NSInteger currentRow = self.videoContestArray.count;
        [self.videoContestArray addObjectsFromArray:[result.contest_clips array]];
        
        if(currentVisibility == VisibilityModeUpload){
            if ([pageNum intValue] == 1) {
                [self.myTableView reloadData];
            }else{
                [self reloadTableViewIndexRow:currentRow];
            }
            // clear the pull to refresh & infinite scroll, this 2 lines very important
            [self.myTableView.pullToRefreshView stopAnimating];
            [self.myTableView.infiniteScrollingView stopAnimating];
        }

    } failure:^(RKObjectRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        [self.myTableView.pullToRefreshView stopAnimating];
        [self.myTableView.infiniteScrollingView stopAnimating];
        [self.myTableView startLoader:NO disableUI:NO];
        WRITE_LOG(error.localizedDescription);
    }];
}


-(void)getContestUsersWithPageNumber:(NSNumber *)pageNum{
    
    NSNumber *contID = self.currentContestID?self.currentContestID:self.currentContest.contest_id;
    [Contest getContestUsersWithContestID:contID andAccessToken:ACCESS_TOKEN() andPageNum:pageNum success:^(RKObjectRequestOperation * _Nonnull operation, Contest * _Nonnull result) {
        
        NSData *responseData = operation.HTTPRequestOperation.responseData;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
        self.userPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
        
        NSInteger currentRow = self.contestantArray.count;
        [self.contestantArray addObjectsFromArray:[result.contest_user array]];
        
        if(currentVisibility == VisibilityModeContestant){
            if ([pageNum intValue] == 1) {
                [self.myTableView reloadData];
            }else{
                [self reloadTableViewIndexRow:currentRow];
            }
            
            // clear the pull to refresh & infinite scroll, this 2 lines very important
            [self.myTableView.pullToRefreshView stopAnimating];
            [self.myTableView.infiniteScrollingView stopAnimating];
        }
        
    } failure:^(RKObjectRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        [self.myTableView.pullToRefreshView stopAnimating];
        [self.myTableView.infiniteScrollingView stopAnimating];
        [self.myTableView startLoader:NO disableUI:NO];
        WRITE_LOG(error.localizedDescription);
    }];
}

-(void)getContestDetailWithPageNumber:(NSNumber *)pageNum{

    [self.myTableView startLoader:YES disableUI:YES];
    NSNumber *contID = self.currentContestID?self.currentContestID:self.currentContest.contest_id;
    [Contest getContestsWithID:contID andAccessToken:ACCESS_TOKEN() andPageNum:pageNum success:^(RKObjectRequestOperation *operation, Contest *result) {
    
        [self.refreshControl endRefreshing];
        [self.myTableView startLoader:NO disableUI:NO];

        self.currentContest = result;
        
        NSArray *contestantWinnersArray = [result.contest_contest_winners array];
        for(ContestWinners *con in contestantWinnersArray){
            Clip *clip = con.contest_winners_clip;
            [self.videoContestArray addObject:clip];
        }
        
        [self.myTableView reloadData];
        
        [self getContestClipsWithPageNumber:pageNum];
        [self getContestUsersWithPageNumber:pageNum];
    
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self.myTableView setContentOffset:CGPointZero animated:YES];
        [self.refreshControl endRefreshing];
        [self.myTableView startLoader:NO disableUI:NO];
        WRITE_LOG(error.localizedDescription);
    }];

}

#pragma mark - UITableView Delegate & Datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0:{
            cell = (ContestInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ContestInfoTableViewCell reuseIdentifier]];
            [(ContestInfoTableViewCell *)cell setCurrentVisibility:currentVisibility];
            [(ContestInfoTableViewCell *)cell setIsExpanded:self.isExpanded];
            [(ContestInfoTableViewCell *)cell setDelegate:self];
            [(ContestInfoTableViewCell *)cell fillCellWithContest:currentContest];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
        default:{
            
            if(self.currentVisibility == VisibilityModeUpload){
                if(self.videoContestArray.count == 0){
                    EmptyLabelTableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:[EmptyLabelTableViewCell reuseIdentifier]];
                    emptyCell.emptyLabel.text = @"Video kontes tidak ditemukan";
                    return emptyCell;
                }
            
                cell = (SearchClipTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[SearchClipTableViewCell reuseIdentifier]];
                Clip *aClip = [self.videoContestArray objectAtIndex:indexPath.row];
                [(SearchClipTableViewCell *)cell setDelegate:self];
                [(SearchClipTableViewCell *)cell fillWithClip:aClip];
                return cell;
                
            }else{
                
                if(self.contestantArray.count == 0){
                    EmptyLabelTableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:[EmptyLabelTableViewCell reuseIdentifier]];
                    emptyCell.emptyLabel.text = @"Kontestan tidak ditemukan";
                    return emptyCell;
                }
                
                User *aUser = [self.contestantArray objectAtIndex:indexPath.row];
                cell = (UserFollowTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[UserFollowTableViewCell reuseIdentifier]];
                [(UserFollowTableViewCell*)cell setCanFollow:YES];
                [(UserFollowTableViewCell*)cell setDelegate:self];
                [(UserFollowTableViewCell*)cell fillCellWithUser:aUser];
                return cell;
            }
        }
        break;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:{
            return 1.0;
        }
            break;
        case 1:{
            if(currentVisibility == VisibilityModeUpload){
                if(self.videoContestArray.count == 0)
                    return 1.0;
                return self.videoContestArray.count;
            }else{
                
                if(self.contestantArray.count == 0)
                    return 1.0;
                return self.contestantArray.count;
            }
        }
            break;
            
        default:
            return 1;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:{
            self.isExpanded = !self.isExpanded;
            NSMutableIndexSet *sets = [NSMutableIndexSet indexSetWithIndex:0];
            [self.myTableView reloadSections:sets withRowAnimation:UITableViewRowAnimationFade];
            
        }
            break;
        default:{
            if(currentVisibility == VisibilityModeUpload){
                if(videoContestArray.count > 0){
                    Clip *theClip = [videoContestArray objectAtIndex:indexPath.row];
                    VideoDetailViewController *vc = [[VideoDetailViewController alloc] initWithClip:theClip];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }else{
                if(contestantArray.count > 0){
                    User *aUser = [self.contestantArray objectAtIndex:indexPath.row];
                    ProfileViewController *vc = [[ProfileViewController alloc] initWithUser:aUser];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }
            break;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:{
            ContestInfoTableViewCell *cell = (ContestInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ContestInfoTableViewCell reuseIdentifier]];
            cell.isExpanded = self.isExpanded;
            [cell fillCellWithContest:currentContest];
            return [cell cellHeight];
        }
            break;
        case 1:{
            if(currentVisibility == VisibilityModeUpload){
                if(videoContestArray.count > 0){
                    return 85.0;
                }
                return 44.0;
            }else{
                return 44.0;
            }
        }
            break;
            
        default:
            return 40.0;
            break;
    }
}

#pragma mark - IBAction

-(void)shareContent{
    
    /*
    if(self.currentContest.event_shareable.shareable_url && ![self.currentEvent.event_shareable.shareable_url isEqualToString:@""]){
        NSLog(@"Shareable : %@", currentEvent.event_shareable);
        NSString* someText = self.currentEvent.event_shareable.shareable_content;
        NSURL* linkText = [[NSURL alloc] initWithString: self.currentEvent.event_shareable.shareable_url];
        NSArray* dataToShare = [NSArray arrayWithObjects: someText,linkText, nil];
        UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
        activityViewController.excludedActivityTypes = @[ UIActivityTypePostToWeibo, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypePrint ];
        [self presentViewController:activityViewController animated:YES completion:^{}];
    }
     */
}

-(IBAction)uploadTapped:(id)sender{
    
    if([User fetchLoginUser]){
        [self showAlbum];
    }else{
        [self presentViewController:[[HomeViewController alloc] initByPresenting] animated:YES completion:nil];
    }

}

- (void)contestDetailImageTapped:(UITapGestureRecognizer *)recognizer{
    ImageDetailViewController *vc = [[ImageDetailViewController alloc] initWithImageURL:self.currentContest.contest_cover_image_url];
    
    [self presentViewController:vc animated:YES completion:nil];
    
}

#pragma mark - Contest Info Cell Delegate
-(void)showingErrorFromServer:(NSString *)errorStr{
    [self showAlertWithMessage:errorStr];
}

-(void)didSelectVisibilityMode:(VisibilityMode)visMod{
    self.currentVisibility = visMod;
    
    if(visMod == VisibilityModeUpload){
        self.myTableView.showsInfiniteScrolling = self.clipPagination.currentPage != self.clipPagination.totalPage;
    }else{
        self.myTableView.showsInfiniteScrolling = self.userPagination.currentPage != self.userPagination.totalPage;
    }
    
    [self.myTableView reloadData];
}

#pragma mark - IOS7 Orientation Change
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        self.videoPlayerTopConstraint.constant = 0.0;
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        
        if(!currentContest.contest_contest_video.contest_video_url){
            posterView.frame = CGRectMake(0, 0, playerView.frame.size.width, playerView.frame.size.height);
        }
        
    }else{
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
        self.videoPlayerTopConstraint.constant = 64.0;
        
        if(!currentContest.contest_contest_video.contest_video_url){
            posterView.frame = CGRectMake(0, 0, TheAppDelegate.deviceWidth, playerView.frame.size.height);
        }
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    self.playerView.originalPlayerSize = self.playerView.frame.size;
    playerView.zoomButton.selected = !playerView.zoomButton.selected;
    
    if(playerView.isShrink){
        [playerView shrinkMainVideoWithAnimation:NO andSize:CGSizeMake(PERCENTAGE_OF_SHRINKEDVIDEO * self.playerView.originalPlayerSize.width, PERCENTAGE_OF_SHRINKEDVIDEO * self.playerView.originalPlayerSize.height)];
    }
    
    if(fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }else{
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

#pragma mark - IOS8 Orientation Change
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.playerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    playerView.zoomButton.selected = !playerView.zoomButton.selected;
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         // do whatever
         self.playerView.originalPlayerSize = self.playerView.frame.size;
         
         if(playerView.isShrink){
             [playerView shrinkMainVideoWithAnimation:NO andSize:CGSizeMake(PERCENTAGE_OF_SHRINKEDVIDEO * self.playerView.originalPlayerSize.width, PERCENTAGE_OF_SHRINKEDVIDEO * self.playerView.originalPlayerSize.height)];
         }
         
         if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
             
             [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
             
             self.navigationController.interactivePopGestureRecognizer.enabled = NO;
             
             [self.navigationController setNavigationBarHidden:YES animated:YES];
             _videoPlayerTopConstraint.constant = 0;
             if(IS_IPAD){
                 self.videoPlayerAspectRationConstraint.active = NO;
                 self.videoPlayerBottomConstraint.constant = 0;
                 self.videoPlayerBottomConstraint.active = YES;
             }
             self.myTableView.hidden = YES;
             [self.view endEditing:YES];
             
             if(!currentContest.contest_contest_video.contest_video_url){
                 posterView.frame = CGRectMake(0, 0, playerView.frame.size.width, playerView.frame.size.height);
             }
         }else{
             
             [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
             
             self.navigationController.interactivePopGestureRecognizer.enabled = YES;
             
             self.videoPlayerTopConstraint.constant = 64.0;
             self.myTableView.hidden = NO;
             if(IS_IPAD){
                 self.videoPlayerAspectRationConstraint.active = YES;
                 self.videoPlayerBottomConstraint.active = NO;
             }
             
             [self.navigationController setNavigationBarHidden:NO animated:YES];
             
             if(!currentContest.contest_contest_video.contest_video_url){
                 posterView.frame = CGRectMake(0, 0, TheAppDelegate.deviceWidth, playerView.frame.size.height);
             }
         }
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         // do whatever
         if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
             
             
         }else{
             
         }
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - DMMoviePlayerViewDelegate
-(void)DMMoviePlayer:(DMMoviePlayer *)moviePlayer resolutionButtonTapped:(NSArray *)resoArray andSeekTime:(CMTime)time{
    
    NSMutableArray *resolutionStringArray = [NSMutableArray array];
    
    for(M3U8ExtXStreamInf *info in resoArray){
        [resolutionStringArray addObject:[NSString stringWithFormat:@"%0.fx%0.f",[info resolution].width, [info resolution].height]];
    }
    
    [UIActionSheet showInView:self.view withTitle:@"Change Resolution" cancelButtonTitle:@"Batal" destructiveButtonTitle:nil otherButtonTitles:resolutionStringArray tapBlock:^(UIActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
        
        if(buttonIndex != actionSheet.cancelButtonIndex){
            M3U8ExtXStreamInf *info = [resoArray objectAtIndex:buttonIndex];
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:info.URI]];
            [self.playerView.moviePlayer.player replaceCurrentItemWithPlayerItem:playerItem];
            [self.playerView.moviePlayer.player.currentItem seekToTime:time];
        }
    }];
}

-(IBAction)PIPtapped:(id)sender{
    [playerView commencingPIPWithMainVideoURL:nil andMiniVideoURL:[NSURL URLWithString:@"http://www.ciphertrick.com/demo/htmlvast/vod/sample.mp4"]];
}

-(IBAction)shrinkTapped:(id)sender{
    
    if(!self.playerView.isShrink){
        [playerView shrinkMainVideoWithAnimation:YES andSize: CGSizeMake(PERCENTAGE_OF_SHRINKEDVIDEO * self.playerView.frame.size.width, PERCENTAGE_OF_SHRINKEDVIDEO * self.playerView.frame.size.height)];
    }else{
        [playerView shrinkMainVideoWithAnimation:YES andSize:self.playerView.frame.size];
    }
}

#pragma mark - Cell Delegate
-(void)successToFollowOrUnfollowWithUser:(User *)obj{
    
}

-(void)failedToFollowOrUnfollowWithErrorString:(NSString *)errorString{
    [self showLocalValidationError:errorString];
}

-(void)moreButtonDidTapForClip:(Clip *)clip{
    self.currentClip = clip;
    [self moreButtonTappedForClip:clip];
}

-(void)didTapMoreVideosButton:(id)contest{
    NSLog(@"more videos!");
    [self.navigationController pushViewController:[[MoreVideosViewController alloc] initWithContest:(Contest *)contest] animated:YES];
}

@end
