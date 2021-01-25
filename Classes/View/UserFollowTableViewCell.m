//
//  UserFollowTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/2/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "UserFollowTableViewCell.h"

@implementation UserFollowTableViewCell

@synthesize delegate;

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    self.userImageView.layer.cornerRadius = CGRectGetHeight(self.userImageView.frame)/2;
    self.userImageView.layer.masksToBounds = YES;
    
}

-(void)fillCellWithUser:(User *)obj{
    self.currentUser = obj;
    self.userImageView.image = nil;
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:obj.user_avatar.avatar_thumbnail]];
    self.userNameLabel.text = obj.user_name;
    
    if([obj.user_id isEqualToString:CURRENT_USER_ID()] || !_canFollow){
        self.followButton.hidden = YES;
    }else if(_canFollow){
        self.followButton.hidden = NO;
    }
    
    UIColor *buttonColor;
    UIColor *textColor;
    if([obj.user_socialization.socialization_following boolValue]){

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
    self.followButton.layer.cornerRadius = 2.0;
    self.followButton.layer.masksToBounds = YES;
    self.followButton.layer.borderColor = [buttonColor CGColor];
    self.followButton.layer.borderWidth = 1.0;
    
    [self.followButton setTitleColor:textColor forState:UIControlStateNormal];
  
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

- (IBAction)followButtonTapped:(id)sender {
    self.followButton.userInteractionEnabled = NO;
    
        if([self.currentUser.user_socialization.socialization_following boolValue]){
            [UIAlertView showWithTitle:@"Unfollow" message:[NSString stringWithFormat:@"Stop following %@ ?",self.currentUser.user_name] cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if(buttonIndex != alertView.cancelButtonIndex){
        
                    [User unfollowUserWithId:self.currentUser.user_id andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                        self.currentUser.user_socialization.socialization_following = @(0);
                        self.followButton.userInteractionEnabled = YES;
                        [[NSNotificationCenter defaultCenter] postNotificationName:kProfileUpdatedNotification object:operation];
                    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                        self.followButton.userInteractionEnabled = YES;
                        
                        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
                        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                            
                            NSData *responseData = operation.HTTPRequestOperation.responseData;
                            NSDictionary* json = [NSJSONSerialization
                                                  JSONObjectWithData:responseData //1
                                                  options:NSJSONReadingMutableLeaves
                                                  error:nil];
                            NSString *message = json[@"error"][@"messages"][0];
                            [delegate failedToFollowOrUnfollowWithErrorString:message];
                        }
                        [self updateFollowButton];
                    }];
                    [self updateFollowButton];
                }
            }];
        
    }else{
        [User followUserWithId:self.currentUser.user_id andAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
            self.currentUser.user_socialization.socialization_following = @(1);
            self.followButton.userInteractionEnabled = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:kProfileUpdatedNotification object:nil];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            self.followButton.userInteractionEnabled = YES;
            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                
                NSData *responseData = operation.HTTPRequestOperation.responseData;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:responseData //1
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
                NSString *message = json[@"error"][@"messages"][0];
                [delegate failedToFollowOrUnfollowWithErrorString:message];
            }
            [self updateFollowButton];
        }];
        [self updateFollowButton];
    }
    
    if([delegate respondsToSelector:@selector(successToFollowOrUnfollowWithUser:)]){
        [delegate successToFollowOrUnfollowWithUser:self.currentUser];
    }
}
@end
