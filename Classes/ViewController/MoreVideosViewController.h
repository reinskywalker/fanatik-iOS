//
//  MoreVideosViewController.h
//  Fanatik
//
//  Created by Erick Martin on 5/22/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ParentViewController.h"
#import "SearchClipTableViewCell.h"

@interface MoreVideosViewController : ParentViewController <UITableViewDataSource, UITableViewDelegate, SearchClipTableViewCellDelegate>

@property (nonatomic, assign) int currentPage;

@property (nonatomic, retain) IBOutlet UIView *tableHeaderView;
@property (nonatomic, retain) IBOutlet UILabel *contestNameLabel;

-(id)initWithClipGroup:(ClipGroup *)clipGroup;
-(id)initWithContest:(Contest *)contest;
@end
