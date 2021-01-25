//
//  SettingsManager.h
//  Guestbook
//
//  Created by Teguh Hidayatullah on 12/17/2014.
//  Copyright 2014 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "AppDelegate.h"
#import "SplashScreenModel.h"
#import "ApplicationInfoModel.h"
#import "ApplicationSettingModel.h"

#define TheSettingsManager ([SettingsManager sharedInstance])

@interface SettingsManager : NSObject {
    NSUserDefaults *defaults;
}

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(SettingsManager)

@property (nonatomic, retain) NSUserDefaults *defaults;


#define ACCESS_TOKEN() ([TheSettingsManager accessToken])
@property (nonatomic, copy) NSString *accessToken;

#define SESSION_TOKEN() ([TheSettingsManager sessionToken])
@property (nonatomic, copy) NSString *sessionToken;

#define CURRENT_USER_ID() ([TheSettingsManager currentUserId])
@property (nonatomic, copy) NSString *currentUserId;

#define SELECTED_MENU() ([TheSettingsManager selectedMenu])
@property(nonatomic, copy) NSString *selectedMenu;

#define SIDE_MENU_ARRAY() ([TheSettingsManager loadSideMenuArray])
@property(nonatomic, retain) NSArray *sideMenuArray;

@property(nonatomic, copy) NSString *lastMenuPurchasing;

#pragma mark - SETTINGS PAGE
@property(nonatomic, assign) BOOL isNotificationActive;
@property(nonatomic, assign) BOOL isActivityHidden;

@property(nonatomic, assign) BOOL isLoadSplashScreen;
@property(nonatomic, assign) NSInteger dayForToday;

@property(nonatomic, copy) NSString *userUploadModelId;
@property (nonatomic, copy) NSString *deviceToken;

#pragma mark - DEBUG
@property(nonatomic, copy) NSString *debugServerURL;
@property(nonatomic, copy) NSString *debugAppVersion;
@property(nonatomic, copy) NSString *debugOSVersion;
@property (nonatomic, assign) NSUInteger uploadTaskIdentifier;

//-(int)lastDatabaseVersion;
//-(void)setLastDatabaseVersion:(int)lastVersion;

-(BOOL)registDeviceTokenOnceADay;
-(void)saveAccessToken:(NSString *)token;
-(void)removeAccessToken;
-(void)saveSessionToken:(NSString *)token;
-(void)removeSessionToken;
-(void)saveCurrentUserId:(NSString *)userId;
-(void)removeCurrentUserId;
-(void)saveSelectedMenu:(NSString *)str;
-(void)removeSelectedMenu;
-(void)saveSideMenuArray:(NSArray *)menuArray;
-(void)resetSideMenuArray;
-(void)changeNotificationActive:(BOOL)active;
-(void)changeActivityHidden:(BOOL)hidden;
-(void)loadedSplashScreen:(BOOL)bol;
-(void)saveDebugServerURL:(NSString *)serverURL;
-(void)saveDebugOSVersion:(NSString *)osVer;
-(void)saveDebugAppVersion:(NSString *)appVer;
-(void)saveDayForToday;
-(NSArray *)loadSideMenuArray;

-(void)saveUserUploadModelId:(NSString *)uumId;
-(void)saveSplashScreen:(SplashScreenModel *)ssMod;
- (SplashScreenModel *)currentSplashScreen;
-(void)saveApplicationInfo:(ApplicationInfoModel *)aaInfo;
- (ApplicationInfoModel *)currentApplicationInfo;
-(void)saveApplicationSettings:(ApplicationSettingModel *)ssMod;
- (ApplicationSettingModel *)currentApplicationSetting;
-(void)saveDeviceToken:(NSString *)devTok;
@end
