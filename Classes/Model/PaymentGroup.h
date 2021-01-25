//
//  PaymentGroup.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Payment;

@interface PaymentGroup : NSManagedObject

@property (nonatomic, retain) NSString * paymentgroup_description;
@property (nonatomic, retain) NSString * paymentgroup_id;
@property (nonatomic, retain) NSString * paymentgroup_name;
@property (nonatomic, retain) NSSet *paymentgroup_payment;
@end

@interface PaymentGroup (CoreDataGeneratedAccessors)

- (void)addPaymentgroup_paymentObject:(Payment *)value;
- (void)removePaymentgroup_paymentObject:(Payment *)value;
- (void)addPaymentgroup_payment:(NSSet *)values;
- (void)removePaymentgroup_payment:(NSSet *)values;

@end
