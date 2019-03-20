//
// Created by 何 义 on 14-5-24.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "AgentGuideView.h"
#import "EBViewFactory.h"
#import "EBStyle.h"

@interface AgentGuideView()
{
    UIImageView *_backgroundView;
    UIPageControl *_pageControl;
    NSArray *_guideInfo;
    UILabel *_title;
    UILabel *_subTitle;

    NSInteger _currentGuide5Index;
    UIView *_guide5SubTitleView;
    NSInteger _imageIndex;
}

@end

@implementation AgentGuideView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
       _backgroundView = [[UIImageView alloc] initWithImage:[self guideImage:@"guide1"]];
       _backgroundView.frame = CGRectMake(0, 0, [EBStyle screenWidth], [EBStyle screenHeight]);
       [self addSubview:_backgroundView];

       [self setupGuide5SubTitleView];
       [self setupLoginButtonAndPageControl:frame.size.height - 73];
       [self setupGestureRecognizer];
       [self setupTitles];

       _guideInfo = @[
               @{@"images":@[@"guide1"], @"title": NSLocalizedString(@"guide_1_title", nil), @"subtitle": NSLocalizedString(@"guide_1_subtitle", nil)},
               @{@"images":@[@"guide2"], @"title": NSLocalizedString(@"guide_2_title", nil), @"subtitle": NSLocalizedString(@"guide_2_subtitle", nil)},
               @{@"images":@[@"guide3_1", @"guide3_2"], @"title": NSLocalizedString(@"guide_3_title", nil), @"subtitle": NSLocalizedString(@"guide_3_subtitle", nil)},
               @{@"images":@[@"guide4_1", @"guide4_2"], @"title": NSLocalizedString(@"guide_4_title", nil)},
               @{@"images":@[@"guide5"], @"title": NSLocalizedString(@"guide_5_title", nil)}
       ];
    }
    return self;
}

- (void)setPage:(NSInteger)page
{
    _pageControl.currentPage = page;
    [self pageChanged];
}

- (void)setupTitles
{
    _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 58, [EBStyle screenWidth], 22)];
    _title.textAlignment = NSTextAlignmentCenter;
    _title.font = [UIFont systemFontOfSize:21.0];
    _title.textColor = [UIColor whiteColor];
    _title.backgroundColor = [UIColor clearColor];
    [self addSubview:_title];
    
    _subTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 85, [EBStyle screenWidth], 20)];
    _subTitle.textAlignment = NSTextAlignmentCenter;
    _subTitle.font = [UIFont systemFontOfSize:14.0];
    _subTitle.textColor = [UIColor whiteColor];
    _subTitle.backgroundColor = [UIColor clearColor];
    [self addSubview:_subTitle];
}

- (void)setupLoginButtonAndPageControl:(CGFloat)btnYOffset
{
    UIButton *btn = [EBViewFactory blueButtonWithFrame:CGRectMake(20, btnYOffset, [EBStyle screenWidth]-40, 43) title:NSLocalizedString(@"btn_login", nil)
                                                target:self action:@selector(loginClicked:)];
    UIImage *bgN = [[UIImage imageNamed:@"guide_btn_n"] stretchableImageWithLeftCapWidth:6 topCapHeight:1];
    UIImage *bgP = [[UIImage imageNamed:@"guide_btn_p"] stretchableImageWithLeftCapWidth:6 topCapHeight:1];
    [btn setBackgroundImage:bgN forState:UIControlStateNormal];
    [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
    [self addSubview:btn];

    CGRect pageCtrlFrame = CGRectMake(0, btnYOffset - 30, [EBStyle screenWidth], 20);
    _pageControl = [[UIPageControl alloc] initWithFrame:pageCtrlFrame];
    [_pageControl setBackgroundColor:[UIColor clearColor]];
    _pageControl.numberOfPages = 5;
    _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    [self addSubview:_pageControl];

    [_pageControl addTarget:self action:@selector(pageChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)setupGestureRecognizer
{
    UISwipeGestureRecognizer *leftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previousPage)];
    UISwipeGestureRecognizer *rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextPage)];
    leftGesture.direction = UISwipeGestureRecognizerDirectionRight;
    rightGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:leftGesture];
    [self addGestureRecognizer:rightGesture];
}

- (void)loginClicked:(UIButton *)btn
{
    
   if (self.finishGuide)
   {
       self.finishGuide();
   }
}

- (void)previousPage
{
    NSInteger currentPage = _pageControl.currentPage;
    if (currentPage == 0)
    {
        return;
    }
    _pageControl.currentPage = currentPage - 1;

   [self pageChanged];
}

- (void)nextPage
{
    NSInteger currentPage = _pageControl.currentPage;
    if (currentPage == 4)
    {
        if (self.finishGuide)
        {
            self.finishGuide();
        }
        return;
    }
    _pageControl.currentPage = currentPage + 1;

    [self pageChanged];
}

- (void)pageChanged
{
    _imageIndex = 1;
    _guide5SubTitleView.alpha = 0;

    NSDictionary *info = _guideInfo[_pageControl.currentPage];
    NSArray *images = info[@"images"];
    [UIView transitionWithView:_backgroundView
                      duration:1.0f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        _backgroundView.image = [self guideImage:[images firstObject]];
                    } completion:^(BOOL finished){
        [self updateImage:_pageControl.currentPage];
    }];

    _title.text = info[@"title"];
    _subTitle.text = info[@"subtitle"];
//    _title.frame = CGRectMake(-160, 30, 320, 20);
//    _subTitle.frame = CGRectMake(160, 50, 320, 20);
    _title.alpha = 0.0;
    _subTitle.alpha = 0.0;
    _guide5SubTitleView.frame =  CGRectMake(0, 120, [EBStyle screenWidth], 280);
    [UIView animateWithDuration:1.0f animations:^
    {
//        _title.frame = CGRectMake(0, 30, 320, 20);
//        _subTitle.frame = CGRectMake(0, 50, 320, 20);
        _subTitle.alpha = 1.0;
        _title.alpha = 1.0;
    } completion:^(BOOL finished)
    {
        if (_pageControl.currentPage == 4)
        {
            [UIView animateWithDuration:1.0 animations:^
            {
                _guide5SubTitleView.frame =  CGRectMake(0, 90, [EBStyle screenWidth], 280);
                _guide5SubTitleView.alpha = 1.0;
            } completion:^(BOOL finished){
                if (_pageControl.currentPage != 4)
                {
                    _guide5SubTitleView.alpha = 0;
                }
            }];
        }
    }];
}

- (UIImage *)guideImage:(NSString *)imageName
{
   NSString *path = [[NSBundle mainBundle]
           pathForResource:[NSString stringWithFormat:@"guide.bundle/%@@2x", imageName] ofType:@"jpg"];
   return [UIImage imageWithContentsOfFile:path];
}

- (void)updateImage:(NSInteger)page
{
    NSDictionary *info = _guideInfo[page];
    NSArray *images = info[@"images"];
    
    if (images.count > 1)
    {
        int64_t delayInSeconds = 3.0;
        if (_imageIndex == 1)
        {
            delayInSeconds = 0.5;
        }
        if (_imageIndex % 2 == 1)
        {
            delayInSeconds = 1.5;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * delayInSeconds), dispatch_get_main_queue(), ^
        {
            if (page == _pageControl.currentPage)
            {
                [UIView transitionWithView:_backgroundView
                                  duration:1.0f
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    _backgroundView.image = [self guideImage:[images objectAtIndex:_imageIndex % (images.count)]];
                                } completion:^(BOOL finished){
                                    if (finished)
                                    {
                                        _imageIndex += 1;
                                        [self updateImage:page];
                                    }
                                }];
            }
        });
    }
}

- (void)showTextsForGuide5
{
    if (_pageControl.currentPage != 4)
    {
        return;
    }

    UILabel *label = (UILabel *)[_guide5SubTitleView viewWithTag:1000 + _currentGuide5Index];
    if (label)
    {
        [UIView animateWithDuration:0.5 animations:^
        {
            label.frame = CGRectMake(90, 40 * _currentGuide5Index, 240, 40);
            label.alpha = 1.0;
        } completion:^(BOOL finished)
        {
            _currentGuide5Index++;
            [self showTextsForGuide5];
        }];
    }
}

#pragma mark -- 第五个引导图的子类标题
- (void)setupGuide5SubTitleView
{
   _guide5SubTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 120, [EBStyle screenWidth], 280)];
    _guide5SubTitleView.backgroundColor = [UIColor clearColor];
   [self addSubview:_guide5SubTitleView];
   _guide5SubTitleView.alpha = 0;

   CGFloat yOffset = 0;
   for (NSInteger i = 0; i < 7; i++)
   {
       UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(90, yOffset, 240, 40)];
       label.backgroundColor = [UIColor clearColor];
       label.font = [UIFont systemFontOfSize:16.0];
       label.textColor = [UIColor whiteColor];
       label.tag = 1000 + i;
       NSString *key = [NSString stringWithFormat:@"guide_5_subtitle%ld", i];
       label.text = NSLocalizedString(key, nil);
       [_guide5SubTitleView addSubview:label];

       UIImageView *dotView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"guide_text_lead"]];
       dotView.center = CGPointMake(-10, 20);
       [label addSubview:dotView];

       yOffset += label.frame.size.height;
   }
}

- (void)resetSubTitleView
{
    CGFloat yOffset = 30;
    for (NSInteger i = 0; i < 7; i++)
    {
        UILabel *label = (UILabel *)[_guide5SubTitleView viewWithTag:1000 + i];
        label.alpha = 0;
        label.frame = CGRectMake(90, yOffset, 240, 40);
        yOffset += label.frame.size.height;
    }

    _currentGuide5Index = 0;
}

@end