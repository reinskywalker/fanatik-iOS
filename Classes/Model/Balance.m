//
//  Balance.m
//  Fanatik
//
//  Created by Erick Martin on 12/10/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import "Balance.h"
@implementation Balance

-(id)initWithDictionary:(NSDictionary *)jsonDict{
    if(self=[super init]){
        self.balanceId = [self intFromJSONObject:jsonDict[@"id"]];
        self.balanceAmount = [self intFromJSONObject:jsonDict[@"amount"]];
        self.balanceAmountFormatted = [self stringFromJSONObject:jsonDict[@"amountFormatted"]];
        self.balanceAmountText = [self stringFromJSONObject:jsonDict[@"amountText"]];
        self.balanceUID = [self stringFromJSONObject:jsonDict[@"uid"]];
        self.balanceNote = [self stringFromJSONObject:jsonDict[@"note"]];
    }
    return self;
}


-(id)initWithFMResultSet:(FMResultSet *)result{
    if(self = [super init]){
        self.balanceId = [result intForColumn:@"balanceId"];
        self.balanceAmount = [result intForColumn:@"balanceAmount"];
        self.balanceAmountFormatted = [result stringForColumn:@"balanceAmountFormatted"];
        self.balanceAmountText = [result stringForColumn:@"balanceAmountText"];
        self.balanceUID = [result stringForColumn:@"balanceUID"];
        self.balanceNote = [result stringForColumn:@"balanceNote"];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)decoder{
    if(self=[super init]){
        self.balanceId = [decoder decodeIntForKey:@"balanceId"];
        self.balanceAmount = [decoder decodeIntForKey:@"balanceAmount"];
        self.balanceAmountFormatted = [decoder decodeObjectForKey:@"balanceAmountFormatted"];
        self.balanceAmountText = [decoder decodeObjectForKey:@"balanceAmountText"];
        self.balanceUID = [decoder decodeObjectForKey:@"balanceUID"];
        self.balanceNote = [decoder decodeObjectForKey:@"balanceNote"];
    }
    return self;
}


-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeInt:self.balanceId forKey:@"balanceId"];
    [encoder encodeInt:self.balanceAmount forKey:@"balanceAmount"];
    [encoder encodeObject:self.balanceAmountFormatted forKey:@"balanceAmountFormatted"];
    [encoder encodeObject:self.balanceAmountText forKey:@"balanceAmountText"];
    [encoder encodeObject:self.balanceUID forKey:@"balanceUID"];
    [encoder encodeObject:self.balanceNote forKey:@"balanceNote"];
}

@end