//
//  AlertManager.m
//  Valo
//
//  Created by Jefry Da Gucci on 9/24/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "AlertManager.h"
#import "OJRAlertViewController.h"

@implementation AlertManager

+ (AlertManager *)sharedInstance{
    static AlertManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AlertManager alloc] init];
    });
    return sharedInstance;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message{
    
    OJRAlertViewController *alertController = [OJRAlertViewController sharedInstance];
    [alertController showTextWithTitle:title detail:message titleTextColor:COLOR_HEX(sColorBlack) detailTexColor:COLOR_HEX(sColorBlack) backgroundColor:COLOR_HEX(sColorLightBlue)];
    [APPDELEGATE().window addSubview:alertController.view];
    alertController.view.alpha = 0;
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        alertController.view.alpha = 1;
    } completion:^(BOOL finished) {
        if(finished){
            [UIView animateWithDuration:0.5 delay:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
                alertController.view.alpha = 0;
            } completion:^(BOOL finished) {
                if(finished){
                    [alertController.view removeFromSuperview];
                }
            }];
        }
    }];
    
    
    
}

- (void)showAlertWithResponseData:(NSData *)responseData error:(NSError *)error{
//    NSDictionary *json = [responseData toDictionary];
//    NSString *message = @"";
//    if(json!=nil && json.allKeys.count>0){
//        NSString *message =  ([json[@"error"] isKindOfClass:[NSString class]]?json[@"error"]:@"");
//        ALERT_MANAGER_SHOW_ALERT(([json[@"status"] isKindOfClass:[NSString class]]?json[@"status"]:@""), message);
//    }
//    else if(error!=nil){
//        message = error.userInfo[@"NSLocalizedDescription"];
//        ALERT_MANAGER_SHOW_ALERT(@"Error", message);
//    }
}

- (void)showAlertWithResponseData:(NSData *)responseData{
//    NSDictionary *json = [responseData toDictionary];
//    if(json!=nil){
//        NSString *message =  ([json[@"message"] isKindOfClass:[NSString class]]?json[@"message"]:@"");
//        ALERT_MANAGER_SHOW_ALERT(([json[@"status"] isKindOfClass:[NSString class]]?json[@"status"]:@""), message);
//    }
}

@end
