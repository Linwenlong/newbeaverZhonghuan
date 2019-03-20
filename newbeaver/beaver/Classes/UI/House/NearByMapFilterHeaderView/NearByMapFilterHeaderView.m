//
//  NearByMapFilterHeaderView.m
//  beaver
//
//  Created by linger on 16/2/25.
//  Copyright © 2016年 eall. All rights reserved.
//

#import "NearByMapFilterHeaderView.h"
#import "EBIconLabel.h"
#import "EBSingleChoiceView.h"
#import "EBFilter.h"
#import "EBSortOrderView.h"
#import "EBStyle.h"
@interface NearByMapFilterHeaderView()
{
    NSArray *_titles;
    NSInteger _currentOpen;
    UIImage *_indicatorDown;
}

@end
@implementation NearByMapFilterHeaderView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _titles = @[NSLocalizedString(@"filter_district", nil),
                    NSLocalizedString(@"filter_price", nil),
                    NSLocalizedString(@"filter_room", nil),
                    NSLocalizedString(@"filter_area", nil)];
        
        _indicatorDown = [UIImage imageNamed:@"filter_indicator"];
        //      _indicatorUp = [_indicatorDown imageRotatedByDegrees:180];
        
        _currentOpen = -1;
        NSInteger totalCount = _titles.count - 1;
        CGFloat itemWidth = frame.size.width /(CGFloat) totalCount;
        CGFloat xOffset = 0;
        for (NSInteger i = 0; i < totalCount +1 ; i++)
        {
            if (i==0) {
                continue;
            }
            [self addBtnWith:xOffset width:itemWidth title:_titles[i] tag:i + 1];
             xOffset += itemWidth;
        }
        [self setBackgroundColor:[UIColor whiteColor]];

        
    }
    
   
    return self;
}

- (void)setFilter:(EBFilter *)filter
{
    _filter = filter;
    for (NSInteger i = 1; i < _titles.count + 1; i++)
    {
        EBIconLabel *icLabel = (EBIconLabel *)[[self viewWithTag:i] viewWithTag:99];
        [self resizeIcLabel:icLabel index:i - 1];
    }
}

- (void)addBtnWith:(CGFloat)xOffset width:(CGFloat)width title:(NSString *)title tag:(NSInteger)tag
{
  
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(xOffset, 0, width, self.frame.size.height)];
    btn.tag = tag;
    [btn addTarget:self action:@selector(headerClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    EBIconLabel *icLabel = [[EBIconLabel alloc] initWithFrame:CGRectZero];
    icLabel.imageView.image = _indicatorDown;
    icLabel.label.textColor = [EBStyle blueMainColor];
    icLabel.label.font= [UIFont systemFontOfSize:14.0];
    icLabel.label.text = title;
    icLabel.gap = 3.f;
    icLabel.maxWidth = width - 10;
    icLabel.userInteractionEnabled = NO;
    icLabel.tag = 99;
    icLabel.label.numberOfLines = 1;
    icLabel.label.lineBreakMode = NSLineBreakByTruncatingTail;
    CGRect icLabelFrame = icLabel.currentFrame;

    icLabel.frame = CGRectOffset(icLabelFrame, (width - icLabelFrame.size.width) / 2,
                                 (self.frame.size.height - icLabelFrame.size.height) / 2);

    [btn addSubview:icLabel];
    
    if (tag !=_titles.count) {
        UIImageView *separator = [[UIImageView alloc] initWithFrame:CGRectMake(width-1.0, 0, 1.0, btn.height)];
        separator.contentMode = UIViewContentModeCenter;
        separator.image = [UIImage imageNamed:@"pager_separator"];
        [btn addSubview:separator];
    }


    [self addSubview:btn];
}

- (void)headerClicked:(UIButton *)btn
{
    EBIconLabel *icLabel = (EBIconLabel *)[btn viewWithTag:99];
    NSInteger clickedIndex = btn.tag - 1;
    
    if (_currentOpen == clickedIndex)
    {
        [UIView animateWithDuration:0.25 animations:^
         {
             icLabel.imageView.transform = CGAffineTransformMakeRotation(0);
         }];
        
        //       icLabel.imageView.image = _indicatorDown;
        
        [self filterSelected:-1 deSelected:_currentOpen btn:btn];
        _currentOpen = -1;
    }
    else
    {
        EBIconLabel *oldIcLabel;
        if (_currentOpen != -1)
        {
            oldIcLabel = (EBIconLabel *)[[self viewWithTag:_currentOpen + 1] viewWithTag:99];
            //           oldIcLabel.imageView.image = _indicatorDown;
        }
        //       icLabel.imageView.image = _indicatorUp;
        
        [UIView animateWithDuration:0.25 animations:^
         {
             icLabel.imageView.transform = CGAffineTransformMakeRotation(M_PI);
             if (oldIcLabel)
             {
                 oldIcLabel.imageView.transform = CGAffineTransformMakeRotation(0);
             }
         }];
        
        [self filterSelected:clickedIndex deSelected:_currentOpen btn:btn];
        _currentOpen = clickedIndex;
    }
}

- (void)filterSelected:(NSInteger)selected deSelected:(NSInteger)deselected btn:(UIButton *)btn
{
    EBSingleChoiceView *singleChoiceView = [self singleChoiceView];
    if (selected >= 0)
    {
        if (deselected < 0)
        {
            [self showPopViewWithAnimation:singleChoiceView alignTop:NO];
        }
        
        if (selected == 0)
        {
            singleChoiceView.leftIndex = _filter.district1;
            singleChoiceView.rightIndex = _filter.district2;
        }
        else
        {
            singleChoiceView.rightIndex = [_filter choiceByIndex:selected];
//            singleChoiceView.houseType = _filter.requireOrRentalType;
        }
        singleChoiceView.title = _titles[selected];
        singleChoiceView.choices = [_filter choicesByIndex:selected];
        
        __block EBSingleChoiceView *choiceView = singleChoiceView;
        singleChoiceView.makeChoice = ^(NSInteger rightChoice, NSInteger leftChoice){
            EBIconLabel *icLabel = (EBIconLabel *)[btn viewWithTag:99];
            [UIView animateWithDuration:0.25 animations:^
             {
                 icLabel.imageView.transform = CGAffineTransformMakeRotation(0);
             }];
            _currentOpen = -1;
            [self hidePopViewWithAnimation:choiceView completion:^(){
                if (selected >= 0 && rightChoice >= 0)
                {
                    if (selected == 0)
                    {
                        if (_filter.district1 != leftChoice || _filter.district2 != rightChoice)
                        {
                            _filter.district1 = leftChoice;
                            _filter.district2 = rightChoice;
                            [_delegate filterChoiceChanged:selected];
                            [_delegate filterToSeleted:[self.filter currentArgs]];

                            [self resizeIcLabel:icLabel index:selected];
                        }
                    }
                    else
                    {
                        if ([_filter choiceByIndex:selected] != rightChoice)
                        {
                            
                            [_filter setChoice:rightChoice byIndex:selected];
                            [_delegate filterChoiceChanged:selected];
                            [_delegate filterToSeleted:[self.filter currentArgs]];

                            [self resizeIcLabel:icLabel index:selected];
                        }
                        else if (selected == 1 || selected == 3)
                        {
                            if (rightChoice == [[_filter choicesByIndex:selected] count] - 1)
                            {
                                [_filter setChoice:rightChoice byIndex:selected];
                                [_delegate filterChoiceChanged:selected];
                                [_delegate filterToSeleted:[self.filter currentArgs]];
                                [self resizeIcLabel:icLabel index:selected];
                            }
                        }
                    }
                }
                else
                {
                    
                }
            }];
        };
    }
    else
    {
        [self hidePopViewWithAnimation:singleChoiceView completion:^(){}];
    }
}

- (void)resizeIcLabel:(EBIconLabel *)icLabel index:(NSInteger)index
{
    NSString *title = [_filter titleByIndex:index];
    CGFloat itemWidth = self.frame.size.width / (_titles.count-1);
    if (title == nil)
    {
        title = _titles[index];
    }
    icLabel.label.text = title;
    CGRect icLabelFrame = icLabel.currentFrame;
    icLabelFrame.origin.x = (itemWidth - icLabelFrame.size.width) / 2;
    icLabel.frame = icLabelFrame;
    [icLabel setNeedsLayout];
}


- (EBSingleChoiceView *)singleChoiceView
{
    UIView *superView = [self superview];
    EBSingleChoiceView *singleChoiceView = (EBSingleChoiceView *)[superView viewWithTag:456];
    if (singleChoiceView == nil)
    {
        singleChoiceView = [[EBSingleChoiceView alloc] initWithFrame:CGRectMake(0, self.frame.origin.y + self.frame.size.height,
                                                                                self.frame.size.width, superView.frame.size.height - self.frame.size.height)];
        singleChoiceView.tag = 456;
        [superView addSubview:singleChoiceView];
        [superView bringSubviewToFront:singleChoiceView];
        singleChoiceView.hidden = YES;
    }
    
    //    singleChoiceView.frame = CGRectMake(0, self.frame.origin.y + self.frame.size.height,
    //            self.frame.size.width, superView.frame.size.height - self.frame.size.height);
    
    return singleChoiceView;
}

- (void)toggleSortOrderView
{
    UIView *superView = [self superview];
    EBSortOrderView *sortOrderView = (EBSortOrderView *)[superView viewWithTag:789];
    if (sortOrderView == nil)
    {
        sortOrderView = [[EBSortOrderView alloc] initWithFrame:CGRectMake(0, 0,
                                                                          self.frame.size.width, superView.frame.size.height)];
        sortOrderView.tag = 789;
        [superView addSubview:sortOrderView];
        [superView bringSubviewToFront:sortOrderView];
        
        sortOrderView.sortIndex = _filter.sortIndex - 1;
        __block EBSortOrderView *sortView = sortOrderView;
        sortOrderView.chooseSort = ^(NSInteger sortIndex){
            [self hidePopViewWithAnimation:sortView completion:^(){
                if (sortIndex >= 0 && _filter.sortIndex != sortIndex + 1)
                {
                    _filter.sortIndex = sortIndex + 1;
                    [_delegate filterChoiceChanged:-1];
                    [_delegate filterToSeleted:[self.filter currentArgs]];
                }
            }];
        };
        sortOrderView.hidden = YES;
    }
    
    if (_currentOpen != -1)
    {
        EBIconLabel *oldIcLabel = (EBIconLabel *)[[self viewWithTag:_currentOpen + 1] viewWithTag:99];
        oldIcLabel.imageView.image = _indicatorDown;
        
        [UIView animateWithDuration:0.25 animations:^
         {
             oldIcLabel.imageView.transform = CGAffineTransformMakeRotation(0);
         }];
        
        UIView *choiceView = [superView viewWithTag:456];
        if (choiceView && !choiceView.hidden)
        {
            [self hidePopViewWithAnimation:choiceView completion:nil];
        }
        _currentOpen = -1;
    }
    
    if (sortOrderView.hidden)
    {
        sortOrderView.sortIndex = _filter.sortIndex - 1;
        [self showPopViewWithAnimation:sortOrderView alignTop:YES];
        sortOrderView.orders = [EBFilter rawSortOrders];
    }
    else
    {
        [self hidePopViewWithAnimation:sortOrderView completion:nil];
    }
}

- (BOOL)dismissPopUpView
{
    UIView *superView = [self superview];
    UIView *sortView = [superView viewWithTag:789];
    UIView *choiceView = [superView viewWithTag:456];
    if (sortView && !sortView.hidden)
    {
        [self hidePopViewWithAnimation:sortView completion:nil];
        
        return YES;
    }
    
    if (choiceView && !choiceView.hidden)
    {
        if (_currentOpen != -1)
        {
            EBIconLabel *oldIcLabel = (EBIconLabel *)[[self viewWithTag:_currentOpen + 1] viewWithTag:99];
            [UIView animateWithDuration:0.25 animations:^
             {
                 oldIcLabel.imageView.transform = CGAffineTransformMakeRotation(0);
             }];
        }
        _currentOpen = -1;
        [self hidePopViewWithAnimation:choiceView completion:nil];
        return YES;
    }
    
    return NO;
}

- (void)showPopViewWithAnimation:(UIView *)view alignTop:(BOOL)alignTop
{
    CGRect displayFrame;
    
    if (alignTop)
    {
        displayFrame = CGRectMake(0, 0, self.frame.size.width, self.superview.frame.size.height);
        [self.superview bringSubviewToFront:view];
    }
    else
    {
        [self.delegate popupViewWillShow];
        [self.superview bringSubviewToFront:self];
        displayFrame = CGRectMake(0, self.frame.origin.y + self.frame.size.height, self.frame.size.width,
                                  self.superview.frame.size.height - self.frame.size.height);
    }
    view.frame = CGRectOffset(displayFrame, 0, -displayFrame.size.height);
    view.backgroundColor = [UIColor clearColor];
    view.hidden = NO;
    
    [UIView animateWithDuration:0.25 animations:^
     {
         view.frame = displayFrame;
     } completion:^(BOOL finished)
     {
         view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
     }];
}

- (void)hidePopViewWithAnimation:(UIView *)view completion:(void(^)())completion
{
    CGRect frame = view.frame;
    frame.origin.y -= frame.size.height;
    view.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.25 animations:^
     {
         view.frame = frame;
     } completion:^(BOOL finished)
     {
         view.hidden = YES;
         if (completion)
         {
             completion();
         }
     }];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    EBSingleChoiceView *singleChoiceView = [self singleChoiceView];
    if (singleChoiceView && !singleChoiceView.hidden)
    {
        CGRect displayFrame = CGRectMake(0, self.frame.origin.y + self.frame.size.height, self.frame.size.width,self.superview.frame.size.height - self.frame.size.height);
        
        [UIView animateWithDuration:0.2 animations:^
         {
             singleChoiceView.frame = displayFrame;
         } completion:^(BOOL finished)
         {
         }];
    }
}
-(void)setHouseType:(NSInteger)houseType
{
    EBSingleChoiceView *singleChoiceView = [self singleChoiceView];
    singleChoiceView.houseType = houseType;
    
}

@end
