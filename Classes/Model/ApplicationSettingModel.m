//
//  ApplicationInfoModel.m
//  Fanatik
//
//  Created by Erick Martin on 6/4/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ApplicationSettingModel.h"

@implementation ApplicationSettingModel
@synthesize settingStickersComment;

-(id)initWithDictionary:(NSDictionary *)jsonDict{
    if(self=[super init]){
        self.settingStickersComment = jsonDict[@"sticker_comment"];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        self.settingStickersComment = [decoder decodeBoolForKey:@"settingStickersComment"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeBool:self.settingStickersComment forKey:@"settingStickersComment"];
}

@end
