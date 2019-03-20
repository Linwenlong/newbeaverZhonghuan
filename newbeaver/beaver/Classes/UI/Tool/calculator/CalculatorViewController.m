//
//  CalculatorViewController.m
//  beaver
//
//  Created by 何 义 on 14-2-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "CalculatorViewController.h"
#import "EBViewPager.h"
#import "MortgageCalcView.h"
#import "CalcResultViewController.h"
#import "EBViewFactory.h"

@interface CalculatorViewController () <EBViewPagerDelegate, MortgageCalcViewDelegate>
{
}
@end

@implementation CalculatorViewController

- (void)loadView
{
    [super loadView];
    self.navigationItem.title = NSLocalizedString(@"loan_calculator", nil);

    UIScrollView *scrollView = [EBViewFactory pagerScrollView:NO];
    [self.view addSubview:scrollView];

    CGFloat mortgage = -1;
    if (_isOpenByTool)
    {
        mortgage = -1;
    }
    else
    {
        if (self.userInfo && self.userInfo[@"amount"]&&self.userInfo[@"mortgage"])
        {
            if ([self.userInfo[@"amount"] floatValue] == 0)
            {
                mortgage = -1;
            }
            else
            {
                mortgage = [self.userInfo[@"mortgage"] floatValue];
            }
        }
    }

    CGRect contentFrame = scrollView.bounds;
    for (NSInteger i = 0; i < 3; i++)
    {
        MortgageCalcView *calcView = [[MortgageCalcView alloc] initWithFrame:contentFrame withMortgageType:i];
        calcView.delegate = self;
        calcView.tag = 500 + i;
        [scrollView addSubview:calcView];
        contentFrame.origin.x += contentFrame.size.width;

        [calcView.mortgageHelper updateItem:EMortgageDataItemPriceUnit value:[NSString stringWithFormat:@"%d", -1]];
        [calcView.mortgageHelper updateItem:EMortgageDataItemArea value:[NSString stringWithFormat:@"%d", -1]];
        if (i == 0)
        {
            [calcView.mortgageHelper updateItem:EMortgageDataItemAmount value:[NSString stringWithFormat:@"%.0f", mortgage]];
        }
        else if (i == 1)
        {
            if (mortgage > 80.0)
            {
                [calcView.mortgageHelper updateItem:EMortgageDataItemAmount value:@"80"];
            }
            else
            {
                [calcView.mortgageHelper updateItem:EMortgageDataItemAmount value:[NSString stringWithFormat:@"%.0f", mortgage]];
            }
        }
        else if (i == 2)
        {
            if (mortgage > 80.0)
            {
                [calcView.mortgageHelper updateItem:EMortgageDataItemFundAmount value:@"80"];
                [calcView.mortgageHelper updateItem:EMortgageDataItemCommercialAmount value:[NSString stringWithFormat:@"%.0f", (mortgage - 80)]];
            }
            else
            {
                [calcView.mortgageHelper updateItem:EMortgageDataItemFundAmount value:[NSString stringWithFormat:@"%.0f", mortgage]];
                if (_isOpenByTool)
                {
                    [calcView.mortgageHelper updateItem:EMortgageDataItemCommercialAmount value:@"-1"];
                }
                else
                {
                    if (self.userInfo && self.userInfo[@"amount"]&&self.userInfo[@"mortgage"])
                    {
                        if ([self.userInfo[@"amount"] floatValue] == 0)
                        {
                            [calcView.mortgageHelper updateItem:EMortgageDataItemCommercialAmount value:@"-1"];
                        }
                        else
                        {
                            [calcView.mortgageHelper updateItem:EMortgageDataItemCommercialAmount value:@"0"];
                        }
                    }
                    else{
                        [calcView.mortgageHelper updateItem:EMortgageDataItemCommercialAmount value:@"-1"];
                    }
                }
            }
        }
    }

    scrollView.contentSize = CGSizeMake(contentFrame.size.width * 3, contentFrame.size.height);
    //Add view pager.
    EBViewPager *viewPager = [[EBViewPager alloc] initWithFrame:[EBStyle viewPagerFrame]
            pagerTitles:@[NSLocalizedString(@"calculator1", nil), NSLocalizedString(@"calculator2", nil), NSLocalizedString(@"calculator3", nil)] defaultPage:0];

    viewPager.tag = 1000;
    [self.view addSubview:viewPager];
    viewPager.delegate = self;
    viewPager.scrollView = scrollView;
    scrollView.delegate = viewPager;
}

- (void)viewDidAppear:(BOOL)animated
{
    EBViewPager *viewPager = (EBViewPager*)[self.view viewWithTag:1000];
    if (viewPager)
    {
        NSInteger currentPage = viewPager.currentPage;
        MortgageCalcView *calcView = (MortgageCalcView*)[viewPager.scrollView viewWithTag:500 + currentPage];
        if (calcView)
        {
//            [calcView checkTextViewBecomeFirst];
        }
    }
}

#pragma ViewPagerDelegate
- (void) switchToPageIndex:(NSInteger) page
{
//    [scrollView setContentOffset:CGPointMake(page * scrollView.bounds.size.width,0) animated:YES];
    EBViewPager *viewPager = (EBViewPager*)[self.view viewWithTag:1000];
    if (viewPager)
    {
        NSInteger currentPage = viewPager.currentPage;
        MortgageCalcView *calcView = (MortgageCalcView*)[viewPager.scrollView viewWithTag:500 + currentPage];
        if (calcView)
        {
//            [calcView checkTextViewBecomeFirst];
        }
    }
}

#pragma mark - MortgageCalcViewDelegate
-(void)calcView:(MortgageCalcView*)calcView showResult:(NSArray *)result
{
    CalcResultViewController *controller = [[CalcResultViewController alloc] init];
    controller.resultArray = result;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
