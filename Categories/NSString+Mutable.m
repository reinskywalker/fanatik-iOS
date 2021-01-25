//
//  NSString+Mutable.m
//  Fanatik
//
//  Created by Erick Martin on 6/6/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "NSString+Mutable.h"

@implementation NSString (Mutable)


-(NSString*)stringBeforeString:(NSString*)match inString:(NSString*)string
{
    if ([string rangeOfString:match].location != NSNotFound)
    {
        NSString *preMatch;
        
        NSScanner *scanner = [NSScanner scannerWithString:string];
        [scanner scanUpToString:match intoString:&preMatch];
        
        return preMatch;
    }
    else
    {
        return string;
    }
}

-(NSString*)stringAfterString:(NSString*)match inString:(NSString*)string
{
    if ([string rangeOfString:match].location != NSNotFound)
    {
        NSScanner *scanner = [NSScanner scannerWithString:string];
        
        [scanner scanUpToString:match intoString:nil];
        
        NSString *postMatch;
        
        if(string.length == scanner.scanLocation)
        {
            postMatch = [string substringFromIndex:scanner.scanLocation];
        }
        else
        {
            postMatch = [string substringFromIndex:scanner.scanLocation + match.length];
        }
        
        return postMatch;
    }
    else
    {
        return string;
    }
}

@end
