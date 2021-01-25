//
//  VideoRelatedTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VideoRelatedTableViewCell;
@protocol VideoRelatedTableViewCellDelegate <NSObject>

-(void)videoTableViewCell:(VideoRelatedTableViewCell *)cell moreButtonDidTap:(Clip *)aClip;

@end

@interface VideoRelatedTableViewCell : UITableViewCell
+(NSString *)reuseIdentifier;

@property (strong, nonatomic) IBOutlet UIImageView *videoThumbnailImage;
@property (strong, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet DTAttributedLabel *videoViewAttributedLabel;
@property (nonatomic, assign) BOOL isLastRow;
@property (nonatomic, weak) id <VideoRelatedTableViewCellDelegate> delegate;
@property (nonatomic, retain) Clip *currentClip;
@property (nonatomic, retain) IBOutlet UILabel *isPremiumLabel;

- (IBAction)moreButtonTapped:(id)sender;

-(void)fillWithClip:(Clip *)aClip;

@end
