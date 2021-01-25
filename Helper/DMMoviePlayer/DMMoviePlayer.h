//
//  DMMoviePlayer.h
//  DMMoviePlayer
//
//  Created by Erick Martin on 9/29/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "VastAd.h"
#import "M3U8PlaylistModel.h"

typedef enum {
    MediaPlayerViewControllerPlaybackTypeNone = 0,
    MediaPlayerViewControllerPlaybackTypePreroll = 1,
    MediaPlayerViewControllerPlaybackTypeMedia = 2,
    MediaPlayerViewControllerPlaybackTypePostroll = 3
    
} MediaPlayerViewControllerPlaybackType;

typedef enum {
    PlayerCheckPointFirstQuartile = 0,
    PlayerCheckPointMidPoint = 1,
    PlayerCheckPointThirdQuartila = 2,
} PlayerCheckPoint;

@class DMMoviePlayer;

@protocol DMMoviePlayerDelegate <NSObject>
@optional
-(void)DMMoviePlayer:(DMMoviePlayer *)view playbackDidPlayToEndTime:(NSNotification *)notification;
-(void)DMMoviePlayer:(DMMoviePlayer *)moviePlayer playPreroll:(VastAd *)preRollAd;
-(void)DMMoviePlayer:(DMMoviePlayer *)moviePlayer playPostroll:(VastAd *)postRollAd;
-(void)DMMoviePlayer:(DMMoviePlayer *)moviePlayer playMediaURL:(NSURL *)mediaURL;
-(void)DMMoviePlayer:(DMMoviePlayer *)moviePlayer playerReachCheckPoint:(PlayerCheckPoint)chk;
-(void)DMMoviePlayer:(DMMoviePlayer *)moviePlayer resolutionButtonTapped:(NSArray *)array andSeekTime:(CMTime)time;
@end

@interface DMMoviePlayer : UIView

@property (assign, nonatomic) IBOutlet id <DMMoviePlayerDelegate> delegate;
@property (retain, nonatomic) NSURL *contentURL;
@property (nonatomic, retain) NSURL *thumbnailURL;
@property (nonatomic, retain) NSURL *vastURL;
@property (retain, nonatomic) NSURL *contentMiniURL;


@property (assign, nonatomic) BOOL isPlaying;
@property (assign, nonatomic) BOOL isLive;

@property (retain, nonatomic) UIButton *playPauseButton;
@property (retain, nonatomic) UIButton *volumeButton;
@property (retain, nonatomic) UIButton *zoomButton;
@property (retain, nonatomic) UIButton *resolutionButton;

@property (retain, nonatomic) UISlider *progressBar;
@property (retain, nonatomic) UISlider *volumeBar;

@property (retain, nonatomic) UILabel *playBackTime;
@property (retain, nonatomic) UILabel *playBackTotalTime;
@property (retain, nonatomic) UILabel *liveDescLabel;

@property (retain,nonatomic) UIView *playerManagerViewTop;
@property (retain,nonatomic) UIView *playerManagerViewBottom;

@property (strong, nonatomic) AVPlayerViewController *moviePlayer;
@property (strong, nonatomic) AVPlayerViewController *miniMoviePlayer;

@property (nonatomic, retain) UIImageView *thumbnailImageView;
@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) UIButton *playButton;

@property (nonatomic, retain) NSString *durationString;

@property (nonatomic, retain) NSMutableArray *streamListArray;
@property (nonatomic, retain) M3U8PlaylistModel *playlistModel;

@property (nonatomic, assign) CGSize originalPlayerSize;
@property (nonatomic, assign) BOOL isShrink;
@property (nonatomic, assign) BOOL isPIP;

@property (nonatomic, retain) UIImage *thumbnailImage;

- (void)initializeWithContentURL:(NSURL*)contentURL andThumbnailURL:(NSURL*)thumURL andVastURL:(NSURL *)vast durationString:(NSString *)dur;
-(void)play;
-(void)pause;
-(void)closePlayerManager;
-(void)openPlayerManager;
-(void)stopMovie;

-(void)commencingPIPWithMainVideoURL:(NSURL *)mainURL andMiniVideoURL:(NSURL *)miniURL;
-(void)shrinkMainVideoWithAnimation:(BOOL)animate andSize:(CGSize)size;

@end
