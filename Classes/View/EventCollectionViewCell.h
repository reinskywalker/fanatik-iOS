//
//  EventCollectionViewCell.h
//  Fanatik
//
//  Created by Erick Martin on 11/16/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BroadcasterOfflineModel.h"

@interface EventCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *eventThumbnailImage;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *eventTitleLabel;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *eventTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *isPremiumLabel;

@property (nonatomic, retain) Event *currentEvent;

+(NSString *)reuseIdentifier;
-(void)setItem:(Event *)event;
@end
