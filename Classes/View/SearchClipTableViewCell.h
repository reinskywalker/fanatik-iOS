
//
//  SearchClipTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/11/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserUploads.h"

@class SearchClipTableViewCell;

@protocol SearchClipTableViewCellDelegate <NSObject>

-(void)moreButtonDidTapForClip:(Clip *)clip;

@end

@interface SearchClipTableViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *premiumLabel;
@property(nonatomic, weak) id <SearchClipTableViewCellDelegate> delegate;
@property (nonatomic, retain) Clip *currentClip;
@property (strong, nonatomic) IBOutlet UIImageView *videoImageView;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *videoTitleLabel;
@property (strong, nonatomic) IBOutlet DTAttributedLabel *viewCountLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleLabelHeight;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIView *separatorView;
@property (strong, nonatomic) IBOutlet UIImageView *badgeWinner;

- (IBAction)moreButtonTapped:(id)sender;
- (void)fillWithClip:(Clip *)aClip;
+(NSString *)reuseIdentifier;
@end
