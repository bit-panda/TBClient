//
//  SINavigationMenuView.m
//  NavigationMenu
//
//  Created by Ivan Sapozhnik on 2/19/13.
//  Copyright (c) 2013 Ivan Sapozhnik. All rights reserved.
//

#import "SINavigationMenuView.h"
#import "QuartzCore/QuartzCore.h"
#import "SIMenuConfiguration.h"

@interface SINavigationMenuView  ()
@property (nonatomic, retain) SIMenuTable *table;
@property (nonatomic, retain) UIView *menuContainer;
@end

@implementation SINavigationMenuView

- (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        if ([self defaultGradient]) {
            
        } else {
            [self setSpotlightCenter:CGPointMake(frame.size.width/2, frame.size.height*(-1)+10)];
            [self setBackgroundColor:[UIColor clearColor]];
            [self setSpotlightStartRadius:0];
            [self setSpotlightEndRadius:frame.size.width/2];
        }
        
        frame.origin.y -= 2.0;
        self.title = [[UILabel alloc] initWithFrame:frame];
        self.title.textAlignment = NSTextAlignmentCenter;
        self.title.backgroundColor = [UIColor clearColor];
        self.title.textColor = [UIColor whiteColor];
        self.title.font = [UIFont boldSystemFontOfSize:20.0];
        self.title.shadowColor = [UIColor darkGrayColor];
        self.title.shadowOffset = CGSizeMake(0, -1);
        self.title.text = title;
        [self addSubview:self.title];
        
        self.arrow = [[UIImageView alloc] initWithImage:[SIMenuConfiguration arrowImage]];
        [self addSubview:self.arrow];
        
        [self addTarget:self action:@selector(onHandleMenuTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)displayMenuInView:(UIView *)view
{
    self.menuContainer = view;
}

#pragma mark -
#pragma mark Actions
- (void)onHandleMenuTap:(id)sender
{
    if (self.isActive)
    {
        [self onShowMenu];
    } else
    {
        [self onHideMenu];
    }
}

- (void)onShowMenu
{
    if (!self.table) {
//        UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
//        CGRect frame = mainWindow.frame;
//        frame.origin.y += self.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
        self.table = [[SIMenuTable alloc] initWithFrame:self.menuContainer.frame items:self.items];
        self.table.menuDelegate = self;
    }
    [self.menuContainer addSubview:self.table];
    [self rotateArrow:M_PI];
    [self.table show];
}

- (void)onHideMenu
{
    [self rotateArrow:0];
    [self.table hide];
}

- (void)rotateArrow:(float)degrees
{
    [UIView animateWithDuration:[SIMenuConfiguration animationDuration] delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.arrow.layer.transform = CATransform3DMakeRotation(degrees, 0, 0, 1);
    } completion:NULL];
}

#pragma mark -
#pragma mark Delegate methods
- (void)didSelectItemAtIndex:(NSUInteger)index
{
    self.isActive = !self.isActive;
    [self onHandleMenuTap:nil];
    [self.delegate didSelectItemAtIndex:index];
}

- (void)didBackgroundTap
{
    self.isActive = !self.isActive;
    [self onHandleMenuTap:nil];
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc
{
    [_items release], _items = nil;
    [_table release], _table = nil;
    [_menuContainer release], _menuContainer = nil;
    
    [super dealloc];
}


- (UIImageView *)defaultGradient
{
    return nil;
}

- (void)layoutSubviews
{
    [self.title sizeToFit];
    self.title.center = CGPointMake(self.frame.size.width/2, (self.frame.size.height-2.0)/2);
    self.arrow.center = CGPointMake(CGRectGetMaxX(self.title.frame) + [SIMenuConfiguration arrowPadding], self.frame.size.height / 2);
}

#pragma mark -
#pragma mark Handle taps
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.isActive = !self.isActive;
    CGGradientRef defaultGradientRef = [[self class] newSpotlightGradient];
    [self setSpotlightGradientRef:defaultGradientRef];
    CGGradientRelease(defaultGradientRef);
    return YES;
}
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.spotlightGradientRef = nil;
}
- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    self.spotlightGradientRef = nil;
}

#pragma mark - Drawing Override
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGGradientRef gradient = self.spotlightGradientRef;
    float radius = self.spotlightEndRadius;
    float startRadius = self.spotlightStartRadius;
    CGContextDrawRadialGradient (context, gradient, self.spotlightCenter, startRadius, self.spotlightCenter, radius, kCGGradientDrawsAfterEndLocation);
}


#pragma mark - Factory Method

+ (CGGradientRef)newSpotlightGradient
{
    size_t locationsCount = 2;
    CGFloat locations[2] = {1.0f, 0.0f,};
    CGFloat colors[12] = {0.0f,0.0f,0.0f,0.0f,
        0.0f,0.0f,0.0f,0.55f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
    CGColorSpaceRelease(colorSpace);
    
    return gradient;
}

- (void)setSpotlightGradientRef:(CGGradientRef)newSpotlightGradientRef
{
    CGGradientRelease(_spotlightGradientRef);
    _spotlightGradientRef = nil;
    
    _spotlightGradientRef = newSpotlightGradientRef;
    CGGradientRetain(_spotlightGradientRef);
    
    [self setNeedsDisplay];
}

@end
