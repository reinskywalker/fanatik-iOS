//
//  NotificationTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/19/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "NotificationTableViewCell.h"
#import "Like.h"
#import "Mention.h"
#import "Event.h"

@implementation NotificationTableViewCell
@synthesize delegate;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)fillCellWithNotif:(Notification *)aNotif{
    self.currentNotif = aNotif;
    _userImageView.layer.cornerRadius = _userImageView.frame.size.width/2;
    _userImageView.layer.masksToBounds = YES;
    
    _userImageView.image = nil;
    NSString *urlUserImage = nil;
    NSString *urlNotifImage = nil;
    
    if(aNotif.notifType == NotifTypeLikeClip){
        urlUserImage = aNotif.notification_like.like_user.user_avatar.avatar_thumbnail;
        urlNotifImage = aNotif.notification_like.like_clip.clip_video.video_thumbnail.thumbnail_320;
    }else if(aNotif.notifType == NotifTypeNewClipUploaded){
        urlUserImage = aNotif.notification_clip.clip_user.user_avatar.avatar_thumbnail;
        urlNotifImage = aNotif.notification_clip.clip_video.video_thumbnail.thumbnail_320;
    }else if(aNotif.notifType == NotifTypeFollowUser){
        urlUserImage = aNotif.notification_user.user_avatar.avatar_thumbnail;
        urlNotifImage = @"";
    }else if(aNotif.notifType == NotifTypeCommentClip){
        urlUserImage = aNotif.notification_comment.comment_user.user_avatar.avatar_thumbnail;
        urlNotifImage = aNotif.notification_comment.comment_clip.clip_video.video_thumbnail.thumbnail_320;
    }else if(aNotif.notifType == NotifTypeCommentEvent){
        urlUserImage = aNotif.notification_comment.comment_user.user_avatar.avatar_thumbnail;
        urlNotifImage = aNotif.notification_comment.comment_event.event_poster_thumbnail.thumbnail_320;
    }else if(aNotif.notifType == NotifTypeMentionClip){
        urlUserImage = aNotif.notification_mention.mention_comment.comment_user.user_avatar.avatar_thumbnail;
        urlNotifImage = aNotif.notification_mention.mention_comment.comment_clip.clip_video.video_thumbnail.thumbnail_320;
    }else if(aNotif.notifType == NotifTypeMentionTVChannel){
        urlUserImage = aNotif.notification_mention.mention_comment.comment_user.user_avatar.avatar_thumbnail;
        urlNotifImage = aNotif.notification_mention.mention_comment.comment_live.live_thumbnail.thumbnail_320;
    }
    
    _notifFollowButton.hidden = ![urlNotifImage isEqualToString:@""];
    _notifFollowButton.selected = [self.currentNotif.notification_user.user_socialization.socialization_following boolValue];
    
    _frameView.layer.borderColor = [UIColor grayColor].CGColor;
    _frameView.layer.borderWidth = 0.5;
    _frameView.hidden = urlNotifImage==nil;
    
    [_userImageView sd_setImageWithURL:[NSURL URLWithString:urlUserImage]];
    [_notifImageView sd_setImageWithURL:[NSURL URLWithString:urlNotifImage]];
    
    NSAttributedString *as = [[[DTHTMLAttributedStringBuilder alloc]
                               initWithHTML:[aNotif.notification_message dataUsingEncoding:NSUnicodeStringEncoding]
                               options:@{
                                         DTDefaultFontSize: @(12),
                                         DTDefaultFontFamily: InterfaceStr(@"default_font_regular"),
                                         DTDefaultTextColor: [UIColor blackColor]
                                         }
                               documentAttributes:NULL] generatedAttributedString];
    
    
    self.notifLabel.attributedString = as;
    self.notifLabel.numberOfLines = 0;
    self.notifLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.notifLabel sizeToFit];
    self.notifDateLabel.text = aNotif.dateString;
}

-(CGFloat)cellHeight{
    CGFloat cellPadding = 25;
    CGSize correctLabelSize = [self.currentNotif.notification_message sizeOfTextWithfont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:12] frame:CGRectMake(42, 10, TheAppDelegate.deviceWidth - 88.0, 40)];
    self.notifLabelHeightConstraint.constant = correctLabelSize.height;
//    NSLog(@"origin y : %f, label height : %f", self.notifLabel.frame.origin.y, self.notifLabelHeightConstraint.constant);
    return self.notifLabel.frame.origin.y + self.notifLabelHeightConstraint.constant + cellPadding;
}

- (IBAction)followButtonTapped:(id)sender {
    [self.notifFollowButton setUserInteractionEnabled:NO];
    
    if([_currentNotif.notification_user.user_socialization.socialization_following boolValue]){
        
        [UIAlertView showWithTitle:@"Unfollow" message:[NSString stringWithFormat:@"Stop following %@ ?",_currentNotif.notification_user.user_name] cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if(buttonIndex != alertView.cancelButtonIndex){
                
                [User unfollowUserWithId:_currentNotif.notification_user.user_id andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                    
                    
                    self.currentNotif.notification_user.user_socialization.socialization_following = @NO;
                    [self.notifFollowButton setUserInteractionEnabled:YES];
                    
                    
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    [self.notifFollowButton setUserInteractionEnabled:YES];
                    
                    NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                    if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                        
                        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                        
                        [delegate showingErrorFromServer:jsonDict[@"error"][@"messages"][0]];
                    }
                    
                    self.notifFollowButton.selected = YES;
                }];
                
                self.notifFollowButton.selected = NO;
                
            }
        }];
    }else{
        
        [User followUserWithId:_currentNotif.notification_user.user_id andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
            
            self.currentNotif.notification_user.user_socialization.socialization_following = @YES;
            [self.notifFollowButton setUserInteractionEnabled:YES];
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self.notifFollowButton setUserInteractionEnabled:YES];
            
            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                
                [delegate showingErrorFromServer:jsonDict[@"error"][@"messages"][0]];
            }
            
            self.notifFollowButton.selected = NO;
        }];
        
        self.notifFollowButton.selected = YES;
    }
}

- (void)layoutSubviews{
    [self cellHeight];
    [super layoutSubviews];
    [self.contentView layoutIfNeeded];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
@end
