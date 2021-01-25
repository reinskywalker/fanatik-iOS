//
//  PaginationWrapper.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "PaginationModel.h"

@implementation PaginationModel

-(id)initWithDictionary:(NSDictionary *)jsonDict{
    if(self = [super initWithDictionary:jsonDict]){
        self.prevPage = [jsonDict[@"prev_page"] intValue];
        self.nextPage = [jsonDict[@"next_page"] intValue];
        self.currentPage = [jsonDict[@"current_page"] intValue];
        self.totalEntries = [jsonDict[@"total_entries"] intValue];
        self.totalPage = [jsonDict[@"total_page"] intValue];
        self.firstURL = jsonDict[@"first_url"];
        self.lastURL = jsonDict[@"last_url"];
        self.nextURL = jsonDict[@"next_url"];
        self.prevURL = jsonDict[@"prev_url"];
        
    }
    return self;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"curPage: %d | nextPage: %d | totalPage: %d",self.currentPage, self.nextPage, self.totalPage];
}

@end
