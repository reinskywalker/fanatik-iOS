//
//  ApplicationMenuModel.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 4/27/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "ApplicationMenuModel.h"

@implementation ApplicationMenuModel

-(id)initWithFMResultSet:(FMResultSet *)result{
    if(self = [super init]){
        self.pageID = [result intForColumn:@"pageID"];
        self.pageCode = [result objectForColumnName:@"pageCode"];
        self.pageName = [result objectForColumnName:@"pageName"];
        self.pageTitle = [result objectForColumnName:@"pageTitle"];
    }
    return self;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"pageCode: %@ | pageName: %@ | pageTitle:%@",self.pageCode, self.pageName, self.pageTitle];
}

@end
