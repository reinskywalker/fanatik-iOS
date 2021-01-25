//
//  UserMentionTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/2/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserMentionTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *userFullNameLabel;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *userNameLabel;
@property (nonatomic, retain) User *currentUser;

+(NSString *)reuseIdentifier;
-(void)fillCellWithUser:(User *)obj;

@end
