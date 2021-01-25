//
//  Balance.h
//  Fanatik
//
//  Created by Erick Martin on 12/10/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "BaseModel.h"
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Balance : BaseModel

-(id)initWithDictionary:(NSDictionary *)jsonDict;
-(id)initWithFMResultSet:(FMResultSet *)result;
-(id)initWithCoder:(NSCoder *)decoder;
-(void)encodeWithCoder:(NSCoder *)encoder;

@property (nonatomic, assign) int balanceId;
@property (nonatomic, assign) int balanceAmount;
@property (nonatomic, copy) NSString *balanceAmountFormatted;
@property (nonatomic, copy) NSString *balanceAmountText;
@property (nonatomic, copy) NSString *balanceUID;
@property (nonatomic, copy) NSString *balanceNote;

@end