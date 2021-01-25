//
//  SectionMenu.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RowMenu, SideMenu;

@interface SectionMenu : NSManagedObject

@property (nonatomic, retain) NSSet *section_menu_row_menus;
@property (nonatomic, retain) SideMenu *section_menu_side_menu;
@end

@interface SectionMenu (CoreDataGeneratedAccessors)

- (void)addSection_menu_row_menusObject:(RowMenu *)value;
- (void)removeSection_menu_row_menusObject:(RowMenu *)value;
- (void)addSection_menu_row_menus:(NSSet *)values;
- (void)removeSection_menu_row_menus:(NSSet *)values;

@end
