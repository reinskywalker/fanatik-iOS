//
//  BroadcasterDetailViewController.m
//  Fanatik
//
//  Created by Erick Martin on 11/17/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "BroadcasterDetailViewController.h"
#import "UIView+SDCAutoLayout.h"
#import "DMVideoReporting.h"
#import "DMChatView.h"
#import "WhisperListViewController.h"
#import "UIActionSheet+Blocks.h"
#import <AFNetworking/AFNetworking.h>

#define PERCENTAGE_OF_SHRINKEDVIDEO 0.7

@interface BroadcasterDetailViewController ()<DMMoviePlayerDelegate, DMChatViewDelegate>
@property (nonatomic, retain) DMVideoReporting *myDMReporting;
@property (nonatomic, copy) NSString *visitorId;
@property (nonatomic, copy) NSString *visitorStringId;
@end

@implementation BroadcasterDetailViewController
@synthesize playerView, defaultVideoHeight, videoPlayerTopConstraint, myDMReporting, videoPlayerAspectRationConstraint, videoPlayerBottomConstraint, currentBroadcaster;
@synthesize videoPlayerTrailingConstraint, videoPlayerToChatBottomConstraint, chatTopConstraint;


-(id)initWithBroadcaster:(Broadcaster*)broadcast{
    if(self = [super init]){
        self.currentBroadcaster = broadcast;
        self.myDMReporting = [[DMVideoReporting alloc] init];
        self.visitorId = @"";
        self.visitorStringId = @"";
    }
    return self;
}

-(id)initWithBroadcasterID:(NSNumber *)broadID{
    if(self = [super init]){
        self.currentBroadcasterId = broadID;
        self.myDMReporting = [[DMVideoReporting alloc] init];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if([self.visitorId isEqualToString:@""] || [User fetchLoginUser]){
        [self handshakeWebSocket];
    }
    
    self.myChatView.forceLoginButton.hidden = (BOOL)[User fetchLoginUser];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = currentBroadcaster.broad_name;
    self.currentPageCode = MenuPageBroadcasterDetail;
    
    NSURL *thumbnailURL = [NSURL URLWithString:currentBroadcaster.broad_banner_url];
    NSURL *videoURL = [NSURL URLWithString:currentBroadcaster.broad_streaming_url];
    NSURL *vastURL = nil;//[NSURL URLWithString:@"http://dev.fanatik.id/test/vast.xml"];
    [playerView initializeWithContentURL:videoURL andThumbnailURL:thumbnailURL andVastURL:vastURL durationString:@"13:31"];
    self.myDMReporting.reportingURL = @"dev.fanatik.id";
    
    self.myChatView.headerMenuTextArray = @[@"PUBLIC CHAT", @"WHISPER"];
    [self.myChatView initializeView];
}

-(void)handshakeWebSocket{
    
    [self.myChatView setCurrentBroadcaster:currentBroadcaster];
    
    int random4Digit = arc4random() % 9000 + 1000;
    int random8Digit = arc4random() % 90000000 + 10000000;
    
    self.visitorId = [NSString stringWithFormat:@"%d",random8Digit];
    self.visitorStringId = [NSString stringWithFormat:@"Visitor%d", random4Digit];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 @"handshake", @"action",
                                 [NSString stringWithFormat:@"broadcaster_%@", currentBroadcaster.broad_user_id], @"roomName",
                                 currentBroadcaster.broad_user_id, @"broadcasterId",
                                 self.visitorId, @"id",
                                 self.visitorStringId, @"username",
                                 [NSString stringWithFormat:@"%@/avatar.png", ConstStr(@"server_url")], @"avatar",
                                 @(1),@"initial_join",
                                 nil];
    
    [self.myChatView setVisitorId:[NSString stringWithFormat:@"%d", random8Digit]];
    
    if(CURRENT_USER_ID()){
        [self.myChatView setVisitorId:@""];
        User *currUser = CURRENT_USER();
        
        [dict setObject:currUser.user_id forKey:@"id"]; //8 digit random string angka
        [dict setObject:currUser.user_name forKey:@"username"]; //Visitor4digitrandom
        [dict setObject:currUser.user_avatar.avatar_thumbnail forKey:@"avatar"]; //url server dev.fanatik.id/assets/avatar.png
    }
    
    NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           @"action", @"event",
                           dict, @"params",
                           nil];
    [self.myChatView setWebSocketParameter:dict1];
    [self.myChatView connectWebSocket];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.playerView stopMovie];
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
        // View is disappearing because a new view controller was pushed onto the stack
        NSLog(@"New view controller was pushed");
    } else if ([viewControllers indexOfObject:self] == NSNotFound) {
        // View is disappearing because it was popped from the stack
        NSLog(@"View controller was popped");
        [self.myChatView disconnectWebSocket];
    }
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
   
}

#pragma mark - IOS7 Orientation Change
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.myChatView.chatTF resignFirstResponder];
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        self.videoPlayerTopConstraint.constant = 0.0;
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        
    }else{
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
        self.videoPlayerTopConstraint.constant = 64.0;
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    self.playerView.originalPlayerSize = self.playerView.frame.size;
    if(playerView.isShrink){
        [playerView shrinkMainVideoWithAnimation:NO andSize:CGSizeMake(PERCENTAGE_OF_SHRINKEDVIDEO * self.playerView.originalPlayerSize.width, PERCENTAGE_OF_SHRINKEDVIDEO * self.playerView.originalPlayerSize.height)];
    }
    
    if(fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
    }else{
        if(!IS_IPAD)
            [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

#pragma mark - IOS8 Orientation Change
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.myChatView.chatTF resignFirstResponder];
    [self.playerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
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
             
             [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
             
             self.navigationController.interactivePopGestureRecognizer.enabled = NO;
             
             [self.myChatView.chatTF resignFirstResponder];
             self.myChatView.hidden = YES;
             [self.navigationController setNavigationBarHidden:YES animated:YES];
             videoPlayerTopConstraint.constant = 0;
             if(IS_IPAD){
                 self.videoPlayerAspectRationConstraint.active = NO;
                 self.videoPlayerBottomConstraint.constant = 0;
                 self.videoPlayerBottomConstraint.active = YES;
             }
         }else{
             
             [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
             
             self.navigationController.interactivePopGestureRecognizer.enabled = YES;
             
             self.myChatView.hidden = NO;
             [self.navigationController setNavigationBarHidden:NO animated:YES];
             self.videoPlayerTopConstraint.constant = 64.0;
             if(IS_IPAD){
                 self.videoPlayerAspectRationConstraint.active = YES;
                 self.videoPlayerBottomConstraint.active = NO;
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


#pragma mark - DMChatViewDelegate
-(void)DMChatViewDelegateNeedToLogin:(DMChatView *)chatView{
    [self presentViewController:[[HomeViewController alloc] initByPresenting] animated:YES completion:nil];
}
-(void)DMChatViewDelegateKeyboardWillShow:(DMChatView *)chatView{
    
    //di sini nih
    
    self.videoPlayerTrailingConstraint.constant = 64.0;
//    self.videoPlayerToChatBottomConstraint.constant = 18.0;
    self.videoPlayerToChatBottomConstraint.active = NO;
    self.chatTopConstraint.constant = 64.0;
//    self.videoPlayerTopConstraint.constant = -self.playerView.frame.size.height + 64;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    
}

-(void)DMChatViewDelegateKeyboardWillHide:(DMChatView *)chatView{
//    self.videoPlayerTopConstraint.constant = 64.0;
    self.videoPlayerTrailingConstraint.constant = 0.0;
    self.chatTopConstraint.constant = 64.0 + self.playerView.frame.size.height;
    self.videoPlayerToChatBottomConstraint.active = YES;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    
}

-(void)DMChatViewDelegate:(DMChatView *)chatView didSelectHorizontalMenuAtIndex:(NSInteger)idx{
    
    /*
     if (idx == 1) {
         [self.navigationController pushViewController:[[WhisperListViewController alloc] init] animated:YES];
     }
     */
}

-(void)DMChatViewDelegateOpenWhisperListView:(DMChatView *)chatView{
    [self.navigationController pushViewController:[[WhisperListViewController alloc] initWithUserArray:chatView.whisperChatUserArray] animated:YES];
}

-(void)DMChatViewDelegate:(DMChatView *)chatView didTapChatUser:(Message *)chat{
    [UIActionSheet showInView:self.view withTitle:@"" cancelButtonTitle:@"Batal" destructiveButtonTitle:nil otherButtonTitles:@[@"View Profile", @"Follow"] tapBlock:^(UIActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
        
        if(buttonIndex != actionSheet.cancelButtonIndex){
            switch (buttonIndex) {
                case 0:{
                    NSLog(@"View Profile");
                    //                    [chatView.whisperChatUserArray addObject:chat.chat_user];
                    //                    chatView.currentWhisperChatUser = chat.chat_user;
                    //                    [chatView addedUserToWhisper];
                }
                    break;
                case 1:{
                    
                }
                    break;
                case 2:{
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
    }];
}
@end
