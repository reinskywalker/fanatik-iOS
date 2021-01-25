//
//  Message.h
//  Fanatik
//
//  Created by Erick Martin on 11/19/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sticker.h"
#define MessageTypeText @"text"
#define MessageTypeSticker @"sticker"
#define MessageTypeDisconnected @"disconnected"

@interface Message : NSObject

@property(nonatomic, retain) NSString *messageContent;
@property(nonatomic, retain) NSString *messageEvent;
@property(nonatomic, retain) NSString *messageType;
@property(nonatomic, retain) NSString *messageUserId;
@property(nonatomic, retain) NSString *messageUserName;
@property(nonatomic, retain) NSString *messageUserAvatarURL;
@property(nonatomic, retain) NSString *messageRoom;
@property(nonatomic, retain) NSString *messageContext;
@property(nonatomic, assign) NSInteger messageSentAt;
@property(nonatomic, retain) Sticker *messageSticker;
@property(nonatomic, retain) NSString *dateString;

-(id)initWithJSON:(NSString *)json;
-(NSString *)messageSentDate;
@end
