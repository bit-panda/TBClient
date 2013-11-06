//
//  LCVars.h
//  LoveClasses
//
//  Created by cxz(@bitpanda) on 13-5-28.
//  Copyright (c) 2013年 cxz. All rights reserved.
//

#import <Foundation/Foundation.h>

//global
typedef NS_ENUM(NSInteger, ScrollDirection)
{
    ScrollDirectionBack     = -1,
    ScrollDirectionNone     = 0,
    ScrollDirectionForward  = 1
};

#define LCSTATUS_BAR_HEIGHT             20          //默认20
#define LCNAVIGATION_BAR_HEIGHT         30          //默认44
#define LCTAB_BAR_HEIGHT                48          //默认48

#define SCREEN_SIZE         [[UIScreen mainScreen] bounds].size
#define MAIN_VIEW_SIZE      CGSizeMake(SCREEN_SIZE.width, SCREEN_SIZE.height - LCSTATUS_BAR_HEIGHT - LCNAVIGATION_BAR_HEIGHT - LCTAB_BAR_HEIGHT)

#define LOADMORE_WIDTH             MAIN_VIEW_SIZE.width
#define LOADMORE_HEIGHT            35

//activity
#define ACTIVITY_FOCUS_WIDTH                MAIN_VIEW_SIZE.width
#define ACTIVITY_FOCUS_HEIGHT               160
#define ACTIVITY_NORMAL_WIDTH               MAIN_VIEW_SIZE.width
#define ACTIVITY_NORMAL_HEIGHT              100

#define ACTIVITY_FOCUS_TITLE_HEIGHT         20
#define ACTIVITY_FOCUS_CONTROL_WIDTH        100

#define ACTIVITY_FOCUS_SCROLL_OFFSET        20

#define ACTIVITY_NORMAL_IMAGE_X_PADDING     10
#define ACTIVITY_NORMAL_IMAGE_WIDTH         60
#define ACTIVITY_NORMAL_IMAGE_HEIGHT        60
#define ACTIVITY_NORMAL_TITLE_X_PADDING     85
#define ACTIVITY_NORMAL_TITLE_Y_PADDING     10
#define ACTIVITY_NORMAL_TITLE_WIDTH         210

//menu_view
#define MENU_VIEW_ALL_HEADER_HEIGHT                     30
#define MENU_VIEW_PRODUCT_HEADER_HEIGHT                 20

#define MENU_VIEW_MENU_TABLE_WIDTH                      100
#define MENU_VIEW_MENU_TABLE_CELL_HEIGHT                50
#define MENU_VIEW_PRODUCT_TABLE_CELL_HEIGHT             100

#define ORDER_HEADER_VIEW_HEIGHT          30.0f

#define TABLE_TAG_MENU          101
#define TABLE_TAG_PRODUCT       102

//about_view
#define ABOUT_LARGECARD_WIDTH           200
#define ABOUT_LARGECARD_HEIGHT          250

//push
#define LCPUSH_LAERT_VIEW_TAG              1135
