//
//  UIImage+ColorHelper.m
//  VideoPlayerView
//
//  Created by Sam Lau on 4/29/15.
//  Copyright (c) 2015 Sam Lau. All rights reserved.
//

#import "UIImage+ColorHelper.h"

@implementation UIImage (ColorHelper)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
