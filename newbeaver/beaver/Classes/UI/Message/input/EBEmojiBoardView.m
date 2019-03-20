//
//  EBEmojiBoardView.m
//  AppKeFuIMSDK
//
//  Created by jack on 13-10-19.
//  Copyright (c) 2013年 appkefu.com. All rights reserved.
//

#import "EBEmojiBoardView.h"
#import "EBStyle.h"
#import "EBCache.h"

#define  SCROLL_VIEW_WIDTH  300
#define  SCROLL_VIEW_HEIGHT 190

@implementation EBEmojiBoardView

@synthesize scrollView,pageControl,sendButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        NSDictionary *faceMap = [[EBCache sharedInstance] emojiMap];

        NSArray *emojiKeys = [faceMap allKeys];
        emojiKeys = [emojiKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2)
        {
            return [obj1 compare:obj2];
        }];

        NSInteger pageCount = emojiKeys.count / 20 + (emojiKeys.count % 20 > 0 ? 1 : 0);

        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], SCROLL_VIEW_HEIGHT)];
        scrollView.pagingEnabled = YES;
        scrollView.contentSize = CGSizeMake([EBStyle screenWidth] * pageCount, SCROLL_VIEW_HEIGHT);
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.delegate = self;
        scrollView.clipsToBounds = NO;
        [self addSubview:scrollView];

        for (int i = 0; i < pageCount; i++)
        {
            TSEmojiView *emojiView = [[TSEmojiView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width*i, 10, [UIScreen mainScreen].bounds.size.width, SCROLL_VIEW_HEIGHT)];

            NSInteger length = MIN(emojiKeys.count - i * 20, 20);
            emojiView.emojiKeys = [emojiKeys subarrayWithRange:NSMakeRange(i * 20, length)];
            emojiView.faceMap = faceMap;
            emojiView.clipsToBounds = NO;
//            emojiView.userInteractionEnabled = YES;

            emojiView.delegate=self;
            [scrollView addSubview:emojiView];
        }

        scrollView.canCancelContentTouches = NO;
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(70, 180,[EBStyle screenWidth] - 140 , 20)];
        pageControl.numberOfPages = pageCount;
        pageControl.currentPage = 0;
        [pageControl setCurrentPageIndicatorTintColor:[UIColor grayColor]];
        [pageControl setPageIndicatorTintColor:[UIColor whiteColor]];
        [pageControl addTarget:self action:@selector(turnPage) forControlEvents:UIControlEventValueChanged];
        [self addSubview:pageControl];

        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake([EBStyle screenWidth] - 70, 180, 60, 30)];
        UIEdgeInsets insets = UIEdgeInsetsMake(15, 7, 15, 7);
        [btn setBackgroundImage:[[UIImage imageNamed:@"im_btn_emoji_n"] resizableImageWithCapInsets:insets] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIImage imageNamed:@"im_btn_emoji_p"] resizableImageWithCapInsets:insets]forState:UIControlStateHighlighted];
        [btn setBackgroundImage:[[UIImage imageNamed:@"im_btn_emoji_d"] resizableImageWithCapInsets:insets]forState:UIControlStateDisabled];

        [btn setTitle:NSLocalizedString(@"im_btn_send", nil) forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateHighlighted];
        [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateDisabled];

        btn.titleLabel.font = [UIFont systemFontOfSize:14.0];

        [self addSubview:btn];

        sendButton = btn;
        [sendButton addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        //top line
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.5)];
        lineView.backgroundColor = [UIColor colorWithRed:0xcc/255.0 green:0xcc/255.0 blue:0xcc/255.0 alpha:1.0];
        [self addSubview:lineView];
    }
    return self;
}

- (void)didTouchEmojiView:(TSEmojiView *)emojiView touchedEmoji:(NSString *)string
{
    [self.delegate emojiBoardView:self didSelect:string];
}

- (void)didTouchEmojiViewBackspace:(TSEmojiView *)emojiView
{
    [self.delegate emojiBoardView:self didDelete:@""];
}

- (void)sendButtonPressed
{
    //NSLog(@"%s",__FUNCTION__);
    
    [self.delegate emojiBoardView:self didSend:@""];
    
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)lScrollView
{
    [pageControl setCurrentPage:lScrollView.contentOffset.x/320];
    [pageControl updateCurrentPageDisplay];
}

#pragma mark
-(void)turnPage
{
    NSInteger currentIndex = pageControl.currentPage;
    [scrollView scrollRectToVisible:CGRectMake(12+320*currentIndex, 12, [EBStyle screenWidth], SCROLL_VIEW_HEIGHT)
                           animated:YES];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
