//
//  PackageHeaderTableViewCell.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "PackageHeaderTableViewCell.h"



@implementation PackageHeaderTableViewCell
@synthesize packageInfoContainerView, packageNameLabel, priceLabel, favoritLabel;

-(void)fillWithPackage:(Package *)obj andIsFavorite:(BOOL)isFavorite{
    packageInfoContainerView.layer.cornerRadius = 2.0;
    packageInfoContainerView.layer.masksToBounds= YES;
    packageInfoContainerView.layer.borderColor = [HEXCOLOR(0xdae2e2ff) CGColor];
    packageInfoContainerView.layer.borderWidth = 1.0;
    
    if(isFavorite){
        favoritLabel.hidden = NO;
        favoritLabel.layer.cornerRadius= 2.0;
        favoritLabel.layer.masksToBounds = YES;
    }else{
        favoritLabel.hidden = YES;
    }
    
    packageNameLabel.text = obj.package_name;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"id_ID"];
    [numberFormatter setLocale:locale];
    
    NSString *currency = [numberFormatter stringFromNumber:obj.package_price];
    self.priceLabel.text = [NSString stringWithFormat:@"%@,-",currency];
    
    
}

+(NSString *) reuseIdentifier{
    return NSStringFromClass([self class]);
}

@end