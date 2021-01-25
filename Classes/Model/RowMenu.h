//
//  RowMenu.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/13/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MenuIcon, RowMenuParam, SectionMenu;

@interface RowMenu : NSManagedObject

@property (nonatomic, retain) NSNumber * row_menu_id;
@property (nonatomic, retain) NSString * row_menu_name;
@property (nonatomic, retain) NSString * row_menu_page;
@property (nonatomic, retain) MenuIcon *row_menu_icon;
@property (nonatomic, retain) SectionMenu *row_menu_section;
@property (nonatomic, retain) RowMenuParam *row_menu_param;

@end
