//
//  AppDelegate.h
//  Urband Sport Finder
//
//  Created by Teguh Hidayatullah on 10/4/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseManager.h"

#import "ECSlidingViewController.h"
#import "CustomNavigationController.h"
#import "UserWrapper.h"
#import "REFrostedViewController.h"
#import "CustomREFrostedViewController.h"
#import "ApplicationInfoModel.h"

@class ParentViewController;

#define TheAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

static const NSString *kFacebookLoginNotification = @"kFacebookLoginNotification";
extern NSString *const kProfileUpdatedNotification;
static const int kRequestLimit = 3;
extern NSString *const kLogoutCompletedNotification;
extern NSString *const kLoginCompletedNotification;
extern NSString *const kPaymentCompleted;
extern NSString *const kPaymentFailed;
extern NSString *const kRefreshProfilePage;
extern NSString *const kThreadDeleted;
extern NSString *const kThreadCreated;
extern NSString *const kThreadUpdated;
extern NSString *const kGetPushNotification;
extern NSString *const kChangeCenterController;
extern NSString *const kShowFailedNotification;
extern NSString *const kRequestSideMenuNotification;
extern NSString *const kOpenLoginPageNotification;
extern NSString *const kGetInAppPushNotification;
extern NSString *const kBackgroudSessionUploadIdentifier;
extern NSString *const kUploadVideoMetaFinished;

extern const int kCommentCacheAmount;
extern const float kCommentCacheTime;


@interface AppDelegate : UIResponder <UIApplicationDelegate, REFrostedViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (nonatomic, strong) CustomREFrostedViewController *slidingViewController;
@property (nonatomic, retain) CustomNavigationController *navController;
@property (nonatomic, retain) ApplicationInfoModel *currentAppInfo;


@property (copy) void (^backgroundDownloadSessionCompletionHandler)();
@property (copy) void (^backgroundUploadSessionCompletionHandler)();


-(void)showRightMenu;
-(void)showLeftMenu;
-(void)changeCenterController:(ParentViewController *)aController;


- (NSURL *)applicationDocumentsDirectory;
- (NSString *)pathCentralData;
- (void)createCentralDataIfDoesntExist;

-(void)openActiveSessionWithPermissions:(NSArray *)permissions allowLoginUI:(BOOL)allowLoginUI;
-(void)loginSuccessAndShouldDismiss:(BOOL)shouldDismiss;
-(void)logoutSuccess;
-(void)goToLogin;
- (void)removeLocalData;
-(NSDateFormatter *)defaultTimeFormatter;
-(NSDateFormatter *)defaultDateFormatter;
-(NSDateFormatter *)defaultDateTimeFormatter;

#define WRITE_LOG(txt)([TheAppDelegate writeLog:txt])
-(void)writeLog:(id)log;


-(UIButton *)createButtonWithTitle:(NSString *)title imageName:(NSString *)img highlightedImageName:(NSString *)img2 forLeftButton:(BOOL)isLeft;

-(NSMutableDictionary *)stripURL:(NSString *)urlString;
-(ParentViewController *)getViewControllerById:(NSString *)pageName withParamId:(NSNumber *)pageParam;

-(NSInteger)bundleVersion;
-(CGFloat)deviceWidth;
-(CGFloat)deviceHeight;
@end

