//
//  SINavigationMenuView.h
//  NavigationMenu
//
//  Created by Ivan Sapozhnik on 2/19/13.
//  Copyright (c) 2013 Ivan Sapozhnik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SIMenuTable.h"

@protocol SINavigationMenuDelegate <NSObject>

- (void)didSelectItemAtIndex:(NSUInteger)index;

@end

@interface SINavigationMenuView : UIButton <SIMenuDelegate>

@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) CGGradientRef spotlightGradientRef;
@property (nonatomic, assign) CGFloat spotlightStartRadius;
@property (nonatomic, assign) float spotlightEndRadius;
@property (nonatomic, assign) CGPoint spotlightCenter;
@property (nonatomic, retain) UILabel *title;
@property (nonatomic, retain) UIImageView *arrow;
@property (nonatomic, assign) id <SINavigationMenuDelegate> delegate;
@property (nonatomic, retain) NSArray *items;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;
- (void)displayMenuInView:(UIView *)view;

- (UIImageView *)defaultGradient;

@end
