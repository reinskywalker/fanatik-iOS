//
//  GoogleManager.m
//  Valo
//
//  Created by Jefry Da Gucci on 11/11/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "GoogleManager.h"



@interface GoogleManager ()
@property(nonatomic,retain) GTMOAuth2Authentication *authentication;

@end

@implementation GoogleManager

+ (GoogleManager *)sharedInstance{
    static GoogleManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GoogleManager alloc] init];
    });
    return sharedInstance;
}

- (void)setupGoogleSignin{
    self.signIn = [GPPSignIn sharedInstance];
    
    self.signIn.shouldFetchGooglePlusUser    = YES;
    self.signIn.shouldFetchGoogleUserEmail   = YES;
    self.signIn.shouldFetchGoogleUserID      = YES;
    self.signIn.clientID = GOOGLE_ID();
    
    self.signIn.scopes = @[ kGTLAuthScopePlusLogin, @"profile", kGTLAuthScopePlusMe];
    
    self.signIn.delegate = self;
}

#pragma mark - GPPSignInDelegate
- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error{
    if(error){
        if([self.delegate respondsToSelector:@selector(GoogleManager:didConnectWithAuth:error:)]){
            [self.delegate GoogleManager:self didConnectWithAuth:auth error:error];
        }
    }
    else{
        self.authentication = auth;
        if([self.delegate respondsToSelector:@selector(GoogleManager:didConnectWithAuth:signin:)]){
            [self.delegate GoogleManager:self didConnectWithAuth:auth signin:[GPPSignIn sharedInstance]];
        }
    }
}

- (void)didDisconnectWithError:(NSError *)error{
    self.authentication = nil;
    if([self.delegate respondsToSelector:@selector(GoogleManager:didDisconnectWithError:)]){
        [self.delegate GoogleManager:self didDisconnectWithError:error];
    }
}

#pragma mark - share
- (void)shareOnGooglePlusWithURLString:(NSString *)urlString prefillText:(NSString *)prefillText title:(NSString *)title description:(NSString *)description thumbnailURLString:(NSString *)thumbnailURLString andRecipientIDArray:(NSArray*)recipientsArray{
    
    [GPPShare sharedInstance].delegate = self;
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    
    if(urlString){
        [shareBuilder setURLToShare:[NSURL URLWithString:urlString]];
    }
    if(prefillText){
        [shareBuilder setPrefillText:prefillText];
    }
    
    if(recipientsArray && recipientsArray.count > 0){
        [shareBuilder setPreselectedPeopleIDs:recipientsArray];
    }
    [shareBuilder setTitle:title description:description thumbnailURL:[NSURL URLWithString:thumbnailURLString]];
    
    


    
    if(![shareBuilder open]){
        id<GPPShareBuilder>shareBuilder = [[GPPShare sharedInstance] shareDialog];
        if(urlString){
            [shareBuilder setURLToShare:[NSURL URLWithString:urlString]];
        }
        if(prefillText){
            [shareBuilder setPrefillText:prefillText];
        }
        [shareBuilder setTitle:title description:description thumbnailURL:[NSURL URLWithString:thumbnailURLString]];
        [shareBuilder open];
    }
}

#pragma mark - GPPShareDelegate 
- (void)finishedSharingWithError:(NSError *)error {
    NSString *text;
    
    if (!error) {
        text = @"Success";
    } else if (error.code == kGPPErrorShareboxCanceled) {
        text = @"Canceled";
    } else {
        text = [NSString stringWithFormat:@"Error (%@)", [error localizedDescription]];
    }

    NSLog(@"Status: %@", text);
    if([self.delegate respondsToSelector:@selector(GoogleManager:finishedSharingWithError:)]){
        [self.delegate GoogleManager:self finishedSharingWithError:error];
    }
}

#pragma mark - friends
- (void)getUserFriendsWithCompletion:(void(^)(GTLServiceTicket *ticket,
                                              GTLPlusPeopleFeed *peopleFeed,
                                              NSError *error))complete
{
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:self.authentication];
    GTLQueryPlus *query =
    [GTLQueryPlus queryForPeopleListWithUserId:@"me"
                                    collection:kGTLPlusCollectionVisible];
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPeopleFeed *peopleFeed,
                                NSError *error) {
                if (error) {
                    GTMLoggerError(@"Error: %@", error);
                } else {
                    
                    
                }
                if(complete)
                    complete(ticket, peopleFeed, error);
            }];
}

@end
