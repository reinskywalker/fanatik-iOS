//
//  VideoInfoTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VideoInfoTableViewCellDelegate <NSObject>

-(void)commentButtonDidTap;
-(void)userButtonDidTap;
-(void)showingErrorFromServer:(NSString *)errorStr;
-(void)likeButtonDidTap;
-(void)shareButtonDidTap;
-(void)addPlaylistButtonDidTap;

@end

@interface VideoInfoTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *uploaderImageView;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *uploaderNameLabel;
@property (strong, nonatomic) IBOutlet CustomMediumButton *followButton;

@property (strong, nonatomic) IBOutlet CustomBoldLabel *videoTitleLabel;
@property (strong, nonatomic) IBOutlet CustomBoldButton *likeButton;
@property (strong, nonatomic) IBOutlet CustomBoldButton *commentButton;
@property (strong, nonatomic) IBOutlet CustomBoldButton *viewButton;
@property (strong, nonatomic) IBOutlet DTAttributedLabel *videoDateLabel;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *videoDescLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoDescHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoTitleHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoDateHeightConstraint;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, weak) id <VideoInfoTableViewCellDelegate> delegate;
@property (nonatomic, retain) Clip *currentClip;
@property (strong, nonatomic) IBOutlet DTAttributedLabel *videoViewsLabel;
@property (strong, nonatomic) IBOutlet UIImageView *downArrow;
@property (strong, nonatomic) IBOutlet DTAttributedLabel *sourceLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sourceHeightConstraint;


- (IBAction)userButtonTapped:(id)sender;
+(NSString *)reuseIdentifier;
- (IBAction)followButtonTapped:(id)sender;
- (IBAction)likeButtonTapped:(id)sender;
- (IBAction)commentButtonTapped:(id)sender;
- (IBAction)shareTapped:(id)sender;
-(CGFloat)cellHeight;
-(void)fillCellWithClip:(Clip*)aClip;
- (IBAction)playlistTapped:(id)sender;


@end
