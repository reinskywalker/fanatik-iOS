//
//  Smooth.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/24/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Live, Resolution;

@interface Smooth : NSManagedObject

@property (nonatomic, retain) NSString * smooth_url;
@property (nonatomic, retain) Resolution *smooth_resolution;
@property (nonatomic, retain) Live *smooth_live;

@end
