//
//  NSDictionary+QueryString.h
//  Fanatik
//
//  Created by Erick Martin on 12/15/15.
//  Copyright © 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSDictionary (UrlEncoding)

-(NSString*) urlEncodedString;

@end