//
//  TimelineVideoTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TimelineVideoTableViewCell;
@protocol TimelineVideoTableViewCellDelegate <NSObject>

-(void)timelineVideoTableViewCell:(TimelineVideoTableViewCell *)cell moreButtonDidTapForClip:(Clip *)clip;

@end


@interface TimelineVideoTableViewCell : UITableViewCell

@property(nonatomic, weak) id <TimelineVideoTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *userActivityDesc;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *activityTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;

@property (weak, nonatomic) IBOutlet UIView *videoDurationView;
@property (weak, nonatomic) IBOutlet UILabel *videoDurationLabel;

@property (weak, nonatomic) IBOutlet UILabel *videoTitle;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;

@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (nonatomic, retain) Timeline *currentTimeline;

- (IBAction)detailButtonTapped:(id)sender;
- (IBAction)likeButtonTapped:(id)sender;
- (IBAction)commentButtonTapped:(id)sender;
+(NSString *)reuseIdentifier;
-(void)fillWithTimeline:(Timeline *)obj;
@end
