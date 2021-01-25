//
//  ContestInfoTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ContestInfoTableViewCell.h"
#import "ContestStats.h"

@implementation ContestInfoTableViewCell
@synthesize delegate, currentContest, headerMenu, currentVisibility;
@synthesize statusLabel;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    
    [super awakeFromNib];
    // iOS 8.3 bug, where contentView's x position isnt aligned with self's x position...
    // So we add a constraint to do the obvious...
    [self.contentView sdc_alignEdgesWithSuperview:UIRectEdgeAll];
}


-(void)fillCellWithContest:(Contest *)aContest{
    self.currentContest = aContest;

    _titleLabel.text = aContest.contest_name;
    _descLabel.text = aContest.contest_description;
    
    NSDateFormatter *df = [TheAppDelegate defaultDateFormatter];    
    _dateLabel.text = [NSString stringWithFormat:@"%@ - %@", [df stringFromDate:aContest.contest_start_time], [df stringFromDate:aContest.contest_end_time]];
    
    statusLabel.hidden = NO;
    if([self.currentContest.contest_badge_text isEqualToString:@""] || !self.currentContest.contest_badge_text){
        statusLabel.hidden = YES;
    }
    statusLabel.text = self.currentContest.contest_badge_text;
    
    CGSize actualSize = [self.statusLabel.text sizeOfTextByBoundingWidth:200.0 andFont:[UIFont systemFontOfSize:8.0]];
    _statusWidthConstraint.constant = actualSize.width + 10.0;
    
    [statusLabel setTextColor:[TheInterfaceManager convertColorStrToColor:self.currentContest.contest_badge_color isBackground:NO]];
    
    [statusLabel setBackgroundColor:[TheInterfaceManager convertColorStrToColor:self.currentContest.contest_badge_background isBackground:YES]];
    
    self.headerMenu.delegate = self;
    self.headerMenu.dataSource = self;
    [self.headerMenu reloadData];
}

-(CGFloat)cellHeight{
    CGFloat cellPadding = 115;
    CGFloat labelWidth = CGRectGetWidth(self.descLabel.frame);
    CGSize expandedSize = CGSizeMake(labelWidth, 1000);
    CGSize fitSize = [self.descLabel sizeThatFits:self.descLabel.frame.size];
    expandedSize.height = fitSize.height;
    
    self.descHeightConstraint.constant = self.isExpanded ? expandedSize.height : 0;

    CGSize titleSize = [self.titleLabel sizeThatFits:self.titleLabel.frame.size];
    self.titleHeightConstraint.constant = titleSize.height;
    
    [_downArrow setImage:[UIImage imageNamed:self.isExpanded?@"upArrow":@"downArrow"]];
    return ceilf(self.titleHeightConstraint.constant + self.descHeightConstraint.constant + cellPadding);
}

- (void)layoutSubviews{
    [self cellHeight];
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -
#pragma mark SwipeheaderMenu methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    //return the total number of items in the carousel
    return 2.0;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    UIView *bottomSeparator = nil;
    UIView *selectedBottomSeparator = nil;
    UIView *verticalSeparator = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        CGRect modifiedRect = CGRectZero;

        modifiedRect.size.width = ceilf(headerMenu.frame.size.width)/2;
        modifiedRect.size.height = headerMenu.frame.size.height;

        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, modifiedRect.size.width, modifiedRect.size.height)];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.backgroundColor = [UIColor clearColor];
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:14.0];
        
        label.tag = 1;
        [view addSubview:label];
        
        CGRect bottomRect = CGRectZero;
        bottomRect.origin.y = CGRectGetHeight(headerMenu.frame);
        
        bottomSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, bottomRect.origin.y-1, CGRectGetWidth(view.frame), 1.0)];
        bottomSeparator.tag = 2;
        bottomSeparator.backgroundColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0];
        [view addSubview:bottomSeparator];
        
        verticalSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1.0, CGRectGetHeight(view.frame))];
        verticalSeparator.tag = 5;
        verticalSeparator.backgroundColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0];
        [view addSubview:verticalSeparator];
        
        selectedBottomSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, bottomRect.origin.y - 2, CGRectGetWidth(view.frame), 2.0)];
        selectedBottomSeparator.tag = 3;
        selectedBottomSeparator.backgroundColor = [UIColor colorWithRed:248/255.0 green:207/255.0 blue:63/255.0 alpha:1.0];
        [view addSubview:selectedBottomSeparator];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
        bottomSeparator = [view viewWithTag:2];
        selectedBottomSeparator = [view viewWithTag:3];
        verticalSeparator = [view viewWithTag:5];
    }
    
    UIColor *textSelectedColor = [UIColor colorWithRed:217/255.0 green:180/255.0 blue:52/255.0 alpha:1.0];
    UIColor *textNormalColor = HEXCOLOR(0x8E8E93FF);
    
    //swipeview header
    label.text = index==0?[NSString stringWithFormat:@"LATEST UPLOAD (%@)",self.currentContest.contest_contest_stats.contest_stats_videos]:[NSString stringWithFormat:@"CONTESTANT (%@)", self.currentContest.contest_contest_stats.contest_stats_contestants];
    label.textColor = index == self.currentVisibility ? textSelectedColor : textNormalColor;
    
    if(index == self.currentVisibility){
        bottomSeparator.hidden = YES;
        selectedBottomSeparator.hidden = NO;
        view.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
    }else{
        bottomSeparator.hidden = NO;
        selectedBottomSeparator.hidden = YES;
        view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    }
    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return CGSizeMake(ceilf(headerMenu.frame.size.width)/2, headerMenu.frame.size.height);
}

-(void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index{
    self.currentVisibility = (int)index;
    [self.headerMenu reloadData];
    [self.delegate didSelectVisibilityMode:currentVisibility];
}

@end
