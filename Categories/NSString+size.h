//
//  NSString+size.h
//
//  Created by Jefry Da Gucci on 9/7/14.
//

#import <Foundation/Foundation.h>

@interface NSString (size)

- (CGSize)sizeOfTextWithfont:(UIFont *)font frame:(CGRect)frame;
- (CGSize)sizeOfTextByBoundingWidth:(CGFloat)width andFont:(UIFont *)font;

@end
