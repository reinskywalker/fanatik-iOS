//
//  ClubListTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 3/11/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ClubListTableViewCell.h"

@implementation ClubListTableViewCell
@synthesize isJoinButton, delegate;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.clubImageView.layer.cornerRadius = CGRectGetHeight(self.clubImageView.frame)/2;
    self.clubImageView.layer.masksToBounds = YES;
}

-(void)fillWithClub:(Club *)theObj{
    self.currentClub = theObj;
    self.clubImageView.image = nil;
    [self.clubImageView sd_setImageWithURL:[NSURL URLWithString:theObj.club_user.user_avatar.avatar_thumbnail]];
    self.clubNameLabel.text = theObj.club_name;
    self.clubStatsLabel.text = [NSString stringWithFormat:@"%@ anggota", theObj.club_stats.stats_member];
    
    self.joinButton.layer.cornerRadius = 2.0;
    self.joinButton.layer.masksToBounds = YES;
    self.joinButton.layer.borderWidth = 1.0;
    
    if([self.currentClub.club_membership.membership_joined boolValue]){
        [self.joinButton setImage:[UIImage imageNamed:@"minicheck"] forState:UIControlStateNormal];
        [self.joinButton setImageEdgeInsets:UIEdgeInsetsMake(0, -7, 0, 0)];
        [self.joinButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        
        [self.joinButton setTitle:@"Joined" forState:UIControlStateNormal];
        [self.joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.joinButton setBackgroundColor:HEXCOLOR(0x1563f3FF)];
        self.joinButton.layer.borderColor = [HEXCOLOR(0x1563f3FF) CGColor];
    
    }else{
        [self.joinButton setImage:nil forState:UIControlStateNormal];
        [self.joinButton setTitle:@"Join" forState:UIControlStateNormal];
        [self.joinButton setTitleColor:HEXCOLOR(0x1563f3FF) forState:UIControlStateNormal];
        [self.joinButton setBackgroundColor:[UIColor clearColor]];
        self.joinButton.layer.borderColor = [HEXCOLOR(0x1563f3FF) CGColor];
    }
    
    [self.joinButton setNeedsLayout];
    [self.joinButton layoutIfNeeded];
    
}

- (IBAction)joinClubTapped:(id)sender {
    if([self.currentClub.club_membership.membership_joined boolValue]){
        [delegate clubListTableViewCell:self leaveClub:self.currentClub];
    }else{
        [delegate clubListTableViewCell:self joinClub:self.currentClub];
    }
    
}
@end
