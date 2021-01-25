//
//  EventInfoTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "EventInfoTableViewCell.h"

@implementation EventInfoTableViewCell
@synthesize delegate, currentEvent, headerMenu, currentVisibility;

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


-(void)fillCellWithEvent:(Event *)aEvent{
    self.currentEvent = aEvent;
    _followButton.layer.cornerRadius = 2.0;
    _followButton.layer.masksToBounds = YES;
    _followButton.layer.borderColor = [_followButton.titleLabel.textColor CGColor];
    _followButton.layer.borderWidth = 1.0;
    
    _uploaderImageView.layer.cornerRadius = _uploaderImageView.frame.size.width/2;
    _uploaderImageView.layer.masksToBounds = YES;
    
    _uploaderImageView.image = nil;
    [_uploaderImageView sd_setImageWithURL:[NSURL URLWithString:aEvent.event_user.user_avatar.avatar_thumbnail]];
    _uploaderNameLabel.text = aEvent.event_user.user_name;

    _eventTitleLabel.text = aEvent.event_name;
    _eventDescLabel.text = aEvent.event_description;
    _eventWatchingLabel.text = [NSString stringWithFormat:@"%@ watching",aEvent.event_watching_count];
    self.eventDateLabel.text = aEvent.eventDateWithTimezone;
    
    UIColor *buttonColor;
    UIColor *textColor;
    if([aEvent.event_user.user_socialization.socialization_following boolValue]){
        [self.followButton setImage:[UIImage imageNamed:@"minicheck"] forState:UIControlStateNormal];
        [self.followButton setImageEdgeInsets:UIEdgeInsetsMake(0, -7, 0, 0)];
        [self.followButton setTitleEdgeInsets: UIEdgeInsetsMake(0, 5, 0, 0)];
        [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
        [self.followButton setBackgroundColor:HEXCOLOR(0x1563f3FF)];
        buttonColor = HEXCOLOR(0x1563f3FF);
        textColor = [UIColor whiteColor];
    }else{

        buttonColor = HEXCOLOR(0x1563f3FF);
        textColor = HEXCOLOR(0x1563f3FF);
        
        [self.followButton setImage:nil forState:UIControlStateNormal];
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        [self.followButton setBackgroundColor:[UIColor clearColor]];
    }
    self.followButton.layer.borderColor = [buttonColor CGColor];
    self.followButton.layer.borderWidth = 1.0;
    [self.followButton setTitleColor:textColor forState:UIControlStateNormal];
    
    self.headerMenu.delegate = self;
    self.headerMenu.dataSource = self;
    [self.headerMenu reloadData];
//    NSLog(@"cell content offset: %@",NSStringFromCGPoint(self.contentOffset));
//    NSLog(@"cell content inset: %@", NSStringFromUIEdgeInsets(self.myTableView.contentInset));
}

-(CGFloat)cellHeight{
    CGFloat cellPadding = 165;
    CGFloat labelWidth = CGRectGetWidth(self.eventDescLabel.frame);
    CGSize expandedSize = CGSizeMake(labelWidth, 1000);
    CGSize fitSize = [self.eventDescLabel sizeThatFits:self.eventDescLabel.frame.size];
    expandedSize.height = fitSize.height;
    
    self.eventDescHeightConstraint.constant = self.isExpanded ? expandedSize.height : 0;

    CGSize titleSize = [self.eventTitleLabel sizeThatFits:self.eventTitleLabel.frame.size];
    self.eventTitleHeightConstraint.constant = titleSize.height;
    
    [_downArrow setImage:[UIImage imageNamed:self.isExpanded?@"upArrow":@"downArrow"]];
    return ceilf(self.eventTitleHeightConstraint.constant + self.eventDescHeightConstraint.constant + cellPadding);
}

- (void)layoutSubviews{
    [self cellHeight];
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)followButtonTapped:(id)sender {
    [self.followButton setUserInteractionEnabled:NO];
    if([currentEvent.event_user.user_socialization.socialization_following boolValue]){
        
        [UIAlertView showWithTitle:@"Unfollow" message:[NSString stringWithFormat:@"Stop following %@ ?",currentEvent.event_user.user_name] cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if(buttonIndex != alertView.cancelButtonIndex){
                
                [User unfollowUserWithId:currentEvent.event_user.user_id andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                    self.currentEvent.event_user.user_socialization.socialization_following = @NO;
                    [self.followButton setUserInteractionEnabled:YES];
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    [self.followButton setUserInteractionEnabled:YES];
                    
                    NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                    if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){

                        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                        
                        [delegate showingErrorFromServer:jsonDict[@"error"][@"messages"][0]];
                    }
                    
                    [self updateFollowButton];
                }];
                
                [self updateFollowButton];
            }
        }];
    }else{
        [User followUserWithId:currentEvent.event_user.user_id andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
            self.currentEvent.event_user.user_socialization.socialization_following = @YES;
            [self.followButton setUserInteractionEnabled:YES];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self.followButton setUserInteractionEnabled:YES];
            
            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){

                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                
                [delegate showingErrorFromServer:jsonDict[@"error"][@"messages"][0]];
            }
            
            [self updateFollowButton];
        }];
        
        [self updateFollowButton];
    }
}

-(void)updateFollowButton{
    UIColor *buttonColor;
    UIColor *textColor;
    if([self.followButton.titleLabel.text isEqualToString:@"Follow"]){
        
        [self.followButton setImage:[UIImage imageNamed:@"minicheck"] forState:UIControlStateNormal];
        [self.followButton setImageEdgeInsets:UIEdgeInsetsMake(0, -7, 0, 0)];
        [self.followButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
        [self.followButton setBackgroundColor:HEXCOLOR(0x1563f3FF)];
        buttonColor = HEXCOLOR(0x1563f3FF);
        textColor = [UIColor whiteColor];
        
    }else{
        
        buttonColor = HEXCOLOR(0x1563f3FF);
        textColor = HEXCOLOR(0x1563f3FF);
        
        [self.followButton setImage:nil forState:UIControlStateNormal];
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        [self.followButton setBackgroundColor:[UIColor clearColor]];
    }
    self.followButton.layer.borderColor = [buttonColor CGColor];
    self.followButton.layer.borderWidth = 1.0;
    [self.followButton setTitleColor:textColor forState:UIControlStateNormal];
}

- (IBAction)userButtonTapped:(id)sender {
    [delegate userButtonDidTap];
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
    NSNumber *totalComments = currentEvent.event_stats.event_stats_comments;
    if(totalComments == nil){
        totalComments = @0;
    }

    label.text = index==0?[NSString stringWithFormat:@"COMMENTS (%@)", totalComments]:@"VIDEOS";
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
