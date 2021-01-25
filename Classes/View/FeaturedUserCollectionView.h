//
//  LargeVideoTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/12/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FeaturedUserCollectionViewDelegate <NSObject>


@end

@interface FeaturedUserCollectionView : UICollectionViewCell

@property(nonatomic, weak) id <FeaturedUserCollectionViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIImageView *avatarThumbnailImage;
@property (strong, nonatomic) IBOutlet UIImageView *featuredUserImage;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic, retain) User *currentUser;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *userNameLabel;


+(NSString *)reuseIdentifier;
-(void)setItem:(User *)user;

@end
