//
//  EventDetailViewController.m
//  Fanatik
//
//  Created by Erick Martin on 11/17/15.
//  Copyright © 2015 Domikado. All rights reserved.
//


#import "EventDetailViewController.h"
#import "UIView+SDCAutoLayout.h"
#import "DMVideoReporting.h"
#import <AFNetworking/AFNetworking.h>
#import "EventInfoTableViewCell.h"
#import "VideoCommentTableViewCell.h"
#import "EventSmallTableViewCell.h"
#import <MZFayeClient.h>
#import "EventAnnouncementModel.h"
#import "UploadVideoViewController.h"
#import "ViewMoreTableViewCell.h"

#define PERCENTAGE_OF_SHRINKEDVIDEO 0.7

@interface EventDetailViewController ()<DMMoviePlayerDelegate, EventInfoTableViewCellDelegate, SearchClipTableViewCellDelegate, IBActionSheetDelegate, MZFayeClientDelegate>

@property (nonatomic, retain) DMVideoReporting *myDMReporting;
@property (nonatomic, copy) NSString *visitorId;
@property (nonatomic, copy) NSString *visitorStringId;

@property (nonatomic, retain) NSMutableArray *commentsArray;
@property (nonatomic, retain) NSMutableArray *relatedClipsArray;

@property(nonatomic, assign) EmojiKeyboardType emojiType;
@property(nonatomic, assign) BOOL isExpanded;
@property(nonatomic, assign) NSNumber *currentPage;
@property (nonatomic, assign) BOOL isBack;
@property (nonatomic, assign) BOOL isKeyboardShown;
@property (nonatomic, retain) UIRefreshControl *refreshControl;
@property(nonatomic, retain) Pagination *currentPagination;
@property (nonatomic, assign) BOOL isCommentReloading;
@property (nonatomic,assign) BOOL notAllowedToWatch;
@property (nonatomic,assign) BOOL isFirstTimeLoad;
@property (nonatomic,assign) BOOL needToReloadVideo;
@property (nonatomic,assign) int indexRow;
@property (nonatomic, assign) VisibilityMode currentVisibility;
@property (nonatomic, retain) NSNumber *currentCommentID;
@property (nonatomic, strong) MZFayeClient *client;
@property (nonatomic, retain) UIImageView *posterView;
@end

@implementation EventDetailViewController
@synthesize playerView, defaultVideoHeight, videoPlayerTopConstraint, myDMReporting, videoPlayerAspectRationConstraint, videoPlayerBottomConstraint, currentEvent;
@synthesize keyboardView, emojiType, isKeyboardShown, heightKeyboardViewConstraint;
@synthesize marqueeHeightConstraint, marqueeLabel, refreshControl;
@synthesize currentEventId, currentPagination, isCommentReloading, isBack, notAllowedToWatch, isFirstTimeLoad, currentVisibility, posterView, needToReloadVideo, indexRow, heightKeyboardiOSConstraint, heightKeyboardiOSConstraintTemp;

-(id)initWithEvent:(Event *)event{
    if(self = [super init]){
        self.currentEvent = event;
        self.myDMReporting = [[DMVideoReporting alloc] init];
        self.visitorId = @"";
        self.visitorStringId = @"";
        self.emojiType = EmojiKeyboardTypeInitiate;
        self.commentsArray = [NSMutableArray array];
        self.relatedClipsArray = [NSMutableArray array];
        self.isBack = NO;
        self.needToReloadVideo = NO;
    }
    return self;
}

-(id)initWithEventID:(NSNumber *)eventId{
    if(self = [super init]){
        self.currentEventId = eventId;
        self.myDMReporting = [[DMVideoReporting alloc] init];
        self.visitorId = @"";
        self.visitorStringId = @"";
        self.emojiType = EmojiKeyboardTypeInitiate;
        self.commentsArray = [NSMutableArray array];
        self.relatedClipsArray = [NSMutableArray array];
        self.isBack = NO;
        self.needToReloadVideo = NO;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    self.pageObjectName = self.currentEvent.event_name;
    [super viewWillAppear:animated];
    
    isBack = NO;
    
    if([self.visitorId isEqualToString:@""] || [User fetchLoginUser]){
        [self handshakeWebSocket];
    }
    
    self.keyboardView.forceLoginButton.hidden = (BOOL)[User fetchLoginUser];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.currentPageCode = MenuPageEventDetail;
    self.isFirstTimeLoad = YES;

    [keyboardView initializeView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentDidSuccess:) name:kPaymentCompleted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentDidFail:) name:kPaymentFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullToRefreshTable) name:kLoginCompletedNotification object:nil];

    [self.myTableView startLoader:YES disableUI:NO];
    [self reloadVideo];
    
    //Faye Client Setup
    self.client = [[MZFayeClient alloc] initWithURL:[NSURL URLWithString:FAYE_SERVER_URL()]];
    [self.client subscribeToChannel:[NSString stringWithFormat:@"/live-events/%@/announcements/all",self.currentEvent.event_id] success:nil failure:nil receivedMessage:nil];
    [self.client subscribeToChannel:[NSString stringWithFormat:@"/live-events/%@/watching", self.currentEvent.event_id] success:nil failure:nil receivedMessage:nil];
    [self.client subscribeToChannel:[NSString stringWithFormat:@"/live-events/%@", self.currentEvent.event_id] success:nil failure:nil receivedMessage:nil];
    self.client.delegate = self;
    [self.client connect:nil failure:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if(self.isFirstTimeLoad){
        
        self.currentPageCode = MenuPageEventDetail;
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"btnShare"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(shareContent)];
        self.navigationItem.rightBarButtonItem = shareButton;
        
        UIButton *lButton = [TheAppDelegate createButtonWithTitle:nil imageName:@"leftArrow" highlightedImageName:@"leftArrowHighlight" forLeftButton:YES];
        [lButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
        self.navigationItem.leftBarButtonItem = backButton;
        
        self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

        self.currentPage = @1;
        self.isFirstTimeLoad = NO;
        [self.myTableView registerNib:[UINib nibWithNibName:[EventInfoTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([EventInfoTableViewCell class])];
        [self.myTableView registerNib:[UINib nibWithNibName:[VideoCommentTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([VideoCommentTableViewCell class])];
        [self.myTableView registerNib:[UINib nibWithNibName:[SearchClipTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([SearchClipTableViewCell class])];
        [self.myTableView registerNib:[UINib nibWithNibName:[ViewMoreTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([ViewMoreTableViewCell class])];
        [self.myTableView registerNib:[UINib nibWithNibName:[EmptyLabelTableViewCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:NSStringFromClass([EmptyLabelTableViewCell class])];
        
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        
        self.refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(pullToRefreshTable) forControlEvents:UIControlEventValueChanged];
        [self.myTableView addSubview:refreshControl];
        
        [self getRelatedVideoAndCommentFromServerForPage:0];
        
        [self.myTableView reloadData];
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
        
        if(self.client.isConnected)
            [self.client disconnect:nil failure:nil];
    }
    [self.keyboardView disconnectWebSocket];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [playerView stopMovie];
}

-(void)reloadVideo{
    
    if(![currentEvent.event_live boolValue]){
        NSURL *filePath = [NSURL URLWithString:self.currentEvent.event_poster_thumbnail.thumbnail_480];
        NSLog(@"%@",self.currentEvent.event_poster_thumbnail);
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
        
        NSURL *thumbnailURL = [NSURL URLWithString:currentEvent.event_poster_thumbnail.thumbnail_480];
        NSURL *videoURL = [NSURL URLWithString:currentEvent.event_streaming_url];
        NSURL *vastURL = nil;//[NSURL URLWithString:@"http://dev.fanatik.id/test/vast.xml"];
        [playerView initializeWithContentURL:videoURL andThumbnailURL:thumbnailURL andVastURL:vastURL durationString:@"13:31"];
        self.myDMReporting.reportingURL = @"dev.fanatik.id";
        
        self.playerView.isLive = [self.currentEvent.event_live boolValue];
        [self.playerView startLoader:YES disableUI:NO];
        [playerView play];
    }
}

-(void)pullToRefreshTable{
    [self.myTableView setContentOffset:CGPointMake(0, -1.0f * self.refreshControl.frame.size.height) animated:YES];
    [self.refreshControl beginRefreshing];
    self.currentPagination.current_page = @(1);
    [self.commentsArray removeAllObjects];
    [self.myTableView reloadData]; // before load new content, clear the existing table list
    [self getRelatedVideoAndCommentFromServerForPage:0]; // load new data
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
    NSData *data = [[messageData description] dataUsingEncoding:NSUTF8StringEncoding];
    id jsonResult = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    //Watching Count
    if([jsonResult[@"live_event"][@"watching_count"] intValue]){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        EventInfoTableViewCell *cell = [self.myTableView cellForRowAtIndexPath:indexPath];
        cell.eventWatchingLabel.text = [NSString stringWithFormat:@"%@ watching", jsonResult[@"live_event"][@"watching_count"]];
    }
    
    //Announcement
    if(jsonResult[@"live_event_announcements"]){
        NSString *announceString = @"";
        NSArray *announcementArray = [NSArray arrayWithArray:jsonResult[@"live_event_announcements"]];
        for(NSDictionary *announceDict in announcementArray){
            EventAnnouncementModel *newAnnouncement = [[EventAnnouncementModel alloc] initWithDictionary:announceDict];
            announceString = [announceString stringByAppendingString:[NSString stringWithFormat:@"%@%@",newAnnouncement.announcementContent, announcementArray.count > 0?@"  ●  ":@""]];
            
        }
        [self showAnnouncementWithText:announceString];
    }
    
    //Refresh Event
    if(jsonResult[@"message"]){
        [self pullToRefreshTable];
        needToReloadVideo = YES;
    }
}

#pragma mark - ServerRequest

-(void)getRelatedVideoAndCommentFromServerForPage:(NSNumber *)pageNum{
    if(isCommentReloading)
        return;
    isCommentReloading = YES;
    NSNumber *eventId;
    if (currentEvent == nil) {
        eventId = currentEventId;
    }else{
        eventId = currentEvent.event_id;
    }
    
    [Event getEventDetailWithId:eventId withPageNumber:pageNum andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation * _Nonnull operation, Event *eventObject) {
        
        [self.myTableView setContentOffset:CGPointZero animated:YES];
        [self.refreshControl endRefreshing];
        
        isCommentReloading = NO;
        [self.myTableView startLoader:NO disableUI:NO];
        int vidRow = (int)self.relatedClipsArray.count;
        if(vidRow==0){
            NSArray *sortedArray = [[eventObject.event_clip array] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"clip_position" ascending:YES], nil]];
            [self.relatedClipsArray addObjectsFromArray:sortedArray];
        }

        [self.commentsArray addObjectsFromArray:[eventObject.event_comment array]];
        NSArray *sortedCommentsArray = [self.commentsArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"comment_id" ascending:YES], nil]];
        self.commentsArray = [NSMutableArray arrayWithArray:sortedCommentsArray];
    
        self.currentPagination = eventObject.event_pagination;
        if([currentEvent.event_streaming_url isEqualToString:@""] && ![eventObject.event_streaming_url isEqualToString:@""]){
            needToReloadVideo = YES;
        }
        self.currentEvent = eventObject;
        
        // Announcement
        NSString *announceString = @"";
        for (EventAnnouncement *ann in [currentEvent.event_announcement array]) {
            announceString = [announceString stringByAppendingString:[NSString stringWithFormat:@"%@  ●  ",ann.event_announcement_content]];
        }
        [self showAnnouncementWithText:announceString];
        
        // if no more result
        if (sortedCommentsArray == 0) {
            self.myTableView.showsInfiniteScrolling = NO;
            return;
        }

        self.currentPage = self.currentPagination.next_page; // increase the page number
        
        // Change the layer of video or poster
        if(needToReloadVideo){
            [self reloadVideo];
            needToReloadVideo = NO;
        }
        [self.myTableView reloadData];
        
        // store the sorted items into the existing list
        NSMutableIndexSet *sets = [NSMutableIndexSet indexSetWithIndex:1];
        [self.myTableView reloadSections:sets withRowAnimation:UITableViewRowAnimationAutomatic];
        
        // clear the pull to refresh & infinite scroll, this 2 lines very important
        [self.myTableView.pullToRefreshView stopAnimating];
        [self.myTableView.infiniteScrollingView stopAnimating];
        
    } failure:^(RKObjectRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
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
                            
                                      [playerView stopMovie];
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
                                      
                                      [playerView stopMovie];
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

#pragma mark - Payment Notification Handler
-(void)paymentDidSuccess:(NSNotification *)notif{
    self.notAllowedToWatch = NO;
    self.needToReloadVideo = YES;
    [self pullToRefreshTable];
}

-(void)paymentDidFail:(NSNotification *)notif{
    
}

#pragma mark - IBAction
-(void)showAnnouncementWithText:(NSString *)contentString{
    marqueeLabel.text = contentString;
    
    if([contentString isEqualToString:@""]){
        marqueeHeightConstraint.constant = 0.0;
    }else{
        marqueeHeightConstraint.constant = 20.0;
    }
    
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(IBAction)uploadTapped:(id)sender{
    [self showAlbum];
}

-(void)shareContent{

    if(self.currentEvent.event_shareable.shareable_url && ![self.currentEvent.event_shareable.shareable_url isEqualToString:@""]){
        NSLog(@"Shareable : %@", currentEvent.event_shareable);
        NSString* someText = self.currentEvent.event_shareable.shareable_content;
        NSURL* linkText = [[NSURL alloc] initWithString: self.currentEvent.event_shareable.shareable_url];
        NSArray* dataToShare = [NSArray arrayWithObjects: someText,linkText, nil];
        UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
        activityViewController.excludedActivityTypes = @[ UIActivityTypePostToWeibo, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypePrint ];
        [self presentViewController:activityViewController animated:YES completion:^{}];
    }
}

#pragma mark - UITableView Delegate & Datasource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:{
            EventInfoTableViewCell *cell = (EventInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[EventInfoTableViewCell reuseIdentifier]];
            cell.isExpanded = self.isExpanded;
            [cell fillCellWithEvent:self.currentEvent];
            return [cell cellHeight];
        }
            break;
        case 1:{
            if(currentVisibility == VisibilityModeComment){
    
                if(self.commentsArray.count == 0)
                    return 57.0;
                    
                if([self deviationViewMore]==1 && indexPath.row==0)
                    return 40.0;
        
                VideoCommentTableViewCell *cell = (VideoCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[VideoCommentTableViewCell reuseIdentifier]];
                Comment *aComment = [self.commentsArray objectAtIndex:indexPath.row-[self deviationViewMore]];
                [cell fillCellWithComment:aComment];
                return [cell cellHeight];
            }else{
                
                if(self.relatedClipsArray.count == 0)
                    return 57.0;
                return 85.0;
            }
        }
            break;
            
        default:
            return 85.0;
            break;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:{
            return 1.0;
        }
            break;
        case 1:{
            if(currentVisibility == VisibilityModeComment){
                if(self.commentsArray.count == 0)
                    return 1.0;
                return self.commentsArray.count + [self deviationViewMore];
            }else{
                
                if(self.relatedClipsArray.count == 0)
                    return 1.0;
                return self.relatedClipsArray.count;
            }
        }
            break;
            
        default:
            return 1;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0:{
            cell = (EventInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[EventInfoTableViewCell reuseIdentifier]];
            [(EventInfoTableViewCell *)cell setCurrentVisibility:currentVisibility];
            [(EventInfoTableViewCell *)cell setIsExpanded:self.isExpanded];
            [(EventInfoTableViewCell *)cell setDelegate:self];
            [(EventInfoTableViewCell *)cell fillCellWithEvent:currentEvent];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
        case 1:{
            
            if(self.currentVisibility == VisibilityModeComment){
        
                if(self.commentsArray.count == 0){
                    EmptyLabelTableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:[EmptyLabelTableViewCell reuseIdentifier]];
                    emptyCell.emptyLabel.text = @"Komentar tidak ditemukan";
                    return emptyCell;
                }
                
                if([self deviationViewMore] == 1 && indexPath.row == 0){
                    cell =  (ViewMoreTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[ViewMoreTableViewCell reuseIdentifier]];
                    return cell;
                }
            
                cell =  (VideoCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[VideoCommentTableViewCell reuseIdentifier]];
                if(indexPath.row-[self deviationViewMore] < self.commentsArray.count){
                    Comment *aComment = [self.commentsArray objectAtIndex:indexPath.row-[self deviationViewMore]];
                    [(VideoCommentTableViewCell *)cell fillCellWithComment:aComment];
                }
                
                return cell;
                
            }else{
                
                if(self.relatedClipsArray.count == 0){
                    EmptyLabelTableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:[EmptyLabelTableViewCell reuseIdentifier]];
                    emptyCell.emptyLabel.text = @"Video event tidak ditemukan";
                    return emptyCell;
                }
                
                Clip *aClip = [self.relatedClipsArray objectAtIndex:indexPath.row];
                SearchClipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SearchClipTableViewCell reuseIdentifier]];
                cell.delegate = self;
                [cell fillWithClip:aClip];
                cell.separatorView.hidden = NO;
                
                return cell;
            }
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
            [self.myTableView reloadSections:sets withRowAnimation:UITableViewRowAnimationFade];
            
        }
            break;
            
        default:{

            if(self.currentVisibility == VisibilityModeComment){
                //comment
                if(self.commentsArray.count > 0){
                    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                    if([cell class] == [ViewMoreTableViewCell class]){
                        [self.myTableView startLoader:YES disableUI:NO];
                        [self getRelatedVideoAndCommentFromServerForPage:self.currentPage];
                    }else{
                    
                        //check wether the comment is mine
                        Comment *theComment = self.commentsArray[indexPath.row-[self deviationViewMore]];
                        if([theComment.comment_user.user_id isEqual:[User fetchLoginUser].user_id]){
                            NSString *title;
                            
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
                }
            }else{
                if(self.relatedClipsArray.count > 0){
                    Clip *theClip = [self.relatedClipsArray objectAtIndex:indexPath.row];
                    VideoDetailViewController *vc = [[VideoDetailViewController alloc] initWithClip:theClip];
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

-(void)moreButtonDidTapForClip:(Clip *)clip{

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
                                  [Comment deleteCommentWithEventId:self.currentEvent.event_id andCommentId:self.currentCommentID withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Comment *object) {
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

#pragma mark - Event Info Cell Delegate
-(int)deviationViewMore{
    int deviation = 0;
    if(self.currentPagination.next_page && [self.currentPagination.next_page intValue] > 0 ){
        deviation = 1;
    }
    
    return deviation;
}

-(void)userButtonDidTap{
    [self.playerView stopMovie];
    
    ProfileViewController *vc = [[ProfileViewController alloc] initWithUser:currentEvent.event_user];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)showingErrorFromServer:(NSString *)errorStr{
    [self showAlertWithMessage:errorStr];
}

-(void)didSelectVisibilityMode:(VisibilityMode)visMod{
    self.currentVisibility = visMod;
    keyboardView.hidden = currentVisibility;
    _uploadView.hidden = !currentVisibility;
    
    [self.myTableView reloadData];
}

#pragma mark - IOS7 Orientation Change
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if(![currentEvent.event_live boolValue]){
        return;
    }
    
    [self.keyboardView.chatTextView resignFirstResponder];
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        self.videoPlayerTopConstraint.constant = 0.0;
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        
        if(![currentEvent.event_live boolValue]){
            posterView.frame = CGRectMake(0, 0, playerView.frame.size.width, playerView.frame.size.height);
        }
        
    }else{
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
        self.videoPlayerTopConstraint.constant = 64.0;
        
        if(![currentEvent.event_live boolValue]){
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
    
    [keyboardView.chatTextView resignFirstResponder];
    
    if(fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        heightKeyboardViewConstraint.constant = 0;
        heightKeyboardiOSConstraint.constant = 0;
    }else{

        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        heightKeyboardViewConstraint.constant = 45.0;
        heightKeyboardiOSConstraint.constant = heightKeyboardiOSConstraintTemp;
    }
}

#pragma mark - IOS8 Orientation Change
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.keyboardView.chatTextView resignFirstResponder];
    [self.playerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    playerView.zoomButton.selected = !playerView.zoomButton.selected;
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         // do whatever
         self.playerView.originalPlayerSize = self.playerView.frame.size;
         NSLog(@"CGSIze zxc : %@", NSStringFromCGSize(self.playerView.originalPlayerSize));
         
         if(playerView.isShrink){
             [playerView shrinkMainVideoWithAnimation:NO andSize:CGSizeMake(PERCENTAGE_OF_SHRINKEDVIDEO * self.playerView.originalPlayerSize.width, PERCENTAGE_OF_SHRINKEDVIDEO * self.playerView.originalPlayerSize.height)];
         }
         
         if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
             
             heightKeyboardViewConstraint.constant = 0;
             heightKeyboardiOSConstraint.constant = 0;
             videoPlayerTopConstraint.constant = 0;
             
             [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
             self.navigationController.interactivePopGestureRecognizer.enabled = NO;
             [self.keyboardView.chatTextView resignFirstResponder];
             
             if(IS_IPAD){
                 self.videoPlayerAspectRationConstraint.active = NO;
                 self.videoPlayerBottomConstraint.constant = 0;
                 self.videoPlayerBottomConstraint.active = YES;
             }
             self.myTableView.hidden = YES;
             [self.view endEditing:YES];
             
             if(![currentEvent.event_live boolValue]){
                 posterView.frame = CGRectMake(0, 0, playerView.frame.size.width, playerView.frame.size.height);
             }
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
             
             if(![currentEvent.event_live boolValue]){
                 posterView.frame = CGRectMake(0, 0, TheAppDelegate.deviceWidth, playerView.frame.size.height);
             }
         }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)DMMoviePlayer:(DMMoviePlayer *)view playbackDidPlayToEndTime:(NSNotification *)notification{
    AVPlayerItem *currentItem = view.moviePlayer.player.currentItem;
    AVAsset *currentPlayerAsset = currentItem.asset;
    NSURL *url = [(AVURLAsset *)currentPlayerAsset URL];
    NSTimeInterval currentTime = CMTimeGetSeconds(currentItem.currentTime);
    NSTimeInterval durationTime = CMTimeGetSeconds(currentItem.duration);
    
    [myDMReporting trackVideoWithURL:[url absoluteString] title:@"" videoDuration:durationTime playbackTime:currentTime isStreaming:NO playbackState:kDMVideoPlaybackStateFinished customParams:nil withCompletion:^(NSString *message) {
        NSLog(@"report kDMVideoPlaybackStateFinished success");
        
    } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"report kDMVideoPlaybackStateFinished Failed");
    }];
}


-(void)DMMoviePlayer:(DMMoviePlayer *)view playerReachCheckPoint:(PlayerCheckPoint)chk{
    AVPlayerItem *currentItem = view.moviePlayer.player.currentItem;
    AVAsset *currentPlayerAsset = currentItem.asset;
    NSURL *url = [(AVURLAsset *)currentPlayerAsset URL];
    NSTimeInterval currentTime = CMTimeGetSeconds(currentItem.currentTime);
    NSTimeInterval durationTime = CMTimeGetSeconds(currentItem.duration);
    
    if(chk == PlayerCheckPointFirstQuartile){
        myDMReporting.reportingURL = @"dev.fanatik.id/video-report/first-quartile";
    }else if(chk == PlayerCheckPointMidPoint){
        myDMReporting.reportingURL = @"dev.fanatik.id/video-report/midpoint";
    }else{
        myDMReporting.reportingURL = @"dev.fanatik.id/video-report/third-quartile";
    }
    
    [myDMReporting trackVideoWithURL:[url absoluteString] title:@"" videoDuration:durationTime playbackTime:currentTime isStreaming:NO playbackState:kDMVideoPlaybackStatePlaying customParams:nil withCompletion:^(NSString *message) {
        NSLog(@"report kDMVideoPlaybackStateFinished success");
        
    } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"report kDMVideoPlaybackStateFinished Failed");
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


#pragma mark - DMKeyboardViewDelegate
-(void)addComment:(NSString *)content{
    
    if([content isEqualToString:@""])
        return;
    
    heightKeyboardiOSConstraint.constant = 0.0;
    
    if(![User fetchLoginUser]){
        
        [UIAlertView showWithTitle:self.appName
                           message:@"Anda harus login untuk menambahkan komentar."
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                                  [self.playerView stopMovie];
                                  [self presentViewController:[[HomeViewController alloc] initByPresenting] animated:YES completion:nil];
                              }
                          }];
        
    }else{
        
        [self.view startLoader:YES disableUI:YES];
        [Comment postCommentWithEventId:(NSNumber *)self.currentEvent.event_id andCommentContent:content withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Comment *object) {
            NSData *responseData = operation.HTTPRequestOperation.responseData;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:responseData
                                  options:NSJSONReadingMutableLeaves
                                  error:nil];
            self.currentEvent.event_stats.event_stats_comments = json[@"live_event"][@"stats"][@"comments"];
            [self.view startLoader:NO disableUI:NO];
            
            [self.commentsArray addObject:object];
            [self.myTableView reloadData];
            [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.commentsArray.count-1 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
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

-(void)DMKeyboardViewDelegateAutoComplete:(DMKeyboardView *)chatView withArray:(NSArray *)userArray{
}

-(void)DMKeyboardViewDelegateResizeTextBox:(DMKeyboardView *)chatView withHeight:(CGFloat)boxHeight{
    heightKeyboardiOSConstraint.constant = boxHeight - 45.0;
    heightKeyboardiOSConstraintTemp = heightKeyboardiOSConstraint.constant;
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
    [self addComment:content];
}

-(void)DMKeyboardViewDelegateSendComment:(DMKeyboardView *)chatView WithStickerId:(NSString *)stickerId{
    
    [self.view startLoader:YES disableUI:YES];
    [Comment postCommentWithEventId:currentEvent.event_id andStickerId:stickerId withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, Comment *object) {
        
        NSData *responseData = operation.HTTPRequestOperation.responseData;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
        self.currentEvent.event_stats.event_stats_comments = json[@"live_event"][@"stats"][@"comments"];
        [self.view startLoader:NO disableUI:NO];
        
        [self.commentsArray addObject:object];
        [self.myTableView reloadData];
        [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.commentsArray.count-1 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
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
    NSLog(@"Height keyboard constraint : %f",heightKeyboardViewConstraint.constant);
    
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
