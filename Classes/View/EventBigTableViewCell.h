//
//  EventBigTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EventBigTableViewCell;

@interface EventBigTableViewCell : UITableViewCell
+(NSString *)reuseIdentifier;

@property (strong, nonatomic) IBOutlet UIImageView *eventThumbnailImage;
@property (strong, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *isPremiumLabel;
@property (nonatomic, retain) IBOutlet UIView *gradientView;
@property (nonatomic, retain) Event *currentEvent;
@property (nonatomic, retain) CAGradientLayer *gradient;

-(void)fillWithEvent:(Event *)aEvent;

@end
