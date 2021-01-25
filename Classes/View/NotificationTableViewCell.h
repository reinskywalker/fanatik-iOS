//
//  NotificationTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotificationTableViewCellDelegate <NSObject>

-(void)showingErrorFromServer:(NSString *)errorStr;

@end

@interface NotificationTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *frameView;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet DTAttributedLabel *notifLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *notifLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet UILabel *notifDateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *notifImageView;
@property (strong, nonatomic) IBOutlet UIButton *notifFollowButton;
@property (strong, nonatomic) Notification *currentNotif;
@property (nonatomic, weak) id <NotificationTableViewCellDelegate> delegate;

+(NSString *)reuseIdentifier;
-(CGFloat)cellHeight;
-(void)fillCellWithNotif:(Notification *)aNotif;
-(IBAction)followButtonTapped:(id)sender;

@end
