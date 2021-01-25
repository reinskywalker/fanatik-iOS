//
//  MenuIcon.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MenuIcon : NSManagedObject

@property (nonatomic, retain) NSString * xxxhdpi;
@property (nonatomic, retain) NSString * xxhdpi;
@property (nonatomic, retain) NSString * xhdpi;
@property (nonatomic, retain) NSString * hdpi;
@property (nonatomic, retain) NSString * mdpi;
@property (nonatomic, retain) NSManagedObject *icon_menu;

@end
