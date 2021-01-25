//
//  TVChannelInfoTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/23/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVChannelInfoTableViewCell : UITableViewCell

@property (nonatomic, retain) Live *currentLive;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *liveTitleLabel;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *liveDescriptionLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *liveDescriptionLabelHeight;
@property (nonatomic, assign) BOOL isExpanded;
@property (strong, nonatomic) IBOutlet UIImageView *downArrow;
-(void)setCellWithLive:(Live *)obj;
+(NSString *)reuseIdentifier;
-(CGFloat)cellHeight;

@end
