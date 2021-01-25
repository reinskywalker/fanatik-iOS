//
//  MeTableViewCell.h
//  DMMoviePlayer
//
//  Created by Erick Martin on 10/22/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface MeTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *chatLabel;
@property (strong, nonatomic) IBOutlet UILabel *chatDateLabel;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIImageView *bubbleImage;
@property (strong, nonatomic) IBOutlet UIImageView *stickerImgView;
@property (nonatomic, retain) Message *currentMessage;

+(NSString *)reuseIdentifier;
-(CGFloat)cellHeight;
-(void)fillCellWithMessage:(Message *)achat;

@end
