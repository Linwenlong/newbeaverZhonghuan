//
//  GatherHouseAddSecondViewController.m
//  beaver
//
//  Created by wangyuliang on 14-8-29.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "GatherHouseAddSecondViewController.h"
#import "EBElementStyle.h"
#import "EBInputElement.h"
#import "EBInputView.h"
#import "EBSelectElement.h"
#import "EBSelectView.h"
#import "EBPrefixElement.h"
#import "EBPrefixView.h"
#import "EBComponentView.h"
#import "EBRegionView.h"
#import "EBRegionElement.h"
#import "EBAssociateViewController.h"
#import "EBController.h"
#import "EBFilter.h"
#import "EBHttpClient.h"
#import "EBParserContainerView.h"
#import "HouseDataSource.h"
#import "MTLJSONAdapter.h"
#import "EBHouse.h"
#import "EBAlert.h"
#import "RegexKitLite.h"
#import "EBRangeView.h"
#import "EBCache.h"
#import "EBCheckView.h"
#import "EBSelectOptionsViewController.h"
#import "EBNavigationController.h"
#import "HouseClientExistViewController.h"
#import "GatherHouseAddThirdViewController.h"
#import "ERPWebViewController.h"
@interface GatherHouseAddSecondViewController () <EBSelectViewDelegate, EBInputViewDelegate, EBCheckViewDelegate>
{
    UIScrollView *_scrollView;
    EBParserContainerView *_parserContainerView;
    
    EBSelectView *_districtSelectView;
    EBInputView *_communityInputView;
    
    EBFilter *_filter;
    
    UIToolbar *_toolbar;
    UIBarButtonItem *_previousBarButton;
    UIBarButtonItem *_nextBarButton;
    EBElementView *_currentElementView;
    EBRegionElement *_regionElement;
    
    UIButton *_openPageBtn;
    BOOL _if_start;
    NSString *_open_page_url;
    
    BOOL backAlert;
}



@end

@implementation GatherHouseAddSecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"gather_house_add_erp_title", nil);
    [self addRightNavigationBtnWithTitle:NSLocalizedString(@"nextstep", nil) target:self action:@selector(nextStep)];
    _filter = [[EBFilter alloc] init];
    _scrollView = [[UIScrollView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    [_scrollView setContentOffset:CGPointMake(0, 0)];
    [self.view addSubview:_scrollView];
    [self initViews];
    [self initToolbar];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [[EBHttpClient sharedInstance] houseRequest:@{@"relate_house_id":self.params[@"relate_house_id"], @"type": self.params[@"type"], @"purpose": self.params[@"purpose"], @"step":[NSNumber numberWithInt:2]} houseParameter:^(BOOL success, id result)
    {
        if (!success)
            return;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        [self initParserContainer:result];
        _scrollView.contentSize = CGSizeMake(_scrollView.width, _scrollView.height + 10);
        
        for (UIView *view in _parserContainerView.subviews)
        {
            if ([view isMemberOfClass:EBRegionView.class])
            {
                EBRegionElement *regionElement = (EBRegionElement *)[(EBRegionView *)view element];
                if (regionElement.count > 0)
                {
                    [self addCommunityView];
                }
                break;
            }
        }
        [_communityInputView setValueOfView:_gatherHouse.community];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private methods
- (void)initViews
{
    CGFloat dx = 30, dy = 20, height = 44.0;
    
    EBElementStyle *style = [EBElementStyle defaultStyle];
    EBSelectElement *selectElement = [EBSelectElement new];
    selectElement.placeholder = NSLocalizedString(@"house_text_district_0", nil);
    selectElement.prefix = NSLocalizedString(@"house_text_district_0", nil);
    selectElement.star = EBElementViewStarVisible;
    
    _districtSelectView = [[EBSelectView alloc] initWithStyle:CGRectMake(dx, dy, _scrollView.width-dx, height) element:selectElement style:style];
    _districtSelectView.delegate = self;
    if (_gatherHouse.district1 && _gatherHouse.district1.length > 0 && _gatherHouse.district2 && _gatherHouse.district2.length > 0)
    {
        [_districtSelectView setValueOfView:[NSString stringWithFormat:@"%@ %@", _gatherHouse.district1, _gatherHouse.district2]];
        [self updateFilter:_filter districtOne:_gatherHouse.district1 districtTwo:_gatherHouse.district2];
//        NSArray *array = [EBFilter rawDistrictChoices];
//        int i = 0;
//        for (; i < array.count; i ++)
//        {
//            if ([array[i][@"title"] isEqualToString:_gatherHouse.district1])
//            {
//                break;
//            }
//        }
//        if (i >= array.count)
//        {
//            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//            dic[@"title"] = _gatherHouse.district1;
//            dic[@"children"] = [[NSArray alloc] initWithObjects:@"不限", _gatherHouse.district2, nil];
//            NSMutableArray *oprArray = [[NSMutableArray alloc] initWithArray:array];
//            [oprArray addObject:dic];
//            [[EBCache sharedInstance] removeObjectForKey:EB_CACHE_KEY_DISTRICTS];
//            [[EBCache sharedInstance] setObject:oprArray forKey:EB_CACHE_KEY_DISTRICTS];
//            _filter.district1 = i;
//            _filter.district2 = 1;
//        }
//        else
//        {
//            _filter.district1 = i;
//            NSArray *children = array[i][@"children"];
//            int j = 0;
//            for (; j < children.count; j ++)
//            {
//                if ([children[j] isEqualToString:_gatherHouse.district2])
//                {
//                    break;
//                }
//            }
//            if (j < children.count)
//            {
//                _filter.district2 = j;
//            }
//            else
//            {
//                NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
//                newDic[@"title"] = array[i][@"title"];
//                NSMutableArray *newChildArray = [[NSMutableArray alloc] initWithArray:array[i][@"children"]];
//                [newChildArray addObject:_gatherHouse.district2];
//                NSMutableArray *newArray = [[NSMutableArray alloc] init];
//                for (int m = 0; m < array.count; m ++ )
//                {
//                    if (m != i)
//                    {
//                        [newArray addObject:array[m]];
//                    }
//                    else
//                    {
//                        [newArray addObject:newChildArray];
//                    }
//                }
//                [[EBCache sharedInstance] removeObjectForKey:EB_CACHE_KEY_DISTRICTS];
//                [[EBCache sharedInstance] setObject:newArray forKey:EB_CACHE_KEY_DISTRICTS];
//                
//                _filter.district2 = j;
//            }
//        }
    }
    [_scrollView addSubview:_districtSelectView];
    [_districtSelectView drawView];
    [_communityInputView setValueOfView:_gatherHouse.community];
    //    [_districtSelectView setValueOfView:@"不限"];
}

- (void)updateFilter:(EBFilter*)filter districtOne:(NSString*)districtOne districtTwo:(NSString*)districtTwo
{
    if (districtOne && districtOne.length > 0 && districtTwo && districtTwo.length > 0)
    {
        NSArray *array = [EBFilter rawDistrictChoices];
        int i = 0;
        for (; i < array.count; i ++)
        {
            if ([array[i][@"title"] isEqualToString:districtOne])
            {
                break;
            }
        }
        if (i >= array.count)
        {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            dic[@"title"] = districtOne;
            dic[@"children"] = [[NSArray alloc] initWithObjects:@"不限", districtTwo, nil];
            NSMutableArray *oprArray = [[NSMutableArray alloc] initWithArray:array];
            [oprArray addObject:dic];
            [[EBCache sharedInstance] removeObjectForKey:EB_CACHE_KEY_DISTRICTS];
            [[EBCache sharedInstance] setObject:oprArray forKey:EB_CACHE_KEY_DISTRICTS];
            filter.district1 = i;
            filter.district2 = 1;
        }
        else
        {
            filter.district1 = i;
            NSArray *children = array[i][@"children"];
            int j = 0;
            for (; j < children.count; j ++)
            {
                if ([children[j] isEqualToString:districtTwo])
                {
                    break;
                }
            }
            if (j < children.count)
            {
                filter.district2 = j;
            }
            else
            {
                NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
                newDic[@"title"] = array[i][@"title"];
                NSMutableArray *newChildArray = [[NSMutableArray alloc] initWithArray:array[i][@"children"]];
                [newChildArray addObject:districtTwo];
                newDic[@"children"] = newChildArray;
                NSMutableArray *newArray = [[NSMutableArray alloc] init];
                for (int m = 0; m < array.count; m ++ )
                {
                    if (m != i)
                    {
                        [newArray addObject:array[m]];
                    }
                    else
                    {
                        [newArray addObject:newDic];
                    }
                }
                [[EBCache sharedInstance] removeObjectForKey:EB_CACHE_KEY_DISTRICTS];
                [[EBCache sharedInstance] setObject:newArray forKey:EB_CACHE_KEY_DISTRICTS];
                
                filter.district2 = j;
            }
        }
    }
}

- (void)initToolbar
{
    _toolbar = [[UIToolbar alloc] init];
    _toolbar.frame = CGRectMake(0, 0, self.view.width, 44);
    // set style
    [_toolbar setBarStyle:UIBarStyleDefault];
    
    _previousBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"toolbar_previous", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonIsClicked:)];
    _nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"toolbar_next", nil)
                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonIsClicked:)];
    
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"toolbar_done", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonIsClicked:)];
    
    NSArray *barButtonItems = @[_previousBarButton, _nextBarButton, flexBarButton, doneBarButton];
    
    _toolbar.items = barButtonItems;
}

- (void)addCommunityView
{
    CGFloat dx = 30, height = 44.0;
    EBInputElement *inputElement = [EBInputElement new];
    inputElement.placeholder = NSLocalizedString(@"house_text_community_0", nil);
    inputElement.prefix = NSLocalizedString(@"house_text_community_0", nil);
    inputElement.star = EBElementViewStarVisible;
    _communityInputView = [[EBInputView alloc] initWithStyle:CGRectMake(dx, _districtSelectView.top+_districtSelectView.height, _scrollView.width-dx, height) element:inputElement style:[EBElementStyle defaultStyle]];
    [_scrollView insertSubview:_communityInputView belowSubview:_districtSelectView];
    [_communityInputView drawView];
    [_communityInputView setValueOfView:_regionElement.community];
    _communityInputView.delegate = self;
    
    _parserContainerView.frame = CGRectOffset(_parserContainerView.frame, 0, _communityInputView.height);
    
    _openPageBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, _parserContainerView.bottom +10, [EBStyle screenWidth] -40 , 40)];
    _openPageBtn.backgroundColor = [EBStyle blueMainColor];
    [_openPageBtn setTitle:@"选择房间号" forState:UIControlStateNormal];
    _openPageBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_scrollView addSubview:_openPageBtn];
    [_openPageBtn addTarget:self action:@selector(toOpenPage) forControlEvents:UIControlEventTouchUpInside];
    _openPageBtn.alpha= 0 ;
}
#pragma mark  0 上面可输入 下面不可点
- (void)toOpenPage
{
    ERPWebViewController *erpVc = [ERPWebViewController sharedInstance];
    [erpVc openWebPage:@{@"title":@"",@"url":_open_page_url}];
    [erpVc setHouse:^(NSDictionary *params) {
        NSLog(@"%@",params);
        
        EBInputView *vc0 = (EBInputView *)_parserContainerView.inputViews[0];
        EBInputView *vc1 = _parserContainerView.inputViews[1];
        EBInputView *vc2 = _parserContainerView.inputViews[2];
        vc0.inputTextField.text = params[@"block"];
        vc1.inputTextField.text = params[@"unit_name"];
        vc2.inputTextField.text = params[@"house_code"];
        
    }];
    [self.navigationController pushViewController:erpVc animated:YES];
    
}
- (void)initParserContainer:(id)result
{
    _parserContainerView = [[EBParserContainerView alloc] initWithFrame:CGRectMake(0, _districtSelectView.bottom, _scrollView.width, _scrollView.height)];
    _parserContainerView.controller = self;
    [_parserContainerView showInView:_scrollView toolbar:_toolbar];
    EBElementParser *parser = [EBElementParser new];
    parser.delegate = _parserContainerView;
    [parser parse:result[@"param"][@"base"]];
}

#pragma mark - ebelementview delegate
- (void)viewDidSelect:(EBElementView *)elementView
{
    backAlert = YES;
}

- (void)checkViewDidChanged:(EBCheckView *)checkView
{
    backAlert = YES;
}

#pragma mark - ebselectview delegate
- (void)selectViewShouldShowOptions:(EBSelectView *)selectView options:(NSArray *)options selectedIndex:(NSInteger)index
{
    backAlert = YES;
    
    if (selectView == _districtSelectView) {
        if (_gatherHouse.district1 && _gatherHouse.district1.length > 0 && _gatherHouse.district2 && _gatherHouse.district2.length > 0)
        {
            [self updateFilter:_filter districtOne:_gatherHouse.district1 districtTwo:_gatherHouse.district2];
        }
        
        __weak EBFilter *weakFilter = _filter;
        [[EBController sharedInstance] promptChoices:[_filter choicesByIndex:0] withRightChoice:_filter.district2 leftChoice:_filter.district1 title:NSLocalizedString(@"filter_district", nil) houseType:_filter.requireOrRentalType completion:^(NSInteger rightChoice, NSInteger leftChoice) {
            if ((weakFilter.district1 != leftChoice || weakFilter.district2 != rightChoice) && _communityInputView) {
                [_communityInputView setValueOfView:@""];
            }
            weakFilter.district1 = leftChoice;
            weakFilter.district2 = rightChoice;
            
//            NSDictionary *district1 = [EBFilter rawDistrictChoices][weakFilter.district1];
//            NSString *title = @"";
//            if ((weakFilter.district1 > 0) && (weakFilter.district2 > 0)) {
//                title = [NSString stringWithFormat:@"%@ %@", district1[@"title"], district1[@"children"][weakFilter.district2]];
//            }
            NSDictionary *district1 = [EBFilter rawDistrictChoices][weakFilter.district1];
            NSMutableString *title = [[NSMutableString alloc] init];
            if (weakFilter.district1 > 0) {
                [title appendString:district1[@"title"]];
            }else{
                [title appendString:@"不限"];
            }
            if (weakFilter.district2 > 0) {
                [title appendFormat:@" %@", district1[@"children"][weakFilter.district2]];
            }
            [(EBSelectElement *)selectView.element setOptions:[NSArray arrayWithObjects:title, nil]];
            [selectView setValueOfView:[NSNumber numberWithInt:0]];
            
            [self isOKtoUpView];
        }];
    } else {
        EBSelectOptionsViewController *controller = [[EBSelectOptionsViewController alloc] initWithData:selectView.element.name options:options selectedIndex:[(EBSelectElement *)selectView.element selectedIndex]];
        EBNavigationController *naviController = [[EBNavigationController alloc] initWithRootViewController:controller];
        __weak GatherHouseAddSecondViewController *weakSelf = self;
        controller.onCancel = ^{
            GatherHouseAddSecondViewController *strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }
        };
        controller.onSelect = ^(NSInteger selectedIndex) {
            //            HouseAddSecondStepViewController *strongSelf = weakSelf;
            [selectView setValueOfView:[NSNumber numberWithInteger:selectedIndex]];
        };
        if ([(EBSelectElement *)selectView.element multiSelect]) {
            controller.multiSelect = YES;
            controller.selectedIndexes = [NSMutableArray arrayWithArray:[(EBSelectElement *)selectView.element selectedIndexes]];
            controller.onMultiSelect = ^(NSArray *selectedIndexes) {
                [selectView setValueOfView:selectedIndexes];
            };
        }
        [self presentViewController:naviController animated:YES completion:^{
            
        }];
    }
}

#pragma mark - ebinputview delegate
- (void)inputViewDidBeginEditing:(EBInputView *)inputView
{
    backAlert = YES;
    
    _currentElementView = inputView;
    [self setBarButtonNeedsDisplayAtIndex:[_parserContainerView.inputViews indexOfObject:_currentElementView]];
    
    if (inputView == _communityInputView) {
        NSArray *subviews = _communityInputView.subviews;
        _scrollView.frame = [EBStyle fullScrTableFrame:NO];
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [inputView deSelect:nil];
        EBAssociateViewController *viewController = [[EBAssociateViewController alloc] init];
        if (_filter.district1 == 0)
        {
            viewController.district = @"";
            viewController.region = @"";
        }
        else if (_filter.district2 == 0)
        {
            NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
            viewController.district = district1[@"title"];
            viewController.region = @"";
        }
        else
        {
            NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
            viewController.district = district1[@"title"];
            viewController.region = district1[@"children"][_filter.district2];
        }
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.handleSelection = ^(NSString *district, NSString *region, EBCommunity *community){
            [inputView setValueOfView:community.community];
            
            _if_start =[community.if_start boolValue];
            _open_page_url = community.open_page_url;
            
            
            if (_if_start) {
                [self isOKtoDownView];
            }else{
                [self isOKtoUpView];
                
            }
            
            NSArray *districts = [EBFilter rawDistrictChoices];
            for (NSInteger i = 0; i < districts.count; i ++) {
                NSDictionary *district1 = districts[i];
                if ([community.district isEqualToString:district1[@"title"]]) {
                    _filter.district1 = i;
                    NSArray *regions = district1[@"children"];
                    for (NSInteger j = 0; j < regions.count; j ++) {
                        if ([community.region isEqualToString:regions[j]]) {
                            _filter.district2 = j;
                            break;
                        }
                    }
                    break;
                }
            }
            NSDictionary *district1 = districts[_filter.district1];
            NSMutableString *title = [[NSMutableString alloc] init];
            if (_filter.district1 > 0) {
                [title appendString:district1[@"title"]];
            }else{
                [title appendString:@"不限"];
            }
            if (_filter.district2 > 0) {
                [title appendFormat:@" %@", district1[@"children"][_filter.district2]];
            }
            
            [(EBSelectElement *)_districtSelectView.element setOptions:[NSArray arrayWithObjects:title, nil]];
            [_districtSelectView setValueOfView:[NSNumber numberWithInt:0]];
        };
        [self.navigationController pushViewController:viewController animated:NO];
    }
//    backAlert = YES;
//    
//    _currentElementView = inputView;
//    [self setBarButtonNeedsDisplayAtIndex:[_parserContainerView.inputViews indexOfObject:_currentElementView]];
//    
//    if (inputView == _communityInputView) {
//        
//        _scrollView.frame = [EBStyle fullScrTableFrame:NO];
//        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//        [inputView deSelect:nil];
//        if (_filter.district1 > 0 && _filter.district2 > 0) {
//            EBAssociateViewController *viewController = [[EBAssociateViewController alloc] init];
//            
//            if (_gatherHouse.district1 && _gatherHouse.district1.length > 0 && _gatherHouse.district2 && _gatherHouse.district2.length > 0)
//            {
//                [self updateFilter:_filter districtOne:_gatherHouse.district1 districtTwo:_gatherHouse.district2];
//            }
//            if (_filter.district1 == 0)
//            {
//                viewController.district = @"";
//                viewController.region = @"";
//            }
//            else if (_filter.district2 == 0)
//            {
//                NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
//                viewController.district = district1[@"title"];
//                viewController.region = @"";
//            }
//            else
//            {
//                NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
//                viewController.district = district1[@"title"];
//                viewController.region = district1[@"children"][_filter.district2];
//            }
//            if (_filter.district1 == 0)
//            {
//                viewController.district = @"";
//                viewController.region = @"";
//            }
//            else if (_filter.district2 == 0)
//            {
//                NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
//                viewController.district = district1[@"title"];
//                viewController.region = @"";
//            }
//            else
//            {
//                NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
//                viewController.district = district1[@"title"];
//                viewController.region = district1[@"children"][_filter.district2];
//            }
//            viewController.hidesBottomBarWhenPushed = YES;
//            viewController.handleSelection = ^(NSString *district, NSString *region, EBCommunity *community){
//                [inputView setValueOfView:community.community];
//                
//                _if_start =[community.if_start boolValue];
//                _open_page_url = community.open_page_url;
//                
//                if (_if_start) {
//                    [self isOKtoDownView];
//                }else{
//                    [self isOKtoUpView];
//                    
//                }
//            };
//            [self.navigationController pushViewController:viewController animated:NO];
//        }
//        else
//        {
//            [EBAlert alertError:NSLocalizedString(@"pl_input_district", nil)];
//        }
//    }
}

#pragma mark -
#pragma next step btn action
- (void)nextStep
{
    [_currentElementView deSelect:nil];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.params];
    params = [self setReqParams:params];
    if (!params) {
        return;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self doneButtonIsClicked:nil];
    
    [EBAlert showLoading:nil];
    __weak GatherHouseAddSecondViewController *weakSelf = self;
    [[EBHttpClient sharedInstance] houseRequest:params houseValidate:^(BOOL success, id result) {
        [EBAlert hideLoading];
        GatherHouseAddSecondViewController *strongSelf = weakSelf;
        strongSelf.navigationItem.rightBarButtonItem.enabled = YES;
        
        if (!success) {
            return;
        }
        NSArray *tmparr = result[@"validate"][@"houses"];
        if (tmparr.count > 0) {
            HouseClientExistViewController *controller = [HouseClientExistViewController new];
            controller.data = result;
            controller.title = self.navigationItem.title;
            controller.goon = ^(void) {
                GatherHouseAddSecondViewController *strongSelf = weakSelf;
                [strongSelf doNextStep:params];
            };
            [strongSelf.navigationController pushViewController:controller animated:YES];
        } else {
            //            BOOL canContinue = (BOOL)result[@"validate"][@"can_continue"];
            NSNumber *number = (NSNumber*)result[@"validate"][@"can_continue"];
            BOOL canContinue = [number boolValue];
            if (canContinue) {
                [strongSelf doNextStep:params];
            }
        }
    }];
}
#pragma mark  if_start 为0 上面可点。   为1 下面可点
- (void)isOKtoUpView
{
    for (EBInputView *vc in _parserContainerView.inputViews) {
        vc.userInteractionEnabled =YES;
        vc.inputTextField.text = @"";
    }
    _openPageBtn.alpha = 0;
    
}
- (void)isOKtoDownView
{
    for (EBInputView *vc in _parserContainerView.inputViews) {
        vc.userInteractionEnabled =NO;
        vc.inputTextField.text = @"";
    }
    _openPageBtn.alpha = 1;
}
- (void)doNextStep:(NSDictionary *)params
{
    GatherHouseAddThirdViewController *controller = [GatherHouseAddThirdViewController new];
    controller.params = [NSDictionary dictionaryWithDictionary:params];
    controller.gatherHouse = _gatherHouse;
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (BOOL)validateElementView:(EBElementView *)view
{
    if ([view element].required)
    {
        if ([view isKindOfClass:EBPrefixView.class]) {
            EBPrefixElement *prefixElement = (EBPrefixElement *)[(EBPrefixView *)view element];
            if ([view respondsToSelector:@selector(valid)] && ![view valid]) {
                [EBAlert alertError:[NSString stringWithFormat:NSLocalizedString(@"house_add_alert_text_3", nil), prefixElement.prefix ? prefixElement.prefix : prefixElement.suffix]];
                return NO;
            }
            if ([view respondsToSelector:@selector(matchRegex)] && ![view matchRegex]) {
                [EBAlert alertError:[NSString stringWithFormat:NSLocalizedString(@"house_add_alert_text_4", nil), prefixElement.prefix ? prefixElement.prefix : prefixElement.suffix]];
                return NO;
            }
            if ([view isKindOfClass:EBRangeView.class] && ![[[(EBRangeView *)view minInputView] valueOfView] isEqualToString:@""] && ![[[(EBRangeView *)view maxInputView] valueOfView] isEqualToString:@""]) {
                CGFloat min = [[[(EBRangeView *)view minInputView] valueOfView] floatValue];
                CGFloat max = [[[(EBRangeView *)view maxInputView] valueOfView] floatValue];
                if (min > max) {
                    EBRangeView *rangeView = (EBRangeView*)view;
                    NSString *suffix = [(EBPrefixElement*)rangeView.maxInputView.element suffix];
                    [EBAlert alertError:[NSString stringWithFormat:@"%@不应该是从%f%@到%f%@", prefixElement.prefix ? prefixElement.prefix : prefixElement.suffix, min, suffix, max ,suffix]];
                    return NO;
                }
            }
        } else {
            if ([[view valueOfView] isEqualToString:@""]) {
                [EBAlert alertError:[NSString stringWithFormat:NSLocalizedString(@"house_add_alert_text_3", nil), @""]];
                return NO;
            } else if ([view respondsToSelector:@selector(matchRegex)] && ![view matchRegex]) {
                [EBAlert alertError:[NSString stringWithFormat:NSLocalizedString(@"house_add_alert_text_4", nil), @""]];
                return NO;
            }
        }
    }
    else
    {
        if ([view isKindOfClass:EBPrefixView.class]) {
            EBPrefixElement *prefixElement = (EBPrefixElement *)[(EBPrefixView *)view element];
            if ([view isKindOfClass:EBRangeView.class] && ![[[(EBRangeView *)view minInputView] valueOfView] isEqualToString:@""] && ![[[(EBRangeView *)view maxInputView] valueOfView] isEqualToString:@""]) {
                CGFloat min = [[[(EBRangeView *)view minInputView] valueOfView] floatValue];
                CGFloat max = [[[(EBRangeView *)view maxInputView] valueOfView] floatValue];
                if (min > max) {
                    EBRangeView *rangeView = (EBRangeView*)view;
                    NSString *suffix = [(EBPrefixElement*)rangeView.maxInputView.element suffix];
                    [EBAlert alertError:[NSString stringWithFormat:@"%@不应该是从%f%@到%f%@", prefixElement.prefix ? prefixElement.prefix : prefixElement.suffix, min, suffix, max , suffix]];
                    return NO;
                }
            }
        }
    }
    
    return YES;
}



- (NSMutableDictionary *)setReqParams:(NSMutableDictionary *)params
{
    if (_districtSelectView&& [[_districtSelectView valueOfView] isEqualToString:@""]) {
        if (_districtSelectView.element.required)
        {
            [EBAlert alertError:NSLocalizedString(@"pl_input_district", nil)];
            return nil;
        }
    }
    if (_communityInputView && [[_communityInputView valueOfView] isEqualToString:@""]) {
        if (_communityInputView.element.required)
        {
            [EBAlert alertError:NSLocalizedString(@"pl_input_community", nil)];
            return nil;
        }
    }
    
    //    if ([[_districtSelectView valueOfView] isEqualToString:@""]) {
    //        [EBAlert alertError:NSLocalizedString(@"house_add_alert_text_2", nil)];
    //        return;
    //    }
    
    for (UIView *view in _parserContainerView.subviews) {
        if ([view isKindOfClass:EBElementView.class] && [(EBElementView *)view element].visible) {
            if ([view isMemberOfClass:EBComponentView.class]) {
                for (UIView *subview in view.subviews) {
                    if ([subview isKindOfClass:EBElementView.class] && ![self validateElementView:(EBElementView *)subview]) {
                        return nil;
                    }
                }
            } else {
                if (![self validateElementView:(EBElementView *)view]) {
                    return nil;
                }
            }
        }
    }
    
    if (_gatherHouse.district1 && _gatherHouse.district1.length > 0 && _gatherHouse.district2 && _gatherHouse.district2.length > 0)
    {
        [self updateFilter:_filter districtOne:_gatherHouse.district1 districtTwo:_gatherHouse.district2];
    }
    
    NSString *district = @"", *region = @"";
    if (_filter.district1 > 0) {
        NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
        district = district1[@"title"];
        if (_filter.district2 > 0) {
            region = district1[@"children"][_filter.district2];
        }
    }
    //    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.params];
    [params addEntriesFromDictionary:@{@"district": district, @"region": region, @"community": (_communityInputView ? [_communityInputView valueOfView] : @"")}];
    
    for (UIView *view in _parserContainerView.subviews) {
        if ([view isKindOfClass:EBElementView.class] && [(EBElementView *)view element].visible) {
            if ([view isMemberOfClass:EBComponentView.class]) {
                for (UIView *subview in view.subviews) {
                    if ([subview isKindOfClass:EBElementView.class]) {
                        [params setObject:[(EBElementView *)subview valueOfView] forKey:[(EBElementView *)subview element].eid];
                    }
                }
            } else {
                [params setObject:[(EBElementView *)view valueOfView] forKey:[(EBElementView *)view element].eid];
            }
        }
    }
    return params;
}

#pragma mark - private method

- (void)doneButtonIsClicked:(id)sender
{
    [_currentElementView deSelect:nil];
}

- (void)nextButtonIsClicked:(id)sender
{
    NSInteger tagIndex = [_parserContainerView.inputViews indexOfObject:_currentElementView];
    EBElementView *textField =  [_parserContainerView.inputViews objectAtIndex:++tagIndex];
    while (!textField.element.visible) {
        textField = [_parserContainerView.inputViews objectAtIndex:++tagIndex];
    }
    
    [textField onSelect:nil];
}

- (void)previousButtonIsClicked:(id)sender
{
    NSInteger tagIndex = [_parserContainerView.inputViews indexOfObject:_currentElementView];
    
    EBElementView *textField =  [_parserContainerView.inputViews objectAtIndex:--tagIndex];
    while (!textField.element.visible) {
        textField = [_parserContainerView.inputViews objectAtIndex:--tagIndex];
    }
    
    [textField onSelect:nil];
}

- (void)setBarButtonNeedsDisplayAtIndex:(NSInteger)index
{
    if (_parserContainerView.inputViews.count == 1) {
        _previousBarButton.enabled = NO;
        _nextBarButton.enabled = NO;
        return;
    }
    if (index == 0) {
        _previousBarButton.enabled = NO;
        _nextBarButton.enabled = YES;
    } else if (index == _parserContainerView.inputViews.count-1) {
        _previousBarButton.enabled = YES;
        _nextBarButton.enabled = NO;
    } else {
        _previousBarButton.enabled = YES;
        _nextBarButton.enabled = YES;
    }
}

#pragma mark - back popup
- (BOOL)shouldPopOnBack
{
    return YES;
}

@end
