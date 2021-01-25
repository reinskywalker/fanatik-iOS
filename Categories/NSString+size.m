//
//  NSString+size.m
//
//  Created by Jefry Da Gucci on 9/7/14.
//

#import "NSString+size.h"

@implementation NSString (size)

- (CGSize)sizeOfTextWithfont:(UIFont *)font frame:(CGRect)frame{
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    CGSize maximumLabelSize = CGSizeMake(CGRectGetWidth(frame),CGFLOAT_MAX);
    
    
    CGRect textRect = [self
                       boundingRectWithSize:maximumLabelSize
                       options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
)
                       attributes:attributes
                       context:nil];
    
    CGSize labelSize = CGSizeMake(textRect.size.width, textRect.size.height);
    return labelSize;
}

- (CGSize)sizeOfTextByBoundingWidth:(CGFloat)width andFont:(UIFont *)font{

    CGRect textRect = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    
    return textRect.size;
    
}
@end
