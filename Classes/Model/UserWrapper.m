//
//  UserWrapper.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "UserWrapper.h"

typedef enum {
    LoginProviderFacebook = 0,
    LoginProviderGPlus = 1
}LoginProvider;

@implementation UserWrapper

-(id)initWithDictionary:(NSDictionary *)jsonDict{
    if(self = [super init]){
        self.userFullName = jsonDict[@"full_name"];
        self.userPassword = jsonDict[@"password"];
        self.userName = jsonDict[@"user_name"];
        self.userEmail = jsonDict[@"email"];
        self.userToken = jsonDict[@"token"];
        self.userProvider = jsonDict[@"provider"];
        self.userUID = jsonDict[@"uid"];
    }
    return self;
}

@end
