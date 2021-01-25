//
//  StickerCategory.h
//  Fanatik
//
//  Created by Erick Martin on 11/26/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Sticker.h"

@interface StickerCategory : BaseModel

-(id)initWithDictionary:(NSDictionary *)jsonDict;
-(id)initWithFMResultSet:(FMResultSet *)result;
-(id)initWithCoder:(NSCoder *)decoder;
-(void)encodeWithCoder:(NSCoder *)encoder;

@property (nonatomic, assign) int stickerCategoryId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSDate *visible_at;
@property (nonatomic, retain) NSDate *enable_at;
@property (nonatomic, retain) NSMutableArray *stickerArray;

@end