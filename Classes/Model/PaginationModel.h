//
//  PaginationWrapper.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 12/29/14.
//  Copyright (c) 2014 Domikado. All rights reserved.
//

#import "BaseModel.h"

@interface PaginationModel : BaseModel

@property(nonatomic, assign) int prevPage;
@property(nonatomic, assign) int nextPage;
@property(nonatomic, copy) NSString *firstURL;
@property(nonatomic, copy) NSString *prevURL;
@property(nonatomic, copy) NSString *nextURL;
@property(nonatomic, copy) NSString *lastURL;

@property(nonatomic, assign) int currentPage;
@property(nonatomic, assign) int totalPage;
@property(nonatomic, assign) int totalEntries;

-(id)initWithDictionary:(NSDictionary *)jsonDict;
@end
