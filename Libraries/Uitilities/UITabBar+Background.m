//
//  UITabBar+Background.m
//  LoveClasses
//
//  Created by cxz(@bitpanda) on 13-5-15.
//  Copyright (c) 2013年 cxz. All rights reserved.
//

#import "UITabBar+Background.h"
#import "UIImage+Local.h"


@implementation UITabBar (Background)

+ (void)useCustomBackgroundImageForAllTabBars
{
	// iOS 5的导航背景条.
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0
	if ([UITabBar conformsToProtocol:@protocol(UIAppearance)])
	{
		UIImage *image = [UIImage localImageNamed:@"tab_bar_background.png"];
		[[UITabBar appearance] setBackgroundImage:image];
//        [[UITabBar appearance] setSelectionIndicatorImage:[UIImage localImageNamed:@"tab_icon_shadow.png"]];
        [[UITabBar appearance] setSelectedImageTintColor:[UIColor yellowColor]];
        [[UITabBar appearance] setTintColor:[UIColor lightGrayColor]];
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont systemFontOfSize:14.0f],UITextAttributeFont,
                                    [UIColor lightGrayColor], UITextAttributeTextColor,
                                    [UIColor grayColor], UITextAttributeTextShadowColor,
                                    [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                    nil];
        
        [[UITabBarItem appearance] setTitleTextAttributes: dictionary forState:UIControlStateNormal];
        
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont systemFontOfSize:14.0f],UITextAttributeFont,
                                    [UIColor whiteColor], UITextAttributeTextColor,
                                    [UIColor grayColor], UITextAttributeTextShadowColor,
                                    [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                    nil];
        
        [[UITabBarItem appearance] setTitleTextAttributes: dictionary forState:UIControlStateHighlighted];
        
#if __IPHONE_6_0 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
        if ([UITabBar instancesRespondToSelector:@selector(setShadowImage:)])
        {
            // Disable the shadow on iOS 6.
            [[UITabBar appearance] setShadowImage:[[[UIImage alloc] init] autorelease]];
        }
#endif
	}
#endif
}

- (void)customColor
{

}

- (void)drawRect:(CGRect)rect{

    UIImage *backgroundImage = [UIImage localImageNamed:@"tab_bar_background.png"];
    
    [backgroundImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(self.frame.size.width, 44);
}

@end
