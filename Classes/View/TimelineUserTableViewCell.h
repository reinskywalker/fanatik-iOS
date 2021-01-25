//
//  TimelineUserTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineUserTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *userBackgroundImage;
@property (strong, nonatomic) IBOutlet UIImageView *userAvatarImage;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *userNameLabel;


+(NSString *)reuseIdentifier;
-(void)fillWithTimeline:(Timeline *)obj;
@end
