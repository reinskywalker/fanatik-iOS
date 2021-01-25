//
//  UserUploads+functionality.m
//  Fanatik
//
//  Created by Erick Martin on 6/10/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "AWSRequestObject+functionality.h"

@implementation AWSRequestObject (functionality)

+(RKEntityMapping *)myMapping{
    RKEntityMapping *mappingEntity = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:TheDatabaseManager.managedObjectStore];

    NSMutableDictionary *dictEntity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"aws_host", @"host",
                                       @"aws_bucket_name", @"bucket_name",
                                       @"aws_path", @"path",
                                       @"aws_filename", @"filename",
                                       nil];
    [mappingEntity addAttributeMappingsFromDictionary:dictEntity];
    
    return mappingEntity;
}

@end
