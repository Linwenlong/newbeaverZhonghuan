//
//  EBShowingView.m
//  beaver
//
//  Created by 凯文马 on 15/12/15.
//  Copyright © 2015年 eall. All rights reserved.
//

#import "EBShowingView.h"
#import "UIImage+Alpha.h"
#import "UIButton+WebCache.h"

@interface EBShowingView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) NSTimer *timer;

@end


@implementation EBShowingView

- (instancetype)init
{
    if (self = [super init]) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)initView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:scrollView];
    _scrollView = scrollView;
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.hidesForSinglePage = YES;
    _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    [self addSubview:_pageControl];
}

- (void)setCurrentPage:(NSUInteger)currentPage
{
    [self setCurrentPage:currentPage withAnimation:NO];
}

- (void)setCurrentPage:(NSUInteger)currentPage withAnimation:(BOOL)animation
{
    _currentPage = currentPage;
    [_pageControl setCurrentPage:currentPage];
    // TODO: 切换
}

# pragma mark - public setting

- (void)setImages:(NSArray *)images
{
    if (!images || !images.count) {
        images = @[[UIImage imageNamed:@"work_home_up_holder"]];
    };
    _images = images;
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat width = self.width;
    CGFloat height = self.height;
    for (NSInteger i = 0; i < images.count + 2; i++) {
        UIImage *image = images[(i - 1) % images.count];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i * width, 0, width, height)];
        if ([image isKindOfClass:[NSString class]]) {
            [btn sd_setBackgroundImageWithURL:[NSURL URLWithString:(NSString *)image] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"work_home_up_holder"] completed:^(UIImage *aimage, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [btn setBackgroundImage:[aimage imageByApplyingAlpha:0.4f] forState:UIControlStateHighlighted];
            }];
        } else {
            [btn setBackgroundImage:image forState:UIControlStateNormal];
            [btn setBackgroundImage:[image imageByApplyingAlpha:0.4f] forState:UIControlStateHighlighted];
        }
        [btn addTarget:self action:@selector(imageBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(stopTimer) forControlEvents:UIControlEventTouchDown];
        [btn addTarget:self action:@selector(startTimer) forControlEvents:UIControlEventTouchCancel];
        [_scrollView addSubview:btn];
    }
    _scrollView.contentSize = CGSizeMake((images.count + 2) * width, 0);
    self.pageControl.numberOfPages = images.count;
    self.pageControl.currentPage = 0;
}

- (void)addImage:(UIImage *)image
{
    NSMutableArray *temp = [self.images mutableCopy];
    [temp addObject:image];
    self.images = [temp copy];
}

- (void)setPageTintColor:(UIColor *)pageTintColor
{
    _pageTintColor = pageTintColor;
    _pageControl.pageIndicatorTintColor = pageTintColor;
}

- (void)setPageCurrentTintColor:(UIColor *)pageCurrentTintColor
{
    _pageCurrentTintColor = pageCurrentTintColor;
    _pageControl.pageIndicatorTintColor = pageCurrentTintColor;
}

- (NSUInteger)totalPage
{
    return self.pageControl.numberOfPages;
}

- (void)setAutoScrollInterval:(CGFloat)autoScrollInterval
{
    if (_autoScrollInterval != autoScrollInterval) {
        _autoScrollInterval = autoScrollInterval;
        // 先停止
        [self stopTimer];
        // 再开启
        [self startTimer];
    }
}

# pragma mark - timer
- (void)startTimer
{
    if (!self.timer && _autoScrollInterval >= 0.3f) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:_autoScrollInterval target:self selector:@selector(timeActions) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timeActions
{
    if (_scrollView.contentOffset.x + self.width >= _scrollView.contentSize.width) {
        _scrollView.contentOffset = CGPointMake(self.width, 0);
        _pageControl.currentPage = 1;
    }
    [UIView animateWithDuration:.3f animations:^{
        CGPoint temp = _scrollView.contentOffset;
        temp.x += self.width;
        _scrollView.contentOffset = temp;
    } completion:^(BOOL finished) {
        
    }];
}

# pragma mark - base setting

- (void)layoutSubviews
{
    [super layoutSubviews];
    // 调整视图位置
    _scrollView.frame = self.bounds;
    _pageControl.width = self.width;
    _pageControl.height = 10.f;
    _pageControl.top = self.height - 20.f;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    _scrollView.backgroundColor = backgroundColor;
}

# pragma mark - private method

- (void)imageBtnAction:(UIButton *)sender
{
    NSUInteger index = sender.tag;
    if (self.selectAction) {
        self.selectAction(index);
    }
    if ([self.delegate respondsToSelector:@selector(showingView:didSelectImageAtIndex:)]) {
        [self.delegate showingView:self didSelectImageAtIndex:index];
    }
    [self startTimer];
}

# pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.timer) {
        if (scrollView.contentOffset.x  + self.width >= scrollView.contentSize.width) {
            scrollView.contentOffset = CGPointMake(self.width, 0);
        }
        if (scrollView.contentOffset.x < self.width) {
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x + self.totalPage * self.width, 0);
        }
    }
    NSUInteger index = (NSUInteger)(scrollView.contentOffset.x / self.width - 0.5f + 1) % self.images.count;
    _pageControl.currentPage = index;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self startTimer];
}
@end
