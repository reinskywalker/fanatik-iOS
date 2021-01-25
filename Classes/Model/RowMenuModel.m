//
//  RowMenuModel.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/18/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "RowMenuModel.h"

@implementation RowMenuModel
@synthesize rowMenuID;
@synthesize rowMenuName;
@synthesize rowMenuIconOriginal;
@synthesize rowMenuIconMDPI;
@synthesize rowMenuIconHDPI;
@synthesize rowMenuIconXHDPI;
@synthesize rowMenuIconXXHDPI;
@synthesize rowMenuIconXXXHDPI;
@synthesize rowMenuPage;
@synthesize rowMenuParamsID;
@synthesize rowMenuBadge;

-(id)initWithDictionary:(NSDictionary *)jsonDict{
    if(self=[super init]){
        self.rowMenuID = jsonDict[@"id"];
        self.rowMenuName = jsonDict[@"name"];
        self.rowMenuPage = jsonDict[@"application_page"];
        
        NSDictionary *iconDict = jsonDict[@"icon"];
        self.rowMenuIconOriginal = iconDict[@"original"];
        self.rowMenuIconXHDPI = iconDict[@"xhdpi"];
        self.rowMenuIconXXHDPI = iconDict[@"xxhdpi"];
        self.rowMenuIconXXXHDPI = iconDict[@"xxxhdpi"];
        self.rowMenuIconHDPI = iconDict[@"hdpi"];
        self.rowMenuIconMDPI = iconDict[@"mdpi"];
        
        NSDictionary *paramsDict = jsonDict[@"params"];
        self.rowMenuParamsID = paramsDict[@"id"];
        self.rowMenuBadge = jsonDict[@"badge"];
    }
    return self;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"id: %@ | name: %@ | page: %@", self.rowMenuID, self.rowMenuName, self.rowMenuPage];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.rowMenuID forKey:@"id"];
    [encoder encodeObject:self.rowMenuName forKey:@"name"];
    [encoder encodeObject:self.rowMenuPage forKey:@"application_page"];
    [encoder encodeObject:self.rowMenuIconOriginal forKey:@"original"];
    [encoder encodeObject:self.rowMenuIconXHDPI forKey:@"xhdpi"];
    [encoder encodeObject:self.rowMenuIconXXHDPI forKey:@"xxhdpi"];
    [encoder encodeObject:self.rowMenuIconXXXHDPI forKey:@"xxxhdpi"];
    [encoder encodeObject:self.rowMenuParamsID forKey:@"params_id"];
    [encoder encodeObject:self.rowMenuIconHDPI forKey:@"hdpi"];
    [encoder encodeObject:self.rowMenuIconMDPI forKey:@"mdpi"];
    [encoder encodeObject:self.rowMenuBadge forKey:@"badge"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.rowMenuID = [decoder decodeObjectForKey:@"id"];
        self.rowMenuName = [decoder decodeObjectForKey:@"name"];
        self.rowMenuPage = [decoder decodeObjectForKey:@"application_page"];
        self.rowMenuIconOriginal = [decoder decodeObjectForKey:@"original"];
        self.rowMenuIconMDPI = [decoder decodeObjectForKey:@"mdpi"];
        self.rowMenuIconHDPI = [decoder decodeObjectForKey:@"hdpi"];
        self.rowMenuIconXHDPI = [decoder decodeObjectForKey:@"xhdpi"];
        self.rowMenuIconXXHDPI = [decoder decodeObjectForKey:@"xxhdpi"];
        self.rowMenuIconXXXHDPI = [decoder decodeObjectForKey:@"xxxhdpi"];
        self.rowMenuParamsID = [decoder decodeObjectForKey:@"params_id"];
        self.rowMenuBadge = [decoder decodeObjectForKey:@"badge"];
    }
    return self;
}

@end
