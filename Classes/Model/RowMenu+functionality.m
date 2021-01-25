//
//  Menu+functionality.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 1/5/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "RowMenu+functionality.h"
#import "MenuIcon+functionality.h"
#import "RowMenuParam+functionality.h"

@implementation RowMenu (functionality)
+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];
    
    mappingEntity.identificationAttributes = [NSArray arrayWithObjects:
                                              @"row_menu_id",
                                              nil];
    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"row_menu_id", @"id",
                                       @"row_menu_name", @"name",
                                       @"row_menu_page", @"application_page",
                                       nil];
    
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    RKEntityMapping *menuIconMapping = [MenuIcon myMapping];
    RKEntityMapping *menuParamMapping = [RowMenuParam myMapping];
    
    
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"icon" toKeyPath:@"row_menu_icon" withMapping:menuIconMapping]];
    [mappingEntity addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"params" toKeyPath:@"row_menu_param" withMapping:menuParamMapping]];
    
    
    return mappingEntity;
}

+(NSSet *)mainMenuSet{
    NSSet *mainMenuSet = [NSSet setWithObjects:MenuPageHome, MenuPageTVChannel, MenuPageClub, MenuPageTimeline, MenuPageFollowing, MenuPageEventList, MenuPageNotification, MenuPageLiveChatList, MenuPageContest, MenuPageVideoCategory, MenuPageVideoCategoryDashboard, nil];
    return mainMenuSet;
}

@end
