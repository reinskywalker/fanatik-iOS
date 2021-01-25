//
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/23/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TVChannelTableViewCell;
@interface TVChannelTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *liveImageView;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *channelNameLabel;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *likeCountLabel;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *commentCountLabel;
@property (nonatomic, retain) Live *currentLive;
@property (strong, nonatomic) IBOutlet UILabel *isPremiumLabel;

-(void)setCellWithLive:(Live *)obj;
+(NSString *)reuseIdentifier;

@end
