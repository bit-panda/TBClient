//
//  SAMenuTable.m
//  NavigationMenu
//
//  Created by Ivan Sapozhnik on 2/19/13.
//  Copyright (c) 2013 Ivan Sapozhnik. All rights reserved.
//

#import "SIMenuTable.h"
#import "SIMenuCell.h"
#import "SIMenuConfiguration.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Extension.h"
#import "SICellSelection.h"

@interface SIMenuTable () {
    CGRect endFrame;
    CGRect startFrame;
    NSIndexPath *currentIndexPath;
}
@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) NSArray *items;
@end

@implementation SIMenuTable

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items
{
    self = [super initWithFrame:frame];
    if (self) {
        self.items = [NSArray arrayWithArray:items];
        
        self.layer.backgroundColor = [UIColor color:[SIMenuConfiguration mainColor] withAlpha:0.0].CGColor;
        self.clipsToBounds = YES;
        
        endFrame = self.bounds;
        startFrame = endFrame;
        startFrame.origin.y -= self.items.count*[SIMenuConfiguration itemCellHeight];
        
        self.table = [[UITableView alloc] initWithFrame:startFrame style:UITableViewStylePlain];
        self.table.delegate = self;
        self.table.dataSource = self;
        self.table.backgroundColor = [UIColor clearColor];
        self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.table.bounds.size.height, [SIMenuConfiguration menuWidth], self.table.bounds.size.height)];
        header.backgroundColor = [UIColor color:[SIMenuConfiguration itemsColor] withAlpha:[SIMenuConfiguration menuAlpha]];
        [self.table addSubview:header];

    }
    return self;
}

- (void)show
{
    [self addSubview:self.table];
    if (!self.table.tableFooterView) {
        [self addFooter];
    }
    [UIView animateWithDuration:[SIMenuConfiguration animationDuration] animations:^{
        self.layer.backgroundColor = [UIColor color:[SIMenuConfiguration mainColor] withAlpha:[SIMenuConfiguration backgroundAlpha]].CGColor;
        self.table.frame = endFrame;
        self.table.contentOffset = CGPointMake(0, [SIMenuConfiguration bounceOffset]);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:[self bounceAnimationDuration] animations:^{
            self.table.contentOffset = CGPointMake(0, 0);
        }];
    }];
}

- (void)hide
{
    __block SIMenuTable *blockself = self;
    
    [UIView animateWithDuration:[self bounceAnimationDuration] animations:^{
        blockself.table.contentOffset = CGPointMake(0, [SIMenuConfiguration bounceOffset]);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:[SIMenuConfiguration animationDuration] animations:^{
            blockself.layer.backgroundColor = [UIColor color:[SIMenuConfiguration mainColor] withAlpha:0.0].CGColor;
            blockself.table.frame = startFrame;
        } completion:^(BOOL finished) {
            SIMenuCell *cell = (SIMenuCell *)[blockself.table cellForRowAtIndexPath:blockself->currentIndexPath];
            [cell setSelected:NO withCompletionBlock:^{

            }];
            [currentIndexPath release], currentIndexPath = nil;
            [blockself removeFooter];
            [blockself.table removeFromSuperview];
            [blockself removeFromSuperview];
        }];
    }];
}

- (float)bounceAnimationDuration
{
    float percentage = 28.57;
    return [SIMenuConfiguration animationDuration]*percentage/100.0;
}

- (void)addFooter
{
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [SIMenuConfiguration menuWidth], self.table.bounds.size.height - (self.items.count * [SIMenuConfiguration itemCellHeight]))];
    self.table.tableFooterView = footer;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackgroundTap:)];
    [footer addGestureRecognizer:tap];
}

- (void)removeFooter
{
    self.table.tableFooterView = nil;
}

- (void)onBackgroundTap:(id)sender
{
    [self.menuDelegate didBackgroundTap];
}

- (void)dealloc
{
    [_items release], _items = nil;
    [_table release], _table = nil;
    self.menuDelegate = nil;
    
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SIMenuConfiguration itemCellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    SIMenuCell *cell = (SIMenuCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[SIMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.items objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentIndexPath)
    {
        [currentIndexPath release];
    }
    currentIndexPath = [indexPath retain];
    
    SIMenuCell *cell = (SIMenuCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:YES withCompletionBlock:^{
        [self.menuDelegate didSelectItemAtIndex:indexPath.row];
    }];
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SIMenuCell *cell = (SIMenuCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO withCompletionBlock:^{

    }];
}

@end
