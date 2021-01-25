//
//  RightMenuViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/17/14.
//  Copyright (c) 2014 Teguh Hidayatullah. All rights reserved.
//

#import "RightMenuViewController.h"

@interface RightMenuViewController ()<UITextFieldDelegate, UIAlertViewDelegate>
- (IBAction)saveURL:(id)sender;
@property(nonatomic, copy) NSString *debugLogs;
- (IBAction)saveHeader:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *OSVerTF;
@property (strong, nonatomic) IBOutlet UITextField *appVerTF;


@end

@implementation RightMenuViewController
@synthesize debugURL, serverURLTF, debugTextView, debugLogs, OSVerTF, appVerTF;
SYNTHESIZE_SINGLETON_FOR_CLASS(RightMenuViewController)


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIButton *lButton = [TheAppDelegate createButtonWithTitle:@"Debug Menu" imageName:@"leftArrow" highlightedImageName:@"leftArrowHighlight" forLeftButton:YES];
    [lButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    self.navigationItem.leftBarButtonItem = backButton;
   
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.serverURLTF.text = ConstStr(@"server_url");
    debugTextView.text = debugLogs;
    
    if(TheSettingsManager.debugAppVersion && ![TheSettingsManager.debugAppVersion isEqualToString:@""]){
        appVerTF.text = TheSettingsManager.debugAppVersion;
    }else{
        NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
        NSString *appVersion = infoDictionary[@"CFBundleShortVersionString"];
        appVerTF.text = appVersion;
    }
    
    if(TheSettingsManager.debugOSVersion && ![TheSettingsManager.debugOSVersion isEqualToString:@""]){
        OSVerTF.text = TheSettingsManager.debugOSVersion;
    }else{
        OSVerTF.text = SYSTEM_VERSION;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)writeToDebugScreen:(id)txt{
    if(!debugLogs)
        debugLogs = @"";
    debugLogs = [debugLogs stringByAppendingString:[NSString stringWithFormat:@"\n%@",txt]];
//    debugLogs = [[NSString stringWithFormat:@"%@",txt] stringByAppendingString:[NSString stringWithFormat:@"\n%@",debugLogs]];
    debugTextView.text = debugLogs;
    
}

- (IBAction)clearScreen:(id)sender {
    debugLogs = @"";
    debugTextView.text = @"";
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.serverURLTF resignFirstResponder];
    [self.debugTextView resignFirstResponder];
    [self resignFirstResponder];
    return YES;
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [self clearScreen:nil];
        [self doLogoutUser];
    }
}


-(void)doLogoutUser{
    [User logoutWithCompletion:^(NSString *message) {
//        [[FBSession activeSession] closeAndClearTokenInformation];
        [TheSettingsManager saveDebugServerURL:self.debugURL];
        [TheAppDelegate logoutSuccess];
    } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSUInteger statusCode = operation.response.statusCode;
        if(statusCode == StatusCodeExpired || statusCode == StatusCodeForbidden){
            if(statusCode == StatusCodeForbidden){
                [TheSettingsManager removeAccessToken];
                [TheSettingsManager removeSessionToken];
                [TheSettingsManager removeCurrentUserId];
                [TheSettingsManager resetSideMenuArray];
                [TheAppDelegate logoutSuccess];
            }
            [TheServerManager requestAccessTokenWithCompletion:^(NSString *accessToken) {
                [User logoutWithCompletion:^(NSString *message) {
//                    [[FBSession activeSession] closeAndClearTokenInformation];
                    [TheAppDelegate logoutSuccess];
                    
                } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSUInteger statusCode = operation.response.statusCode;
                    if(statusCode == StatusCodeExpired || statusCode == StatusCodeForbidden){
            if(statusCode == StatusCodeForbidden){
                [TheSettingsManager removeAccessToken];
                [TheSettingsManager removeSessionToken];
                [TheSettingsManager removeCurrentUserId];
                [TheSettingsManager resetSideMenuArray];
                [TheAppDelegate logoutSuccess];
            }
                        [TheServerManager requestAccessTokenWithCompletion:^(NSString *accessToken) {
                            [self doLogoutUser];
                
                        } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        }];
                        
                        
                    }else{
                        
                        NSUInteger statusCode = operation.response.statusCode;
                        if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.responseData){
                            NSData *responseData = operation.responseData;
                            NSDictionary* json = [NSJSONSerialization
                                                  JSONObjectWithData:responseData //1
                                                  options:NSJSONReadingMutableLeaves
                                                  error:nil];
                            NSString *message = json[@"error"][@"messages"][0];
                            [self showLocalValidationError:message];
                        }
                    }
                }];
            } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {

            }];
            
        }
    }];
}

#pragma mark - IBAction
- (IBAction)saveURL:(id)sender {
    self.debugURL = serverURLTF.text;
    
    if([User fetchLoginUser]){
        NSString *title = @"You have to log out to change the Server URL.  Do you want to log out?";
        UIAlertView *resultAlertView = [[UIAlertView alloc] initWithTitle:nil message:title delegate:nil cancelButtonTitle:@"Nope" otherButtonTitles:@"Aw Yisss!",nil];
        resultAlertView.delegate = self;
        [resultAlertView show];
    }else{
        [self clearScreen:nil];
        [TheSettingsManager saveDebugServerURL:self.debugURL];
        [self showAlertWithMessage:@"Berhasil!"];
    }
}

- (IBAction)saveHeader:(id)sender {
    [TheSettingsManager saveDebugAppVersion:appVerTF.text];
    [TheSettingsManager saveDebugOSVersion:OSVerTF.text];
    [self showAlertWithMessage:@"Berhasil!"];
}
@end
