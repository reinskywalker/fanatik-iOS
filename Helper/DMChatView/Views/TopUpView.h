//
//  TopUpViewController.h
//  Fanatik
//
//  Created by Erick Martin on 12/3/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Balance.h"

@interface TopUpView : UIView
@property (strong, nonatomic) IBOutlet CustomSemiBoldButton *remainingBalanceButton;


- (IBAction)topUpButtonTapped:(id)sender;
-(void)reloadDataWithBalance:(Balance*)currBalance;

@end
