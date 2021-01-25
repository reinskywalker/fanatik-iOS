//
//  VideoInfoTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "VideoInfoTableViewCell.h"

@implementation VideoInfoTableViewCell
@synthesize delegate, currentClip;



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


-(void)fillCellWithClip:(Clip *)aClip{
//    aClip.clip_video.video_description = @"lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit ametlorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet";
    self.currentClip = aClip;
    _followButton.layer.cornerRadius = 2.0;
    _followButton.layer.masksToBounds = YES;
    _followButton.layer.borderColor = [_followButton.titleLabel.textColor CGColor];
    _followButton.layer.borderWidth = 1.0;
    
    _uploaderImageView.layer.cornerRadius = _uploaderImageView.frame.size.width/2;
    _uploaderImageView.layer.masksToBounds = YES;
    
    _uploaderImageView.image = nil;
    [_uploaderImageView sd_setImageWithURL:[NSURL URLWithString:aClip.clip_user.user_avatar.avatar_thumbnail]];
    _uploaderNameLabel.text = aClip.clip_user.user_name;
    
    _videoTitleLabel.text = aClip.clip_content;
    _videoDescLabel.text = aClip.clip_video.video_description;
    
    [_commentButton setTitle:[aClip.clip_stats.clip_stats_comments stringValue] forState:UIControlStateNormal];
    [_likeButton setTitle:[aClip.clip_stats.clip_stats_likes stringValue] forState:UIControlStateNormal];
    [_viewButton setTitle:[aClip.clip_stats.clip_stats_views stringValue] forState:UIControlStateNormal];
    
    NSDateFormatter *df = [TheAppDelegate defaultDateFormatter];

    if([currentClip.clip_liked boolValue]){
        [_likeButton setImage:[UIImage imageNamed:@"btnHeartActive"] forState:UIControlStateNormal];
    }else{
        [_likeButton setImage:[UIImage imageNamed:@"btnHeart"] forState:UIControlStateNormal];
    }
    
    NSString *htmlString = [NSString stringWithFormat:@"PUBLISHED <b>%@</b>", [df stringFromDate:aClip.clip_published_at]];
    
    NSAttributedString *as = [[[DTHTMLAttributedStringBuilder alloc]
                               initWithHTML:[htmlString dataUsingEncoding:NSUnicodeStringEncoding]
                               options:@{
                                         DTDefaultFontSize: @(10),
                                         DTDefaultFontFamily: InterfaceStr(@"default_font_regular"),
                                         DTDefaultTextColor: HEXCOLOR(0x666666FF)
                                         }
                               documentAttributes:NULL] generatedAttributedString];
    
    
    self.videoDateLabel.attributedString = as;
    self.videoDateLabel.numberOfLines = 1;
    
    htmlString = @"<br>SOURCE: <b>Youtube</b>";
    
    as = [[[DTHTMLAttributedStringBuilder alloc]
           initWithHTML:[htmlString dataUsingEncoding:NSUnicodeStringEncoding]
           options:@{
                     DTDefaultFontSize: @(10),
                     DTDefaultFontFamily: InterfaceStr(@"default_font_regular"),
                     DTDefaultTextColor: HEXCOLOR(0x666666FF)
                     }
           documentAttributes:NULL] generatedAttributedString];
    
    self.sourceLabel.attributedString = as;
    self.sourceLabel.numberOfLines = 1;
    
    
    htmlString = [NSString stringWithFormat:@"<b>%@</b> views",aClip.clip_stats.clip_stats_views];
    
    
    as = [[[DTHTMLAttributedStringBuilder alloc]
                               initWithHTML:[htmlString dataUsingEncoding:NSUnicodeStringEncoding]
                               options:@{
                                         DTDefaultFontSize: @(11),
                                         DTDefaultFontFamily: InterfaceStr(@"default_font_regular"),
                                         DTDefaultTextColor: HEXCOLOR(0x666666FF)
                                         }
                               documentAttributes:NULL] generatedAttributedString];
    
    self.videoViewsLabel.attributedString = as;
    self.videoViewsLabel.numberOfLines = 1;
    
    UIColor *buttonColor;
    UIColor *textColor;
    if([aClip.clip_user.user_socialization.socialization_following boolValue]){
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
    
//    NSLog(@"cell content offset: %@",NSStringFromCGPoint(self.contentOffset));
//    NSLog(@"cell content inset: %@", NSStringFromUIEdgeInsets(self.myTableView.contentInset));
}

-(CGFloat)cellHeight{
    CGFloat cellPadding = 150;
    CGFloat labelWidth = CGRectGetWidth(self.videoDescLabel.frame);
    CGSize expandedSize = CGSizeMake(labelWidth, 1000);
    CGSize fitSize = [self.videoDescLabel sizeThatFits:self.videoDescLabel.frame.size];
    CGSize correctLabelSize = self.videoDescLabel.frame.size;
    correctLabelSize.height = fitSize.height;
    expandedSize.height = fitSize.height;
    
    if(correctLabelSize.height > 80){
        correctLabelSize.height = 80;
    }
    
    self.videoDescHeightConstraint.constant = self.isExpanded ? expandedSize.height : 0;
    self.videoDateHeightConstraint.constant = self.isExpanded ? 15.0 : 0;
    self.sourceHeightConstraint.constant = 0;
    if([[self.currentClip.clip_video.video_type lowercaseString] isEqualToString:@"youtube"] && self.isExpanded){
        _sourceHeightConstraint.constant = 15.0;
    }
    
    CGSize titleSize = [self.videoTitleLabel sizeThatFits:self.videoTitleLabel.frame.size];
    self.videoTitleHeightConstraint.constant = titleSize.height;
    
    [_downArrow setImage:[UIImage imageNamed:self.isExpanded?@"upArrow":@"downArrow"]];
    return ceilf(self.videoTitleHeightConstraint.constant + self.videoDateHeightConstraint.constant + self.videoDescHeightConstraint.constant + cellPadding);
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
    if([currentClip.clip_user.user_socialization.socialization_following boolValue]){
        
        [UIAlertView showWithTitle:@"Unfollow" message:[NSString stringWithFormat:@"Stop following %@ ?",currentClip.clip_user.user_name] cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if(buttonIndex != alertView.cancelButtonIndex){
                
                [User unfollowUserWithId:currentClip.clip_user.user_id andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                    self.currentClip.clip_user.user_socialization.socialization_following = @NO;
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
        [User followUserWithId:currentClip.clip_user.user_id andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
            self.currentClip.clip_user.user_socialization.socialization_following = @YES;
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

- (IBAction)likeButtonTapped:(id)sender {
    [delegate likeButtonDidTap];
}

- (IBAction)commentButtonTapped:(id)sender {
    [delegate commentButtonDidTap];
}

- (IBAction)shareTapped:(id)sender {
    [delegate shareButtonDidTap];
}

- (IBAction)userButtonTapped:(id)sender {
    [delegate userButtonDidTap];
}

- (IBAction)playlistTapped:(id)sender {
    [delegate addPlaylistButtonDidTap];
}
@end
