//
//  NSMutableDictionary+Encoding.h
//  Fanatik
//
//  Created by Erick Martin on 12/17/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Encoding)

-(void)dictionaryByReplacingNullsWithStrings;
-(void)removeUnusedCharacterInDictionary;
-(NSDictionary *)removeUnusedCharacterAndNull;
@end
