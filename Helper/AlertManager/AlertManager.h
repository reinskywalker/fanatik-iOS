//
//  AlertManager.h
//  Valo
//
//  Created by Jefry Da Gucci on 9/24/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertManager : NSObject

#define ALERT_MANAGER_INSTACE() ([AlertManager sharedInstance])
+ (AlertManager *)sharedInstance;

#define ALERT_MANAGER_SHOW_ALERT(aTitle, aMessage) ([ALERT_MANAGER_INSTACE() showAlertWithTitle:aTitle message:aMessage])
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;


#define ALERT_MANAGER_SHOW_ALERT_RESPONSE_ERROR(responseData, error) ([ALERT_MANAGER_INSTACE() showAlertWithResponseData:responseData error:error])
- (void)showAlertWithResponseData:(NSData *)responseData error:(NSError *)error;

#define ALERT_MANAGER_SHOW_ALERT_RESPONSE(responseData) ([ALERT_MANAGER_INSTACE() showAlertWithResponseData:responseData])
- (void)showAlertWithResponseData:(NSData *)responseData;

@end
