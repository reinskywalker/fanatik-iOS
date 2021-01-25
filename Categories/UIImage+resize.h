//
//  UIImage+resize.h
//  Fanatik
//
//  Created by Erick Martin on 3/31/16.
//  Copyright © 2016 Domikado. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (resize)

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
@end
