//
//  PaymentMethodTableViewCell.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentMethodTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *paymentImageView;
@property (strong, nonatomic) IBOutlet CustomRegularLabel *paymentNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *checkBoxButton;
@property (nonatomic, assign) BOOL isChecked;
@property (strong, nonatomic) IBOutlet UIImageView *gradationOverlay;
@property (nonatomic, assign) BOOL isFirstRow;

+(NSString *)reuseIdentifier;
-(void)fillWithPayment:(Payment *)payment andIsChecked:(BOOL)checked andIsFirstRow:(BOOL)firstRow;

@end
