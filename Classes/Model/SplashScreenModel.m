//
//  SplashScreenModel.m
//  Fanatik
//
//  Created by Erick Martin on 6/4/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "SplashScreenModel.h"

@implementation SplashScreenModel
@synthesize splash_screen_id, splash_screen_time, ss_image_original, ss_image_640, ss_image_480, ss_image_320, ss_image_240;

-(id)initWithDictionary:(NSDictionary *)jsonDict{
    if(self=[super init]){
        
        self.splash_screen_id = jsonDict[@"id"];
        self.splash_screen_time = jsonDict[@"time"];
        
        if(jsonDict[@"image"] && ![jsonDict[@"image"] isKindOfClass:[NSNull class]]){
            self.ss_image_240 = jsonDict[@"image"][@"_240"];
            self.ss_image_320 = jsonDict[@"image"][@"_320"];
            self.ss_image_480 = jsonDict[@"image"][@"_480"];
            self.ss_image_640 = jsonDict[@"image"][@"_640"];
            self.ss_image_original = jsonDict[@"image"][@"original"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.splash_screen_id forKey:@"splash_screen_id"];
    [encoder encodeObject:self.splash_screen_time forKey:@"splash_screen_time"];
    [encoder encodeObject:self.ss_image_240 forKey:@"ss_image_240"];
    [encoder encodeObject:self.ss_image_320 forKey:@"ss_image_320"];
    [encoder encodeObject:self.ss_image_480 forKey:@"ss_image_480"];
    [encoder encodeObject:self.ss_image_640 forKey:@"ss_image_640"];
    [encoder encodeObject:self.ss_image_original forKey:@"ss_image_original"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.splash_screen_id = [decoder decodeObjectForKey:@"splash_screen_id"];
        self.splash_screen_time = [decoder decodeObjectForKey:@"splash_screen_time"];
        self.ss_image_240 = [decoder decodeObjectForKey:@"ss_image_240"];
        self.ss_image_320 = [decoder decodeObjectForKey:@"ss_image_320"];
        self.ss_image_480 = [decoder decodeObjectForKey:@"ss_image_480"];
        self.ss_image_640 = [decoder decodeObjectForKey:@"ss_image_640"];
        self.ss_image_original = [decoder decodeObjectForKey:@"ss_image_original"];
    }
    return self;
}

+(void)getApplicationInfoWithAccessToken:(void(^) (ApplicationInfoModel *appInfoMod))complete andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:TheConstantsManager.serverURL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   ACCESS_TOKEN(), @"access_token",
                                   nil];
    
    NSMutableURLRequest *req =  [manager requestWithObject:self method:RKRequestMethodGET path:@"applications/info" parameters:params];
    [TheServerManager setGlobalHeaderForRequest:req];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:req];
    [operation start];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [TheAppDelegate writeLog:[operation responseString]];

        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        
        SplashScreenModel *ssModel = [[SplashScreenModel alloc]initWithDictionary:jsonDict[@"splash_screen"]];
        [TheSettingsManager saveSplashScreen:ssModel];
        
        ApplicationInfoModel *appInfoMod = [[ApplicationInfoModel alloc]initWithDictionary:jsonDict[@"application_version"]];
        [TheSettingsManager saveApplicationInfo:appInfoMod];
        
        ApplicationSettingModel *appSettMod = [[ApplicationSettingModel alloc] initWithDictionary:jsonDict[@"application_setting"]];
        [TheSettingsManager saveApplicationSettings:appSettMod];
        
        if(complete){
            complete(appInfoMod);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [TheAppDelegate writeLog:[operation responseString]];
            NSUInteger statusCode = operation.response.statusCode;
            if(statusCode == StatusCodeExpired || statusCode == StatusCodeForbidden){
                [TheServerManager requestAccessTokenWithCompletion:^(NSString *accessToken) {
                    [self getApplicationInfoWithAccessToken:^(ApplicationInfoModel *appInfoMod) {
                        if(complete){
                            complete(appInfoMod);
                        }
                    } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        if(failure){
                            failure(operation, error);
                        }
                    }];
                } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [TheAppDelegate writeLog:error.description];
                    
                }];
            }
            
            if(failure){
                failure(operation, error);
            }
    }];
}
@end
