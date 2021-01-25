//
//  UserWrapper.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "BaseModel.h"

@interface UserWrapper : BaseModel

@property (nonatomic, retain) NSString * userFullName;
@property (nonatomic, retain) NSString * userEmail;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * userPassword;
@property (nonatomic, retain) NSString * userProvider;
@property (nonatomic, retain) NSString * userUID;
@property (nonatomic, retain) NSString * userToken;

@end
