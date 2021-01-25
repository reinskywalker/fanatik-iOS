//
//  UploadVideoDetailViewController.m
//  Fanatik
//
//  Created by Erick Martin on 6/30/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "UploadVideoDetailViewController.h"
#import "CustomTableView.h"

@implementation UploadVideoDetailViewController

@synthesize moviePlayer, descLabel, titleLabel, userUploadOnDetail, videoThumbnailImageView;
@synthesize videoContainerView, btnPlay, videoDetailContainerView;
@synthesize videoPlayerTopConstraint;

-(id)initWithUserUploads:(UserUploads *)uu{
    if(self=[super init]){
        self.userUploadOnDetail = uu;
    }
    return self;
}

- (void)viewDidLoad {
    self.title = @"Video";
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self configureView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerPlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerLoadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerPlaybackDidFinishReasonUserInfoKey:)
                                                 name:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
  
    if(self.moviePlayer){
        [self.moviePlayer play];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(void)configureView{
    
    self.titleLabel.text = userUploadOnDetail.user_uploads_title;
    self.descLabel.text = userUploadOnDetail.user_uploads_description;
    [self.descLabel sizeToFit];
    
    [self.videoThumbnailImageView sd_setImageWithURL:[NSURL URLWithString:self.userUploadOnDetail.user_uploads_video_thumbnail] completed:nil];
    
    UIButton *lButton = [TheAppDelegate createButtonWithTitle:nil imageName:@"leftArrow" highlightedImageName:@"leftArrowHighlight" forLeftButton:YES];
    [lButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (IBAction)btnPlayTapped:(id)sender {
    self.btnPlay.hidden = YES;
    
    NSURL *movieURL = [NSURL URLWithString:self.userUploadOnDetail.user_uploads_video_url];
    
    if(!self.moviePlayer){
        self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
        self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
        
        [self.moviePlayer.view setFrame:self.videoContainerView.bounds];
        [self.moviePlayer.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
        [self.videoContainerView insertSubview:self.moviePlayer.view belowSubview:self.videoThumbnailImageView];
    }else{
        self.moviePlayer.contentURL = movieURL;
    }
    
    [self.moviePlayer play];
}

#pragma mark - IOS7 Orientation Change
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        self.videoPlayerTopConstraint.constant = 0.0;
    }else{
        self.videoPlayerTopConstraint.constant = 64.0;
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    if(fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
    }else{
        if(!(IS_IPAD))
            [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

#pragma mark - IOS8 Orientation Change

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.videoContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         // do whatever
         if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
             
             self.videoPlayerTopConstraint.constant = 0.0;
             
             if(!(IS_IPAD))
                 [self.navigationController setNavigationBarHidden:YES animated:YES];
         }else{
             self.videoPlayerTopConstraint.constant = 64.0;
             [self.navigationController setNavigationBarHidden:NO animated:YES];
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

#pragma mark - MPMoviewPlayerNotification

- (void)MPMoviePlayerPlaybackStateDidChange:(NSNotification *)notification
{
    NSLog(@"state : %ld",(long)self.moviePlayer.playbackState);
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying){
        self.videoThumbnailImageView.hidden = YES;
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

- (void)MPMoviePlayerLoadStateDidChange:(NSNotification *)notification
{
    NSString *state = @"MPMovieLoadStateUnknown";
    
    MPMoviePlayerController *player = notification.object;
    MPMovieLoadState loadState = player.loadState;
    /* The load state is not known at this time. */
    if (loadState & MPMovieLoadStateUnknown)
    {
        
    }
    
    /* The buffer has enough data that playback can begin, but it
     may run out of data before playback finishes. */
    if (loadState & MPMovieLoadStatePlayable)
    {
        state = @"MPMovieLoadStatePlayable";
    }
    
    /* Enough data has been buffered for playback to continue uninterrupted. */
    if (loadState & MPMovieLoadStatePlaythroughOK)
    {
        // Add an overlay view on top of the movie view
        state = @"MPMovieLoadStatePlaythroughOK";
    }
    
    /* The buffering of data has stalled. */
    if (loadState & MPMovieLoadStateStalled)
    {
        state = @"MPMovieLoadStateStalled";
        [self.moviePlayer pause];
    }
    
    NSLog(@"load state : %@ : %lu",state,(unsigned long)self.moviePlayer.loadState);
    
}

- (void)MPMoviePlayerPlaybackDidFinishReasonUserInfoKey:(NSNotification *)notification
{
    
    NSLog(@"playback didfinish %@",notification.userInfo);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
