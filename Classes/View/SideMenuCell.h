//
//  SideMenuCell.h
//  Template 1
//
//  Created by Rafael on 05/12/13.
//  Copyright (c) 2013 Rafael Colatusso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RowMenuModel.h"
@interface SideMenuCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet CustomRegularLabel *cellLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellCountLabel;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *redLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *redLabelXConstraint;

-(void)setCellWithRowMenu:(RowMenuModel *)obj;
-(void)setFollowingLabelWithStats:(UserStats *)stat;
-(void)setFollowerLabelWithStats:(UserStats *)stat;
+(NSString *)reuseIdentifier;

@end
