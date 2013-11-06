//
//  UIImage+Local.m
//  LoveClasses
//
//  Created by cxz(@bitpanda) on 13-5-14.
//  Copyright (c) 2013年 cxz. All rights reserved.
//

#import "UIImage+Local.h"

@implementation UIImage (Local)

+ (UIImage *)localImageNamed:(NSString *)imageName
{
	return [[self class] localImageNamed:imageName cache:YES];
}

+ (UIImage *)localImageNamed:(NSString *)imageName cache:(BOOL)cache
{
   	if (!imageName)
	{
		return nil;
	}
    
    UIImage *image = nil;
	
	NSString *normalizedImageName = [[self class] normalizedImageName:imageName];
    
    NSString *imagePath = [@"" stringByAppendingPathComponent:normalizedImageName];
    image = [UIImage imageWithContentsOfFile:imagePath];
    
    if (!image)
    {
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    
    if (!image)
    {
        // Read from main bundle.
        image = [UIImage imageWithContentsOfFile:
                 [[NSBundle mainBundle] pathForResource:[normalizedImageName stringByDeletingPathExtension]
                                                 ofType:[normalizedImageName pathExtension]]];
    }
    
    if (!image)
    {
        //默认的
        image = [UIImage imageNamed:normalizedImageName];
    }
	
	return image;
}

+ (NSString *)normalizedImageName:(NSString *)imageName
{
	static BOOL checked = NO;
	static BOOL needsNormalizeImageName = NO;
	
	// Fix the issue of not correctly loading @2x images on iOS [4.0, 4.1).
	if (!checked &&
		[[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0f &&
		[[[UIDevice currentDevice] systemVersion] floatValue] < 4.1 &&
		[[UIScreen mainScreen] scale] == 2.0f)
	{
		needsNormalizeImageName = YES;
	}
	
	checked = YES;
	
	if (needsNormalizeImageName)
	{
		return [NSString stringWithFormat:@"%@@2x.%@", [imageName stringByDeletingPathExtension], [imageName pathExtension]];
	}
	
	return imageName;
}

//截取部分图像
-(UIImage*)getSubImage:(CGRect)rect
{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return smallImage;
}
//等比例缩放
-(UIImage*)scaleToSize:(CGSize)size
{
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
    float verticalRadio = size.height*1.0/height;
    float horizontalRadio = size.width*1.0/width;
    
    float radio = 1;
    if(verticalRadio>1 && horizontalRadio>1)
    {
        radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
    }
    else
    {
        radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
    }
    
    width = width*radio;
    height = height*radio;
    
    int xPos = (size.width - width)/2;
    int yPos = (size.height-height)/2;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(xPos, yPos, width, height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片  
    return scaledImage;
}

- (UIImage *)stretchableImageWithCapInsets:(UIEdgeInsets)capInsets
{
    if ([self respondsToSelector:@selector(resizableImageWithCapInsets:)])
    {
        return [self resizableImageWithCapInsets:capInsets];
    }
    return [self stretchableImageWithLeftCapWidth:capInsets.left topCapHeight:capInsets.top];
}

- (UIImage *)stretchableImageByCenter
{
	CGFloat leftCapWidth = floorf(self.size.width / 2);
	if (leftCapWidth == self.size.width / 2)
	{
		leftCapWidth--;
	}
	
	CGFloat topCapHeight = floorf(self.size.height / 2);
	if (topCapHeight == self.size.height / 2)
	{
		topCapHeight--;
	}
	return [self stretchableImageWithCapInsets:UIEdgeInsetsMake(topCapHeight, leftCapWidth, topCapHeight, leftCapWidth)];
	return [self stretchableImageWithLeftCapWidth:leftCapWidth
									 topCapHeight:topCapHeight];
}

- (UIImage *)stretchableImageByHeightCenter
{
	CGFloat topCapHeight = floorf(self.size.height / 2);
	if (topCapHeight == self.size.height / 2)
	{
		topCapHeight--;
	}
    return [self stretchableImageWithCapInsets:UIEdgeInsetsMake(topCapHeight, 0, topCapHeight, 0)];
	return [self stretchableImageWithLeftCapWidth:0
									 topCapHeight:topCapHeight];
}

- (UIImage *)stretchableImageByWidthCenter
{
	CGFloat leftCapWidth = floorf(self.size.width / 2);
	if (leftCapWidth == self.size.width / 2)
	{
		leftCapWidth--;
	}
    return [self stretchableImageWithCapInsets:UIEdgeInsetsMake(0, leftCapWidth, 0, leftCapWidth)];
	return [self stretchableImageWithLeftCapWidth:leftCapWidth
									 topCapHeight:0];
}
@end
