//
//  ShareManager.h
//
//  Created by Michael Dihardja on 8/17/09.
//  Copyright 2009 MD Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "ParentViewController.h"
#import "UIImageView+WebCache.h"

#define TheShareManager ([ShareManager sharedInstance])

@interface ShareManager : NSObject {
    NSMutableArray *parseUsers;
}

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(ShareManager)

-(void)sendPushNotificationsToUserArray:(NSArray *)pfUserArray withActivity:(ActivityObject *)actObject andMessageString:(NSString *)msg;

-(NSString *)facebookShareString;
-(NSString *)smsSharePersonalString:(NSString *)toName;
-(NSString *)smsShareMultipleString;
-(NSString *)twitterShareString;
-(NSString *)sportyLink;

@end
