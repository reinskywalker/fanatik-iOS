//
//  SideMenu.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SectionMenu;

@interface SideMenu : NSManagedObject

@property (nonatomic, retain) NSSet *sidemenu_section_menus;
@end

@interface SideMenu (CoreDataGeneratedAccessors)

- (void)addSidemenu_section_menusObject:(SectionMenu *)value;
- (void)removeSidemenu_section_menusObject:(SectionMenu *)value;
- (void)addSidemenu_section_menus:(NSSet *)values;
- (void)removeSidemenu_section_menus:(NSSet *)values;

@end
