//
//  ViewPager.h
//  beaver
//
//  Created by 何 义 on 14-2-28.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EBViewPagerDelegate <NSObject>

@required
- (void) switchToPageIndex:(NSInteger) page;
@end

@interface EBViewPager : UIView <UIScrollViewDelegate>

@property(nonatomic, weak) id<EBViewPagerDelegate>  delegate;
@property(nonatomic, assign) NSInteger currentPage;
@property(nonatomic, strong) UIScrollView *scrollView;

- (id)initWithFrame:(CGRect)frame pagerTitles:(NSArray *)titles defaultPage:(NSInteger)page;

@end
