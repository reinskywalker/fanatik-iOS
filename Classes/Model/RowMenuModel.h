//
//  RowMenuModel.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/18/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "BaseModel.h"

@interface RowMenuModel : BaseModel

@property(nonatomic, copy) NSString *rowMenuID;
@property(nonatomic, copy) NSString *rowMenuName;
@property(nonatomic, copy) NSString *rowMenuIconOriginal;
@property(nonatomic, copy) NSString *rowMenuIconMDPI;
@property(nonatomic, copy) NSString *rowMenuIconHDPI;
@property(nonatomic, copy) NSString *rowMenuIconXHDPI;
@property(nonatomic, copy) NSString *rowMenuIconXXHDPI;
@property(nonatomic, copy) NSString *rowMenuIconXXXHDPI;
@property(nonatomic, copy) NSString *rowMenuPage;
@property(nonatomic, copy) NSString *rowMenuParamsID;
@property(nonatomic, copy) NSString *rowMenuBadge;

@end
