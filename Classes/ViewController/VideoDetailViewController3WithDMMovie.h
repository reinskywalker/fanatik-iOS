//
//  VideoDetailViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/14/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "YTPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PackageListViewController.h"
#import "DMKeyboardView.h"
#import "DMMoviePlayer.h"

@interface VideoDetailViewController : ParentViewController<YTPlayerViewDelegate, UITableViewDelegate, UITableViewDataSource, PackageListViewControllerDelegate, UIAlertViewDelegate, DMKeyboardViewDelegate>{
}

@property (strong, nonatomic) IBOutlet YTPlayerView *youtubePlayer;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UITableView *autoCompleteTableView;
@property (nonatomic, retain) NSMutableArray *commentsArray;
@property (nonatomic, retain) NSMutableArray *relatedClipsArray;
@property (nonatomic, retain) NSArray *userAutoCompleteArray;
@property (readwrite, retain) IBOutlet DMMoviePlayer *playerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *youtubePlayerTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerAspectRationConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerBottomConstraint;
@property (nonatomic, retain) IBOutlet DMKeyboardView *keyboardView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightKeyboardViewConstraint;

-(id)initWithClip:(Clip *)aClip;
-(id)initWithClipId:(NSNumber *)clipID;
@end
