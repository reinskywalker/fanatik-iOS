//
//  UserMentionTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/2/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "UserMentionTableViewCell.h"

@implementation UserMentionTableViewCell

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.userImageView.layer.cornerRadius = CGRectGetHeight(self.userImageView.frame)/2;
    self.userImageView.layer.masksToBounds = YES;
}

-(void)fillCellWithUser:(User *)obj{
    self.currentUser = obj;
    self.userImageView.image = nil;
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:obj.user_avatar.avatar_thumbnail]];
    self.userNameLabel.text = obj.user_username;
    self.userFullNameLabel.text = obj.user_name;

}

@end
