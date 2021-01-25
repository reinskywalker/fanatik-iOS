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

@interface VideoDetailViewController : ParentViewController<YTPlayerViewDelegate, UITableViewDelegate, UITableViewDataSource, PackageListViewControllerDelegate, UIAlertViewDelegate, DMKeyboardViewDelegate>{
}

@property (strong, nonatomic) IBOutlet YTPlayerView *youtubePlayer;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UITableView *autoCompleteTableView;
@property (nonatomic, retain) NSMutableArray *commentsArray;
@property (nonatomic, retain) NSMutableArray *relatedClipsArray;
@property (nonatomic, retain) NSArray *userAutoCompleteArray;
@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, retain) IBOutlet UIView *videoContainerView;
@property (nonatomic, retain) IBOutlet DMKeyboardView *keyboardView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightKeyboardViewConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightKeyboardiOSConstraint;
@property (assign, nonatomic) float heightKeyboardiOSConstraintTemp;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerAspectRationConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerBottomConstraint;


-(id)initWithClip:(Clip *)aClip;
-(id)initWithClipId:(NSNumber *)clipID;
@end
