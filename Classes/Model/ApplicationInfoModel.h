//
//  ApplicationInfoModel.h
//  Fanatik
//
//  Created by Erick Martin on 6/4/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplicationInfoModel : BaseModel

@property (nonatomic, retain) NSNumber * appCurrentVersion;
@property (nonatomic, retain) NSNumber * appMinimumVersion;
@property (nonatomic, copy) NSString * appMessage;

-(id)initWithDictionary:(NSDictionary *)jsonDict;

@end
