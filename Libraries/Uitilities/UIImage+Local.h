//
//  UIImage+Local.h
//  LoveClasses
//
//  Created by cxz(@bitpanda) on 13-5-14.
//  Copyright (c) 2013年 cxz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Local)

+ (UIImage *)localImageNamed:(NSString *)imageName;
+ (UIImage *)localImageNamed:(NSString *)imageName cache:(BOOL)cache;
+ (NSString *)normalizedImageName:(NSString *)imageName;

- (UIImage *)stretchableImageWithCapInsets:(UIEdgeInsets)capInsets;
- (UIImage*)getSubImage:(CGRect)rect;
- (UIImage*)scaleToSize:(CGSize)size;
- (UIImage *)stretchableImageByCenter;
- (UIImage *)stretchableImageByHeightCenter;
- (UIImage *)stretchableImageByWidthCenter;
@end
