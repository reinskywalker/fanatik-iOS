//
//  SettingsManager.m
//  Guestbook
//
//  Created by Teguh Hidayatullah on 12/17/2014.
//  Copyright 2014 Domikado. All rights reserved.
//

#import "SettingsManager.h"

@implementation SettingsManager

NSString *const kAccessToken = @"kAccessToken";
NSString *const kSessionToken = @"kSessionToken";
NSString *const kCurrentUserId = @"kCurrentUserId";
NSString *const kSelectedMenuIndex = @"kSelectedMenuIndex";
NSString *const kSideMenuArray = @"kSideMenuArray";
NSString *const kIsNotificationActive = @"kIsNotificationActive";
NSString *const kIsActivityHidden = @"kIsActivityHidden";
NSString *const kDayForToday = @"kDayForToday";
NSString *const kIsLoadSplashScreen = @"kIsLoadSplashScreen";
NSString *const kSplashScreen = @"kSplashScreen";
NSString *const kUserUploadModelId = @"kUserUploadModelId";
NSString *const kApplicationInfo = @"kApplicationInfo";
NSString *const kApplicationSettings = @"kApplicationSettings";
NSString *const kDeviceToken = @"kDeviceToken";

@synthesize defaults, accessToken,lastMenuPurchasing;
SYNTHESIZE_SINGLETON_FOR_CLASS(SettingsManager)


-(id)init {
	if (self = [super init]) {
		self.defaults = [NSUserDefaults standardUserDefaults];
 
        if([defaults objectForKey:kAccessToken]){
            self.accessToken = [defaults objectForKey:kAccessToken];
        }else{
            self.accessToken = @"";
        }
        
        if([defaults objectForKey:kSessionToken]){
            self.sessionToken = [defaults objectForKey:kSessionToken];
        }else{
            self.sessionToken = @"";
        }
        
        if([defaults objectForKey:kCurrentUserId]){
            self.currentUserId = [defaults objectForKey:kCurrentUserId];
        }else{
            self.currentUserId = nil;
        }
        
        if(![self.selectedMenu isEqualToString:@""]){
            self.selectedMenu = MenuPageHome;
        }
        
        if([defaults objectForKey:kSideMenuArray]){
            self.sideMenuArray = [defaults objectForKey:kSideMenuArray];
        }else{
            self.sideMenuArray = nil;
        }
        
        self.isNotificationActive = YES;
        if([defaults valueForKey:kIsNotificationActive]!=nil){
            self.isNotificationActive = [defaults boolForKey:kIsNotificationActive];
        }
        
        self.isActivityHidden = NO;
        if([defaults valueForKey:kIsActivityHidden] != nil){
            self.isActivityHidden = [defaults boolForKey:kIsActivityHidden];
        }
        
        if([defaults valueForKey:kDayForToday] != nil){
            self.dayForToday = [defaults integerForKey:kDayForToday];
        }
    
        self.isLoadSplashScreen = NO;

        if([defaults objectForKey:@"kDebugServerURL"]){
            self.debugServerURL = [defaults objectForKey:@"kDebugServerURL"];
        }else{
            self.debugServerURL = @"";
        }
        
        if([defaults objectForKey:@"kDebugOSVersion"]){
            self.debugOSVersion = [defaults objectForKey:@"kDebugOSVersion"];
        }else{
            self.debugOSVersion = @"";
        }
        
        if([defaults objectForKey:@"kDebugAppVersion"]){
            self.debugAppVersion = [defaults objectForKey:@"kDebugAppVersion"];
        }else{
            self.debugAppVersion = @"";
        }
        
        if([defaults objectForKey:kDeviceToken]){
            self.deviceToken = [defaults objectForKey:kDeviceToken];
        }else{
            self.deviceToken = @"";
        }
        
        if([defaults objectForKey:kUserUploadModelId] != nil){
            self.userUploadModelId = [defaults objectForKey:kUserUploadModelId];
        }
    }
	return self;
}

-(BOOL)registDeviceTokenOnceADay{
    
    if(!self.dayForToday){
        self.dayForToday = [NSDate date].day;
        return YES;
    }
    
    if(self.dayForToday == [NSDate date].day){
        return NO;
    }
    
    return YES;
}

-(void)saveDeviceToken:(NSString *)devTok{
    self.deviceToken = devTok;
    [defaults setObject:self.deviceToken forKey:kDeviceToken];
    [defaults synchronize];
}

-(void)saveDayForToday{
    self.dayForToday = [NSDate date].day;
    [defaults setObject:@(self.dayForToday) forKey:kDayForToday];
    [defaults synchronize];
}

-(void)saveAccessToken:(NSString *)token{
    self.accessToken = token;
    [defaults setObject:token forKey:kAccessToken];
    [defaults synchronize];
}

-(void)removeAccessToken{
    self.accessToken = nil;
    [defaults removeObjectForKey:kAccessToken];
    [defaults synchronize];
}

-(void)saveSessionToken:(NSString *)token{
    self.sessionToken = token;
    [defaults setObject:token forKey:kSessionToken];
    [defaults synchronize];
}

-(void)saveUserUploadModelId:(NSString *)uumId{
    self.userUploadModelId = uumId;
    [defaults setObject:self.userUploadModelId forKey:kUserUploadModelId];
    [defaults synchronize];
}

-(void)removeSessionToken{
    self.sessionToken = nil;
    [defaults removeObjectForKey:kSessionToken];
    [defaults synchronize];
}

-(void)saveCurrentUserId:(NSString *)userId{
    self.currentUserId = userId;
    [defaults setObject:userId forKey:kCurrentUserId];
    [defaults synchronize];
}

-(void)removeCurrentUserId{
    self.currentUserId = nil;
    [defaults removeObjectForKey:kCurrentUserId];
    [defaults synchronize];
}

-(void)saveSelectedMenu:(NSString *)str{
    self.selectedMenu = str;
}

-(void)removeSelectedMenu{
    self.selectedMenu = nil;
}

-(void)saveSideMenuArray:(NSArray *)menuArray{
    self.sideMenuArray = [NSArray arrayWithArray:menuArray];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:menuArray] forKey:kSideMenuArray];
}

-(void)resetSideMenuArray{
    self.sideMenuArray = nil;
    [defaults removeObjectForKey:kSideMenuArray];
    [defaults synchronize];
}

-(NSArray *)loadSideMenuArray{
    NSData *dataRepresentingSavedArray = [defaults objectForKey:kSideMenuArray];
    if (dataRepresentingSavedArray != nil)
    {
        NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
        if (oldSavedArray != nil)
            self.sideMenuArray = [[NSMutableArray alloc] initWithArray:oldSavedArray];
        else
            self.sideMenuArray = [[NSMutableArray alloc] init];
    }
    return self.sideMenuArray;
}

//TODO : change access and session token storage to ObjectStore

-(void)changeNotificationActive:(BOOL)active{
    self.isNotificationActive = active;
    [defaults setBool:active forKey:kIsNotificationActive];
    [defaults synchronize];
}

-(void)changeActivityHidden:(BOOL)hidden{
    self.isActivityHidden = hidden;
    [defaults setBool:hidden forKey:kIsActivityHidden];
    [defaults synchronize];
}

-(void)loadedSplashScreen:(BOOL)bol{
    self.isLoadSplashScreen = bol;
}

-(void)saveDebugServerURL:(NSString *)serverURL{
    self.debugServerURL = serverURL;
    [defaults setObject:serverURL forKey:@"kDebugServerURL"];
    [defaults synchronize];
}

-(void)saveDebugOSVersion:(NSString *)osVer{
    self.debugOSVersion = osVer;
    [defaults setObject:osVer forKey:@"kDebugOSVersion"];
    [defaults synchronize];
}

-(void)saveDebugAppVersion:(NSString *)appVer{
    self.debugAppVersion = appVer;
    [defaults setObject:appVer forKey:@"kDebugAppVersion"];
    [defaults synchronize];
}

-(void)saveSplashScreen:(SplashScreenModel *)ssMod{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:ssMod];
    [defaults setObject:encodedObject forKey:kSplashScreen];
    [defaults synchronize];
}

- (SplashScreenModel *)currentSplashScreen{
    NSData *encodedObject = [defaults objectForKey:kSplashScreen];
    SplashScreenModel *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}

-(void)saveApplicationInfo:(ApplicationInfoModel *)aaInfo{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:aaInfo];
    [defaults setObject:encodedObject forKey:kApplicationInfo];
    [defaults synchronize];
}

- (ApplicationInfoModel *)currentApplicationInfo{
    NSData *encodedObject = [defaults objectForKey:kApplicationInfo];
    ApplicationInfoModel *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}

-(void)saveApplicationSettings:(ApplicationSettingModel *)ssMod{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:ssMod];
    [defaults setObject:encodedObject forKey:kApplicationSettings];
    [defaults synchronize];
}

- (ApplicationSettingModel *)currentApplicationSetting{
    NSData *encodedObject = [defaults objectForKey:kApplicationSettings];
    ApplicationSettingModel *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}

@end
