//
//  UIColor+Local.m
//  LoveClasses
//
//  Created by cxz(@bitpanda) on 13-6-16.
//  Copyright (c) 2013年 cxz. All rights reserved.
//

#import "UIColor+Local.h"

@implementation UIColor (Local)

+ (UIColor *)colorWithHexRGB:(int)hexrgb
{
    CGFloat r = hexrgb & 0xFF0000 >> 16;
    CGFloat g = hexrgb & 0x00FF00 >> 8;
    CGFloat b = hexrgb & 0x0000FF >> 0;
    
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f];
}

- (BOOL)customGetHue:(CGFloat *)hue saturation:(CGFloat *)saturation brightness:(CGFloat *)brightness alpha:(CGFloat *)alpha
{
    const CGFloat* components = CGColorGetComponents(self.CGColor);
    float r = components[0];
    float g = components[1];
    float b = components[2];
    
    *alpha = CGColorGetAlpha(self.CGColor);
    
    CGFloat minRGB = MIN(r, MIN(g,b));
    CGFloat maxRGB = MAX(r, MAX(g,b));
    
    if (minRGB==maxRGB) {
        *hue = 0;
        *saturation = 0;
        *brightness = minRGB;
    } else {
        double d = (r==minRGB) ? g-b : ((b==minRGB) ? r-g : b-r);
        double h = (r==minRGB) ? 3 : ((b==minRGB) ? 1 : 5);
        *hue = (60*(h - d/(maxRGB - minRGB))) / 360.;
        *saturation = ((maxRGB - minRGB)/maxRGB);
        *brightness = maxRGB;
    }

    return YES;
}

@end
