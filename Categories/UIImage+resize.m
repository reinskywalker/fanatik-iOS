//
//  UIImage+resize.m
//  Fanatik
//
//  Created by Erick Martin on 3/31/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import "UIImage+resize.h"

@implementation UIImage (resize)

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
