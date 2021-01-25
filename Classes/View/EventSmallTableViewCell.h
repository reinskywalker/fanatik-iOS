//
//  EventSmallTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EventSmallTableViewCell;

@interface EventSmallTableViewCell : UITableViewCell
+(NSString *)reuseIdentifier;

@property (strong, nonatomic) IBOutlet UIImageView *eventThumbnailImage;
@property (strong, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *isPremiumLabel;

@property (nonatomic, retain) Event *currentEvent;

-(void)fillWithEvent:(Event *)aEvent;

@end
