//
//  LiveChatDetailViewController.h
//  Fanatik
//
//  Created by Erick Martin on 11/17/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "DMChatView.h"
#import "DMMoviePlayer.h"

@interface LiveChatDetailViewController : ParentViewController

@property (strong, nonatomic) IBOutlet DMMoviePlayer *playerView;
@property (strong, nonatomic) IBOutlet DMChatView *myChatView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerAspectRationConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerBottomConstraint;

@property (nonatomic, assign) CGFloat defaultVideoHeight;
@property (nonatomic, strong) BroadcasterOnline *currentBroadcaster;
@property (nonatomic, retain) NSNumber *currentBroadcasterId;

-(id)initWithBroadcaster:(BroadcasterOnline *)broadcast;
-(id)initWithBroadcasterID:(NSNumber *)broadID;
-(IBAction)PIPtapped:(id)sender;
-(IBAction)shrinkTapped:(id)sender;

@end
