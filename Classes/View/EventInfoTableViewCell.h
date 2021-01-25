//
//  EventInfoTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    VisibilityModeComment = 0,
    VisibilityModeVideo = 1
}VisibilityMode;

@protocol EventInfoTableViewCellDelegate <NSObject>

-(void)userButtonDidTap;
-(void)showingErrorFromServer:(NSString *)errorStr;
-(void)didSelectVisibilityMode:(VisibilityMode)visMod;

@end

@interface EventInfoTableViewCell : UITableViewCell <SwipeViewDataSource, SwipeViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *uploaderImageView;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *uploaderNameLabel;
@property (strong, nonatomic) IBOutlet CustomMediumButton *followButton;

@property (strong, nonatomic) IBOutlet CustomBoldLabel *eventTitleLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *eventTitleHeightConstraint;
@property (strong, nonatomic) IBOutlet CustomSemiBoldLabel *eventWatchingLabel;
@property (strong, nonatomic) IBOutlet CustomSemiBoldLabel *eventDateLabel;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *eventDescLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *eventDescHeightConstraint;
@property (nonatomic, retain) IBOutlet SwipeView *headerMenu;

@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, weak) id <EventInfoTableViewCellDelegate> delegate;
@property (nonatomic, retain) Event *currentEvent;
@property (strong, nonatomic) IBOutlet UIImageView *downArrow;
@property (nonatomic, assign) VisibilityMode currentVisibility;

- (IBAction)userButtonTapped:(id)sender;
+(NSString *)reuseIdentifier;
- (IBAction)followButtonTapped:(id)sender;
-(CGFloat)cellHeight;
-(void)fillCellWithEvent:(Event *)aClip;


@end
