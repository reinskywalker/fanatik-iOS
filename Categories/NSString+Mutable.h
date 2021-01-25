//
//  NSString+Mutable.h
//  Fanatik
//
//  Created by Erick Martin on 6/6/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Mutable)

-(NSString*)stringBeforeString:(NSString*)match inString:(NSString*)string;
-(NSString*)stringAfterString:(NSString*)match inString:(NSString*)string;

@end
