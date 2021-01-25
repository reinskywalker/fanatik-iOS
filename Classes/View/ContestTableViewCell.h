//
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/23/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContestTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *contestImageView;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *contestTimeLabel;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *contestNameLabel;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *contestDescriptionLabel;
@property (nonatomic, retain) Contest *currentContest;
@property (nonatomic, retain) IBOutlet UIView *gradientView;
@property (nonatomic, retain) CAGradientLayer *gradient;
@property (strong, nonatomic) IBOutlet CustomBoldLabel *badgeLabel;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *contestantCountLabel;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *clipCountLabel;
@property (strong, nonatomic) IBOutlet UIView *selectedStyleView;

-(void)setItem:(Contest *)obj;
+(NSString *)reuseIdentifier;

@end
