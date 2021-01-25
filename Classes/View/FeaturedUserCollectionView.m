//
//  LargeVideoTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/12/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "FeaturedUserCollectionView.h"
#import "Thumbnail+functionality.h"
#import "Video+functionality.h"
#import "ClipStats+functionality.h"

@implementation FeaturedUserCollectionView

@synthesize delegate;
@synthesize bottomView, currentUser, avatarThumbnailImage, userNameLabel;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)setItem:(User *)user{
    self.currentUser = user;
    
    [avatarThumbnailImage sd_setImageWithURL:[NSURL URLWithString:currentUser.user_avatar.avatar_thumbnail]];
    _featuredUserImage.hidden = !user.user_featured;
    userNameLabel.text = currentUser.user_name;
}

@end
