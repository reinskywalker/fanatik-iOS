//
//  Payment.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PaymentGroup;

@interface Payment : NSManagedObject

@property (nonatomic, retain) NSString * payment_id;
@property (nonatomic, retain) NSString * payment_logo;
@property (nonatomic, retain) NSString * payment_name;
@property (nonatomic, retain) PaymentGroup *payment_paymentgroup;

@end
