//
//  DMMoviePlayer.m
//  DMMoviePlayer
//
//  Created by Erick Martin on 9/29/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "DMMoviePlayer.h"
#import "UIView+SDCAutoLayout.h"
#import "UIImageView+WebCache.h"
#import "TBXML+HTTP.h"
#import "TBXML.h"
#import "DMVideoReporting.h"
#import <CoreMedia/CoreMedia.h>

#define PlayerManagerTopHeight 30
#define PlayerManagerBottomHeight 40
#define PERCENTAGE_OF_PIP 0.3

@interface DMMoviePlayer(){
    NSTimer *timer;
    TBXML *objTbxml;
    VastAd *prerollAd;
    VastAd *postrollAd;
    MediaPlayerViewControllerPlaybackType playbackType;
    BOOL hasReachedFirstQuartile;
    BOOL hasReachedMidPoint;
    BOOL hasReachedThirdQuartile;
}
@property (nonatomic, retain) VastAd *theAd;
@end

@implementation DMMoviePlayer
{
    id playbackObserver;
    BOOL viewIsShowing;
}

static void * PlayerStatusContext = &PlayerStatusContext;
static void * PlayerRateContext = &PlayerRateContext;
static void * PlayerItemCurrentTime = &PlayerItemCurrentTime;

@synthesize moviePlayer, thumbnailImageView, playButton, thumbnailURL, isLive, delegate, backgroundImageView, contentMiniURL, streamListArray, playlistModel, resolutionButton, originalPlayerSize, isShrink, isPIP;

- (void)initializeWithContentURL:(NSURL*)contentURL andThumbnailURL:(NSURL*)thumURL andVastURL:(NSURL *)vast durationString:(NSString *)dur
{
    self.durationString = dur;
    self.vastURL = vast;
    self.moviePlayer = nil;
    self.isShrink = NO;
    self.isPIP = NO;
    self.thumbnailURL = thumURL;
    self.contentURL = contentURL;
    
    //GET Resolution by stream list
    self.streamListArray = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        self.playlistModel = [[M3U8PlaylistModel alloc] initWithURL:[self.contentURL absoluteString] error:&error];
        
        for(int i = 0 ; i < playlistModel.masterPlaylist.xStreamList.count; i++){
            M3U8ExtXStreamInf *info = [playlistModel.masterPlaylist.xStreamList xStreamInfAtIndex:i];
            if(info.URI && ![info.URI isEqualToString:@""] && info.resolution.width > 0 && info.resolution.height > 0){
                [self.streamListArray addObject:info];
            }
        }
    });

    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.player = [AVPlayer playerWithURL:contentURL];
    self.moviePlayer = playerViewController;
    self.moviePlayer.view.frame = self.bounds;
    [self.moviePlayer.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    self.moviePlayer.showsPlaybackControls = NO;
    self.moviePlayer.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [self addSubview:moviePlayer.view];

    [self registerKVOForMoviePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVPlayerItemDidPlayToEndTimeNotificationHandler:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    [self initializePlayer:self.frame];
}

-(void)initializePlayer:(CGRect)frame{
    
    self.originalPlayerSize = frame.size;
    
    int frameWidth =  frame.size.width;
    int frameHeight = frame.size.height;

    self.backgroundColor = [UIColor blackColor];
    viewIsShowing =  YES;
    
    [self.layer setMasksToBounds:YES];
    
    //Thumbnail Image
    self.thumbnailImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    [self.thumbnailImageView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    if(_thumbnailImage){
        [self.thumbnailImageView setImage:_thumbnailImage];
    }else{
        [self.thumbnailImageView sd_setImageWithURL:self.thumbnailURL];
    }
    [self addSubview:self.thumbnailImageView];
    
    
    //Background Image
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self.backgroundImageView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    if(_thumbnailImage){
        [self.backgroundImageView setImage:_thumbnailImage];
    }else{
        [self.backgroundImageView sd_setImageWithURL:self.thumbnailURL];
    }
    
    [self insertSubview:self.backgroundImageView belowSubview:self.moviePlayer.view];
    
    //Big Play Button on the Middle
    playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [playButton setImage:[UIImage imageNamed:@"btnPlay"] forState:UIControlStateNormal];
    [playButton setFrame:self.bounds];
    [playButton setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self addSubview:playButton];
    
    //Player Manager Top
    self.playerManagerViewTop = [[UIView alloc] init];
    self.playerManagerViewTop.frame = CGRectMake(0, 0, frameWidth, PlayerManagerTopHeight);
    [self.playerManagerViewTop setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.4]];
    [self.playerManagerViewTop setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self addSubview:self.playerManagerViewTop];
    
    [self.playerManagerViewTop sdc_pinHeight:PlayerManagerTopHeight];
    [self.playerManagerViewTop sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:self];
    [self.playerManagerViewTop sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:self];
    [self.playerManagerViewTop sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:self];
    
    
    //Player Manager Bottom
    self.playerManagerViewBottom = [[UIView alloc] init];
    self.playerManagerViewBottom.frame = CGRectMake(0, frameHeight - PlayerManagerBottomHeight, frameWidth, PlayerManagerBottomHeight);
    [self.playerManagerViewBottom setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.4]];
    [self.playerManagerViewBottom setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.playerManagerViewBottom];
    
    [self.playerManagerViewBottom sdc_pinHeight:PlayerManagerBottomHeight];
    [self.playerManagerViewBottom sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:self];
    [self.playerManagerViewBottom sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:self];
    [self.playerManagerViewBottom sdc_alignEdge:UIRectEdgeBottom withEdge:UIRectEdgeBottom ofView:self];
    

    //Play Pause Button
    self.playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playPauseButton.frame = CGRectMake(0, 0, 44, 44);
    [self.playPauseButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playPauseButton setSelected:NO];
    [self.playPauseButton setImage:[UIImage imageNamed:@"pauseButton"] forState:UIControlStateSelected];
    [self.playPauseButton setImage:[UIImage imageNamed:@"playButton"] forState:UIControlStateNormal];
    [self.playPauseButton setTintColor:[UIColor clearColor]];
    [self.playPauseButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.playerManagerViewBottom addSubview:self.playPauseButton];
    
    [self.playPauseButton sdc_pinHeight:44.0];
    [self.playPauseButton sdc_pinWidth:44.0];
    [self.playPauseButton sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:self.playerManagerViewBottom inset:5.0];
    [self.playPauseButton sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:self.playerManagerViewBottom inset:0];
    
    //VolumeButton
    self.volumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.volumeButton.frame = CGRectMake(10, 5, 44, 40);
    [self.volumeButton addTarget:self action:@selector(volumeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.volumeButton setSelected:YES];
    [self.volumeButton setImage:[UIImage imageNamed:@"soundOn"] forState:UIControlStateSelected];
    [self.volumeButton setImage:[UIImage imageNamed:@"soundOff"] forState:UIControlStateNormal];
    [self.volumeButton setTintColor:[UIColor clearColor]];
    [self.volumeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.playerManagerViewTop addSubview:self.volumeButton];
    
    [self.volumeButton sdc_pinHeight:40];
    [self.volumeButton sdc_pinWidth:44];
    [self.volumeButton sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeLeft ofView:self.playerManagerViewTop inset:5];
    [self.volumeButton sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:self.playerManagerViewTop inset:-5];
    
    //Zoom button
    self.zoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.zoomButton.frame = CGRectMake(frameWidth - 50, 10, 40, 40);
    [self.zoomButton addTarget:self action:@selector(zoomButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.zoomButton setImage:[UIImage imageNamed:@"zoom"] forState:UIControlStateNormal];
    [self.zoomButton setImage:[UIImage imageNamed:@"zoom-minimize"] forState:UIControlStateSelected];
    [self.zoomButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.playerManagerViewBottom addSubview:self.zoomButton];
    
    [self.zoomButton sdc_pinHeight:40.0];
    [self.zoomButton sdc_pinWidth:40.0];
    [self.zoomButton sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:self.playerManagerViewBottom inset:-5];
    [self.zoomButton sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:self.playerManagerViewBottom inset:0];
    
    //Volume Progress Bar
    self.volumeBar = [[UISlider alloc] init];
    self.volumeBar.frame = CGRectMake(70, 0, frameWidth - 140, PlayerManagerTopHeight);
    [self.volumeBar addTarget:self action:@selector(volumeBarChanged:) forControlEvents:UIControlEventValueChanged];
    [self.volumeBar setValue:self.moviePlayer.player.volume];
    [self.volumeBar setThumbImage:[UIImage imageNamed:@"Slider_button"] forState:UIControlStateNormal];
    [self.volumeBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.playerManagerViewTop addSubview:self.volumeBar];
    
    [self.volumeBar sdc_pinHeight:PlayerManagerTopHeight];
    [self.volumeBar sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeRight ofView:self.volumeButton inset:5];
    [self.volumeBar sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:self.playerManagerViewTop inset:-10];
    [self.volumeBar sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:self.playerManagerViewTop inset:0];
    
    //Seek Time Progress Bar
    if(!isLive){
        
        /*
        //Resolution Button
        self.resolutionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.resolutionButton.frame = CGRectMake(0, 0, 40, PlayerManagerBottomHeight);
        [self.resolutionButton addTarget:self action:@selector(resolutionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.resolutionButton setImage:[UIImage imageNamed:@"resolution"] forState:UIControlStateNormal];
        [self.resolutionButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.playerManagerViewBottom addSubview:self.resolutionButton];
        
        [self.resolutionButton sdc_pinHeight:PlayerManagerBottomHeight];
        [self.resolutionButton sdc_pinWidth:40.0];
        [self.resolutionButton sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeLeft ofView:self.zoomButton inset:0];
        [self.resolutionButton sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:self.playerManagerViewBottom inset:0];
         */
        
        //Progress bar Slider
        self.progressBar = [[UISlider alloc] init];
        self.progressBar.frame = CGRectMake(70, 0, frameWidth - 130, PlayerManagerBottomHeight);
        [self.progressBar addTarget:self action:@selector(progressBarChanged:) forControlEvents:UIControlEventValueChanged];
        [self.progressBar addTarget:self action:@selector(proressBarChangeEnded:) forControlEvents:UIControlEventTouchUpInside];
        [self.progressBar setThumbImage:[UIImage imageNamed:@"Slider_button"] forState:UIControlStateNormal];
        [self.progressBar setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.playerManagerViewBottom addSubview:self.progressBar];
        
        [self.progressBar sdc_pinHeight:PlayerManagerBottomHeight];
        [self.progressBar sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeRight ofView:self.playPauseButton inset:5];
//        [self.progressBar sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeLeft ofView:self.resolutionButton inset:-5];
        [self.progressBar sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeLeft ofView:self.zoomButton inset:-5];
        [self.progressBar sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:self.playerManagerViewBottom inset:0];
        
        //Current Time Label
        self.playBackTime = [[UILabel alloc] init];
        self.playBackTime.frame = CGRectMake(70, (PlayerManagerBottomHeight / 2) + 5, 60, 15);
        self.playBackTime.text = [self getStringFromCMTime:self.moviePlayer.player.currentTime];
        [self.playBackTime setTextAlignment:NSTextAlignmentLeft];
        [self.playBackTime setTextColor:[UIColor whiteColor]];
        self.playBackTime.font = [UIFont systemFontOfSize:12];
        [self.playBackTime setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.playerManagerViewBottom addSubview:self.playBackTime];
        
        [self.playBackTime sdc_pinHeight:15.0];
        [self.playBackTime sdc_pinWidth:60.0];
        [self.playBackTime sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeRight ofView:self.playPauseButton inset:5];
        [self.playBackTime sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:self.playerManagerViewBottom inset:(PlayerManagerBottomHeight / 2)+5];
        
        //Total Time label
        self.playBackTotalTime = [[UILabel alloc] init];
        self.playBackTotalTime.frame = CGRectMake(frameWidth - 120, (PlayerManagerBottomHeight / 2) + 5, 60, 15);
        [self.playBackTotalTime setTextAlignment:NSTextAlignmentRight];
        [self.playBackTotalTime setTextColor:[UIColor whiteColor]];
        self.playBackTotalTime.font = [UIFont systemFontOfSize:12];
        [self.playBackTotalTime setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.playerManagerViewBottom addSubview:self.playBackTotalTime];
        self.playBackTotalTime.text = self.durationString;
        
        [self.playBackTotalTime sdc_pinHeight:15.0];
        [self.playBackTotalTime sdc_pinWidth:60.0];
        [self.playBackTotalTime sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeLeft ofView:self.zoomButton inset:-5];
        [self.playBackTotalTime sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:self.playerManagerViewBottom inset:(PlayerManagerBottomHeight / 2)+5];
        
    }else{
        
        /*
        //Resolution Button
        self.resolutionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.resolutionButton.frame = CGRectMake(0, 0, 30, PlayerManagerBottomHeight);
        [self.resolutionButton addTarget:self action:@selector(resolutionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.resolutionButton setImage:[UIImage imageNamed:@"resolution"] forState:UIControlStateNormal];
        [self.resolutionButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.playerManagerViewBottom addSubview:self.resolutionButton];
        
        [self.resolutionButton sdc_pinHeight:PlayerManagerBottomHeight];
        [self.resolutionButton sdc_pinWidth:30.0];
        [self.resolutionButton sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeLeft ofView:self.zoomButton inset:-5];
        [self.resolutionButton sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:self.playerManagerViewBottom inset:0];
         */
        
        //LIVE Broadcast Label
        self.liveDescLabel = [[UILabel alloc] init];
        self.liveDescLabel.frame = CGRectMake(frameWidth - 120, 0, frameWidth, PlayerManagerBottomHeight);
        self.liveDescLabel.text = @"Live";
        [self.liveDescLabel setTextAlignment:NSTextAlignmentCenter];
        [self.liveDescLabel setTextColor:[UIColor whiteColor]];
        self.liveDescLabel.font = [UIFont systemFontOfSize:12];
        [self.liveDescLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.playerManagerViewBottom addSubview:self.liveDescLabel];
        
        [self.liveDescLabel sdc_pinHeight:PlayerManagerBottomHeight];
        [self.liveDescLabel sdc_alignEdge:UIRectEdgeLeft withEdge:UIRectEdgeRight ofView:self.playPauseButton inset:10];
//        [self.liveDescLabel sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeLeft ofView:self.resolutionButton inset:-5];
        [self.liveDescLabel sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeLeft ofView:self.zoomButton inset:-5];
        [self.liveDescLabel sdc_alignEdge:UIRectEdgeTop withEdge:UIRectEdgeTop ofView:self.playerManagerViewBottom inset:0];
    }
    
//    [self closePlayerManager];
    
    for (UIView *view in [self subviews]) {
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];

}

#pragma mark - Player Control Methods
-(void)resolutionButtonTapped:(UIButton *)sender{
    if([delegate respondsToSelector:@selector(DMMoviePlayer:resolutionButtonTapped:andSeekTime:)] && self.streamListArray.count > 0){
        [delegate DMMoviePlayer:self resolutionButtonTapped:self.streamListArray andSeekTime:self.moviePlayer.player.currentItem.currentTime];
    }
}

-(void)zoomButtonPressed:(UIButton*)sender{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    
    if (UIDeviceOrientationIsPortrait(orientation)){
        value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [self.theAd trackAdFullScreen];
    }
    
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

-(NSString*)getStringFromCMTime:(CMTime)time
{
    Float64 currentSeconds = CMTimeGetSeconds(time);
    int mins = currentSeconds/60.0;
    float fsecs = fmodf(currentSeconds, 60.0);
    int secs = ceilf(fsecs);
    NSString *minsString = mins < 10 ? [NSString stringWithFormat:@"0%d", mins] : [NSString stringWithFormat:@"%d", mins];
    NSString *secsString = secs < 10 ? [NSString stringWithFormat:@"0%d", secs] : [NSString stringWithFormat:@"%d", secs];
    
    if(secs < 0){
        minsString = @"00";
        secsString = @"00";
    }
    return [NSString stringWithFormat:@"%@:%@", minsString, secsString];
 
}

-(void)volumeButtonPressed:(UIButton*)sender
{
    if (sender.isSelected) {
        [self.moviePlayer.player setMuted:YES];
        [sender setSelected:NO];
    } else {
        [self.moviePlayer.player setMuted:NO];
        [sender setSelected:YES];
    }
}

-(void)playButtonAction:(UIButton*)sender
{
    //kalo waktu pertama banget dipencet harus process url
    if(playButton.selected){
        if (self.isPlaying) {
            [self pause];
            //        [sender setSelected:NO];
        } else {
            self.playPauseButton.selected = YES;
            [self.moviePlayer.player play];
            self.isPlaying = YES;
        }
    }else{
        self.thumbnailImageView.hidden = YES;
        [self.playButton setImage:nil forState:UIControlStateNormal];
        playButton.selected = YES;
        self.isPlaying = YES;
        if (playbackType == MediaPlayerViewControllerPlaybackTypeNone && self.vastURL) {
            [self processingVastURL];
        }else{
            [self playMediaURL];
            
        }
        [self.playPauseButton setSelected:YES];
        [self performSelector:@selector(closePlayerManager) withObject:nil afterDelay:3.0];
    }
    
}

-(void)progressBarChanged:(UISlider*)sender
{
    if (self.isPlaying) {
        [self.moviePlayer.player pause];
    }
    CMTime seekTime = CMTimeMakeWithSeconds(sender.value * (double)self.moviePlayer.player.currentItem.asset.duration.value/(double)self.moviePlayer.player.currentItem.asset.duration.timescale, self.moviePlayer.player.currentTime.timescale);
    [self.moviePlayer.player seekToTime:seekTime];
}

-(void)proressBarChangeEnded:(UISlider*)sender
{
    if (self.isPlaying) {
        [self.moviePlayer.player play];
    }
}

-(void)volumeBarChanged:(UISlider*)sender
{
    [self.moviePlayer.player setVolume:sender.value];
}

-(void)play
{
    if(playButton.selected){
        if (viewIsShowing) {
            [self closePlayerManager];
        } else {
            [self openPlayerManager];
        }
    }else{
        self.thumbnailImageView.hidden = YES;
        [self.playButton setImage:nil forState:UIControlStateNormal];
        playButton.selected = YES;
        self.isPlaying = YES;
        if (playbackType == MediaPlayerViewControllerPlaybackTypeNone && self.vastURL) {
            [self processingVastURL];
        }else{
            [self playMediaURL];
            
        }
        [self.playPauseButton setSelected:YES];
        [self performSelector:@selector(closePlayerManager) withObject:nil afterDelay:3.0];
    }
}

-(void)pause
{
    [self.theAd trackAdPause];
    [self.moviePlayer.player pause];
    self.isPlaying = NO;
    [self.playPauseButton setSelected:NO];
}

-(void)stopMovie{
    [self.moviePlayer.player pause];
    [self.moviePlayer.player setRate:0.0];
    [timer invalidate];
    [self removeKVOForMoviePlayer];
    self.moviePlayer.player = nil;
    self.moviePlayer = nil;
}

-(void)closePlayerManager{
    
    [UIView animateWithDuration:0.3 animations:^{
        self.playerManagerViewTop.alpha = 0.0;
        self.playerManagerViewBottom.alpha = 0.0;
        viewIsShowing = NO;
    }];
}

-(void)openPlayerManager{

    [UIView animateWithDuration:0.3 animations:^{
        self.playerManagerViewTop.alpha = 1.0;
        self.playerManagerViewBottom.alpha = 1.0;
        viewIsShowing = YES;
    }];
    
    [self performSelector:@selector(closePlayerManager) withObject:nil afterDelay:3.0];
}

-(void)commencingPIPWithMainVideoURL:(NSURL *)mainURL andMiniVideoURL:(NSURL *)miniURL{
    
    //Main Movie Player
    if(mainURL){
        self.contentURL = mainURL;
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:mainURL];
        [self.moviePlayer.player replaceCurrentItemWithPlayerItem:playerItem];
    }
    
    //Mini Movie Player Picture in Picture
    self.contentMiniURL = miniURL;
    if(!self.isPIP){
        self.isPIP = YES;
        self.miniMoviePlayer = nil;
        AVPlayerViewController *miniPlayerViewController = [[AVPlayerViewController alloc] init];
        miniPlayerViewController.player = [AVPlayer playerWithURL:self.contentMiniURL];
        self.miniMoviePlayer = miniPlayerViewController;
        self.miniMoviePlayer.view.frame = CGRectZero;
        self.miniMoviePlayer.showsPlaybackControls = NO;
        self.miniMoviePlayer.view.hidden = NO;
        [self insertSubview:self.miniMoviePlayer.view belowSubview:self.playerManagerViewBottom];
        [self.miniMoviePlayer.player play];

        [self.miniMoviePlayer.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.miniMoviePlayer.view sdc_pinWidthToWidthOfView:self multiplier:PERCENTAGE_OF_PIP];
        [self.miniMoviePlayer.view sdc_pinHeightToHeightOfView:self multiplier:PERCENTAGE_OF_PIP];
        [self.miniMoviePlayer.view sdc_alignEdge:UIRectEdgeRight withEdge:UIRectEdgeRight ofView:self inset:-10];
        [self.miniMoviePlayer.view sdc_alignEdge:UIRectEdgeBottom withEdge:UIRectEdgeBottom ofView:self inset:-10];
    }else if(self.isPIP){
        if(miniURL){
            self.miniMoviePlayer.view.hidden = NO;
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:miniURL];
            [self.miniMoviePlayer.player replaceCurrentItemWithPlayerItem:playerItem];
            [self.miniMoviePlayer.player play];
        }
    }

}

-(void)shrinkMainVideoWithAnimation:(BOOL)animate andSize:(CGSize)modifiedSize{
    
    float animateTime = animate?1.0:0.0;
    
    if(animate)
        self.isShrink = !self.isShrink;

    CGRect modifiedRect = CGRectMake(0, 0, modifiedSize.width, modifiedSize.height);
    
    [UIView animateWithDuration:animateTime animations:^{

        [self.moviePlayer.view setFrame:modifiedRect];
        [self.moviePlayer.view layoutIfNeeded];
        
    }];
}


#pragma mark - KVO Subscribe / Unsubscribe
-(void)registerKVOForMoviePlayer{
    [self removeKVOForMoviePlayer];
    [self.moviePlayer.player addObserver:self forKeyPath:@"status" options:0 context:PlayerStatusContext];
    [self.moviePlayer.player addObserver:self forKeyPath:@"rate" options:0 context:PlayerRateContext];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(itemStalled:) name:AVPlayerItemPlaybackStalledNotification object:nil];
}

-(void)itemStalled:(NSNotification *)notif{
    NSLog(@"%@", @"AVPlayerItemPlaybackStalledNotification");
}

-(void)removeKVOForMoviePlayer{
    @try {
        [self.moviePlayer.player removeObserver:self forKeyPath:@"status"];
        [self.moviePlayer.player removeObserver:self forKeyPath:@"rate"];
    }
    @catch (NSException * __unused exception) {
        
    }
    
}

#pragma mark - KVO listener
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    AVPlayer *thePlayer = (AVPlayer *)object;
    if (context == PlayerStatusContext) {
        
        if ([thePlayer status] == AVPlayerStatusFailed) {
            
            NSError *error = [self.moviePlayer.player error];
            NSLog(@"Status Failed with error : %@",[error localizedDescription]);
            return;
        }else if ([thePlayer status] == AVPlayerStatusReadyToPlay) {
            self.playBackTotalTime.text = [self getStringFromCMTime:self.moviePlayer.player.currentItem.asset.duration];
            NSLog(@"Status Ready to Play");
            return;
        }else if ([thePlayer status] == AVPlayerStatusUnknown) {
            
            NSLog(@"Status Unknown");
            return;
        }
    }else if (context == PlayerRateContext){
        if (thePlayer.rate == 0) {
            NSLog(@"Not Playing");
            
        }else if(thePlayer.rate > 0){
            NSLog(@"Playing");
        }
    }
    return;

}

-(void)AVPlayerItemDidPlayToEndTimeNotificationHandler:(NSNotification *)notif{
    hasReachedThirdQuartile = NO;
    hasReachedFirstQuartile = NO;
    hasReachedMidPoint = NO;
    NSLog(@"AVPlayerItemDidPlayToEndTimeNotification");
    if (self.theAd) {
        [self.theAd trackAdComplete];
    }
    
    AVPlayerItem *thePlayerItem = notif.object;
    [thePlayerItem seekToTime:kCMTimeZero];
    AVAsset *currentPlayerAsset = thePlayerItem.asset;
    NSURL *url = [(AVURLAsset *)currentPlayerAsset URL];
    if([url isEqual:self.contentMiniURL]){
        [self.miniMoviePlayer.player pause];
        [self.miniMoviePlayer.player setRate:0.0];
        self.miniMoviePlayer.view.hidden = YES;
    }else{
        [self.playPauseButton setSelected:NO];
        self.isPlaying = NO;
        if(delegate && [delegate respondsToSelector:@selector(DMMoviePlayer:playbackDidPlayToEndTime:)])
            [delegate DMMoviePlayer:self playbackDidPlayToEndTime:notif];
        [self playBackFinish];
    }
    
}



#pragma mark - Ads Methods
-(VastAd *)theAd{
    return playbackType == MediaPlayerViewControllerPlaybackTypePreroll ? prerollAd : playbackType == MediaPlayerViewControllerPlaybackTypePostroll ? postrollAd : nil;
    
}

- (void)playPreroll {
    if ([prerollAd hasMedia]) {
        self.playPauseButton.hidden = YES;
        self.resolutionButton.hidden = YES;
        self.progressBar.enabled = NO;
        playbackType = MediaPlayerViewControllerPlaybackTypePreroll;
        [self.moviePlayer.player pause];
        [self.moviePlayer.player setRate:0.0];
        [self removeKVOForMoviePlayer];
        self.moviePlayer.player = [AVPlayer playerWithURL:[NSURL URLWithString:prerollAd.mediaFileURL]];
        [self registerKVOForMoviePlayer];
        [self.moviePlayer.player play];
        self.playPauseButton.selected = YES;
        [prerollAd trackAdStart];
        if(delegate && [delegate respondsToSelector:@selector(DMMoviePlayer:playPreroll:)])
            [delegate DMMoviePlayer:self playPreroll:prerollAd];
    }
    else {
        [self playMediaURL];
    }
}

- (void)playMediaURL {
    self.playPauseButton.hidden = NO;
    self.resolutionButton.hidden = NO;
    self.progressBar.enabled = YES;
    playbackType = MediaPlayerViewControllerPlaybackTypeMedia;
    [self.moviePlayer.player pause];
    [self.moviePlayer.player setRate:0.0];
    [self removeKVOForMoviePlayer];
    self.moviePlayer.player = [AVPlayer playerWithURL:self.contentURL];
    [self registerKVOForMoviePlayer];
    [self.moviePlayer.player play];
    self.playPauseButton.selected = YES;
    if(delegate && [delegate respondsToSelector:@selector(DMMoviePlayer:playMediaURL:)])
        [delegate DMMoviePlayer:self playMediaURL:self.contentURL];
    NSLog(@"playing video at %@", self.contentURL);
}

- (void)playPostroll {
    playbackType = MediaPlayerViewControllerPlaybackTypePostroll;
    if ([postrollAd hasMedia]) {
        self.playPauseButton.hidden = YES;
        self.resolutionButton.hidden = YES;
        self.progressBar.enabled = NO;
        [self.moviePlayer.player pause];
        [self.moviePlayer.player setRate:0.0];
        [self removeKVOForMoviePlayer];
        self.moviePlayer.player = [AVPlayer playerWithURL:[NSURL URLWithString:postrollAd.mediaFileURL]];
        [self registerKVOForMoviePlayer];
        [self.moviePlayer.player play];
        self.playPauseButton.selected = YES;
        [postrollAd trackAdStart];
        if(delegate && [delegate respondsToSelector:@selector(DMMoviePlayer:playPostroll:)])
            [delegate DMMoviePlayer:self playPostroll:postrollAd];
    }
    else {
        [self playBackFinish];
    }
}


- (void)playBackFinish{
    if (playbackType == MediaPlayerViewControllerPlaybackTypeNone) {
        NSLog(@"should play preRoll");
        [self playPreroll];
    }
    else if (playbackType == MediaPlayerViewControllerPlaybackTypePreroll) {
        NSLog(@"should play media");
        [self playMediaURL];
    }
    else if (playbackType == MediaPlayerViewControllerPlaybackTypeMedia) {
        NSLog(@"should play postRoll");
        [self playPostroll];
    }
    else if (playbackType == MediaPlayerViewControllerPlaybackTypePostroll) {
        NSLog(@"should udahan");
        [self stopMovie];
        [self initializeWithContentURL:self.contentURL andThumbnailURL:self.thumbnailURL andVastURL:self.vastURL durationString:self.durationString];
    }
}


#pragma mark - vast URL
- (void)processingVastURL{
    [self timerFired];
    
    objTbxml = [[TBXML alloc] initWithURL:self.vastURL success:^(TBXML *tbxml) {
        
        TBXMLElement *vastNode = tbxml.rootXMLElement;
        if (vastNode) {
            TBXMLElement *adNode = vastNode->firstChild;
            while (adNode) {
                TBXMLAttribute *attribute = adNode->firstAttribute;
                
                while (attribute) {
                    NSLog(@"elementName adNode:%@ | attributeName attribute:%@ | attributeValue attribute: %@",[TBXML elementName:adNode], [TBXML attributeName:attribute],[TBXML attributeValue:attribute]);
                    if ([[TBXML elementName:adNode] isEqualToString:@"Ad"] && [[TBXML attributeName:attribute] isEqualToString:@"id"] && [[TBXML attributeValue:attribute] isEqualToString:@"pre-roll-0"]) {
                        // parse preroll
                        if(adNode){
                            prerollAd = [[VastAd alloc] initWithTBXMLElement:adNode];
                            if ([prerollAd hasMedia]) {
                                NSLog(@"=====PreRoll Ada=====");
                            }
                        }
                    }
                    
                    if ([[TBXML elementName:adNode] isEqualToString:@"Ad"] && [[TBXML attributeName:attribute] isEqualToString:@"id"] && [[TBXML attributeValue:attribute] isEqualToString:@"post-roll-0"]) {
                        // parse postroll
                        if(adNode){
                            postrollAd = [[VastAd alloc] initWithTBXMLElement:adNode];
                            if ([postrollAd hasMedia]) {
                                NSLog(@"=====PostRoll Ada=====");
                            }
                        }
                    }
                    
                    attribute = attribute->next;
                }
                
                adNode = adNode->nextSibling;
            }
        }
        
        [self performSelectorOnMainThread:@selector(playBackFinish) withObject:nil waitUntilDone:NO];
        
    } failure:^(TBXML *tbxml, NSError *error) {
        
        [self performSelectorOnMainThread:@selector(playBackFinish) withObject:nil waitUntilDone:NO];
        
    }];
}

#pragma mark - Timer functions

- (NSString *)minutesSecondsFromDuration:(double)duration {
    int seconds = MAX(0, (int)floor(duration)%60);
    int minutes = MAX(0, ((int)floor(duration) - seconds)/60);
    
    return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
}


- (void)timerFired {
    
    [self startLoader:NO disableUI:NO];
    
    AVPlayerItem *currentItem =moviePlayer.player.currentItem;
    NSTimeInterval currentTime = CMTimeGetSeconds(currentItem.currentTime);
    NSTimeInterval durationTime = CMTimeGetSeconds(currentItem.duration);
    //    NSLog(@" Capturing Time :%d ",(int)currentTime);
    
    if(moviePlayer.player.rate > 0){
        double progress = ceil(currentTime) / ceil(durationTime);

        self.progressBar.value = progress;
    
        self.playBackTime.text = [self getStringFromCMTime:self.moviePlayer.player.currentTime];

        if (self.theAd) {
            //ad is playing
            [self.theAd trackAdWithProgress:currentTime/durationTime];
        }else{
            //movie is playing
            if (!hasReachedFirstQuartile && (progress >= 0.25) && (progress < 0.5) ) {
                NSLog(@"Media reach first quartile");
                if(delegate && [delegate respondsToSelector:@selector(DMMoviePlayer:playerReachCheckPoint:)]){
                    [delegate DMMoviePlayer:self playerReachCheckPoint:PlayerCheckPointFirstQuartile];
                }
                hasReachedFirstQuartile = YES;
            }else if (!hasReachedMidPoint && (progress >= 0.5) && (progress < 0.75)) {
                NSLog(@"Media reach midpoint");
                if(delegate && [delegate respondsToSelector:@selector(DMMoviePlayer:playerReachCheckPoint:)]){
                    [delegate DMMoviePlayer:self playerReachCheckPoint:PlayerCheckPointMidPoint];
                }
                hasReachedMidPoint = YES;
            }else if (!hasReachedThirdQuartile && (progress >= 0.75) && (progress < 1.0)) {
                NSLog(@"Media reach third quartile");
                if(delegate && [delegate respondsToSelector:@selector(DMMoviePlayer:playerReachCheckPoint:)]){
                    [delegate DMMoviePlayer:self playerReachCheckPoint:PlayerCheckPointThirdQuartila];
                }
                hasReachedThirdQuartile = YES;
            }
        }
        
    }
}



-(void)dealloc
{
    [self removeKVOForMoviePlayer];
    [timer invalidate];

}


@end
