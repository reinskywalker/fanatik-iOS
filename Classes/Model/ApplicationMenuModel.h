//
//  ApplicationMenuModel.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 4/27/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "BaseModel.h"

@interface ApplicationMenuModel : BaseModel

@property(nonatomic, assign) int pageID;
@property(nonatomic, copy) NSString *pageCode;
@property(nonatomic, copy) NSString *pageName;
@property(nonatomic, copy) NSString *pageTitle;

@end
