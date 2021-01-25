//
//  TimelineCustomHeader.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/30/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OHAttributedLabel/OHASBasicHTMLParser.h>

@interface TimelineCustomHeader : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

- (void) fillWithTimeline:(Timeline*)obj;

@end
