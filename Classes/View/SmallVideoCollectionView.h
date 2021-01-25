//
//  LargeVideoTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/12/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SmallVideoCollectionViewDelegate <NSObject>

-(void)didTapMoreButtonForClip:(Clip *)aClip;

@end

@interface SmallVideoCollectionView : UICollectionViewCell

@property(nonatomic, weak) id <SmallVideoCollectionViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIImageView *videoThumbnailImage;
@property (strong, nonatomic) IBOutlet UIView *durationView;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *durationLabel;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *videoTitleLabel;
@property (nonatomic, retain) Clip *currentClip;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *isPremiumLabel;

+(NSString *)reuseIdentifier;
-(void)setItem:(Clip *)clip;

@end
