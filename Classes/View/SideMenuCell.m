//
//  SideMenuCell.m
//  Template 1
//
//  Created by Rafael on 05/12/13.
//  Copyright (c) 2013 Rafael Colatusso. All rights reserved.
//

#import "SideMenuCell.h"
#import "MenuIcon+functionality.h"

@implementation SideMenuCell

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setCellWithRowMenu:(RowMenuModel *)obj{
    self.iconImageView.image = nil;
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:obj.rowMenuIconMDPI]];
    self.cellLabel.text = obj.rowMenuName;
    self.cellCountLabel.hidden = YES;
    
    if(![obj.rowMenuBadge isKindOfClass:[NSNull class]] && obj.rowMenuBadge && ![obj.rowMenuBadge isEqualToString:@""]){
        self.redLabel.text = obj.rowMenuBadge;
        self.redLabel.hidden = NO;
    }else{
        self.redLabel.hidden = YES;
    }
    
    CGSize fitSize = [self.cellLabel sizeThatFits:self.cellLabel.frame.size];
    self.redLabelXConstraint.constant = fitSize.width + 70.0;
    
    if([obj.rowMenuPage isEqualToString:MenuPageTimeline] || [obj.rowMenuPage isEqualToString:MenuPageNotification]){
        self.contentView.backgroundColor = [UIColor whiteColor];
    }else{
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    
}

-(void)setFollowingLabelWithStats:(UserStats *)stat{
    self.cellCountLabel.hidden = NO;
    self.cellCountLabel.text = [NSString stringWithFormat:@"%@",stat.user_stats_following];
}

-(void)setFollowerLabelWithStats:(UserStats *)stat{
    self.cellCountLabel.hidden = NO;
    self.cellCountLabel.text = [NSString stringWithFormat:@"%@",stat.user_stats_followers];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.cellCountLabel.layer.cornerRadius = self.cellCountLabel.frame.size.height / 2;
    self.cellCountLabel.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
