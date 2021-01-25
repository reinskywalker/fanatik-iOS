//
//  MeTableViewCell.h
//  DMMoviePlayer
//
//  Created by Erick Martin on 10/22/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface StatusTextTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *chatLabel;
@property (strong, nonatomic) IBOutlet UILabel *chatDateLabel;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, retain) Message *currentMessage;

+(NSString *)reuseIdentifier;
-(void)fillCellWithMessage:(Message *)achat;

@end
