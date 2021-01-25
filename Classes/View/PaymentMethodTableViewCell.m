//
//  PaymentMethodTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "PaymentMethodTableViewCell.h"

@implementation PaymentMethodTableViewCell

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

-(void)fillWithPayment:(Payment *)payment andIsChecked:(BOOL)checked andIsFirstRow:(BOOL)firstRow{
    self.isChecked = checked;
    if(firstRow){
        self.gradationOverlay.hidden = NO;
    }else{
        self.gradationOverlay.hidden = YES;
    }
    self.paymentImageView.image = nil;
    [self.paymentImageView sd_setImageWithURL:[NSURL URLWithString:payment.payment_logo]];
    self.paymentNameLabel.text = payment.payment_name;
    if(self.isChecked){
        [self.checkBoxButton setImage:[UIImage imageNamed:@"blueCheckBoxOn"] forState:UIControlStateNormal];
    }else {
        [self.checkBoxButton setImage:[UIImage imageNamed:@"blueCheckBoxOff"] forState:UIControlStateNormal];
    }
}

//- (IBAction)checkBoxTapped:(id)sender {
//    if(self.isChecked){
//        [self.checkBoxButton setImage:[UIImage imageNamed:@"blueCheckBoxOn"] forState:UIControlStateNormal];
//    }else {
//        [self.checkBoxButton setImage:[UIImage imageNamed:@"blueCheckBoxOff"] forState:UIControlStateNormal];
//    }
//    self.isChecked = !self.isChecked;
//
//}
@end
