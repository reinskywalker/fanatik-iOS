//
//  MimeTypeHelper.m
//  Fanatik
//
//  Created by Teguh Hidayatullah on 9/10/15.
//  Copyright (c) 2015 Domikado. All rights reserved.
//

#import "MimeTypeHelper.h"
#import <MobileCoreServices/MobileCoreServices.h>
@implementation MimeTypeHelper
+ (NSString*) mimeTypeForFileAtPath: (NSString *) path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    // Borrowed from http://stackoverflow.com/questions/5996797/determine-mime-type-of-nsdata-loaded-from-a-file
    // itself, derived from  http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!mimeType) {
        return @"application/octet-stream";
    }
    return [NSMakeCollectable((__bridge NSString *)mimeType) autorelease];
}

@end
