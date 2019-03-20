//
//  ViewPager.m
//  beaver
//
//  Created by 何 义 on 14-2-28.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBViewPager.h"
#import "EBStyle.h"

@interface EBViewPager()
{
    NSInteger _totalPage;
    CGFloat _horizontalOffset;
}
@end

@implementation EBViewPager

#define PAGER_SEPARATOR_WIDTH 1.0f
#define PAGER_CURSOR_TAG 99

- (id)initWithFrame:(CGRect)frame pagerTitles:(NSArray *)titles defaultPage:(NSInteger)page
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // label
        _totalPage = titles.count;
        CGFloat itemWidth = frame.size.width /(CGFloat) _totalPage;
        CGFloat xOffset = 0;
        CGFloat separatorWidth = (frame.size.width - (_totalPage - 1 ) * PAGER_SEPARATOR_WIDTH) / _totalPage;
        for (NSInteger i = 0; i < _totalPage; i++)
        {
            [self addPagerLabelWithTitle:[titles objectAtIndex:i] index:i xOffset:xOffset width:itemWidth];
            if (i < _totalPage - 1)
            {
                [self addSeparator:separatorWidth * (i + 1) + i * PAGER_SEPARATOR_WIDTH];
            }
            xOffset += itemWidth;
        }

        _currentPage = page;
        CGFloat cursorHeight = [EBStyle viewPagerCursorHeight];
        // cursor
        UIView *cursorView = [[UIView alloc] initWithFrame:CGRectMake(_currentPage * itemWidth,
                frame.size.height - cursorHeight, itemWidth, cursorHeight)];
//        _horizontalOffset =
//        cursorView.backgroundColor = AppMainColor(1);     // 4a7cc8
        cursorView.backgroundColor = UIColorFromRGB(0xff3800);     // 4a7cc8
        cursorView.tag = PAGER_CURSOR_TAG;
        [self addSubview:cursorView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(cursorView.frame), kScreenW , 1)];

        lineView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.00];     // 4a7cc8
    
        [self addSubview:lineView];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:tapGestureRecognizer];
//        [self setBackgroundColor:AppMainColor(0.8)];
        [self setBackgroundColor:[UIColor whiteColor]];
         }
    return self;
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    [self.scrollView setContentOffset:CGPointMake(_currentPage * _scrollView.bounds.size.width,0) animated:NO];
}

- (void)setDelegate:(id <EBViewPagerDelegate>)delegate
{
    _delegate = delegate;
    [_delegate switchToPageIndex:_currentPage];
}

- (void) tapped:(UITapGestureRecognizer *) tapGestureRecognizer
{
    CGPoint locationInView = [tapGestureRecognizer locationInView:self];
    CGFloat width = self.bounds.size.width;

    CGFloat itemWidth = width / _totalPage;
    NSInteger nextPage = (NSInteger) locationInView.x / itemWidth;

    [self setCurrentPage:nextPage];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    if (_scrollView == nil)
    {
        _currentPage = currentPage;
        _horizontalOffset = self.frame.size.width * _currentPage;
        [self setNeedsLayout];
        [_delegate switchToPageIndex:_currentPage];
    }
    else
    {
        [_scrollView setContentOffset:CGPointMake(currentPage * self.scrollView.bounds.size.width,0) animated:YES];
    }
}

- (void) layoutSubviews
{
    UIView *cursor = [self viewWithTag:PAGER_CURSOR_TAG];
    CGRect frame = cursor.frame;
    frame.origin.x = _horizontalOffset / _totalPage;
    cursor.frame = frame;
}

#pragma mark UIScrollViewDelegate protocol implementation.

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    _horizontalOffset = scrollView.contentOffset.x;
    [self setNeedsLayout];

    NSInteger nextPage = (NSInteger) _horizontalOffset / self.frame.size.width;
    if (nextPage != _currentPage)
    {
        _currentPage = nextPage;
        [_delegate switchToPageIndex:_currentPage];
    }
}

- (void)addPagerLabelWithTitle:(NSString *)title index:(NSInteger)idx xOffset:(CGFloat)xStart width:(CGFloat)width
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xStart, 0.0, width ,self.frame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:UIColorFromRGB(0xff3800)];
    [label setText:title];
    [label setFont:[UIFont systemFontOfSize:15.0]];
    label.tag = idx + 1;
    [self addSubview:label];
}

- (void)addSeparator:(CGFloat)xOffset
{
    UIImageView *separator = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, 0, PAGER_SEPARATOR_WIDTH, self.frame.size.height)];
    separator.contentMode = UIViewContentModeCenter;
    separator.image = [UIImage imageNamed:@"pager_separator"];
    [self addSubview:separator];
}

@end
