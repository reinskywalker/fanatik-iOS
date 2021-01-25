//
//  Package.h
//  Fanatik
//
//  Created by Sulistyo Wahyu on 4/13/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Package : NSManagedObject

@property (nonatomic, retain) NSDate * package_active_at;
@property (nonatomic, retain) NSString * package_id;
@property (nonatomic, retain) NSDate * package_inactive_at;
@property (nonatomic, retain) NSString * package_name;
@property (nonatomic, retain) NSNumber * package_price;
@property (nonatomic, retain) NSString * package_expired_at;
@property (nonatomic, retain) NSString * package_renewal_id;
@property (nonatomic, retain) NSNumber * package_active;

@end
