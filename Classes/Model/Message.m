//
//  Message.m
//  Fanatik
//
//  Created by Erick Martin on 11/19/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "Message.h"

@implementation Message

@synthesize messageContent, messageType, messageUserId, messageUserName, messageUserAvatarURL, messageRoom;
@synthesize messageContext, messageSentAt;

-(id)initWithJSON:(NSDictionary *)json{
    if(self = [super init]){
        self.messageType = json[@"message"][@"messageType"];
        if([self.messageType isEqualToString:MessageTypeSticker]){
            self.messageSticker = [[Sticker alloc] initWithDictionary:json[@"message"][@"data"][@"message"]];
        }else{
            self.messageContent = json[@"message"][@"data"][@"message"];
        }
        self.messageEvent = json[@"message"][@"event"];
        self.messageUserId = json[@"message"][@"data"][@"from"][@"id"];
        self.messageUserName = json[@"message"][@"data"][@"from"][@"username"];
        self.messageUserAvatarURL = json[@"message"][@"data"][@"from"][@"avatar"];
        self.messageRoom = json[@"room"];
        self.messageContext = json[@"context"];
        self.messageSentAt = [json[@"sentAt"] integerValue];
        
    }
    return self;
}

-(NSString *)messageSentDate{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"HH:mm";
    return [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:(self.messageSentAt / 1000.0)]];
}
@end
