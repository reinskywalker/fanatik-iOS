//
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/14/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "TVChannelViewController.h"
#import "TVChannelInfoTableViewCell.h"
#import "VideoCommentTableViewCell.h"
#import "VideoCommentHeader.h"
#import "PackageListViewController.h"
#import <MZFayeClient.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoCommentHeaderCell.h"
#import "UserMentionTableViewCell.h"

@interface TVChannelDetailViewController ()<IBActionSheetDelegate, UIAlertViewDelegate, MZFayeClientDelegate>

@property(nonatomic, assign) BOOL isExpanded;
@property(nonatomic, assign) int currentPage;
@property(nonatomic, assign) BOOL isVideoLoaded;
@property(nonatomic, assign) BOOL shouldIncreaseView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerTopConstraint;
@property (nonatomic, assign) BOOL isPlaying;
@property (strong, nonatomic) IBOutlet UIImageView *liveThumbnailImage;
@property (nonatomic, retain) NSNumber *currentCommentID;
@property IBActionSheet *customIBAS;
@property (nonatomic, assign) BOOL notAllowedToWatch;
@property (nonatomic, assign) BOOL isCommentReloading;
@property (nonatomic, strong) MZFayeClient *client;
@property (nonatomic, copy) NSString *currentLiveId;
@property (nonatomic, retain) Comment *newestComment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerAspectRationConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerBottomConstraint;
@property (nonatomic, assign) CGRect videoContainerNormalFrame;
@property(nonatomic, assign) EmojiKeyboardType emojiType;
@property (nonatomic, assign) BOOL isBack;
@property (nonatomic, assign) BOOL isKeyboardShown;
@property (nonatomic, copy) NSString *visitorId;
@property (nonatomic, copy) NSString *visitorStringId;
@end

@implementation TVChannelDetailViewController

@synthesize videoContainerView, moviePlayer, commentsArray, relatedClipsArray, videoPlayerTopConstraint, isPlaying, customIBAS, notAllowedToWatch, newestComment;
@synthesize currentLiveId, currentLive, videoContainerNormalFrame;
@synthesize emojiType, visitorId, visitorStringId, keyboardView, isBack, isKeyboardShown;
@synthesize heightKeyboardViewConstraint, userAutoCompleteArray, autoCompleteTableView, heightKeyboardiOSConstraint, heightKeyboardiOSConstraintTemp;

-(id)initWithLive:(Live *)live{
    if(self = [super init]){
        self.currentLive = live;
        self.shouldIncreaseView = YES;
        self.commentsArray = [NSMutableArray array];
        self.relatedClipsArray = [NSMutableArray array];
        self.userAutoCompleteArray = [NSMutableArray array];
        self.emojiType = EmojiKeyboardTypeInitiate;
        self.visitorId = @"";
        self.visitorStringId = @"";
        self.isBack = NO;
    }
    return self;
}

-(id)initWithLiveId:(NSString *)liveId{
    if(self = [super init]){
        self.currentLiveId = liveId;
        self.shouldIncreaseView = YES;
        self.commentsArray = [NSMutableArray array];
        self.relatedClipsArray = [NSMutableArray array];
        self.userAutoCompleteArray = [NSMutableArray array];
        self.emojiType = EmojiKeyboardTypeInitiate;
        self.visitorId = @"";
        self.visitorStringId = @"";
        self.isBack = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.autoCompleteTableView = [[UITableView alloc] init];
    [self.autoCompleteTableView registerNib:[UINib nibWithNibName:[UserMentionTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([UserMentionTableViewCell class])];
    self.autoCompleteTableView.delegate = self;
    self.autoCompleteTableView.dataSource = self;
    [self.view addSubview:self.autoCompleteTableView];
    [self.autoCompleteTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.autoCompleteTableView sdc_pinHeight:TheAppDelegate.deviceHeight - 270.0 - 50.0];
    [self.autoCompleteTableView sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:self.view];
    [self.autoCompleteTableView sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:self.view];
    [self.autoCompleteTableView sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:self.view inset:64.0];
    self.autoCompleteTableView.hidden = YES;
    
    [self configureView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentDidSuccess:) name:kPaymentCompleted object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(MPMoviePlayerPlaybackStateDidChange:)
//                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(MPMoviePlayerLoadStateDidChange:)
//                                                 name:MPMoviePlayerLoadStateDidChangeNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(MPMoviePlayerPlaybackDidFinishReasonUserInfoKey:)
//                                                 name:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey
//                                               object:nil];

}

-(void)reloadData{

    BOOL isDuplicate = NO;
    for(Comment *com in self.commentsArray){
        if ([com.comment_id isEqual:newestComment.comment_id]) {
            isDuplicate = YES;
            break;
        }
    }
    
    if(!isDuplicate){
        [self.commentsArray insertObject:newestComment atIndex:0];
        NSMutableArray *indexPaths = [NSMutableArray array];
        [indexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:2]];
        
        [self.myTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.myTableView reloadData];
    }

}

-(void)configureView{
    
    [keyboardView initializeView];
    keyboardView.canTagging = YES;

    self.currentPageCode = MenuPageTVChannelDetail;
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"btnShare"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(shareContent)];
    self.navigationItem.rightBarButtonItem = shareButton;
    
    UIButton *lButton = [TheAppDelegate createButtonWithTitle:nil imageName:@"leftArrow" highlightedImageName:@"leftArrowHighlight" forLeftButton:YES];
    [lButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.videoContainerNormalFrame = videoContainerView.frame;

    [self.myTableView registerNib:[UINib nibWithNibName:[VideoCommentHeaderCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[VideoCommentHeaderCell reuseIdentifier]];
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.likeButton setImage:[UIImage imageNamed:@"btnCommentBig"]  forState:UIControlStateNormal];
    self.currentPage = 1;
    
    [self.myTableView registerNib:[UINib nibWithNibName:[TVChannelInfoTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([TVChannelInfoTableViewCell class])];
    [self.myTableView registerNib:[UINib nibWithNibName:[VideoCommentTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([VideoCommentTableViewCell class])];


    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    [self.liveThumbnailImage sd_setImageWithURL:[NSURL URLWithString:self.currentLive.live_thumbnail.thumbnail_480]];

    __weak typeof(self) weakSelf = self;
    // refresh new data when pull the table list
    [self.myTableView addPullToRefreshWithActionHandler:^{
        [weakSelf.commentsArray removeAllObjects]; // remove all data
        [weakSelf.myTableView reloadData]; // before load new content, clear the existing table list
        [weakSelf getLiveDetailAndCommentFromServerForPage:0]; // load new data
        [weakSelf.myTableView.pullToRefreshView stopAnimating]; // clear the animation
        
        // once refresh, allow the infinite scroll again
        weakSelf.myTableView.showsInfiniteScrolling = YES;
    }];
    
    // load more content when scroll to the bottom most
    [self.myTableView addInfiniteScrollingWithActionHandler:^{
        if(weakSelf.currentPage && weakSelf.currentPage > 0){
            [weakSelf getLiveDetailAndCommentFromServerForPage:@(weakSelf.currentPage)];
        }else{
            weakSelf.myTableView.showsInfiniteScrolling = NO;
            [weakSelf.myTableView.pullToRefreshView stopAnimating];
            [weakSelf.myTableView.infiniteScrollingView stopAnimating];
            
        }
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[AVAudioSession sharedInstance]
     setCategory: AVAudioSessionCategoryPlayback
     error: nil];
    [self getLiveDetailAndCommentFromServerForPage:0];
    //Faye Client Setup
    self.client = [[MZFayeClient alloc] initWithURL:[NSURL URLWithString:FAYE_SERVER_URL()]];
    [self.client subscribeToChannel:[NSString stringWithFormat:@"/lives/%@/comments",self.currentLive.live_id] success:nil failure:nil receivedMessage:nil];
    self.client.delegate = self;
    [self.client connect:nil failure:nil];
    
    //COMMENT
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //teguh
    [self.moviePlayer.player pause];
    self.moviePlayer = nil;
    self.isPlaying = NO;
    if(self.client.isConnected)
        [self.client disconnect:nil failure:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    self.pageObjectName = self.currentLive.live_title;
    [super viewWillAppear:animated];
    
    isBack = NO;
    
    if([self.visitorId isEqualToString:@""] || [User fetchLoginUser]){
        [self handshakeWebSocket];
    }
    
    self.keyboardView.forceLoginButton.hidden = (BOOL)[User fetchLoginUser];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    isBack = YES;
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
        // View is disappearing because a new view controller was pushed onto the stack
        NSLog(@"New view controller was pushed");
    } else if ([viewControllers indexOfObject:self] == NSNotFound) {
        // View is disappearing because it was popped from the stack
        NSLog(@"View controller was popped");
        [self.keyboardView disconnectWebSocket];
    }
}

-(void)handshakeWebSocket{
    
    int random4Digit = arc4random() % 9000 + 1000;
    int random8Digit = arc4random() % 90000000 + 10000000;
    
    self.visitorId = [NSString stringWithFormat:@"%d",random8Digit];
    self.visitorStringId = [NSString stringWithFormat:@"Visitor%d", random4Digit];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 @"handshake", @"action",
                                 @"-", @"roomName",
                                 @"-", @"broadcasterId",
                                 self.visitorId, @"id",
                                 self.visitorStringId, @"username",
                                 [NSString stringWithFormat:@"%@/avatar.png", ConstStr(@"server_url")], @"avatar",
                                 @(1),@"initial_join",
                                 nil];
    
    [self.keyboardView setVisitorId:[NSString stringWithFormat:@"%d", random8Digit]];
    
    if(CURRENT_USER_ID()){
        [self.keyboardView setVisitorId:@""];
        User *currUser = CURRENT_USER();
        
        [dict setObject:currUser.user_id forKey:@"id"]; //8 digit random string angka
        [dict setObject:currUser.user_name forKey:@"username"]; //Visitor4digitrandom
        [dict setObject:currUser.user_avatar.avatar_thumbnail forKey:@"avatar"]; //url server dev.fanatik.id/assets/avatar.png
    }
    
    NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"action", @"event",
                                  dict, @"params",
                                  nil];
    
    [self.keyboardView setWebSocketParameter:dict1];
    [self.keyboardView connectWebSocket];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getLiveDetailAndCommentFromServerForPage:(NSNumber *)pageNum{
    if(self.isCommentReloading)
        return;
    
    NSString *liveId = currentLiveId?currentLiveId:currentLive.live_id;
    
    [Live getLiveWithLiveId:liveId andPageNumber:pageNum withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Live *object) {
        self.currentLive = object;
        self.isCommentReloading = NO;
        int commentRow = (int)[self.commentsArray count];
        NSArray *sortedCommentsArray = [object.live_comment array];
        NSMutableOrderedSet *commentsSet = [[NSMutableOrderedSet alloc] initWithArray:self.commentsArray];

        [commentsSet addObjectsFromArray:sortedCommentsArray];
        self.commentsArray = [[commentsSet array] mutableCopy];
        
//        [self.commentsArray addObjectsFromArray:sortedCommentsArray];
        if(newestComment){
            int duplicateCount = 0;
            for(Comment *com in self.commentsArray){
                if ([com.comment_id isEqual:newestComment.comment_id]) {
                    duplicateCount += 1;
                }
            }
            if(duplicateCount > 1)
                [self.commentsArray removeObject:newestComment];
        }
        // if no more result
        if (sortedCommentsArray == 0) {
            self.myTableView.showsInfiniteScrolling = NO;
            return;
        }
        
        NSData *responseData = operation.HTTPRequestOperation.responseData;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:nil];

        PaginationModel *currentPagination = [[PaginationModel alloc] initWithDictionary:json[@"pagination"]];
        self.currentPage = currentPagination.nextPage;
        if (pageNum == 0 || !isPlaying) {
            [self playVideoTapped:nil];
            [self.videoContainerView startLoader:NO disableUI:NO];
        }
        // store the items into the existing list
        [self reloadTableViewWithCommentsArray:self.commentsArray commentStartRow:commentRow];
        
        if(self.currentLiveId != nil){
            //init
            [self playVideoTapped:nil];
            [self.myTableView reloadData];
        }
        
        // clear the pull to refresh & infinite scroll, this 2 lines very important
        [self.myTableView.pullToRefreshView stopAnimating];
        [self.myTableView.infiniteScrollingView stopAnimating];
        self.newestComment = nil;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        self.isCommentReloading = NO;
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        NSDictionary *errorDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"=======:%@",errorDict);
        
        if(!isBack){
            if(![User fetchLoginUser] || statusCode == StatusCodeNotLoggedIn){
                [UIAlertView showWithTitle:self.appName
                                   message: errorDict[@"error"][@"messages"][0]
                 // @"Anda harus terdaftar sebagai member Fanatik Premium untuk melihat saluran ini"
                         cancelButtonTitle:@"Close"
                         otherButtonTitles:@[@"Login"]
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      
                                      if (self.moviePlayer) {
                                          [self.moviePlayer.player pause];
                                      }
                                      self.notAllowedToWatch = YES;
                                      
                                      if (buttonIndex != [alertView cancelButtonIndex]) {
                                          
                                          [[NSNotificationCenter defaultCenter] postNotificationName:kOpenLoginPageNotification object:nil];
                                      }
                                  }];
                
            }else if(statusCode == StatusCodePremiumContent){
                
                [UIAlertView showWithTitle:self.appName
                                   message:errorDict[@"error"][@"messages"][0]
                         cancelButtonTitle:@"Close"
                         otherButtonTitles:@[@"Top Up"]
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      
                                      if (self.moviePlayer) {
                                          [self.moviePlayer.player pause];
                                      }
                                      self.notAllowedToWatch = YES;
                                      
                                      if (buttonIndex != [alertView cancelButtonIndex]) {
                                          
                                          TheSettingsManager.lastMenuPurchasing = MenuPageVideoDetail;
                                          [TheServerManager openPackagesForContentClass:ContentClassVideo withID:[self.currentClip.clip_video.video_id stringValue]];
                                      }
                                  }];
            }
        }
        
        WRITE_LOG(error.localizedDescription);
        [self.myTableView.pullToRefreshView stopAnimating];
        [self.myTableView.infiniteScrollingView stopAnimating];
        if (pageNum == 0) {
            [self.videoContainerView startLoader:NO disableUI:NO];
        }
    }];
    
 
}

- (void)reloadTableViewWithCommentsArray:(NSMutableArray*)cArray commentStartRow:(int)cStartRow
{
    // the last row after added new items
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (; cStartRow < commentsArray.count; cStartRow++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:cStartRow inSection:2]];
    }
    
    [self.myTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableView Delegate & Datasource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == autoCompleteTableView){
        return 55.0;
    }else{
        switch (indexPath.section) {
            case 0:{
                if([self.currentLive.live_description isEqualToString:@""])
                    return 40.0;
                
                TVChannelInfoTableViewCell *cell = (TVChannelInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TVChannelInfoTableViewCell reuseIdentifier]];
                [cell setCellWithLive:self.currentLive];
                cell.isExpanded = self.isExpanded;
                return [cell cellHeight];
            }
                break;
            case 1:{
                return 65.0;
            }
                break;
            case 2:{
                VideoCommentTableViewCell *cell = (VideoCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[VideoCommentTableViewCell reuseIdentifier]];
                Comment *aComment = [self.commentsArray objectAtIndex:indexPath.row];
                [cell fillCellWithComment:aComment];
                return [cell cellHeight];
            }
                break;
                
            default:
                return 85.0;
                break;
        }
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == autoCompleteTableView)
        return 1;
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == autoCompleteTableView)
        return userAutoCompleteArray.count;
    
    switch (section) {
        case 2:{
            return self.commentsArray.count;
        }
            break;
        
        default:
            return 1;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // example using a custom UITableViewCell
    UITableViewCell *cell;
    if(tableView == autoCompleteTableView){
        User *aUser = [self.userAutoCompleteArray objectAtIndex:indexPath.row];
        cell = (UserMentionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[UserMentionTableViewCell reuseIdentifier]];
        [(UserMentionTableViewCell*)cell fillCellWithUser:aUser];
        return cell;
    }
    
    switch (indexPath.section) {
        case 0:{
            cell = (TVChannelInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TVChannelInfoTableViewCell reuseIdentifier]];
            [(TVChannelInfoTableViewCell *)cell setIsExpanded:self.isExpanded];
            [(TVChannelInfoTableViewCell *)cell setCellWithLive:self.currentLive];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case 1:{
            cell =  (VideoCommentHeaderCell *)[tableView dequeueReusableCellWithIdentifier:[VideoCommentHeaderCell reuseIdentifier]];
            [(VideoCommentHeaderCell *)cell fillWithLive:currentLive];
            return cell;
            
        }
            break;
        case 2:{
            cell =  (VideoCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[VideoCommentTableViewCell reuseIdentifier]];
            if(indexPath.row < self.commentsArray.count){
                Comment *aComment = [self.commentsArray objectAtIndex:indexPath.row];
                [(VideoCommentTableViewCell *)cell fillCellWithComment:aComment];
            }
       }
            break;
        default:
            break;
    }
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == autoCompleteTableView){
        User *aUser = [self.userAutoCompleteArray objectAtIndex:indexPath.row];
        [keyboardView addTagWithUser:aUser];
    }else{
        if(isKeyboardShown){
            [keyboardView.chatTextView resignFirstResponder];
            
            emojiType = EmojiKeyboardTypeSticker;
            keyboardView.isStickerPresent = NO;
            keyboardView.stickerButton.selected = NO;
            [self hidingKeyboard];
            
            [self.myTableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        
        switch (indexPath.section) {
            case 0:
            {
                self.isExpanded = !self.isExpanded;
                NSMutableIndexSet *sets = [NSMutableIndexSet indexSetWithIndex:0];
    //            [sets addIndex:2];
                [self.myTableView reloadSections:sets withRowAnimation:UITableViewRowAnimationFade];
                
            }
                break;
           
            default:{
                //comment
                //check wether the comment is mine
                Comment *theComment = self.commentsArray[indexPath.row];
                if([theComment.comment_user.user_id isEqual:[User fetchLoginUser].user_id]){
                    NSString *title;
                    
                    Comment *theComment = self.commentsArray[indexPath.row];
                    self.currentCommentID = theComment.comment_id;
                    self.customIBAS = [[IBActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Hapus Komentar" otherButtonTitles: @"Tutup", nil];
                    self.customIBAS.tag = 100;
                    self.customIBAS.blurBackground = NO;
                    [self.customIBAS setFont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:14.0]];
                    
                    [self.customIBAS setButtonBackgroundColor:HEXCOLOR(0xFFFFFFFF)];
                    [self.customIBAS setButtonTextColor:HEXCOLOR(0x3399FFFF)];
                    [self.customIBAS setButtonTextColor:[UIColor redColor] forButtonAtIndex:1];
                    
                    self.customIBAS.buttonResponse = IBActionSheetButtonResponseFadesOnPress;
                    [self.customIBAS showInView:self.view];
                }else{
                    return;
                }
            }
                break;
        }
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


#pragma mark - IBActionSheet/UIActionSheet Delegate Method

// the delegate method to receive notifications is exactly the same as the one for UIActionSheet
- (void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0){

        [UIAlertView showWithTitle:self.appName
                           message:@"Anda yakin?"
                 cancelButtonTitle:@"Tidak"
                 otherButtonTitles:@[@"Ya"]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex != [alertView cancelButtonIndex]) {
                                
                                  [self.myTableView.pullToRefreshView startAnimating];
                                  [Comment deleteCommentWithLiveId:(NSNumber *)self.currentLive.live_id andCommentId:self.currentCommentID withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Comment *object) {
                                      [self.myTableView triggerPullToRefresh];
                                  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                      [self.myTableView.pullToRefreshView stopAnimating];
                                      
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
#pragma mark - IBAction
- (IBAction)restartVideoTapped:(id)sender {
    self.isPlaying = NO;
    [self getLiveDetailAndCommentFromServerForPage:@(self.currentPage)];
}


- (IBAction)playVideoTapped:(id)sender {
    if([self.currentLive.live_premium boolValue] && notAllowedToWatch){
        return;
    }
    if(!isPlaying){
        NSURL *movieURL = [NSURL URLWithString:self.currentLive.live_hls.hls_url];
    //    Initialize a movie player object with the specified URL
        self.moviePlayer = nil;
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        
        playerViewController.player = [AVPlayer playerWithURL:movieURL];
        
        self.moviePlayer = playerViewController;
        self.liveThumbnailImage.hidden = YES;
        self.moviePlayer.view.frame = self.videoContainerView.bounds;
        [self.videoContainerView addSubview:playerViewController.view];
        
        self.videoContainerView.autoresizesSubviews = TRUE;
        [self.moviePlayer.player play];
        self.isPlaying = YES;
    }

}

-(void)shareContent{
    NSString* someText = self.currentLive.live_shareable.shareable_content;
//    someText = @"Streaming Live di sini.";
    NSURL* linkText = [[NSURL alloc] initWithString: self.currentLive.live_shareable.shareable_url];
    NSArray* dataToShare = [NSArray arrayWithObjects: someText,linkText, nil];
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[ UIActivityTypePostToWeibo, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypePrint ];
    [self presentViewController:activityViewController animated:YES completion:^{}];

}

#pragma mark - IOS7 Orientation Change
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        
        self.buttonView.hidden = YES;
        self.videoPlayerTopConstraint.constant = 0.0;
        
    }else{
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
        self.buttonView.hidden = NO;
        self.videoPlayerTopConstraint.constant = 64.0;
    
    }
    self.autoCompleteTableView.hidden = YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [keyboardView.chatTextView resignFirstResponder];
    if(fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.view endEditing:YES];
        heightKeyboardViewConstraint.constant = 0;
        heightKeyboardiOSConstraint.constant = 0;
    }else{
    //    if(!(IS_IPAD))
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        heightKeyboardViewConstraint.constant = 45.0;
        heightKeyboardiOSConstraint.constant = heightKeyboardiOSConstraintTemp;
    }
}

#pragma mark - IOS8 Orientation Change
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [keyboardView.chatTextView resignFirstResponder];
    [self.videoContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         // do whatever
         if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
             
             heightKeyboardViewConstraint.constant = 0;
             heightKeyboardiOSConstraint.constant = 0;
             self.videoPlayerTopConstraint.constant = 0;
             
             [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
             self.navigationController.interactivePopGestureRecognizer.enabled = NO;
             [self.navigationController setNavigationBarHidden:YES animated:YES];
             
             if(IS_IPAD){
                 self.videoPlayerAspectRationConstraint.active = NO;
                 self.videoPlayerBottomConstraint.constant = 0;
                 self.videoPlayerBottomConstraint.active = YES;
             }
             self.myTableView.hidden = YES;
             [self.view endEditing:YES];
         }else{
             
             heightKeyboardViewConstraint.constant = 45.0;
             heightKeyboardiOSConstraint.constant = heightKeyboardiOSConstraintTemp;
             self.videoPlayerTopConstraint.constant = 64.0;
             
             [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
             self.navigationController.interactivePopGestureRecognizer.enabled = YES;
             self.myTableView.hidden = NO;
             if(IS_IPAD){
                 self.videoPlayerAspectRationConstraint.active = YES;
                 self.videoPlayerBottomConstraint.active = NO;
             }
             
             [self.navigationController setNavigationBarHidden:NO animated:YES];
         }
         
         self.autoCompleteTableView.hidden = YES;
         self.liveThumbnailImage.frame = self.videoContainerView.bounds;
         self.playButton.center = self.liveThumbnailImage.center;
         
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         // do whatever

     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
}

#pragma mark - MPMoviewPlayerNotification
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"rate"]) {
        if ([self.moviePlayer.player rate]) {
           
        }
        else {
           
        }
    }
}

//- (void)MPMoviePlayerPlaybackStateDidChange:(NSNotification *)notification
//{
//    NSString *state;
//    switch (self.moviePlayer.playbackState) {
//        case 0:{
//            state = @"MPMoviePlaybackStateStopped";
//            self.liveThumbnailImage.hidden = NO;
//            self.moviePlayer = nil;
//            self.isPlaying = NO;
//            self.playButton.hidden = NO;
//        }
//            break;
//        case 1:{
//            state = @"MPMoviePlaybackStatePlaying";
//            self.isPlaying = YES;
//            self.liveThumbnailImage.hidden = YES;
//            self.playButton.hidden = YES;
//        }
//            break;
//        case 2:{
//            state = @"MPMoviePlaybackStatePaused";
//            self.isPlaying = NO;
//            self.playButton.hidden = NO;
//        }
//            break;
//        case 3:{
//            state = @"MPMoviePlaybackStateInterrupted";
//        }
//            break;
//        case 4:{
//            state = @"MPMoviePlaybackStateSeekingForward";
//        }
//            break;
//        case 5:{
//            state = @"MPMoviePlaybackStateSeekingBackward";
//        }
//            break;
//            
//        default:
//            break;
//    }
//    NSLog(@"playback state%@",state);
//    
//}
//
//- (void)MPMoviePlayerLoadStateDidChange:(NSNotification *)notification
//{
//
//
//
//    NSString *state = @"MPMovieLoadStateUnknown";
//    
//    MPMoviePlayerController *player = notification.object;
//    MPMovieLoadState loadState = player.loadState;
//    /* The load state is not known at this time. */
//    if (loadState & MPMovieLoadStateUnknown)
//    {
//        
//    }
//    
//    /* The buffer has enough data that playback can begin, but it
//     may run out of data before playback finishes. */
//    if (loadState & MPMovieLoadStatePlayable)
//    {
//        state = @"MPMovieLoadStatePlayable";
//    }
//    
//    /* Enough data has been buffered for playback to continue uninterrupted. */
//    if (loadState & MPMovieLoadStatePlaythroughOK)
//    {
//        // Add an overlay view on top of the movie view
//        state = @"MPMovieLoadStatePlaythroughOK";
//    }
//    
//    /* The buffering of data has stalled. */
//    if (loadState & MPMovieLoadStateStalled)
//    {
//        state = @"MPMovieLoadStateStalled";
//        [self.moviePlayer pause];
//    }
//    
//    NSLog(@"load state : %@ : %lu",state,(unsigned long)self.moviePlayer.loadState);
//    
//}
//
//- (void)MPMoviePlayerPlaybackDidFinishReasonUserInfoKey:(NSNotification *)notification
//{
//    
//    NSLog(@"playback didfinish %@",notification.userInfo);
//    
//}

#pragma mark - Payment Notification Handler
-(void)paymentDidSuccess:(NSNotification *)notif{
    self.notAllowedToWatch = NO;
    [self.myTableView triggerPullToRefresh];
    [self playVideoTapped:nil];
}

#pragma mark - PackageListVC Delegate
-(void)didClosePackageList{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Faye Client Delegate
- (void)fayeClient:(MZFayeClient *)client didConnectToURL:(NSURL *)url
{
    NSLog(@"%@",url);
}
- (void)fayeClient:(MZFayeClient *)client didDisconnectWithError:(NSError *)error
{
    NSLog(@"%@",error);
}
- (void)fayeClient:(MZFayeClient *)client didUnsubscribeFromChannel:(NSString *)channel
{
    NSLog(@"%@",channel);
}
- (void)fayeClient:(MZFayeClient *)client didSubscribeToChannel:(NSString *)channel
{
    NSLog(@"%@",channel);
}
- (void)fayeClient:(MZFayeClient *)client didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}
- (void)fayeClient:(MZFayeClient *)client didFailDeserializeMessage:(NSDictionary *)message
         withError:(NSError *)error
{
    NSLog(@"%@",error);
}
- (void)fayeClient:(MZFayeClient *)client didReceiveMessage:(NSDictionary *)messageData fromChannel:(NSString *)channel
{
    NSLog(@"comment : %@",[messageData description]);
    ClipStats *newClipStats = [ClipStats initWithJSONString:[messageData description]];
    self.currentLive.live_clip_stat = newClipStats;
    self.newestComment = [Comment initWithJSONString:[messageData description]];    
    [self reloadData];
}

#pragma mark - DMKeyboardViewDelegate
-(void)DMKeyboardViewDelegateResizeTextBox:(DMKeyboardView *)chatView withHeight:(CGFloat)boxHeight{
    
    heightKeyboardiOSConstraint.constant = boxHeight - 45.0;
    heightKeyboardiOSConstraintTemp = heightKeyboardiOSConstraint.constant;
}


-(void)DMKeyboardViewDelegateAutoComplete:(DMKeyboardView *)chatView withArray:(NSArray *)userArray{
    autoCompleteTableView.hidden = userArray.count == 0;
    userAutoCompleteArray = [NSArray arrayWithArray:userArray];
    [autoCompleteTableView reloadData];
}

-(void)DMKeyboardViewDelegateStickerTapped:(DMKeyboardView *)chatView{
    if(chatView.isStickerPresent){
        emojiType = EmojiKeyboardTypeSticker;
        [self showingKeyboardWithSize:CGSizeMake(TheAppDelegate.deviceWidth, 270.0)];
    }
}

-(void)DMKeyboardViewDelegateNeedToLogin:(DMKeyboardView *)chatView{
    [self presentViewController:[[HomeViewController alloc] initByPresenting] animated:YES completion:nil];
}

-(void)DMKeyboardViewDelegateSendComment:(DMKeyboardView *)chatView WithContent:(NSString *)content andTaggedUser:(NSArray *)userArray{
    
    if([content isEqualToString:@""] && userArray.count == 0)
        return;
    
    heightKeyboardiOSConstraint.constant = 0.0;
    
    if(![User fetchLoginUser]){
        
        [UIAlertView showWithTitle:self.appName
                           message:@"Anda harus login untuk menambahkan komentar."
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                                  if (self.moviePlayer) {
                                      //teguh
                                      //[self.moviePlayer stop];
                                      [self.moviePlayer.player pause];
                                  }
                                  [self presentViewController:[[HomeViewController alloc] initByPresenting] animated:YES completion:nil];
                              }
                          }];
        
    }else{
        
        [self.view startLoader:YES disableUI:YES];
        [Comment postCommentWithLiveId:(NSNumber *)self.currentLive.live_id andCommentContent:content andTaggedUser:userArray withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Comment *object) {
            NSData *responseData = operation.HTTPRequestOperation.responseData;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:responseData
                                  options:NSJSONReadingMutableLeaves
                                  error:nil];
            self.currentLive.live_clip_stat.clip_stats_comments = json[@"live"][@"stats"][@"comments"];
            self.currentLive.live_clip_stat.clip_stats_likes = json[@"live"][@"stats"][@"likes"];
            self.currentLive.live_clip_stat
            .clip_stats_views = json[@"live"][@"stats"][@"views"];
            //            [self.myTableView triggerPullToRefresh]; // refresh from the start
            [self.view startLoader:NO disableUI:NO];
            
            self.newestComment = object;
            [self reloadData];
            [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self.view startLoader:YES disableUI:YES];
            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                [self.view startLoader:NO disableUI:NO];
            }
        }];
    }
}

-(void)DMKeyboardViewDelegateSendComment:(DMKeyboardView *)chatView WithStickerId:(NSString *)stickerId{
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *liveId = [f numberFromString:self.currentLive.live_id];
    
    [self.view startLoader:YES disableUI:YES];
    [Comment postCommentWithLiveId:liveId andStickerId:stickerId withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Comment *object) {
        
        NSData *responseData = operation.HTTPRequestOperation.responseData;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
        self.currentLive.live_clip_stat.clip_stats_comments = json[@"live"][@"stats"][@"comments"];
        self.currentLive.live_clip_stat.clip_stats_likes = json[@"live"][@"stats"][@"likes"];
        self.currentLive.live_clip_stat
        .clip_stats_views = json[@"live"][@"stats"][@"views"];
        //            [self.myTableView triggerPullToRefresh]; // refresh from the start
        [self.view startLoader:NO disableUI:NO];
        
        self.newestComment = object;
        [self reloadData];
        [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self.view startLoader:NO disableUI:NO];
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
            
            [self.view startLoader:NO disableUI:NO];
            [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
        }
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    keyboardView.isStickerPresent = NO;
    keyboardView.stickerButton.selected = keyboardView.isStickerPresent;
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if(emojiType == EmojiKeyboardTypeShown && !(IS_IPAD)){
        keyboardSize.height = 254.0;
    }else if(emojiType == EmojiKeyboardTypeHide && !(IS_IPAD)){
        keyboardSize.height = 215.0;
    }
    
    if (emojiType == EmojiKeyboardTypeInitiate){
        
        emojiType = EmojiKeyboardTypeShown;
        
    }else if(emojiType == EmojiKeyboardTypeHide && keyboardSize.height < 253.0){
        
        emojiType = EmojiKeyboardTypeShown;
        
    }else if(emojiType == EmojiKeyboardTypeShown && !(IS_IPAD)){
        
        emojiType = EmojiKeyboardTypeHide;
    }else if(emojiType == EmojiKeyboardTypeSticker){
        
        emojiType = EmojiKeyboardTypeShown;
    }
    
    [self showingKeyboardWithSize:keyboardSize];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    emojiType = EmojiKeyboardTypeInitiate;
    
    if(!keyboardView.isStickerPresent){
        [self hidingKeyboard];
    }
}


-(void)showingKeyboardWithSize:(CGSize)someSize{
    
    isKeyboardShown = YES;
    CGFloat height = keyboardView.isStickerPresent?0.0:45.0;
    heightKeyboardViewConstraint.constant = someSize.height + height;
    
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)hidingKeyboard{
    
    isKeyboardShown = NO;
    heightKeyboardViewConstraint.constant = 45.0;
    
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
