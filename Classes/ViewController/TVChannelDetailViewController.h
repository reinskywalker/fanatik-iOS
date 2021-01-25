//
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/14/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "YTPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "PackageListViewController.h"
#import "DMKeyboardView.h"

@interface TVChannelDetailViewController : ParentViewController<UITableViewDelegate, UITableViewDataSource, DMKeyboardViewDelegate>{
}

@property (strong, nonatomic) IBOutlet UIButton *addToPlaylistButton;
@property (strong, nonatomic) IBOutlet UIView *videoContainerView;

@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) AVPlayerViewController *moviePlayer;
@property (strong, nonatomic) IBOutlet UIView *buttonView;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UIButton *playVideoButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;

@property(nonatomic, retain) NSMutableArray *commentsArray;
@property(nonatomic, retain) NSMutableArray *relatedClipsArray;
@property(nonatomic, retain) Live *currentLive;
@property (nonatomic, retain) IBOutlet DMKeyboardView *keyboardView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightKeyboardViewConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightKeyboardiOSConstraint;
@property (assign, nonatomic) float heightKeyboardiOSConstraintTemp;

@property (strong, nonatomic) IBOutlet UITableView *autoCompleteTableView;
@property (nonatomic, retain) NSArray *userAutoCompleteArray;

- (IBAction)restartVideoTapped:(id)sender;
-(id)initWithLive:(Live *)live;
-(id)initWithLiveId:(NSString *)liveId;
@end
