//
//  SplashScreenModel.h
//  Fanatik
//
//  Created by Erick Martin on 6/4/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit.h>
#import "ApplicationInfoModel.h"

@interface SplashScreenModel : BaseModel <NSCoding>

@property (nonatomic, retain) NSNumber * splash_screen_id;
@property (nonatomic, retain) NSNumber * splash_screen_time;
@property (nonatomic, copy) NSString * ss_image_original;
@property (nonatomic, copy) NSString * ss_image_640;
@property (nonatomic, copy) NSString * ss_image_480;
@property (nonatomic, copy) NSString * ss_image_320;
@property (nonatomic, copy) NSString * ss_image_240;

-(id)initWithDictionary:(NSDictionary *)jsonDict;

+(void)getApplicationInfoWithAccessToken:(void(^) (ApplicationInfoModel *appInfoMod))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
