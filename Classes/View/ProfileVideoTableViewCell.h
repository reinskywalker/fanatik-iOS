//
//  ProfileVideoTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProfileVideoTableViewCell;

@protocol ProfileVideoTableViewCellDelegate <NSObject>

-(void)deleteClipWithId:(NSNumber *)clipID;
-(void)profileVideoTableViewCell:(ProfileVideoTableViewCell *)cell detailButtonTappedForClip:(Clip *)aClip;

@end

@interface ProfileVideoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
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
@property (strong, nonatomic) IBOutlet UIView *bottomView;

@property (nonatomic, weak) id <ProfileVideoTableViewCellDelegate> delegate;

- (IBAction)deleteButtonTapped:(id)sender;
- (IBAction)detailButtonTapped:(id)sender;
- (IBAction)likeButtonTapped:(id)sender;
- (IBAction)commentButtonTapped:(id)sender;
+ (NSString *)reuseIdentifier;
-(void)fillWithClip:(Clip *)obj;
-(CGFloat)cellHeight;
@end
