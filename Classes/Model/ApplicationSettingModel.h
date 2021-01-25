//
//  ApplicationInfoModel.h
//  Fanatik
//
//  Created by Erick Martin on 6/4/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplicationSettingModel : BaseModel

@property (nonatomic, assign) BOOL settingStickersComment;

-(id)initWithDictionary:(NSDictionary *)jsonDict;

@end
