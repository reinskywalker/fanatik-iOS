//
//  FAManagedObjectRequestOperation.m
//  Fanatik
//
//  Created by Jefry Da Gucci on 4/1/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "FAManagedObjectRequestOperation.h"

@implementation FAManagedObjectRequestOperation

- (instancetype)initWithBaseURL:(NSURL *)baseURL
                        mapping:(RKEntityMapping *)requestMapping
                    pathPattern:(NSString *)pathPattern
                         params:(NSDictionary *)params
                         method:(RKRequestMethod)requestMethod
                        keyPath:(NSString *)keyPath
                timeoutInterval:(NSTimeInterval)timeoutInterval
             managedObjectStore:(RKManagedObjectStore *)managedObjectStore
                   requestBlock:(void(^)(NSMutableURLRequest *request))requestBlock{
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseURL];
    
    NSMutableURLRequest *request = [manager requestWithObject:self method:requestMethod path:pathPattern parameters:params];
    [request setTimeoutInterval:timeoutInterval];
    
    if(requestBlock){
        requestBlock(request);
    }
    
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:requestMapping
                                                 method:requestMethod
                                            pathPattern:pathPattern
                                                keyPath:keyPath
                                            statusCodes:statusCodes];
    
    [manager addResponseDescriptor:responseDescriptor];
    
    manager.managedObjectStore = managedObjectStore;
    
    FAManagedObjectRequestOperation *operation  = [[FAManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    
    operation.managedObjectContext  = managedObjectStore.persistentStoreManagedObjectContext;
    operation.managedObjectCache    = managedObjectStore.managedObjectCache;
    return operation;
}

@end
