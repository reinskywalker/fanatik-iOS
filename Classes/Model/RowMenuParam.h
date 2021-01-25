//
//  RowMenuParam.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 2/13/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RowMenu;

@interface RowMenuParam : NSManagedObject

@property (nonatomic, retain) NSString * rowmenuparam_id;
@property (nonatomic, retain) RowMenu *rowmenuparam_row_menu;

@end
