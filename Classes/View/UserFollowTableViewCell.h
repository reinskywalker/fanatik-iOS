//
//  UserFollowTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/2/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserFollowTableViewCell;
@protocol UserFollowTableViewCellDelegate <NSObject>
@optional
-(void)successToFollowOrUnfollowWithUser:(User *)obj;
-(void)failedToFollowOrUnfollowWithErrorString:(NSString *)errorString;
@end

@interface UserFollowTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *userNameLabel;
@property (strong, nonatomic) IBOutlet CustomMediumButton *followButton;
@property (nonatomic, retain) User *currentUser;
@property (nonatomic, weak) id <UserFollowTableViewCellDelegate> delegate;
@property (nonatomic, assign) BOOL isUpdating;
@property (nonatomic, assign) BOOL canFollow;

-(void)updateFollowButton;
- (IBAction)followButtonTapped:(id)sender;
+(NSString *)reuseIdentifier;
-(void)fillCellWithUser:(User *)obj;

@end
