//
//  TimelineViewController.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "ParentViewController.h"

@interface TimelineViewController : ParentViewController

@property(nonatomic, retain) NSMutableArray *timelinesArray;
@property(nonatomic, retain) PaginationModel *currentPagination;

@property (strong, nonatomic) IBOutlet UIView *timelineSectionHeaderView;
@property (weak, nonatomic) IBOutlet UIImageView *sectionUserAvatar;
@property (weak, nonatomic) IBOutlet UILabel *sectionTimelineLabel;
@property (weak, nonatomic) IBOutlet UILabel *sectionTimeAgoView;

@end
