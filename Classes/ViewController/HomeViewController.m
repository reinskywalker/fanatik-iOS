//
//  HomeViewController.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/31/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "HomeViewController.h"
#import "MainViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
typedef enum
{
    PageModeLogin = 0,
    PageModeRegister = 1,
    PageModeForgotPassword = 2,
    PageModeResetPassword = 3
}PageMode;

#define TextFieldTopSpace  (iPhoneVersion == 4? 100 : 120)

@interface HomeViewController (){
    PageMode currentPageMode;
    
    IBOutlet CustomRegularLabel *titleLabel;
    IBOutlet UIView *textFieldContainer;
    IBOutlet UIButton *rightButton;
    IBOutlet UIButton *leftButton;
    IBOutlet UIView *textButtonContainer;
    IBOutlet NSLayoutConstraint *tfContainerHeightConstraint;
    IBOutlet NSLayoutConstraint *skipBottomSpaceConstraint;
    IBOutlet NSLayoutConstraint *textFieldContainerTopSpace;
    IBOutlet NSLayoutConstraint *facebookViewTopSpaceConstraint;
    IBOutlet NSLayoutConstraint *topMostConstraint;

    IBOutlet CustomMediumTextField *firstTF;
    IBOutlet CustomMediumTextField *secondTF;
    IBOutlet CustomMediumTextField *thirdTF;
    IBOutlet CustomMediumTextField *fouthTF;
    IBOutlet CustomMediumTextField *fifthTF;
    
    IBOutlet UIView *separatorView;
    
    IBOutlet UIButton *skipButton;
    IBOutlet UIView *textFieldView1;
    IBOutlet UIView *textFieldView2;
    IBOutlet UIView *textFieldView3;
    IBOutlet UIView *textFieldView4;
    IBOutlet UIView *textFieldView5;
    IBOutlet UIView *buttonView;
    
    BOOL isKeyboardObstructing;
    float obstructedAreaHeight;
    int numRequest;
}

@end

@implementation HomeViewController
@synthesize actionButton, imgView;

-(instancetype)init{
    if(self=[super init]){
        currentPageMode = PageModeLogin;
        
    }
    return self;
}

-(BOOL)primeNumber:(int)num{
    for(int i=2;i<=num/2;i++){
        if(num % i==0){
            return false;
        }
    }
    return true;
}

-(instancetype)initByPresenting{
    if(self=[super init]){
        currentPageMode = PageModeLogin;
        self.isPresented = YES;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

//    NSLog(@"Prime number : %@", [self primeNumber:29]?@"Yes":@"No");
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFBSessionStateChangeWithNotification:) name:@"kFacebookLoginNotification" object:nil];
    [self configureView];
    
    //Google Manager
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* foofile = [documentsPath stringByAppendingPathComponent:@"test.png"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
    
    if(!TheSettingsManager.isLoadSplashScreen && fileExists){
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:@"test.png"];
        UIImage* image = [UIImage imageWithContentsOfFile:path];
        [imgView setImage:image];
        
        NSLog(@"%f",[TheSettingsManager.currentSplashScreen.splash_screen_time doubleValue]);
        
        [self performBlock:^{
            //fade out
            [UIView animateWithDuration:0.3 animations:^{
                [imgView setAlpha:0.0f];
                
                [TheSettingsManager loadedSplashScreen:YES];
            } completion:nil];
        } afterDelay:[TheSettingsManager.currentSplashScreen.splash_screen_time doubleValue]];
    }
}

-(void)configureView{
    
    [skipButton setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.85] forState:UIControlStateHighlighted];
    [skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    actionButton.layer.cornerRadius = actionButton.frame.size.height /2.0;
    actionButton.layer.masksToBounds = YES;
    [self reloadTextField];
    [self.view layoutIfNeeded];
    switch (currentPageMode) {
        case PageModeLogin:{
            textFieldView3.hidden = YES;
            tfContainerHeightConstraint.constant = 100.0;
            actionButton.titleLabel.text = @"Log In";
            if(iPhoneVersion == 4){
                facebookViewTopSpaceConstraint.constant = 15.0;
                skipBottomSpaceConstraint.constant = 10;
                textFieldContainerTopSpace.constant = TextFieldTopSpace;
            }else{
                facebookViewTopSpaceConstraint.constant = 31.0;
                skipBottomSpaceConstraint.constant = 59.0;
                textFieldContainerTopSpace.constant = TextFieldTopSpace;
            }
        }
            break;
            
        default:
            break;
    }
    
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self reloadTextField];
    
}


-(BOOL)validateField{
    switch (currentPageMode) {
        case PageModeLogin:{
            if([firstTF.text isEqualToString:@""]  || [secondTF.text isEqualToString:@""]){
                [self showLocalValidationError:@"Please fill Username and Password."];
                return NO;
            }
        }
            break;
        case PageModeForgotPassword:{
            if([firstTF.text isEqualToString:@""]){
                [self showLocalValidationError:@"Please fill your email."];
                return NO;
            }
        }
            break;
        case PageModeRegister:{
            if([firstTF.text isEqualToString:@""]  || [secondTF.text isEqualToString:@""] || [thirdTF.text isEqualToString:@""]){
                [self showLocalValidationError:@"Please fill the form."];
                return NO;
            }else if(![fouthTF.text isEqualToString:fifthTF.text]){
                [self showLocalValidationError:@"Password is not matched"];
                return NO;
            }
        }
            break;
            
        default:
            break;
    }
    
    return YES;
}

#pragma mark - IBActions

- (IBAction)actionButtonTapped:(id)sender {
    BOOL isValid = [self validateField];
    
    if(isValid){
        switch (currentPageMode) {
            case PageModeLogin:{
                NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 firstTF.text, @"login",
                                                 secondTF.text, @"password",
                                                nil];
                [self doLoginWithUserDict:jsonDict];
            }
                break;
            case PageModeRegister:{
                NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 firstTF.text, @"name",
                                                 secondTF.text, @"username",
                                                 thirdTF.text, @"email",
                                                 fouthTF.text, @"password",
                                                 nil];
                [self doRegisterWithUserDict:jsonDict];
            }
                break;
            case PageModeForgotPassword:{
                NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 firstTF.text, @"email",

                                                 nil];
                [self doResetPasswordWithUserDict:jsonDict];
                
            }
                break;
                
            default:
                break;
        }
    }
}

- (IBAction)leftButtonTapped:(id)sender {
    if(textFieldView2.hidden){
        textFieldView2.hidden = NO;
        textFieldView2.alpha = 0.0;
    }
    textFieldView3.hidden = NO;
    textFieldView4.hidden = NO;
    textFieldView5.hidden = NO;
    textFieldView3.alpha = 0.0;
    textFieldView4.alpha = 0.0;
    textFieldView5.alpha = 0.0;
    
    textButtonContainer.hidden = NO;
    textButtonContainer.alpha = 0.0;
    tfContainerHeightConstraint.constant = 260.0;
    textFieldContainerTopSpace.constant = 12;
    
    titleLabel.text = @"REGISTER";
    
    firstTF.returnKeyType = UIReturnKeyNext;
    secondTF.returnKeyType = UIReturnKeyNext;
    thirdTF.returnKeyType = UIReturnKeyNext;
    fouthTF.returnKeyType = UIReturnKeyNext;
    fifthTF.returnKeyType = UIReturnKeyDefault;
    
    firstTF.text = @"";
    secondTF.text = @"";
    thirdTF.text = @"";
    fouthTF.text = @"";
    fifthTF.text = @"";
    
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
    
    [UIView animateWithDuration:0.5 animations:^{
        if(textFieldView2.alpha ==0.0){
            textFieldView2.alpha = 1.0;
        }
        textFieldView3.alpha = 1.0;
        textFieldView4.alpha = 1.0;
        textFieldView5.alpha = 1.0;
    
        [actionButton setTitle:@"Register" forState:UIControlStateNormal];
        textButtonContainer.alpha = 1.0;
        skipButton.alpha = 0.0;
        buttonView.alpha = 0.0;
        separatorView.alpha = 0.0;
    } completion:^(BOOL finished) {
        currentPageMode = PageModeRegister;
        skipButton.hidden = YES;
        buttonView.hidden = YES;
        separatorView.hidden = YES;
        [self reloadTextField];
    }];
}

- (IBAction)rightButtonTapped:(id)sender {
    
    firstTF.returnKeyType = UIReturnKeyDefault;
    secondTF.returnKeyType = UIReturnKeyNext;
    thirdTF.returnKeyType = UIReturnKeyDefault;
    
    firstTF.text = @"";
    secondTF.text = @"";
    thirdTF.text = @"";
    
    switch (currentPageMode) {
        case PageModeLogin:{
            
            [actionButton setTitle:@"Reset Password" forState:UIControlStateNormal];
            [titleLabel setText:@"FORGOT PASSWORD"];
            tfContainerHeightConstraint.constant = 50.0;
            textFieldContainerTopSpace.constant = 12;
            [leftButton setTitle:@"Register" forState:UIControlStateNormal];
            [rightButton setTitle:@"Login" forState:UIControlStateNormal];
            currentPageMode = PageModeForgotPassword;
            [UIView animateWithDuration:0.4 animations:^{
                [self.view layoutIfNeeded];
            } completion:nil];
            
            buttonView.hidden = NO;
            [UIView animateWithDuration:0.5 animations:^{
                textFieldView2.alpha = 0.0;
                textFieldView3.alpha = 0.0;
                separatorView.alpha = 0.0;
                buttonView.alpha = 1.0;
            } completion:^(BOOL finished) {
                textFieldView2.hidden = YES;
                textFieldView3.hidden = YES;
                separatorView.hidden = YES;
                [self reloadTextField];
            }];
        }
            break;
        case PageModeForgotPassword:{
            textFieldView2.hidden = NO;
            textFieldView2.alpha = 0.0;
            separatorView.hidden = NO;
            separatorView.alpha = 0.0;
            titleLabel.text = @"LOGIN";
            [actionButton setTitle:@"Log In" forState:UIControlStateNormal];
            [leftButton setTitle:@"Register" forState:UIControlStateNormal];
            [rightButton setTitle:@"Forgot Password" forState:UIControlStateNormal];
            tfContainerHeightConstraint.constant = 100.0;
            textFieldContainerTopSpace.constant = TextFieldTopSpace;
            currentPageMode = PageModeLogin;
            [UIView animateWithDuration:0.4 animations:^{
                [self.view layoutIfNeeded];
            } completion:nil];
            
            [UIView animateWithDuration:0.5 animations:^{
                textFieldView2.alpha = 1.0;
                separatorView.alpha = 1.0;
            } completion:^(BOOL finished) {
                [self reloadTextField];
            }];
            
            
        }
            break;
        default:
            break;
    }
}

- (IBAction)skipButtonTapped:(id)sender {
    
    if(![self connected]){
        [self showAlertWithMessage:@"Tidak ada koneksi internet"];
    }else{
        [TheServerManager requestAccessTokenWithCompletion:^(NSString *accessToken) {
            [TheAppDelegate loginSuccessAndShouldDismiss:self.isPresented];
            
        } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(operation.responseData){
                [self showAlertWithMessage:error.localizedDescription];
            }
        }];
    }

}

- (IBAction)textButtonTapped:(id)sender {
    firstTF.text = @"";
    secondTF.text = @"";
    thirdTF.text = @"" ;
    
    skipButton.hidden = NO;
    buttonView.hidden = NO;
    separatorView.hidden = NO;
    tfContainerHeightConstraint.constant = 100.0;
    textFieldContainerTopSpace.constant = TextFieldTopSpace;
    titleLabel.text = @"LOGIN";
    [actionButton setTitle:@"Log In" forState:UIControlStateNormal];
    
    [rightButton setTitle:@"Forgot Password" forState:UIControlStateNormal];

    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
    [UIView animateWithDuration:0.4 animations:^{
        textFieldView3.alpha = 0.0;
        textFieldView4.alpha = 0.0;
        textFieldView5.alpha = 0.0;
        
        textButtonContainer.alpha = 0.0;
        skipButton.alpha = 1.0;
        buttonView.alpha = 1.0;
        separatorView.alpha = 1.0;
    
    } completion:^(BOOL finished) {
        currentPageMode = PageModeLogin;
        textFieldView3.hidden = YES;
        textButtonContainer.hidden = YES;
        
        [self reloadTextField];
    }];
    
}

-(void)reloadTextField{
    switch (currentPageMode) {
        case PageModeLogin:{
            [firstTF setPlaceholder:@"Username / Email"];
            secondTF.placeholder = @"Password";
            secondTF.secureTextEntry = YES;
        }
            break;
        case PageModeRegister:{
            firstTF.placeholder = @"Name";
            secondTF.placeholder = @"Username";
            secondTF.secureTextEntry = NO;
            thirdTF.placeholder = @"Email";
            thirdTF.secureTextEntry = NO;
            
        }
            break;
        case PageModeForgotPassword:{
            firstTF.placeholder = @"Email";
        }
            break;
        default:
            break;
    }
}


- (IBAction)fbLoginTapped:(id)sender {
    [self.view startLoader:YES disableUI:YES];
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[@"public_profile", @"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            NSLog(@"Process error");
            [self.view startLoader:NO disableUI:NO];
            [self showAlertWithMessage:@"Failed Login with Facebook."];

        } else if (result.isCancelled) {
            NSLog(@"Cancelled");
            [self.view startLoader:NO disableUI:NO];
            [self showAlertWithMessage:@"Login Facebook cancelled."];

        } else {
            
            NSLog(@"Logged in");
            if ([FBSDKAccessToken currentAccessToken]) {
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"email,name,first_name"}]
                 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id resulto, NSError *error) {
                     if (!error) {
                         NSLog(@"fbtoken:%@", result.token.tokenString);
                         NSLog(@"%@",resulto);
                         
                         NSMutableDictionary *jsonDict = @{@"provider" : @"facebook",
                                                           @"uid" : resulto[@"id"],
                                                           @"username" : resulto[@"id"],
                                                           @"token" : result.token.tokenString,
                                                           @"name" : resulto[@"name"],
                                                           @"email" : resulto[@"email"]
                                                           }.mutableCopy;

                         
                         [self doLoginWithUserDict:jsonDict];
                         
                     }
                 }];
            }
        }
    }];

}

#pragma mark - Login handler
-(void)doLoginWithUserDict:(NSMutableDictionary *)jsonDict{

    [User loginWithUserDictionary:jsonDict withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [self.view startLoader:NO disableUI:NO];
        [TheAppDelegate loginSuccessAndShouldDismiss:self.isPresented];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginCompletedNotification object:nil];
        
        [User registerDeviceWithSuccess:^(NSString *message) {
            [TheSettingsManager saveDayForToday];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        NSDictionary *errorDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"=======:%@",errorDict);
        
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode == StatusCodeExpired || statusCode == StatusCodeForbidden){
            [TheServerManager requestAccessTokenWithCompletion:^(NSString *accessToken) {
                if(numRequest<kRequestLimit){
                    numRequest++;
                    [self doLoginWithUserDict:jsonDict];
                } else return;
                
            } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [TheAppDelegate writeLog:error.description];
            }];
            
            
        }else if(statusCode == StatusCodeUnauthorized){
            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:nil];
                
                [self showAlertWithMessage:jsonDict[@"error"][@"messages"][0]];
            }
        }
        [self.view startLoader:NO disableUI:NO];
        WRITE_LOG(operation.HTTPRequestOperation.responseString);
    }];
}

-(void)doRegisterWithUserDict:(NSMutableDictionary *)jsonDict{
    
    [User registerWithUserDictionary:jsonDict withAccessToken:ACCESS_TOKEN() success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        
        [TheAppDelegate loginSuccessAndShouldDismiss:self.isPresented];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        if(statusCode == StatusCodeExpired || statusCode == StatusCodeForbidden){
            [TheServerManager requestAccessTokenWithCompletion:^(NSString *accessToken) {
                
                if(numRequest<kRequestLimit){
                    numRequest++;
                    [self doRegisterWithUserDict:jsonDict];
                }
                else return;
                
            } andFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [TheAppDelegate writeLog:error.description];
            }];
            
            
        }else{
            NSUInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
            if(statusCode != StatusCodeExpired && statusCode != StatusCodeForbidden && operation.HTTPRequestOperation.responseData){

                NSData *responseData = operation.HTTPRequestOperation.responseData;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:responseData //1
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
                NSString *message = json[@"error"][@"messages"][0];
                [self showLocalValidationError:message];
            }
        }
        WRITE_LOG(operation.HTTPRequestOperation.responseString);
    }];
}

-(void)doResetPasswordWithUserDict:(NSMutableDictionary *)jsonDict{
    [User resetPasswordWithUserDict:jsonDict success:^(NSString *message) {
        [self resignFirstResponder];
        [self rightButtonTapped:nil];
        [self showAlertWithMessage:message];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
    }];
}


#pragma mark - Notifications handling

-(void)handleFBSessionStateChangeWithNotification:(NSNotification *)notification{
    // Get the session, state and error values from the notification's userInfo dictionary.
//    NSDictionary *userInfo = [notification userInfo];
//    
//    FBSessionState sessionState = [[userInfo objectForKey:@"state"] integerValue];
//    NSError *error = [userInfo objectForKey:@"error"];
//    
//    // Handle the session state.
//    // Usually, the only interesting states are the opened session, the closed session and the failed login.
//    if (!error) {
//        // In case that there's not any error, then check if the session opened or closed.
//        if (sessionState == FBSessionStateOpen) {
//            // The session is open. Get the user information and update the UI.
//            FBSession *aSession = userInfo[@"session"];
//            NSString *fbToken =  aSession.accessTokenData.accessToken;
//            [FBRequestConnection startWithGraphPath:@"me"
//                                         parameters:nil
//                                         HTTPMethod:@"GET"
//                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                                      if (!error) {
//                                          // Set the use full name.
//                                          NSLog(@"fbuser: %@",result);
//                                          
//                                          NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                                                           @"facebook", @"provider",
//                                                                           result[@"id"], @"uid",
//                                                                           result[@"id"],@"username",
//                                                                           fbToken, @"token",
//                                                                           result[@"name"], @"name",
//                                                                           result[@"email"], @"email",
//                                                                           
//                                                                           nil];
//                                          [self doLoginWithUserDict:jsonDict];
//
//                                      }
//                                      else{
//                                          NSLog(@"%@", [error localizedDescription]);
//                                      }
//                                  }];
//            
//            
//            
//        }
//        else if (sessionState == FBSessionStateClosed || sessionState == FBSessionStateClosedLoginFailed){
//            // A session was closed or the login was failed or canceled. Update the UI accordingly.
//            [self.view startLoader:NO disableUI:NO];
//            [self showAlertWithMessage:@"Login Facebook Gagal."];
//        }
//    }
//    else{
//        // In case an error has occured, then just log the error and update the UI accordingly.
//        NSLog(@"Error: %@", [error localizedDescription]);
//        [self.view startLoader:NO disableUI:NO];
//        [self showAlertWithMessage:@"Login Facebook Gagal."];
//   }
}



#pragma mark - UITextFieldDelegate
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    switch (textField.tag) {
        case 1:{
            if(currentPageMode == PageModeForgotPassword){
                [textField resignFirstResponder];
//                [self actionButtonTapped:nil];
            }else{
                [secondTF becomeFirstResponder];
            }
        }
            break;
        case 2:{
            if(currentPageMode == PageModeLogin){
                [textField resignFirstResponder];
            }else{
                [thirdTF becomeFirstResponder];
            }
        }
            break;
        case 3:{
            if(currentPageMode == PageModeRegister){
                [textField resignFirstResponder];
            }
        }
            break;
            
        default:
            break;
    }
    return YES;
}

#pragma mark - keyboard action

-(void)keyboardWillShowWithRect:(CGRect)keyboardRect{
    float bottomPosition = textFieldContainer.frame.origin.y + textFieldContainer.frame.size.height;
    
    if(bottomPosition >= keyboardRect.origin.y){
        
        NSLog(@"keyboardret : %@",NSStringFromCGRect(keyboardRect));
        obstructedAreaHeight = bottomPosition - keyboardRect.origin.y;
        topMostConstraint.constant = 0;// -= obstructedAreaHeight;
        isKeyboardObstructing = YES;
        [UIView animateWithDuration:0.4 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

-(void)keyboardWillHideWithRect:(CGRect)keyboardRect{
    if(isKeyboardObstructing){
        topMostConstraint.constant = 50.0;// += obstructedAreaHeight;
        isKeyboardObstructing = NO;
        [UIView animateWithDuration:0.4 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

@end
