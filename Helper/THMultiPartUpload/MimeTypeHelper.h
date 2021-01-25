//
//  MimeTypeHelper.h
//  Fanatik
//
//  Created by Teguh Hidayatullah on 9/10/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MimeTypeHelper : NSObject
+ (NSString*) mimeTypeForFileAtPath: (NSString *) path;
@end
