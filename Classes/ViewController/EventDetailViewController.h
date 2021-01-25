//
//  EventDetailViewController.h
//  Fanatik
//
//  Created by Erick Martin on 11/17/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "DMMoviePlayer.h"
#import "DMKeyboardView.h"
#import "MarqueeLabel.h"
#import "Event.h"

@interface EventDetailViewController : ParentViewController <UITableViewDataSource, UITableViewDelegate, DMKeyboardViewDelegate>

@property (strong, nonatomic) IBOutlet DMMoviePlayer *playerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerAspectRationConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerBottomConstraint;

@property (strong, nonatomic) IBOutlet MarqueeLabel *marqueeLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *marqueeHeightConstraint;

@property (nonatomic, assign) CGFloat defaultVideoHeight;
@property (nonatomic, strong) Event *currentEvent;
@property (nonatomic, retain) NSNumber *currentEventId;
@property (nonatomic, retain) IBOutlet DMKeyboardView *keyboardView;
@property (nonatomic, retain) IBOutlet UIView *uploadView;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightKeyboardViewConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightKeyboardiOSConstraint;
@property (assign, nonatomic) float heightKeyboardiOSConstraintTemp;

-(id)initWithEvent:(Event *)event;
-(id)initWithEventID:(NSNumber *)eventId;
-(IBAction)PIPtapped:(id)sender;
-(IBAction)shrinkTapped:(id)sender;
-(IBAction)uploadTapped:(id)sender;

@end
