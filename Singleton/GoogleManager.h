//
//  GoogleManager.h
//  Valo
//
//  Created by Jefry Da Gucci on 11/11/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>


@class GoogleManager, GTMOAuth2Authentication, GPPSignIn;
@protocol GoogleManagerDelegate <NSObject>

@optional
- (void)GoogleManager:(GoogleManager *)GoogleManager didConnectWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error;
- (void)GoogleManager:(GoogleManager *)GoogleManager didConnectWithAuth:(GTMOAuth2Authentication *)auth signin:(GPPSignIn *)signin;
- (void)GoogleManager:(GoogleManager *)GoogleManager didDisconnectWithError:(NSError *)error;
- (void)GoogleManager:(GoogleManager *)GoogleManager finishedSharingWithError:(NSError *)error;

@end

//in ios 8.0 gplus delegate won't be called unless
//the singleton that using the delegate is a subclass of UIViewController
//source: https://code.google.com/p/google-plus-platform/issues/detail?id=901
//
@interface GoogleManager : NSObject
<GPPSignInDelegate, GPPShareDelegate>

@property (strong, nonatomic) NSString *googleClientId;
@property (strong, nonatomic) NSString *googleScheme;

@property (nonatomic, assign) id <GoogleManagerDelegate> delegate;

@property (nonatomic, retain) GPPSignIn *signIn;

#define GOOGLE_MANAGER_INSTANCE() ([GoogleManager sharedInstance])
+ (GoogleManager *)sharedInstance;

- (void)setupGoogleSignin;

#pragma mark - share
- (void)shareOnGooglePlusWithURLString:(NSString *)urlString prefillText:(NSString *)prefillText title:(NSString *)title description:(NSString *)description thumbnailURLString:(NSString *)thumbnailURLString andRecipientIDArray:(NSArray*)recipientsArray;

#pragma mark - friends
- (void)getUserFriendsWithCompletion:(void(^)(GTLServiceTicket *ticket,
                                              GTLPlusPeopleFeed *peopleFeed,
                                              NSError *error))complete;
@end
