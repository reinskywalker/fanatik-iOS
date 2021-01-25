//
//  VideoDetailViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/14/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "VideoDetailViewController.h"
#import "VideoInfoTableViewCell.h"
#import "VideoCommentTableViewCell.h"
#import "TimelineViewController.h"
#import "PostDialogViewController.h"
#import "CustomTableView.h"
#import <AVFoundation/AVFoundation.h>
#import "UserMentionTableViewCell.h"

@interface VideoDetailViewController ()<VideoInfoTableViewCellDelegate, IBActionSheetDelegate, UIActionSheetDelegate, SearchClipTableViewCellDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, assign) BOOL isExpanded;
@property(nonatomic, retain) Pagination *currentPagination;
@property(nonatomic, assign) NSNumber *currentPage;
@property(nonatomic, assign) BOOL isVideoLoaded;
@property(nonatomic, assign) BOOL shouldChangeVideo;
@property(nonatomic, assign) BOOL shouldIncreaseView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerTopConstraint;
@property (strong, nonatomic) IBOutlet UIImageView *videoThumbnailImageView;
@property (nonatomic, retain) NSNumber *currentCommentID;
@property (nonatomic, retain) IBActionSheet *customIBAS;
@property (nonatomic,assign) BOOL isFinishedLoading;
@property (nonatomic,assign) BOOL isFirstTimeLoad;
@property (nonatomic,assign) BOOL notAllowedToWatch;
@property (nonatomic, assign) CGRect videoContainerNormalFrame;
@property (nonatomic, assign) BOOL isCommentReloading;
@property (nonatomic, retain) NSNumber *currentClipID;
@property (nonatomic, retain) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UIButton *btnPlay;
@property(nonatomic, assign) EmojiKeyboardType emojiType;
@property (nonatomic, assign) BOOL isBack;
@property (nonatomic, assign) BOOL isKeyboardShown;
@property (nonatomic, copy) NSString *visitorId;
@property (nonatomic, copy) NSString *visitorStringId;

- (IBAction)btnPlayTapped:(id)sender;
@end

@implementation VideoDetailViewController
@synthesize currentClip, youtubePlayer, commentsArray, relatedClipsArray, currentPagination, videoPlayerTopConstraint, notAllowedToWatch, videoContainerNormalFrame, isCommentReloading, currentClipID, customIBAS, formSheet;
@synthesize refreshControl, isBack, emojiType, keyboardView, isKeyboardShown, autoCompleteTableView;
@synthesize userAutoCompleteArray;

-(id)initWithClip:(Clip *)aClip{
    if(self=[super init]){
        self.currentClip = aClip;
        self.shouldIncreaseView = YES;
        self.commentsArray = [NSMutableArray new];
        self.relatedClipsArray = [NSMutableArray new];
        self.userAutoCompleteArray = [NSArray new];
        self.isBack = NO;
        self.emojiType = EmojiKeyboardTypeInitiate;
        self.visitorId = @"";
        self.visitorStringId = @"";
    }
    return self;
}

-(id)initWithClipId:(NSNumber *)clipID{
    if(self=[super init]){
        self.currentClipID = clipID;
        self.shouldIncreaseView = YES;
        self.commentsArray = [NSMutableArray new];
        self.relatedClipsArray = [NSMutableArray new];
        self.userAutoCompleteArray = [NSArray new];
        self.isBack = NO;
        self.emojiType = EmojiKeyboardTypeInitiate;
        self.visitorId = @"";
        self.visitorStringId = @"";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPageCode = MenuPageVideoDetail;
    [self configureView];
    
    self.shouldChangeVideo = YES;
    self.isFirstTimeLoad = YES;
    [self.videoThumbnailImageView setBackgroundColor:[UIColor blackColor]];
    [self.videoThumbnailImageView sd_setImageWithURL:[NSURL URLWithString:self.currentClip.clip_video.video_thumbnail.thumbnail_480]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentDidSuccess:) name:kPaymentCompleted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentDidFail:) name:kPaymentFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullToRefreshTable) name:kLoginCompletedNotification object:nil];
    
    [self reloadData];
    
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.myTableView startLoader:YES disableUI:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerPlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
}

-(void)configureView{
    
    self.videoContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, 0, 0)];
    CGRect videoContainerDestFrame = self.videoContainerView.frame;
    videoContainerDestFrame.origin.y = 64;
    videoContainerDestFrame.size.width = [UIScreen mainScreen].bounds.size.width;
    videoContainerDestFrame.size.height = videoContainerDestFrame.size.width * 56.25 / 100;//floor((videoContainerDestFrame.size.width / 16)*9);
    self.videoContainerView.frame = videoContainerDestFrame;
    [self.view addSubview:self.videoContainerView];
    self.videoContainerNormalFrame = videoContainerDestFrame;
    
    CGRect videoPlayerDestFrame = videoContainerDestFrame;
    videoPlayerDestFrame.origin.y = 0;
    self.youtubePlayer = [[YTPlayerView alloc] initWithFrame:videoPlayerDestFrame];
    [self.youtubePlayer setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self.videoContainerView addSubview:self.youtubePlayer];

    self.videoThumbnailImageView = [[UIImageView alloc] initWithFrame:videoContainerDestFrame];
    [self.videoThumbnailImageView setContentMode:UIViewContentModeScaleAspectFill];
    CGRect videoThumbnailDestFrame = videoContainerDestFrame;
    videoThumbnailDestFrame.origin.y = 0;
    self.videoThumbnailImageView.frame = videoThumbnailDestFrame;
    [self.videoContainerView addSubview:self.videoThumbnailImageView];
    
    self.btnPlay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 47)];
    [self.btnPlay setImage:[UIImage imageNamed:@"btnPlay"] forState:UIControlStateNormal];
    [self.btnPlay setImage:[UIImage imageNamed:@"btnPlay"] forState:UIControlStateHighlighted];
    [self.btnPlay setImage:[UIImage imageNamed:@"btnPlay"] forState:UIControlStateSelected];
    [self.btnPlay addTarget:self action:@selector(btnPlayTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.btnPlay.center = self.videoThumbnailImageView.center;
    self.btnPlay.hidden = YES;
    [self.videoContainerView addSubview:self.btnPlay];
    
    self.keyboardView = [[DMKeyboardView alloc] initWithFrame:CGRectMake(0, TheAppDelegate.deviceHeight - 45.0, TheAppDelegate.deviceWidth, 270.0)];
    [keyboardView initializeView];
    keyboardView.delegate = self;
    keyboardView.canTagging = YES;
    [self.view addSubview:keyboardView];
    
    self.myTableView = [[CustomTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    CGRect myTableDestFrame = self.myTableView.frame;
    myTableDestFrame.origin.x = 0;
    myTableDestFrame.origin.y = videoContainerDestFrame.origin.y + videoContainerDestFrame.size.height;
    myTableDestFrame.size.height = TheAppDelegate.deviceHeight - myTableDestFrame.origin.y - 45.0;
    myTableDestFrame.size.width = TheAppDelegate.deviceWidth;
    self.myTableView.frame = myTableDestFrame;
    [self.view addSubview:self.myTableView];
    
    self.autoCompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, TheAppDelegate.deviceWidth, TheAppDelegate.deviceHeight - 270.0 - 50.0) style:UITableViewStylePlain];
    [self.view addSubview:self.autoCompleteTableView];
    self.autoCompleteTableView.hidden = YES;
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    if(self.isFirstTimeLoad){
        self.youtubePlayer.delegate = self;
        if([self.currentClip.clip_video.video_type isEqualToString:@"Youtube"]){
            [self reloadVideo];
        }
        
        self.currentPage = @1;
        
        [self.myTableView registerNib:[UINib nibWithNibName:[VideoCommentHeaderCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[VideoCommentHeaderCell reuseIdentifier]];
        [self.myTableView registerNib:[UINib nibWithNibName:[VideoInfoTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([VideoInfoTableViewCell class])];
        [self.myTableView registerNib:[UINib nibWithNibName:[SearchClipTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([SearchClipTableViewCell class])];
        [self.myTableView registerNib:[UINib nibWithNibName:[VideoCommentTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([VideoCommentTableViewCell class])];
        [self.autoCompleteTableView registerNib:[UINib nibWithNibName:[UserMentionTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([UserMentionTableViewCell class])];
        
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        self.autoCompleteTableView.delegate = self;
        self.autoCompleteTableView.dataSource = self;
        
        self.refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(pullToRefreshTable) forControlEvents:UIControlEventValueChanged];
        [self.myTableView addSubview:refreshControl];
        
        __weak typeof(self) weakSelf = self;
        // load more content when scroll to the bottom most
        [self.myTableView addInfiniteScrollingWithActionHandler:^{
            if(weakSelf.currentPage && [weakSelf.currentPage intValue] > 0){
                [weakSelf getRelatedVideoAndCommentFromServerForPage:weakSelf.currentPage];
            }else{
                weakSelf.myTableView.showsInfiniteScrolling = NO;
                [weakSelf.myTableView.pullToRefreshView stopAnimating];
                [weakSelf.myTableView.infiniteScrollingView stopAnimating];
            }
        }];
        
        [self getRelatedVideoAndCommentFromServerForPage:0];
        
        self.isFirstTimeLoad = NO;
    }else{
        if (self.notAllowedToWatch) {
            [self.myTableView triggerPullToRefresh];
        }else{
            [self reloadVideo];
        }
    }
    
    [[AVAudioSession sharedInstance]
     setCategory: AVAudioSessionCategoryPlayback
     error: nil];
    
    NSLog(@"APPEAR");
}

-(void)pullToRefreshTable{
    [self.myTableView setContentOffset:CGPointMake(0, -1.0f * self.refreshControl.frame.size.height) animated:YES];
    [self.refreshControl beginRefreshing];
    self.currentPagination.current_page = @(1);
    [self.commentsArray removeAllObjects];
    [self.myTableView reloadData]; // before load new content, clear the existing table list
    [self getRelatedVideoAndCommentFromServerForPage:0]; // load new data
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

-(void)viewWillAppear:(BOOL)animated{
    self.pageObjectName = self.currentClip.clip_video.video_title;
    [super viewWillAppear:animated];
    self.currentPageCode = MenuPageVideoDetail;

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

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.moviePlayer stop];
    [self.youtubePlayer stopVideo];
    self.videoThumbnailImageView.hidden = NO;
}

-(void)reloadVideo{
    
    if([self.currentClip.clip_video.video_is_premium boolValue] && notAllowedToWatch){
        return;
    }
    if([self.currentClip.clip_video.video_type isEqualToString:@"Youtube"]){
        self.youtubePlayer.hidden = NO;
        self.moviePlayer.view.hidden = YES;
        
        if(!self.isVideoLoaded){
            NSDictionary *playerVars = @{
                                         @"controls" : @"1",
                                         @"playsinline" : @"1",
                                         @"autohide" : @"1",
                                         @"showinfo" : @"1",
                                         @"autoplay" : @"1",
                                         @"fs" : @"1",
                                         @"rel" : @"0",
                                         @"loop" : @"0",
                                         @"enablejsapi" : @"1",
                                         @"modestbranding" : @"1",
                                         };
            [self.youtubePlayer loadWithVideoId:currentClip.clip_video.video_media_id playerVars:playerVars];
            self.isVideoLoaded = YES;
    
        }else{
            
            if(!isBack){
                self.videoThumbnailImageView.hidden = YES;
                [self.youtubePlayer cueVideoById:currentClip.clip_video.video_media_id startSeconds:0.0 suggestedQuality:kYTPlaybackQualityMedium];
                
                [self.youtubePlayer playVideo];
            }
        }
    }else{
        //non youtube video
        self.shouldChangeVideo = NO;
        self.youtubePlayer.hidden = YES;
        self.moviePlayer.view.hidden = NO;
        
        NSURL *movieURL = [NSURL URLWithString:self.currentClip.clip_video.video_hls.hls_url];
        if(!self.moviePlayer){
            self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
            self.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
            
            [self.moviePlayer.view setFrame:self.videoContainerView.bounds];
            [self.moviePlayer.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
            self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
            [self.videoContainerView insertSubview:self.moviePlayer.view aboveSubview:self.videoThumbnailImageView];
        }else{
            self.moviePlayer.contentURL = movieURL;
        }
        
        [self btnPlayTapped:nil];
    }
    
}

-(void)backButtonTapped{
    [self.moviePlayer stop];
    [self.youtubePlayer stopVideo];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)reloadData{
    UIButton *lButton = [TheAppDelegate createButtonWithTitle:nil imageName:@"leftArrow" highlightedImageName:@"leftArrowHighlight" forLeftButton:YES];
    [lButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)shareContent{
    NSString* someText = self.currentClip.clip_shareable.shareable_content;
    //    someText = @"Streaming Live di sini.";
    NSURL* linkText = [[NSURL alloc] initWithString: self.currentClip.clip_shareable.shareable_url];
    NSArray* dataToShare = [NSArray arrayWithObjects: someText,linkText, nil];
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[ UIActivityTypePostToWeibo, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypePrint ];
    if(IS_IPAD){
        if ( [activityViewController respondsToSelector:@selector(popoverPresentationController)] ) { // iOS8 activityViewController.popoverPresentationController.sourceView = _shareItem;
            activityViewController.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
        }
    }
    
    if (self.moviePlayer) {
        [self.moviePlayer stop];
    }
    [self presentViewController:activityViewController animated:YES completion:^{}];
}

#pragma mark - IOS7 Orientation Change
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        self.myTableView.hidden = YES;
        CGRect destFrame = self.videoContainerView.frame;
        destFrame.origin.y = 0;
        destFrame.size = [[UIScreen mainScreen] bounds].size;
        self.videoContainerView.frame = destFrame;
    }else{
        self.myTableView.hidden = NO;
        self.myTableView.hidden = YES;
        self.videoContainerView.frame = videoContainerNormalFrame;
    }
    self.autoCompleteTableView.hidden = YES;
    self.videoThumbnailImageView.frame = self.videoContainerView.bounds;
    self.btnPlay.center = self.videoThumbnailImageView.center;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    if(fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        [self.view endEditing:YES];
    }else{
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

#pragma mark - IOS8 Orientation Change

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.youtubePlayer setTranslatesAutoresizingMaskIntoConstraints:NO];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         // do whatever
         if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
             self.myTableView.hidden = YES;
             CGRect destFrame = self.videoContainerView.frame;
             destFrame.origin.y = 0;
             destFrame.size = [[UIScreen mainScreen] bounds].size;
             self.videoContainerView.frame = destFrame;
             
             self.navigationController.interactivePopGestureRecognizer.enabled = NO; 
             [self.view endEditing:YES];
         }else{
             self.myTableView.hidden = NO;
             self.videoContainerView.frame = videoContainerNormalFrame;
             
             self.navigationController.interactivePopGestureRecognizer.enabled = YES;
         }
         self.videoThumbnailImageView.frame = self.videoContainerView.bounds;
         self.btnPlay.center = self.videoThumbnailImageView.center;
         autoCompleteTableView.hidden = YES;
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         // do whatever
         if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
             [self.navigationController setNavigationBarHidden:YES animated:YES];
         }else{
             [self.navigationController setNavigationBarHidden:NO animated:YES];
         }
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
}

#pragma mark - ServerRequest

-(void)getRelatedVideoAndCommentFromServerForPage:(NSNumber *)pageNum{
    if(isCommentReloading)
        return;
    isCommentReloading = YES;
    NSNumber *clipID;
    if (currentClip == nil) {
        clipID = currentClipID;
    }else{
        clipID = currentClip.clip_id;
    }
    
    [Clip getClipWithId:clipID andPageNumber:pageNum withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Clip *object) {
        
        [self.myTableView setContentOffset:CGPointZero animated:YES];
        [self.refreshControl endRefreshing];
        
        isCommentReloading = NO;
        [self.myTableView startLoader:NO disableUI:NO];
        int vidRow = (int)self.relatedClipsArray.count;
        self.isFinishedLoading = YES;
        if(vidRow==0){
            NSArray *sortedArray = [object.clip_related_clips.allObjects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"clip_position" ascending:YES], nil]];
            [self.relatedClipsArray addObjectsFromArray:sortedArray];
        }
        int commentRow = (int)[self.commentsArray count];
        NSArray *sortedCommentsArray = [object.clip_comment.allObjects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"comment_id" ascending:NO], nil]];
        [self.commentsArray addObjectsFromArray:sortedCommentsArray];
        self.currentPagination = object.clip_pagination;
        self.currentClip = object;
        if([self.currentClip.clip_video.video_type isEqualToString:@"Viostream"] && pageNum == 0 && self.shouldChangeVideo)
        {
            [self reloadVideo];
            
        }
        
        
        // if no more result
        if (sortedCommentsArray == 0) {
            self.myTableView.showsInfiniteScrolling = NO;
            return;
        }
        
        self.currentPage = self.currentPagination.next_page; // increase the page number
        
        
        // store the items into the existing list
        
        [self reloadTableViewWithCommentsArray:self.commentsArray andRelatedVideoArray:self.relatedClipsArray commentStartRow:commentRow andVideoStartRow:vidRow];
        if(self.currentClipID != nil){
            //init
            [self reloadVideo];
            [self.myTableView reloadData];
        }
        
        // clear the pull to refresh & infinite scroll, this 2 lines very important
        [self.myTableView.pullToRefreshView stopAnimating];
        [self.myTableView.infiniteScrollingView stopAnimating];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        [self.myTableView setContentOffset:CGPointZero animated:YES];
        [self.refreshControl endRefreshing];
        
        WRITE_LOG(error.localizedDescription);
        isCommentReloading = NO;
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        
        NSDictionary *errorDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"=======:%@",errorDict);
        
        NSArray *errorArray =  (NSArray*)errorDict[@"error"][@"messages"];
        NSString *tempErrorString = @"";
        for(NSString *str in errorArray){
            tempErrorString = [tempErrorString stringByAppendingString:[NSString stringWithFormat:@"%@\n", str]];
        }
    
        if(!isBack){
            if(statusCode == StatusCodeNotLoggedIn){
                [UIAlertView showWithTitle:self.appName
                                   message:tempErrorString
                         cancelButtonTitle:@"Close"
                         otherButtonTitles:@[@"Login"]
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      
                                      if (self.moviePlayer) {
                                          [self.moviePlayer stop];
                                      }
                                      self.notAllowedToWatch = YES;
                                      
                                      if (buttonIndex != [alertView cancelButtonIndex]) {
                                          
                                          [[NSNotificationCenter defaultCenter] postNotificationName:kOpenLoginPageNotification object:nil];
                                      }
                                  }];

            }else if(statusCode == StatusCodePremiumContent){
            
                [UIAlertView showWithTitle:self.appName
                                   message:tempErrorString
                         cancelButtonTitle:@"Close"
                         otherButtonTitles:@[@"Subscribe"]
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      
                                      if (self.moviePlayer) {
                                          [self.moviePlayer stop];
                                      }
                                      self.notAllowedToWatch = YES;
                                      
                                      if (buttonIndex != [alertView cancelButtonIndex]) {
                                        
                                          TheSettingsManager.lastMenuPurchasing = MenuPageVideoDetail;
                                          [TheServerManager openPackagesForContentClass:ContentClassVideo withID:[self.currentClip.clip_video.video_id stringValue]];
                                      }
                                  }];
                
            }
        }
        
        [self.myTableView.pullToRefreshView stopAnimating];
        [self.myTableView.infiniteScrollingView stopAnimating];
        [self.myTableView startLoader:NO disableUI:NO];
    }];
}



- (void)reloadTableViewWithCommentsArray:(NSMutableArray*)cArray andRelatedVideoArray:(NSMutableArray *)vArray commentStartRow:(int)cStartRow andVideoStartRow:(int)vStartRow;
{
    // the last row after added new items
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (; vStartRow < relatedClipsArray.count; vStartRow++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:vStartRow inSection:1]];
    }
    for (; cStartRow < commentsArray.count; cStartRow++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:cStartRow inSection:3]];
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
                VideoInfoTableViewCell *cell = (VideoInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[VideoInfoTableViewCell reuseIdentifier]];
                [cell fillCellWithClip:currentClip];
                cell.isExpanded = self.isExpanded;
                return [cell cellHeight];
            }
                break;
            case 1:{
                return 85.0;
            }
                break;
            case 2 :{
                return 60.0;
            }
                break;
            case 3:{
                VideoCommentTableViewCell *cell = (VideoCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[VideoCommentTableViewCell reuseIdentifier]];
                Comment *aComment = [self.commentsArray objectAtIndex:indexPath.row];
                [cell fillCellWithComment:aComment];
                return [cell cellHeight];
            }
                break;
            default:
                return 65.0;
                break;
        }
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == autoCompleteTableView)
        return 1;
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == autoCompleteTableView)
        return userAutoCompleteArray.count;
    
    switch (section) {
        case 1:{
            return self.relatedClipsArray.count > 5 ? 5 : self.relatedClipsArray.count;
        }
            break;
        case 3:{
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
            cell = (VideoInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[VideoInfoTableViewCell reuseIdentifier]];
            [(VideoInfoTableViewCell *)cell setIsExpanded:self.isExpanded];
            [(VideoInfoTableViewCell *)cell setDelegate:self];
            [(VideoInfoTableViewCell *)cell fillCellWithClip:currentClip];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case 1:{
            Clip *aClip = [self.relatedClipsArray objectAtIndex:indexPath.row];
            SearchClipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SearchClipTableViewCell reuseIdentifier]];
            cell.delegate = self;
            [cell fillWithClip:aClip];
            cell.separatorView.hidden = NO;
            return cell;
        }
            break;
            
        case 2:{
            cell = (VideoCommentHeaderCell *)[tableView dequeueReusableCellWithIdentifier:[VideoCommentHeaderCell reuseIdentifier]];
            [(VideoCommentHeaderCell *)cell fillWithClip:self.currentClip];
            return cell;
        }
            break;
        case 3:{
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
            case 0:{
                self.isExpanded = !self.isExpanded;
                NSMutableIndexSet *sets = [NSMutableIndexSet indexSetWithIndex:0];
                [self.myTableView reloadSections:sets withRowAnimation:UITableViewRowAnimationAutomatic];
                
            }
                break;
            case 1:{
                self.shouldChangeVideo = YES;
                self.currentClip = [self.relatedClipsArray objectAtIndex:indexPath.row];
                [self.relatedClipsArray removeAllObjects];
                
                self.videoThumbnailImageView.hidden = NO;
                [self.videoThumbnailImageView sd_setImageWithURL:[NSURL URLWithString:self.currentClip.clip_video.video_thumbnail.thumbnail_480]];
                
                self.shouldIncreaseView = YES;
                self.notAllowedToWatch = NO;
                
                if([self.currentClip.clip_video.video_type isEqualToString:@"Youtube"]){
                    [self.moviePlayer stop];
                    self.btnPlay.hidden = YES;
                    [self reloadVideo];
                }else{
                    [self.youtubePlayer stopVideo];
                }
                [self reloadData];
                
                [self.myTableView setContentOffset:CGPointZero animated:NO];
                [self pullToRefreshTable];
            }
                break;
                
            case 2:{
                return;
            }
                break;
                
            default:{
                //comment
                //check wether the comment is mine
                Comment *theComment = self.commentsArray[indexPath.row];
                if([theComment.comment_user.user_id isEqualToString:CURRENT_USER_ID()]){
                    NSString *title;
                    
                    Comment *theComment = self.commentsArray[indexPath.row];
                    self.currentCommentID = theComment.comment_id;
                    self.customIBAS = [[IBActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Delete Comment" otherButtonTitles: @"Close", nil];
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
    [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    if(actionSheet.tag == 100){
        if(buttonIndex == 0){
            
            [UIAlertView showWithTitle:self.appName
                               message:@"Are you sure?"
                     cancelButtonTitle:@"No"
                     otherButtonTitles:@[@"Yes"]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex != [alertView cancelButtonIndex]) {
                                      
                                      [self.myTableView.pullToRefreshView startAnimating];
                                      [Comment deleteCommentWithClipId:(NSNumber *)self.currentClip.clip_id andCommentId:self.currentCommentID withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Comment *object) {
                                          [self pullToRefreshTable];
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
}

#pragma mark - IBAction
- (IBAction)btnPlayTapped:(id)sender {

    if(!isBack){
        self.btnPlay.hidden = YES;
        [self.moviePlayer play];
    }
}

#pragma mark - Custom Cell Delegate
-(void)moreButtonDidTapForClip:(Clip *)clip{
    self.currentClip = clip;
    [self moreButtonTappedForClip:clip];
}

-(void)userButtonDidTap{
    
    [self.moviePlayer stop];
    [self.youtubePlayer stopVideo];
    
    ProfileViewController *vc = [[ProfileViewController alloc] initWithUser:currentClip.clip_user];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)commentButtonDidTap{
    if(self.isFinishedLoading){
        NSIndexPath *idx = self.commentsArray.count > 0 ? [NSIndexPath indexPathForRow:0 inSection:2] : [NSIndexPath indexPathForRow:self.relatedClipsArray.count > 5 ? 4 : self.relatedClipsArray.count-1 inSection:1];
        [self.myTableView scrollToRowAtIndexPath:idx atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

-(void)showingErrorFromServer:(NSString *)errorStr{
    [self showAlertWithMessage:errorStr];
}

-(void)likeButtonDidTap{
    if(![User fetchLoginUser]){
        
        [UIAlertView showWithTitle:self.appName
                           message:@"Anda harus login untuk menyukai video ini."
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                                  if (self.moviePlayer) {
                                      [self.moviePlayer stop];
                                  }
                                  [self presentViewController:[[HomeViewController alloc] initByPresenting] animated:YES completion:nil];
                              }
                          }];
    }else{
        if([currentClip.clip_liked boolValue]){
            [ClipStats unlikeClipWithId:currentClip.clip_id withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                currentClip.clip_liked = @NO;
                currentClip.clip_stats.clip_stats_likes = @([currentClip.clip_stats.clip_stats_likes integerValue] - 1);
                NSIndexSet *sets = [NSIndexSet indexSetWithIndex:0];
                [self.myTableView reloadSections:sets withRowAnimation:UITableViewRowAnimationFade];
                [self reloadData];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                }
            }];
        }else{
            [ClipStats likeClipWithId:currentClip.clip_id withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                currentClip.clip_liked = @YES;
                currentClip.clip_stats.clip_stats_likes = @([currentClip.clip_stats.clip_stats_likes integerValue] + 1);
                NSIndexSet *sets = [NSIndexSet indexSetWithIndex:0];
                [self.myTableView reloadSections:sets withRowAnimation:UITableViewRowAnimationFade];
                [self reloadData];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                }
            }];
        }
    }
}

-(void)shareButtonDidTap{
    [self shareContent];
}
-(void)addPlaylistButtonDidTap{
    if(![User fetchLoginUser]){
        if (self.moviePlayer) {
            [self.moviePlayer stop];
        }
    }
    [self addToPlaylist:currentClip];
}

#pragma mark - YTPlayerViewDelegate
- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView{
    self.videoThumbnailImageView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Playback started" object:self];
    [self.youtubePlayer playVideo];
    
    NSLog(@"video ready");
}
- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state{
    
    NSString *theState = @"";
    switch (state) {
        case kYTPlayerStateUnstarted:{
            theState = @"kYTPlayerStateUnstarted";
        }
            break;
        case kYTPlayerStateEnded:{
            theState = @"kYTPlayerStateEnded";
        }
            break;
        case kYTPlayerStatePlaying:{
            theState = @"kYTPlayerStatePlaying";
            if(self.shouldIncreaseView){
                [ClipStats increaseWatchCountForClipWithId:self.currentClip.clip_id withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result){
                    self.currentClip.clip_stats = [result firstObject];
                    [self.myTableView reloadData];
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                    if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                        [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                    }
                    
                }];
                self.shouldIncreaseView = NO;
            }
        }
            break;
        case kYTPlayerStatePaused:{
            theState = @"kYTPlayerStatePaused";
        }
            break;
        case kYTPlayerStateBuffering:{
            theState = @"kYTPlayerStateBuffering";
        }
            break;
        case kYTPlayerStateQueued:{
            theState = @"kYTPlayerStateQueued";
        }
            break;
        case kYTPlayerStateUnknown:{
            theState = @"kYTPlayerStateUnknown";
        }
            break;
            
        default:
            break;
    }
    NSLog(@"video state : %@",theState);
}
- (void)playerView:(YTPlayerView *)playerView didChangeToQuality:(YTPlaybackQuality)quality{
    
}
- (void)playerView:(YTPlayerView *)playerView receivedError:(YTPlayerError)error{
    
}


#pragma mark - MPMoviewPlayerNotification

- (void)MPMoviePlayerPlaybackStateDidChange:(NSNotification *)notification
{
    NSLog(@"state : %ld",(long)self.moviePlayer.playbackState);
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
    {
        self.videoThumbnailImageView.hidden = YES;
        if(self.shouldIncreaseView){
            [ClipStats increaseWatchCountForClipWithId:self.currentClip.clip_id withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result){
                self.currentClip.clip_stats = [result firstObject];
                [self.myTableView reloadData];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                    [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
                }
            }];
            self.shouldIncreaseView = NO;
        }
    }
    
    NSString *state;
    switch (self.moviePlayer.playbackState) {
        case 0:
            state = @"MPMoviePlaybackStateStopped";
            break;
        case 1:
            state = @"MPMoviePlaybackStatePlaying";
            break;
        case 2:
            state = @"MPMoviePlaybackStatePaused";
            break;
        case 3:
            state = @"MPMoviePlaybackStateInterrupted";
            break;
        case 4:
            state = @"MPMoviePlaybackStateSeekingForward";
            break;
        case 5:
            state = @"MPMoviePlaybackStateSeekingBackward";
            break;
            
        default:
            break;
    }
    NSLog(@"%@",state);
}

#pragma mark - Payment Notification Handler
-(void)paymentDidSuccess:(NSNotification *)notif{
    self.notAllowedToWatch = NO;
    [self.myTableView triggerPullToRefresh];
    [self reloadVideo];
}

-(void)paymentDidFail:(NSNotification *)notif{
    
}

#pragma mark - PackageListVC Delegate
-(void)didClosePackageList{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - DMKeyboardViewDelegate
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
    
    if(![User fetchLoginUser]){
        
        [UIAlertView showWithTitle:self.appName
                           message:@"Anda harus login untuk menambahkan komentar."
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                                  if (self.moviePlayer) {
                                      [self.moviePlayer stop];
                                  }
                                  [self presentViewController:[[HomeViewController alloc] initByPresenting] animated:YES completion:nil];
                              }
                          }];
        
    }else{
        
        [self.view startLoader:YES disableUI:YES];
        [Comment postCommentWithClipId:currentClip.clip_id andCommentContent:content andTaggedUser:userArray withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Comment *object) {
            [self.commentsArray insertObject:object atIndex:0];
            [self.myTableView reloadData];
            //        self.currentClip.clip_stats.clip_stats_comments = @(self.commentsArray.count);
            NSData *responseData = operation.HTTPRequestOperation.responseData;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:responseData
                                  options:NSJSONReadingMutableLeaves
                                  error:nil];
            NSLog(@"jason: %@",json);
            self.currentClip.clip_stats.clip_stats_comments = json[@"clip"][@"stats"][@"comments"];
            self.currentClip.clip_stats.clip_stats_likes = json[@"clip"][@"stats"][@"likes"];
            self.currentClip.clip_stats.clip_stats_views = json[@"clip"][@"stats"][@"views"];
            [self.view startLoader:NO disableUI:NO];
            
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

}

-(void)DMKeyboardViewDelegateSendComment:(DMKeyboardView *)chatView WithStickerId:(NSString *)stickerId{
    
    [self.view startLoader:YES disableUI:YES];
    [Comment postCommentWithClipId:currentClip.clip_id andStickerId:stickerId withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Comment *object) {
        
        [self.commentsArray insertObject:object atIndex:0];
        [self.myTableView reloadData];

        NSData *responseData = operation.HTTPRequestOperation.responseData;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
        NSLog(@"jason: %@",json);
        self.currentClip.clip_stats.clip_stats_comments = json[@"clip"][@"stats"][@"comments"];
        self.currentClip.clip_stats.clip_stats_likes = json[@"clip"][@"stats"][@"likes"];
        self.currentClip.clip_stats.clip_stats_views = json[@"clip"][@"stats"][@"views"];
        [self.view startLoader:NO disableUI:NO];
        
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
        keyboardSize = CGSizeMake(keyboardSize.width, 254.0);
    }else if(emojiType == EmojiKeyboardTypeHide && !(IS_IPAD)){
        keyboardSize = CGSizeMake(keyboardSize.width, 215.0);
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
    CGFloat gapChatBox = keyboardView.isStickerPresent?0.0:45.0;
    
    CGRect tableViewFrame = self.myTableView.frame;
    tableViewFrame.size.height = TheAppDelegate.deviceHeight - self.myTableView.frame.origin.y - someSize.height - gapChatBox;
    [self.myTableView setFrame:tableViewFrame];
    
    CGRect keyboardViewFrame = self.keyboardView.frame;
    keyboardViewFrame.origin.y = TheAppDelegate.deviceHeight - someSize.height - gapChatBox;
    [self.keyboardView setFrame:keyboardViewFrame];
    
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)hidingKeyboard{
    
    isKeyboardShown = NO;
    CGRect tableViewFrame = self.myTableView.frame;
    tableViewFrame.size.height = TheAppDelegate.deviceHeight - self.myTableView.frame.origin.y - 45.0;
    [self.myTableView setFrame:tableViewFrame];
    
    CGRect keyboardViewFrame = self.keyboardView.frame;
    keyboardViewFrame.origin.y = TheAppDelegate.deviceHeight - 45.0;
    [self.keyboardView setFrame:keyboardViewFrame];
    
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
