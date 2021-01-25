//
//  SideMenu.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "SideMenu.h"
#import "SectionMenu+functionality.h"


@implementation SideMenu

@dynamic sidemenu_section_menus;

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    RKEntityMapping *sectionMenuMapping = [SectionMenu myMapping];
    
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"" toKeyPath:@"side_menu_section_menus" withMapping:sectionMenuMapping]];
    return mappingEntity;
}

@end
