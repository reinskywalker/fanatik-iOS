//
//  ApplicationInfoModel.m
//  Fanatik
//
//  Created by Erick Martin on 6/4/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ApplicationInfoModel.h"

@implementation ApplicationInfoModel
@synthesize appCurrentVersion, appMinimumVersion, appMessage;

-(id)initWithDictionary:(NSDictionary *)jsonDict{
    if(self=[super init]){
        self.appCurrentVersion = jsonDict[@"current"];
        self.appMinimumVersion = jsonDict[@"minimum"];
        self.appMessage = jsonDict[@"message"];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        self.appCurrentVersion = [decoder decodeObjectForKey:@"appCurrentVersion"];
        self.appMinimumVersion = [decoder decodeObjectForKey:@"appMinimumVersion"];
        self.appMessage = [decoder decodeObjectForKey:@"appMessage"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.appCurrentVersion forKey:@"appCurrentVersion"];
    [encoder encodeObject:self.appMinimumVersion forKey:@"appMinimumVersion"];
    [encoder encodeObject:self.appMessage forKey:@"appMessage"];
}

@end
