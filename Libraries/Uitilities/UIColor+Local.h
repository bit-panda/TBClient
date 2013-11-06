//
//  UIColor+Local.h
//  LoveClasses
//
//  Created by cxz(@bitpanda) on 13-6-16.
//  Copyright (c) 2013年 cxz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Local)
+ (UIColor *)colorWithHexRGB:(int)hexrgb;
- (BOOL)customGetHue:(CGFloat *)hue saturation:(CGFloat *)saturation brightness:(CGFloat *)brightness alpha:(CGFloat *)alpha;
@end
