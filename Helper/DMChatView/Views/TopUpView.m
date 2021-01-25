//
//  TopUpViewController.m
//  Fanatik
//
//  Created by Erick Martin on 12/3/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "TopUpView.h"

@interface TopUpView ()

- (IBAction)topUpButtonTapped:(id)sender;


@end

@implementation TopUpView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {

    }
    return self;
}

-(void)reloadDataWithBalance:(Balance *)currentBalance{
    [self.remainingBalanceButton setTitle:currentBalance.balanceAmountFormatted forState:UIControlStateNormal];
}

- (IBAction)topUpButtonTapped:(id)sender {
    
    NSLog(@"URL : %@/topup?access_token=%@", TheConstantsManager.baseAPI, ACCESS_TOKEN());
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/topup?access_token=%@", ConstStr(@"website_url"), ACCESS_TOKEN()]]];
    
}

@end
