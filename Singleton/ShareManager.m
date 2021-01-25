//
//  ShareManager.m
//
//  Created by Michael Dihardja
//  Copyright 2009 MD Company. All rights reserved.
//

#import "ShareManager.h"
#import "NSDate-Utilities.h"
#import <AddressBookUI/AddressBookUI.h>
#import "JSON.h"

@implementation ShareManager

SYNTHESIZE_SINGLETON_FOR_CLASS(ShareManager)

-(id)init {
	if (self = [super init]) {
        
	}
	return self;
}


-(void)sendPushNotificationsToUserArray:(NSArray *)pfUserArray withActivity:(ActivityObject *)actObject andMessageString:(NSString *)msg{
    
    
    NSMutableArray *filteredUsersChannels = [NSMutableArray array];
    
    for(PFUser *aUser in pfUserArray){
        if([(NSArray *)aUser[@"channels"] containsObject:@"event_related"] && (actObject.activityType == ActivityTypeEventPlaceChange || actObject.activityType == ActivityTypeEventDateChange || actObject.activityType == ActivityTypeInvite || actObject.activityType == ActivityTypeFriendDecline || actObject.activityType == ActivityTypeEventDeleted || actObject.activityType == ActivityTypeFriendCancelJoin || actObject.activityType == ActivityTypeEventReactivate)){
            
            [filteredUsersChannels addObject:[NSString stringWithFormat:@"user_%@",aUser.objectId]];
            
        }else if([(NSArray *)aUser[@"channels"] containsObject:@"friend_join"] && actObject.activityType == ActivityTypeFriendJoin){
            
            [filteredUsersChannels addObject:[NSString stringWithFormat:@"user_%@",aUser.objectId]];
            
        }else if([(NSArray *)aUser[@"channels"] containsObject:@"chat_message"] && actObject.activityType == ActivityTypeEventChat){
            
            [filteredUsersChannels addObject:[NSString stringWithFormat:@"user_%@",aUser.objectId]];
            
        }else if(actObject.activityType == ActivityTypeFollowingUser){
            [filteredUsersChannels addObject:[NSString stringWithFormat:@"user_%@", aUser.objectId]];
        }
                 
    }
    
    PFPush *push = [[PFPush alloc] init];
    
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
    
    NSLog(@"PFUser current user = %@", [PFUser currentUser]);
    
    if(actObject.activityEventObject){
        infoDict[@"eventId"] = actObject.activityEventObject.objectId;
    }else if(actObject.activityType == ActivityTypeFollowingUser){
        infoDict[@"userId"] = actObject.fromUser.objectId;
    }
    [push setChannels:filteredUsersChannels];
    infoDict[@"badge"] = @"Increment";
    infoDict[@"alert"] = [actObject notificationStringForPush:YES];
    infoDict[@"activityType"] = [NSNumber numberWithInt:actObject.activityType];
    infoDict[@"activityId"] = actObject.objectId;
    [push setData:infoDict];
    [push sendPushInBackground];
}

-(NSString *)sportyLink{
    
    //    NSString *message = [NSString stringWithFormat:@"Hi %@! Let's join me on Sporty Showcase to find out what cool sports we can play around our area.  deeplink.me/sportyapp://", contact.firstName];
    
    return @"www.sportyapp.com/appstore";
}

-(NSString *)facebookShareString{
    PFUser *currentUser = [PFUser currentUser];
    NSString *genderPrefix = @"him/her";
    if(currentUser[@"gender"] && [currentUser[@"gender"] isEqualToString:@"male"]){
        genderPrefix = @"him";
    }else if(currentUser[@"gender"] && [currentUser[@"gender"] isEqualToString:@"female"]){
        genderPrefix = @"her";
    }
    
    return [NSString stringWithFormat:@"%@ has gone Sporty! Sporty lets you play sports activities with people nearby! To become as Sporty as %@, join %@ on %@", currentUser.firstName,genderPrefix,genderPrefix,[self sportyLink]];
}

-(NSString *)smsSharePersonalString:(NSString *)toName{
    PFUser *currentUser = [PFUser currentUser];
    return [NSString stringWithFormat:
            @"Hi %@! %@ has invited you to Sporty! Sporty lets you play sports activities with people nearby! Check it out: %@", toName, currentUser?currentUser.firstName:@"Your friend",[self sportyLink]];
}

-(NSString *)smsShareMultipleString{
    PFUser *currentUser = [PFUser currentUser];
    return [NSString stringWithFormat:
            @"%@ has invited you to Sporty! Sporty lets you play sports activities with people nearby! Check it out: %@", currentUser?currentUser.firstName:@"Your friend",[self sportyLink]];
}

-(NSString *)twitterShareString{
    return [NSString stringWithFormat:
            @"Check out Sporty... it lets you play sports activities with people nearby! %@ @TheSportyApp", [self sportyLink]];
}

@end
