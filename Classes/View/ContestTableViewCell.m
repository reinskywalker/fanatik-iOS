//
//  ContestTableViewCell.m
//  Fanatik
//
//  Created by Erick Martin on 2/23/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ContestTableViewCell.h"
#import "ContestStats.h"

@implementation ContestTableViewCell
@synthesize contestImageView, contestTimeLabel, contestNameLabel, contestDescriptionLabel;
@synthesize currentContest, gradient, badgeLabel;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)setItem:(Contest *)obj{
    self.currentContest = obj;
    contestNameLabel.text = currentContest.contest_name;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"dd MMMM yyyy";
    contestTimeLabel.text = [NSString stringWithFormat:@"Pada tanggal %@ - %@", [df stringFromDate:currentContest.contest_start_time], [df stringFromDate:currentContest.contest_end_time]];
    contestDescriptionLabel.text = currentContest.contest_description;
    [contestImageView sd_setImageWithURL:[NSURL URLWithString:currentContest.contest_cover_image_url] completed:nil];

    badgeLabel.hidden = NO;
    if([self.currentContest.contest_badge_text isEqualToString:@""] || !self.currentContest.contest_badge_text){
        badgeLabel.hidden = YES;
    }
    badgeLabel.text = self.currentContest.contest_badge_text;
    
    CGRect resizedFrame = badgeLabel.frame;
    CGSize actualSize = [self.badgeLabel.text sizeOfTextByBoundingWidth:200.0 andFont:[UIFont systemFontOfSize:8.0]];
    actualSize.height = 20.0;
    actualSize.width = actualSize.width + 10.0;
    resizedFrame.size = actualSize;
    [badgeLabel setFrame:resizedFrame];
    
    [badgeLabel setTextColor:[TheInterfaceManager convertColorStrToColor:self.currentContest.contest_badge_color isBackground:NO]];
    
    [badgeLabel setBackgroundColor:[TheInterfaceManager convertColorStrToColor:self.currentContest.contest_badge_background isBackground:YES]];
    
    _clipCountLabel.text = [NSString stringWithFormat:@"%@", self.currentContest.contest_contest_stats.contest_stats_videos];
    _contestantCountLabel.text = [NSString stringWithFormat:@"%@", self.currentContest.contest_contest_stats.contest_stats_contestants];
    
    if(!gradient){
        gradient = [CAGradientLayer layer];
        CGRect gradientFrame = _gradientView.bounds;
        gradientFrame.size.width = TheAppDelegate.deviceWidth;
        gradient.frame = gradientFrame;
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, nil];
        gradient.startPoint = CGPointMake(1.0f, 0.7f);
        gradient.endPoint = CGPointMake(1.0f, 0.0f);
        [_gradientView.layer insertSublayer:gradient atIndex:0];
    }
    
}

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}
@end
