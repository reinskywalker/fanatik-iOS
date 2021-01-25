//
//  AppDelegate.m
//  Urband Sport Finder
//
//  Created by Teguh Hidayatullah on 10/4/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuViewController.h"
#import "RightMenuViewController.h"
#import "DashboardViewController.h"
#import "HomeViewController.h"
#import <DTCoreText/DTCoreText.h>
#import "SearchViewController.h"
#import "ProfileViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "GAI.h"
#import "TVChannelViewController.h"
#import "ClubViewController.h"
#import "TimeLineViewController.h"
#import "ProfileFollowerViewController.h"
#import "SubscriptionViewController.h"
#import "PlaylistViewController.h"
#import "VideoCategoryDashboardViewController.h"
#import "VideoDetailViewController.h"
#import "TVChannelDetailViewController.h"
#import "ProfileViewController.h"
#import "Live.h"
#import "ThreadDetailsViewController.h"
#import "VideoCategoryViewController.h"
#import "PlaylistDetailsViewController.h"
#import "ContestViewController.h"
#import "ContestDetailViewController.h"
#import "UploadVideoViewController.h"
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "LiveChatViewController.h"
#import "LiveChatDetailViewController.h"
#import "EventViewController.h"
#import "EventDetailViewController.h"
#import "Reachability.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAIEcommerceFields.h"
#import <iAd/iAd.h>
#import "NSMutableDictionary+Encoding.h"
#import "NotificationViewController.h"

#define GPLUS_SCHEME @"domikado.Domikado"
#define FACEBOOK_SCHEME  @"fb1408611126061089"
#define DEEPLINK_SCHEME  @"fanatik.id"

static NSString *dirCentralData = @"MainData";
static NSString *dirOldCentralData = @"CentralData";

const int kCommentCacheAmount = 4;
const float kCommentCacheTime = 1.0;

@interface AppDelegate ()

@property (nonatomic, retain) ParentViewController *mainViewController;
@property (nonatomic, retain) ParentViewController *leftViewController;
@property (nonatomic, retain) ParentViewController *rightViewController;
@property (nonatomic, assign) BOOL isShowingMenu;
@property (nonatomic, assign) BOOL isAnimatingMenu;

@end

@implementation AppDelegate

@synthesize mainViewController, isShowingMenu, navController, leftViewController, rightViewController, isAnimatingMenu, currentAppInfo;
NSString *const kLogoutCompletedNotification = @"kLogoutCompletedNotification";
NSString *const kLoginCompletedNotification = @"kLoginCompletedNotification";
NSString *const kRequestSideMenuNotification = @"kRequestSideMenuNotification";
NSString *const kProfileUpdatedNotification = @"kProfileUpdatedNotification";
NSString *const kPaymentFailed = @"kPaymentFailed";
NSString *const kPaymentCompleted = @"kPaymentCompleted";
NSString *const kThreadDeleted = @"kThreadDeleted";
NSString *const kThreadUpdated = @"kThreadUpdated";
NSString *const kThreadCreated = @"kThreadCreated";
NSString *const kRefreshProfilePage = @"kRefreshProfilePage";
NSString *const kGetPushNotification = @"kGetPushNotification";
NSString *const kGetInAppPushNotification = @"kGetInAppPushNotification";
NSString *const kChangeCenterController = @"kChangeCenterController";
NSString *const kShowFailedNotification = @"kShowFailedNotification";
NSString *const kOpenLoginPageNotification = @"kOpenLoginPageNotification";
NSString *const kBackgroudSessionUploadIdentifier = @"kBackgroudSessionUploadIdentifier";
NSString *const kUploadVideoMetaFinished = @"kUploadVideoMetaFinished";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSLog(@"### Running FB SDK Version: %@", [FBSDKSettings sdkVersion]);
    [self saveNewSplashScreen];
    
    TheDatabaseManager;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideNavigationBar:) name:@"kHideNavBar" object:nil];
    // Register Notif
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    // configure top view controller
    if(![TheSettingsManager.sessionToken isEqualToString:@""]){
        self.mainViewController = [[DashboardViewController alloc] init];
//        self.mainViewController = [[ContestViewController alloc] init];
    }else{
        self.mainViewController = [[HomeViewController alloc] init];
    }
    
    mainViewController.view.backgroundColor = [UIColor whiteColor];
    
    self.navController = [[CustomNavigationController alloc] init];
    
    if([TheSettingsManager.sessionToken isEqualToString:@""]){
        self.navController.navigationBarHidden = YES;
        self.leftViewController = nil;
        self.rightViewController = nil;
    }else{
        self.navController.navigationBarHidden = NO;
        self.leftViewController  = [[MenuViewController alloc] init];
        self.rightViewController = [[RightMenuViewController alloc] init];
    }
    
    self.slidingViewController = [[CustomREFrostedViewController alloc] initWithContentViewController:self.mainViewController menuViewController:self.leftViewController];
    self.slidingViewController.direction = REFrostedViewControllerDirectionLeft;
    self.slidingViewController.backgroundFadeAmount = 0.5;
    self.slidingViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    self.slidingViewController.liveBlur = NO;
    self.slidingViewController.blurRadius = 8;
    self.slidingViewController.delegate = self;
    
    self.navController.viewControllers = [NSArray arrayWithObject: self.slidingViewController];
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fanatikLogo"]];
    self.slidingViewController.navigationItem.titleView = titleImageView;
    
    self.window.rootViewController = self.navController;
    //    self.window.rootViewController = [[VideoDetailViewController alloc] init];
    
    [self.window makeKeyAndVisible];
    
    //google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-34703616-7"];
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-34703616-7"];
    
    tracker.allowIDFACollection = YES;
    //
    
    [Fabric with:@[CrashlyticsKit]];
    
    NSDictionary *remoteNotifInfo = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    //Accept push notification when app is not open
    if (remoteNotifInfo) {
        
        
        [self loginSuccessAndShouldDismiss:NO];
        NSString *pageName = remoteNotifInfo[@"application_page"];
        NSDictionary *params = remoteNotifInfo[@"params"];
        NSNumber *pageParam = params[@"id"];
        
        
        [self performBlock:^{
            [TheAppDelegate.mainViewController.navigationController pushViewController:[self getViewControllerById:pageName withParamId:pageParam] animated:YES];
        } afterDelay:[TheSettingsManager.currentSplashScreen.splash_screen_time doubleValue]];
    }
    
    if([self connected]){
        [TheServerManager getAllStickersWithCompletion:nil andFailure:nil];
    }
    
    NSLog(@"app dir: %@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionUSEast1
                                                          identityPoolId:@"us-east-1:df7d786e-a6a1-4266-be1a-06e05544d6fb"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionAPSoutheast1 credentialsProvider:credentialsProvider];
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    application.applicationIconBadgeNumber = 0;
    [FBSDKAppEvents activateApp];
    
    if(self.bundleVersion < [currentAppInfo.appMinimumVersion integerValue]){
        [UIAlertView showWithTitle:nil message:currentAppInfo.appMessage cancelButtonTitle:@"Update" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            NSString *iTunesLink = @"itms://itunes.apple.com/us/app/fanatik-id/id854865657?mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
            
        }];
    }
    
//    if(TheSettingsManager.deviceToken && ![TheSettingsManager.deviceToken isEqualToString:@""]){
        if([TheSettingsManager registDeviceTokenOnceADay]){
            [User registerDeviceWithSuccess:^(NSString *message) {
                [TheSettingsManager saveDayForToday];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            }];
        }
//    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [TheSettingsManager saveUserUploadModelId:nil];
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
}

#pragma mark - Register Notification
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        NSLog(@"didRegisterUser");
        [application registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    NSLog(@"My token is: %@", hexToken);
    [TheSettingsManager saveDeviceToken:hexToken];
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    [self application:app didReceiveRemoteNotification:notif.userInfo];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    TheRightMenu.debugTextView.text = @"";
    WRITE_LOG(@"xxxxxxxxxxxxxxxxxxxxxx");
    WRITE_LOG(@"xxxxxxxxxxxxxxxxxxxxxx");
    WRITE_LOG(@"xxxxxxxxxxxxxxxxxxxxxx");
    WRITE_LOG(@"xxxxxxxxxxxxxxxxxxxxxx");
    WRITE_LOG(userInfo);

    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGetInAppPushNotification object:nil userInfo:userInfo];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGetPushNotification object:nil userInfo:userInfo];
    }
    
}

-(ParentViewController *)getViewControllerById:(NSString *)pageName withParamId:(NSNumber *)pageParam{
    
    ParentViewController *controller;
    
    if([pageName isEqualToString:MenuPageTimeline]){
        controller = [[TimelineViewController alloc] init];
    }else if([pageName isEqualToString:MenuPageHome]){
        controller = [[DashboardViewController alloc] init];
    }else if([pageName isEqualToString:MenuPagePackages]){
        [TheServerManager openPackagesForContentClass:ContentClassNone withID:nil];
    }else if ([pageName isEqualToString:MenuPageMyPackages]){
        controller = [[SubscriptionViewController alloc] init];
    }else if([pageName isEqualToString:MenuPageFollowing]){
        controller =[[ProfileFollowerViewController alloc] initWithUser:[User fetchLoginUser] withMode:FollowModeFollowing];
    }else if([pageName isEqualToString:MenuPagePlaylist]){
        controller = [[ProfileViewController alloc] initWithUser:[User fetchLoginUser]];
        [(ProfileViewController *)controller setCurrentProfileMode:ProfileModePlaylist];
    }else if([pageName isEqualToString:MenuPagePlaylistDetail]){
        controller = [[PlaylistDetailsViewController alloc] initWithPlaylistID:[pageParam stringValue]];
    }else if([pageName isEqualToString:MenuPageTVChannel]){
        controller = [[TVChannelViewController alloc] init];
    }else if([pageName isEqualToString:MenuPageClub]){
        controller = [[ClubViewController alloc]initWithId:[User fetchLoginUser]? 1 : 0];
    }else if([pageName isEqualToString:MenuPageVideoDetail]){
        controller = [[VideoDetailViewController alloc] initWithClipId:pageParam];
    }else if([pageName isEqualToString:MenuPageTVChannelDetail]){
        controller = [[TVChannelDetailViewController alloc] initWithLiveId:[pageParam stringValue]];
    }else if([pageName isEqualToString:MenuPageProfile]){
        controller = [[ProfileViewController alloc] initWithUserId:[pageParam stringValue]];
    }else if([pageName isEqualToString:MenuPageClubDetail]){
        controller = [[ClubProfileViewController alloc] initWithClubId:[pageParam stringValue]];
    }else if([pageName isEqualToString:MenuPageThreadDetail]){
        controller = [[ThreadDetailsViewController alloc] initWithThreadId:[pageParam stringValue]];
    }else if([pageName isEqualToString:MenuPageVideoCategoryDashboard]){
        controller =[[VideoCategoryDashboardViewController alloc] initWithCategoryID:@"1" andLayoutID:1];
    }else if([pageName isEqualToString:MenuPageVideoCategory]){
        controller = [[VideoCategoryViewController alloc] initWithId:@"1"];
    }else if([pageName isEqualToString:MenuPageContest]){
        controller = [[ContestViewController alloc] init];
    }else if([pageName isEqualToString:MenuPageContestDetail]){
        controller = [[ContestDetailViewController alloc] initWithContestID:pageParam];
    }else if([pageName isEqualToString:MenuPageLiveChatList]){
        controller = [[LiveChatViewController alloc] init];
    }else if([pageName isEqualToString:MenuPageLiveChatDetail]){
        controller = [[LiveChatDetailViewController alloc] initWithBroadcasterID:pageParam];
    }else if([pageName isEqualToString:MenuPageEventList]){
        controller = [[EventViewController alloc] init];
    }else if([pageName isEqualToString:MenuPageEventDetail]){
        controller = [[EventDetailViewController alloc] initWithEventID:pageParam];
    }else if([pageName isEqualToString:MenuPageNotification]){
        controller = [[NotificationViewController alloc] init];
    }
    
    return controller;
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

#pragma mark - URL Handle
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {

    // attempt to extract a token from the url
    NSString *absoluteStr = [url absoluteString];
    NSArray *componentsArray = [absoluteStr componentsSeparatedByString:@"/"];
    
    NSString *urlString = [url absoluteString];
    
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithName:@"tracker"
                                                        trackingId:@"UA-34703616-7"];
    
    tracker.allowIDFACollection = YES;
    GAIDictionaryBuilder *hitParams = [[GAIDictionaryBuilder alloc] init];
    [hitParams setCampaignParametersFromUrl:urlString];
    if(![hitParams get:kGAICampaignSource] && [url host].length !=0) {
        // Set campaign data on the map, not the tracker.
        [hitParams set:@"referrer" forKey:kGAICampaignMedium];
        [hitParams set:[url host] forKey:kGAICampaignSource];
    }
    
    NSDictionary *hitParamsDict = [hitParams build];
    [tracker set:kGAIScreenName value:@"screen name"];
    [tracker send:[[[GAIDictionaryBuilder createScreenView] setAll:hitParamsDict] build]];
    
    NSMutableDictionary *mutableHitParamDict = [NSMutableDictionary dictionaryWithDictionary:hitParamsDict];
    
    
    if([[url scheme] isEqualToString:FACEBOOK_SCHEME]){
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation
                ];
    }else if([componentsArray[2] isEqualToString:@"campaign"] && mutableHitParamDict.count > 0){
        [TheServerManager getGoogleCampaignWithParams:[mutableHitParamDict removeUnusedCharacterAndNull] withCompletion:nil andFailure:nil];
    }else if([[url scheme] isEqualToString:DEEPLINK_SCHEME]){
        NSLog(@"Calling Application Bundle ID: %@", sourceApplication);
        NSLog(@"URL scheme:%@", [url scheme]);
        NSLog(@"URL query: %@", [url query]);
        
        NSString *urlString = [url absoluteString]; //@"fanatik.id://payments/12313213/success?access_token=iskil_private_token";
        NSArray *urlArray = [urlString componentsSeparatedByString:@"/"];
        
        NSString *lastString = urlArray[urlArray.count-1];
        NSRange range = [lastString rangeOfString:@"?"];
        NSString *successStr = @"";
        if(range.location != NSNotFound)
            successStr = [lastString substringToIndex:range.location];
        
        NSString *queryString = [url query];
        NSArray *queryStringArray = [queryString componentsSeparatedByString:@"&"];
        NSString *accToken;
        NSString *sessToken;
        for (NSString *tok in queryStringArray) {
            NSRange accRange = [tok rangeOfString:@"access_token="];
            NSRange sessRange = [tok rangeOfString:@"session_token="];
            if(accRange.location != NSNotFound){
                accToken = [tok substringFromIndex:accRange.length];
                [TheSettingsManager saveAccessToken:accToken];
            }else if(sessRange.location != NSNotFound){
                sessToken = [tok substringFromIndex:sessRange.length];
                [TheSettingsManager saveSessionToken:sessToken];
            }
        }
    
        if([successStr isEqualToString:@"success"]){
            if([urlArray[2] isEqualToString:@"payments"]){
                
                if(TheSettingsManager.lastMenuPurchasing && ![TheSettingsManager.lastMenuPurchasing isEqualToString:@""]){
                    TheSettingsManager.lastMenuPurchasing = @"";
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPaymentCompleted object:nil];
                }else{
                    self.slidingViewController.menuViewController  = nil;
                    
                
                    self.leftViewController = [[MenuViewController alloc] init];
                    

                    
                    
                    self.slidingViewController.menuViewController  = self.leftViewController;
                    SubscriptionViewController *vc = [[SubscriptionViewController alloc] init];
                    [TheAppDelegate changeCenterController:vc];
                    [TheSettingsManager saveSelectedMenu:MenuPageMyPackages];
                }
            }
        }else if([successStr isEqualToString:@"failed"]){
            if([urlArray[2] isEqualToString:@"payments"]){
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowFailedNotification object:nil];
            }
        }
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:kRequestSideMenuNotification object:nil];
    }
    
    return YES;
}

#pragma mark - Background Task Handler
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    /*
     Store the completion handler.
     */
    /* Store the completion handler.*/
    [AWSS3TransferUtility interceptApplication:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];


    
}

#pragma mark - Side Menu

- (void)showRightMenu {
    SearchViewController *vc = [[SearchViewController alloc] init];
    [self.navController pushViewController:vc animated:YES];
}

- (void)showLeftMenu {
    if(!isAnimatingMenu){
        [self.slidingViewController.view endEditing:YES];
        if(isShowingMenu){
            [self.slidingViewController hideMenuViewController];
        }else{
            [self.slidingViewController presentMenuViewController];
        }
    }else{
        return;
    }
}

-(void)changeCenterController:(ParentViewController *)aController{
    self.mainViewController = aController;
    self.navController.viewControllers = [NSArray arrayWithObject: self.slidingViewController];
    self.slidingViewController.navigationItem.titleView = nil;
    
    if ([aController isKindOfClass:[DashboardViewController class]]){
        aController.currentPageCode = MenuPageTVChannel;
        aController.currentApplicationMenu = [TheDatabaseManager getApplicationMenudByPageCode:aController.currentPageCode];
        UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fanatikLogo"]];
        self.slidingViewController.navigationItem.titleView = titleImageView;
        
    }else{
        
        if([aController isKindOfClass:[ProfileViewController class]]){
            aController.currentPageCode = MenuPageProfile;
            aController.currentApplicationMenu = [TheDatabaseManager getApplicationMenudByPageCode:aController.currentPageCode];
            
        }else if ([aController isKindOfClass:[TVChannelViewController class]]){
            aController.currentPageCode = MenuPageTVChannel;
            aController.currentApplicationMenu = [TheDatabaseManager getApplicationMenudByPageCode:aController.currentPageCode];

        
        }else if ([aController isKindOfClass:[ClubViewController class]]){
            aController.currentPageCode = MenuPageClub;
            aController.currentApplicationMenu = [TheDatabaseManager getApplicationMenudByPageCode:aController.currentPageCode];

        }else if ([aController isKindOfClass:[TimelineViewController class]]){
            aController.currentPageCode = MenuPageTimeline;
            aController.currentApplicationMenu = [TheDatabaseManager getApplicationMenudByPageCode:aController.currentPageCode];

        }else if ([aController isKindOfClass:[ProfileFollowerViewController class]]){
            aController.currentPageCode = MenuPageFollowing;
            aController.currentApplicationMenu = [TheDatabaseManager getApplicationMenudByPageCode:aController.currentPageCode];

            
        }else if ([aController isKindOfClass:[SubscriptionViewController class]]){
            aController.currentPageCode = MenuPageMyPackages;
            aController.currentApplicationMenu = [TheDatabaseManager getApplicationMenudByPageCode:aController.currentPageCode];

        }else if ([aController isKindOfClass:[VideoCategoryDashboardViewController class]]){
            aController.currentPageCode = MenuPageVideoCategoryDashboard;
            aController.currentApplicationMenu = [TheDatabaseManager getApplicationMenudByPageCode:aController.currentPageCode];

        }else if ([aController isKindOfClass:[VideoCategoryViewController class]]){
            aController.currentPageCode = MenuPageVideoCategory;
            aController.currentApplicationMenu = [TheDatabaseManager getApplicationMenudByPageCode:aController.currentPageCode];
            
        }else if ([aController isKindOfClass:[ContestViewController class]]){
            aController.currentPageCode = MenuPageContest;
            aController.currentApplicationMenu = [TheDatabaseManager getApplicationMenudByPageCode:aController.currentPageCode];
        }else if ([aController isKindOfClass:[LiveChatViewController class]]){
            aController.currentPageCode = MenuPageLiveChatList;
            aController.currentApplicationMenu = [TheDatabaseManager getApplicationMenudByPageCode:aController.currentPageCode];
        }else if ([aController isKindOfClass:[EventViewController class]]){
            aController.currentPageCode = MenuPageEventList;
            aController.currentApplicationMenu = [TheDatabaseManager getApplicationMenudByPageCode:aController.currentPageCode];
        }else if ([aController isKindOfClass:[NotificationViewController class]]){
            aController.currentPageCode = MenuPageNotification;
            aController.currentApplicationMenu = [TheDatabaseManager getApplicationMenudByPageCode:aController.currentPageCode];
        }
        
        if (aController.currentApplicationMenu.pageTitle && ![aController.currentApplicationMenu.pageTitle isEqualToString:@"-"] && ![aController isKindOfClass:[LiveChatDetailViewController class]]) {
            self.slidingViewController.navigationItem.title = aController.currentApplicationMenu.pageTitle;
            [self.slidingViewController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:InterfaceStr(@"default_font_bold") size:17]}];
        }
    
    }
    self.slidingViewController.contentViewController = aController;
    [self.slidingViewController hideMenuViewController];
    isShowingMenu = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeCenterController object:nil];
}



#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - central data
- (NSString *)pathCentralData{
    return [[self documentsDir] stringByAppendingPathComponent:dirCentralData];
}

- (NSURL *)applicationCentralData{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dirCentralData isDirectory:YES];
}

- (NSURL *)applicationOldCentralData{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dirOldCentralData isDirectory:YES];
}

- (NSString *) documentsDir{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return documentsDir;
}

- (BOOL)isCentralDataExist{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSString *centralData = [[self documentsDir] stringByAppendingPathComponent:dirCentralData];
    
    return [defaultManager fileExistsAtPath:centralData];
}

- (void)createCentralDataIfDoesntExist{
    [self removeOldCenterDataIfExist];
    NSURL *urlCentralData = [self applicationCentralData];
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if(![self isCentralDataExist]){
        if(![defaultManager createDirectoryAtURL:urlCentralData withIntermediateDirectories:NO attributes:nil error:nil]){
            NSLog(@"Failed to create central data dir");
        }
        else{
            NSLog(@"Created central data dir");
        }
    }
}

-(void)removeOldCenterDataIfExist{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if([self isOldCentralDataExist]){
        [defaultManager removeItemAtPath:[NSString stringWithFormat:@"%@/",[self documentsDir]] error:&error];
        [self removeOldCacheData];
        
    }
}

-(void)removeOldCacheData{
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *mainPath    = [myPathList  objectAtIndex:0];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:mainPath error:nil];
    for (NSString *filename in fileArray)  {
        [fileMgr removeItemAtPath:[mainPath stringByAppendingPathComponent:filename] error:NULL];
    }
    
    
}

-(BOOL)isOldCentralDataExist{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSString *centralData = [[self documentsDir] stringByAppendingPathComponent:dirOldCentralData];
    
    return [defaultManager fileExistsAtPath:centralData];
}

#pragma mark - Facebook Delegate
-(void)openActiveSessionWithPermissions:(NSArray *)permissions allowLoginUI:(BOOL)allowLoginUI{
//    [FBSession openActiveSessionWithReadPermissions:permissions
//                                       allowLoginUI:allowLoginUI
//                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
//                                      
//                                      // Create a NSDictionary object and set the parameter values.
//                                      NSDictionary *sessionStateInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                                                        session, @"session",
//                                                                        [NSNumber numberWithInteger:status], @"state",
//                                                                        error, @"error",
//                                                                        nil];
//                                      
//                                      // Create a new notification, add the sessionStateInfo dictionary to it and post it.
//                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"kFacebookLoginNotification"
//                                                                                          object:nil
//                                                                                        userInfo:sessionStateInfo];
//
//                                  }];
}

-(void)loginSuccessAndShouldDismiss:(BOOL)shouldDismiss{
    if (shouldDismiss) {
        [self.mainViewController dismissViewControllerAnimated:YES completion:nil];
        self.leftViewController  = [[MenuViewController alloc] init];
        self.slidingViewController.menuViewController  = self.leftViewController;
    }else{
        if(!TheSettingsManager.selectedMenu || [TheSettingsManager.selectedMenu isEqualToString:@""]){
            [TheSettingsManager saveSelectedMenu:MenuPageHome];
        }
        
        self.mainViewController = [TheAppDelegate getViewControllerById:TheSettingsManager.selectedMenu withParamId:@(1)];
        self.navController.navigationBarHidden = NO;
        self.leftViewController  = [[MenuViewController alloc] init];
        self.rightViewController = [[RightMenuViewController alloc] init];
        self.slidingViewController.menuViewController  = self.leftViewController;
        [self changeCenterController:mainViewController];
    }
}

-(void)logoutSuccess{
    //These menus only show if user already logged in.
    if([TheSettingsManager.selectedMenu isEqualToString:MenuPageTimeline] || [TheSettingsManager.selectedMenu isEqualToString:MenuPageFollowing] || [TheSettingsManager.selectedMenu isEqualToString:MenuPagePlaylist] || [TheSettingsManager.selectedMenu isEqualToString:MenuPageClub] || [TheSettingsManager.selectedMenu isEqualToString:MenuPageClubDetail] || [TheSettingsManager.selectedMenu isEqualToString:MenuPageThread] || [TheSettingsManager.selectedMenu isEqualToString:MenuPageThreadDetail] || [TheSettingsManager.selectedMenu isEqualToString:MenuPageEventDetail] || [TheSettingsManager.selectedMenu isEqualToString:MenuPageVideoDetail] || [TheSettingsManager.selectedMenu isEqualToString:MenuPageNotification])
    {
        [TheSettingsManager saveSelectedMenu:MenuPageHome];
        [TheAppDelegate changeCenterController:[self getViewControllerById:TheSettingsManager.selectedMenu withParamId:nil]];
    }
    
    [self removeLocalData];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutCompletedNotification object:nil];
}

-(void)goToLogin{
    self.mainViewController = [[HomeViewController alloc] init];
    self.navController.navigationBarHidden = YES;
    self.slidingViewController.menuViewController  = nil;
    [self changeCenterController:mainViewController];
}


- (void)removeLocalData{
    
    NSManagedObjectContext *context = [TheDatabaseManager managedObjectContext];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Timeline class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([ClipGroup class]) inContext:context];
    
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Club class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([ClubMembership class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([ClubStats class]) inContext:context];

   [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Thread class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([ThreadStats class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([ThreadContent class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([ThreadComment class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([ThreadRestriction class]) inContext:context];
 
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Actor class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Settings class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Shareable class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([PaymentGroup class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Payment class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Activity class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Playlist class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Live class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Hls class]) inContext:context];[TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Thread class]) inContext:context];
    
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Comment class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([ClipStats class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([ClipCategory class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Clip class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([UserStats class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Package class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Socialization class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Avatar class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([CoverImage class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([User class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Timeline class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Video class]) inContext:context];
    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Thumbnail class]) inContext:context];
//    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Resolution class]) inContext:context];
//    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([SideMenu class]) inContext:context];
//    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([SectionMenu class]) inContext:context];
//    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([RowMenu class]) inContext:context];
//    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([MenuIcon class]) inContext:context];
//    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([RowMenuParam class]) inContext:context];
    
//    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([EventGroup class]) inContext:context];
//    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([EventAnnouncement class]) inContext:context];
//    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([EventStats class]) inContext:context];
//    [TheDatabaseManager deleteAllObjectsFrom:NSStringFromClass([Event class]) inContext:context];
    
    
    
    [TheDatabaseManager deleteAllUserUploadsModels];
    [TheSettingsManager removeCurrentUserId];
    [TheSettingsManager saveUserUploadModelId:nil];

}


#pragma mark - convenient method
-(void)writeLog:(id)log{
    NSLog(@"\n%@",log);
#ifdef DEBUG
    [TheRightMenu writeToDebugScreen:log];
#endif
}

-(NSDateFormatter *)defaultTimeFormatter{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = [TheConstantsManager defaultTimeFormat];
    return df;
}

-(NSDateFormatter *)defaultDateFormatter{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = [TheConstantsManager defaultDateFormat];
    return df;
}

-(NSDateFormatter *)defaultDateTimeFormatter{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = [TheConstantsManager defaultDateTimeFormat];
    [df setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    return df;
}

#pragma  mark - frostedview delegate
- (void)frostedViewController:(REFrostedViewController *)frostedViewController didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer
{
    
}

- (void)frostedViewController:(REFrostedViewController *)frostedViewController willShowMenuViewController:(UIViewController *)menuViewController
{
    self.isAnimatingMenu = YES;
}

- (void)frostedViewController:(REFrostedViewController *)frostedViewController didShowMenuViewController:(UIViewController *)menuViewController
{
    self.isAnimatingMenu = NO;
    isShowingMenu = YES;
    
}

- (void)frostedViewController:(REFrostedViewController *)frostedViewController willHideMenuViewController:(UIViewController *)menuViewController
{
    self.isAnimatingMenu = YES;
}

- (void)frostedViewController:(REFrostedViewController *)frostedViewController didHideMenuViewController:(UIViewController *)menuViewController
{
    self.isAnimatingMenu = NO;
    isShowingMenu = NO;
    
}

-(UIButton *)createButtonWithTitle:(NSString *)title imageName:(NSString *)img highlightedImageName:(NSString *)img2 forLeftButton:(BOOL)isLeft{
    UIButton *lButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    
    if(title && ![title isEqualToString:@""]){
        [lButton setFrame:CGRectMake(0, 0, 160, 44)];
        CGSize optimumSize = [title sizeOfTextWithfont:[UIFont fontWithName:InterfaceStr(@"default_font_regular") size:14.0] frame:lButton.frame];
        optimumSize.width += 10;
        if(optimumSize.width < lButton.frame.size.width){
            [lButton setFrame:CGRectMake(0, 0, optimumSize.width, optimumSize.height)];
        }
        lButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        
        lButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [lButton setTitle:title forState:UIControlStateNormal];
        [lButton setTitleColor:HEXCOLOR(0x333333FF)
                      forState:UIControlStateNormal];
        [lButton setTitleColor:HEXCOLOR(0x3333337F)
                      forState:UIControlStateHighlighted];
        lButton.titleLabel.font = [UIFont fontWithName:InterfaceStr(@"default_font_regular") size:14.0];
        lButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    }else{
        [lButton setFrame:CGRectMake(0, 0, 44, 44)];
    }
    
    if(img && ![img isEqualToString:@""]){
        UIImage *image = [UIImage imageNamed:img];
        [lButton setImage:image
                 forState:UIControlStateNormal];
        UIImage *image2 = img2 && ![img2 isEqualToString:@""] ? [UIImage imageNamed:img2] : image;
        [lButton setImage:image2
                 forState:UIControlStateSelected];
        [lButton setImage:image2
                 forState:UIControlStateHighlighted];
        if(title && ![title isEqualToString:@""]){
            if(isLeft)
                lButton.imageEdgeInsets = UIEdgeInsetsMake(-0, -2, 0, 2);
            else
                lButton.imageEdgeInsets = UIEdgeInsetsMake(-0, 2, 0, -2);
        }else{
            if(isLeft)
                lButton.imageEdgeInsets = UIEdgeInsetsMake(-0, -15, 0, 15);
            else
                lButton.imageEdgeInsets = UIEdgeInsetsMake(-0, 15, 0, -15);
        }
    }
    return lButton;
}

-(NSMutableDictionary *)stripURL:(NSString *)urlString{
    //http://dev.domikado.com/?mobile_action=exit_view&last_page=
    NSLog(@"%@/?",[TheConstantsManager serverURL]);
    NSString *removeThisString = @"http://dev.domikado.com/?";//[NSString stringWithFormat:@"%@/?",[TheConstantsManager serverURL]];
    NSString *newString = [urlString stringByReplacingOccurrencesOfString:removeThisString withString:@""];
    NSArray *paramArray = [newString componentsSeparatedByString:@"&"];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    for (NSString *k in paramArray) {
        NSArray *arr = [k componentsSeparatedByString:@"="];
        paramDict[arr[0]] = arr[1];
        
    }
    return paramDict;
}

-(void)saveNewSplashScreen{
    
    NSLog(@"Downloading...");
    // Get an image from the URL below
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [SplashScreenModel getApplicationInfoWithAccessToken:^(ApplicationInfoModel *appInfoMod) {
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        if(TheSettingsManager.currentSplashScreen.ss_image_original && ![TheSettingsManager.currentSplashScreen.ss_image_original isEqualToString:@""]){
            
            NSLog(@"ss url: %@",[TheSettingsManager currentSplashScreen].ss_image_original);
            UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: [TheSettingsManager currentSplashScreen].ss_image_original]]];
            
            NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            // If you go to the folder below, you will find those pictures
            NSLog(@"%@",docDir);
            
            NSLog(@"saving png");
            NSString *pngFilePath = [NSString stringWithFormat:@"%@/test.png",docDir];
            NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
            [data1 writeToFile:pngFilePath atomically:YES];
            
            NSLog(@"saving image done");
        }else{
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString *filePath = [documentsPath stringByAppendingPathComponent:@"test.png"];
            NSError *error;
            [fileManager removeItemAtPath:filePath error:&error];
        }
        
        NSLog(@"bundle version: %d, minimum app info: %d, current version app info: %d", (int)self.bundleVersion, (int)[appInfoMod.appMinimumVersion integerValue], (int)[appInfoMod.appCurrentVersion integerValue]);
        
        self.currentAppInfo = appInfoMod;
        if(self.bundleVersion < [appInfoMod.appMinimumVersion integerValue]){
            [UIAlertView showWithTitle:nil message:appInfoMod.appMessage cancelButtonTitle:@"Update" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
                NSString *iTunesLink = @"itms://itunes.apple.com/us/app/fanatik-id/id854865657?mt=8";
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                
            }];
        }else if(self.bundleVersion < [appInfoMod.appCurrentVersion integerValue]){
            
            [UIAlertView showWithTitle:nil message:appInfoMod.appMessage cancelButtonTitle:@"Update" otherButtonTitles:@[@"Skip"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
                if(buttonIndex == alertView.cancelButtonIndex){
                    NSString *iTunesLink = @"itms://itunes.apple.com/us/app/fanatik-id/id854865657?mt=8";
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                }
                
            }];
        }
        
    } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

-(void)hideNavigationBar:(NSNotification *)notif{
    NSLog(@"bool = %d", [notif.object boolValue]);
    //    self.navController.navigationBarHidden = [notif.object boolValue];
    [self.navController setNavigationBarHidden:[notif.object boolValue] animated:![notif.object boolValue]];
    
}

-(NSInteger)bundleVersion{
    return [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] integerValue];
}

-(CGFloat)deviceWidth{
    return [UIScreen mainScreen].bounds.size.width;
}

-(CGFloat)deviceHeight{
    return [UIScreen mainScreen].bounds.size.height;
}
@end
