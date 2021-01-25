//
//  FAManagedObjectRequestOperation.h
//  Fanatik
//
//  Created by Jefry Da Gucci on 4/1/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "RKManagedObjectRequestOperation.h"

@interface FAManagedObjectRequestOperation : RKManagedObjectRequestOperation

- (instancetype)initWithBaseURL:(NSURL *)baseURL
                        mapping:(RKEntityMapping *)requestMapping
                    pathPattern:(NSString *)pathPattern
                         params:(NSDictionary *)params
                         method:(RKRequestMethod)requestMethod
                        keyPath:(NSString *)keyPath
                timeoutInterval:(NSTimeInterval)timeoutInterval
             managedObjectStore:(RKManagedObjectStore *)managedObjectStore
                   requestBlock:(void(^)(NSMutableURLRequest *request))requestBlock;

@end
