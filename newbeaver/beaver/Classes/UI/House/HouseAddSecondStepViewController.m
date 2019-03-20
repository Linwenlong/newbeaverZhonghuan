//
//  HouseAddSecondStepViewController.m
//  beaver
//
//  Created by LiuLian on 7/30/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "HouseAddSecondStepViewController.h"
#import "HouseAddViewController.h"
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
#import "HouseClientExistViewController.h"
#import "EBCache.h"
#import "HouseDetailViewController.h"
#import "EBSelectOptionsViewController.h"
#import "EBNavigationController.h"
#import "ERPWebViewController.h"

#import "HouseRoomCodeViewController.h"

@interface HouseAddSecondStepViewController () <EBSelectViewDelegate, EBInputViewDelegate, EBCheckViewDelegate>
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
    int _if_start;
    NSString *_open_page_url;
    
    BOOL backAlert;
     //LWL
    NSNumber  *community_id;//小区id
    NSNumber  *district_id;//行政区
    NSNumber  *region_id;//片区
    
    BOOL _if_lock;//是否锁定
    
    //楼盘信息
    NSInteger floor;//当前楼层
    NSInteger lists;//梯
    NSInteger rooms;//户
    NSInteger totle_floor;//总楼层
    
    //户型 面积
   
    NSInteger bedrooms;//室
    NSInteger sittingrooms;//厅
    NSInteger bathrooms;//卫
    NSInteger balconies;//阳台
    
    NSString *gross_area;//面积
   
    
}

@property (nonatomic, copy) NSNumber *document_id;//room_id

@end

@implementation HouseAddSecondStepViewController

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
    //初始化
    _document_id = @0;
    _if_start = 3;
    
    community_id = [NSNumber numberWithInteger: [_house.community_id integerValue]];
    region_id = [NSNumber numberWithInteger: [_house.region_id integerValue]];
    district_id = [NSNumber numberWithInteger: [_house.district_id integerValue]];
    _open_page_url = [NSString stringWithFormat:@"/appopen/chooseHouseCode?community_id=%@&purpose=%@",_house.community_id,self.purpose];
    NSLog(@"_open_page_url=%@",_open_page_url);
    // Do any additional setup after loading the view.
    self.navigationItem.title = [NSString stringWithFormat:@"%@-%@", NSLocalizedString(@"house", nil), self.params[@"purpose"]];
    
    if (self.editFlag) {
        [self addRightNavigationBtnWithTitle:NSLocalizedString(@"save", nil) target:self action:@selector(endEdit)];
    } else {
        [self addRightNavigationBtnWithTitle:@"下一步" target:self action:@selector(nextStep)];
    }
    
    _filter = [[EBFilter alloc] init];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    [_scrollView setContentOffset:CGPointMake(0, 0)];
    
    [self.view addSubview:_scrollView];
    
    [self initViews];
    [self initToolbar];
    
    CGRect frame = _scrollView.frame;
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (self.editFlag) {
        self.navigationItem.title = NSLocalizedString(@"house_edit_basic_title", nil);
        
        NSString *type = self.house.rentalState == EHouseRentalTypeRent ? @"rent" : @"sale";
        NSDictionary *params = @{@"house_id": self.house.id, @"type": type, @"chunk":[NSNumber numberWithInt:2]};
        
        __weak EBFilter *weakFilter = _filter;
        [[EBHttpClient sharedInstance] houseRequest:params houseEdit:^(BOOL success, id result) {
            if (success) {
                self.navigationItem.rightBarButtonItem.enabled = YES;
                
                [self initParserContainer:result];
                _scrollView.contentSize = CGSizeMake(_scrollView.width, _scrollView.height + 10);
                
                for (UIView *view in _parserContainerView.subviews) {
                    if ([view isMemberOfClass:EBRegionView.class]) {
//                        NSString *text = [(EBPrefixElement *)[(EBPrefixView *)view element] text];
//                        NSArray *arr = [text componentsSeparatedByString:@";"];
//                        [(EBSelectElement *)_districtSelectView.element setOptions:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@ %@", arr[0], arr[1]], nil]];
//                        [_districtSelectView setValueOfView:[NSNumber numberWithInt:0]];
//                        [_communityInputView setValueOfView:arr[2]];
                        _regionElement = (EBRegionElement *)[(EBRegionView *)view element];
                        NSArray *choices = [weakFilter choicesByIndex:0];
                        NSInteger lIndex = 0, rIndex = 0;
                        if ( _regionElement.district.length == 0 || _regionElement.region.length == 0) {
                            lIndex = 0;
                        }
                        else
                        {
                            for (NSDictionary *lDic in choices) {
                                if ([(NSString *)lDic[@"title"] isEqualToString:_regionElement.district]) {
                                    for (NSString *str in lDic[@"children"]) {
                                        if ([str isEqualToString:_regionElement.region]) {
                                            break;
                                        }
                                        rIndex++;
                                    }
                                    break;
                                }
                                lIndex++;
                            }
                        }
                        
                        if (lIndex == choices.count) {
                            lIndex = 0;
                        }
                        weakFilter.district1 = lIndex;
                        weakFilter.district2 = rIndex;
                        
                        NSDictionary *district1 = [EBFilter rawDistrictChoices][weakFilter.district1];
                        if (rIndex >= [(NSArray *)district1[@"children"] count]) {
                            rIndex = 0;
                            weakFilter.district2 = rIndex;
                        }
                        NSString *title = @"";
                        if (weakFilter.district1 > 0 && weakFilter.district2 > 0) {
                            title = district1[@"title"];
                            if (weakFilter.district2 > 0) {
                                title = [title stringByAppendingFormat:@" %@", district1[@"children"][weakFilter.district2]];
                            }
                        }
                        
                        [(EBSelectElement *)_districtSelectView.element setOptions:[NSArray arrayWithObjects:title, nil]];
                        [_districtSelectView setValueOfView:[NSNumber numberWithInt:0]];
                        
                        if (_regionElement.count > 0) {
                            [self addCommunityView];
                        }
                        
                        break;
                    }
                }
            } else {
            }
        }];
    } else {
        [[EBHttpClient sharedInstance] houseRequest:@{@"type": self.params[@"type"], @"purpose": self.params[@"purpose"], @"step":[NSNumber numberWithInt:2]} houseParameter:^(BOOL success, id result) {
            if (!success) {
                return;
            }
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
            [self initParserContainer:result];
            _scrollView.contentSize = CGSizeMake(_scrollView.width, _scrollView.height + 10);
            
            for (UIView *view in _parserContainerView.subviews) {
                if ([view isMemberOfClass:EBRegionView.class]) {
                    //                        NSString *text = [(EBPrefixElement *)[(EBPrefixView *)view element] text];
                    //                        NSArray *arr = [text componentsSeparatedByString:@";"];
                    //                        [(EBSelectElement *)_districtSelectView.element setOptions:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@ %@", arr[0], arr[1]], nil]];
                    //                        [_districtSelectView setValueOfView:[NSNumber numberWithInt:0]];
                    //                        [_communityInputView setValueOfView:arr[2]];
                    EBRegionElement *regionElement = (EBRegionElement *)[(EBRegionView *)view element];
                    if (regionElement.count > 0) {
                        [self addCommunityView];
                    }
                    
                    break;
                }
            }
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)initViews
{
    CGFloat dx = 25, dy = 20, height = 44.0;
    
    EBElementStyle *style = [EBElementStyle defaultStyle];
    EBSelectElement *selectElement = [EBSelectElement new];
    selectElement.placeholder = NSLocalizedString(@"house_text_district_0", nil);
    selectElement.prefix = NSLocalizedString(@"house_text_district_0", nil);
    selectElement.star = EBElementViewStarVisible;
    
    _districtSelectView = [[EBSelectView alloc] initWithStyle:CGRectMake(dx, dy, _scrollView.width-dx, height) element:selectElement style:style];
    _districtSelectView.delegate = self;
    [_scrollView addSubview:_districtSelectView];
    [_districtSelectView drawView];
//    [_districtSelectView setValueOfView:@"不限"];
}

- (void)addCommunityView
{
    CGFloat dx = 25, height = 44.0;
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

    if (_house.if_start == YES) {
//        _openPageBtn.alpha = 1 ;
        [self isOKtoDownView];
    }else{
         [self isOKtoUpView];
//        _openPageBtn.alpha = 0 ;
    }
   
}
#pragma mark  0 上面可输入 下面不可点
- (void)toOpenPage
{
    //lwl
//    HouseRoomCodeViewController *houseRoomCode = [[HouseRoomCodeViewController alloc]init];
//    houseRoomCode.hidesBottomBarWhenPushed = YES;
//     [self.navigationController pushViewController:houseRoomCode animated:YES];
    ERPWebViewController *erpVc = [ERPWebViewController sharedInstance];
    NSLog(@"_open_page_url=%@",_open_page_url);
    [erpVc openWebPage:@{@"title":@"",@"url":_open_page_url}];
    [erpVc setHouse:^(NSDictionary *params) {
        NSLog(@"%@",params);
        _if_lock = [params[@"if_lock"] integerValue];
        //判断房号是否锁定
        floor = [params[@"extra_floor"] integerValue];//当前楼层
        lists = [params[@"extra_lists"] integerValue];//梯
        rooms = [params[@"extra_rooms"] integerValue];//户
        totle_floor = [params[@"extra_total_floor_num"] integerValue];//总楼层
        
        //楼盘锁定
        bedrooms = [params[@"bedrooms"] integerValue];//室
        sittingrooms = [params[@"sittingrooms"] integerValue];//厅
        bathrooms = [params[@"bathrooms"] integerValue];//卫
        balconies = [params[@"balconies"] integerValue];//阳台
        gross_area = [NSString stringWithFormat:@"%@",params[@"gross_area"]];
        if ([params.allKeys containsObject:@"document_id"]) {
            _document_id = params[@"document_id"];
        }else{
            _document_id = @0;
        }
        
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
        __weak EBFilter *weakFilter = _filter;
//        NSMutableArray *dataArray = [[_filter choicesByIndex:0] mutableCopy];
//        NSArray *arrayM = [self dataFactory:dataArray];
        
        [[EBController sharedInstance] promptChoices:[_filter choicesByIndex:0] withRightChoice:_filter.district2 leftChoice:_filter.district1 title:NSLocalizedString(@"filter_district", nil) houseType:_filter.requireOrRentalType hidezero:NO completion:^(NSInteger rightChoice, NSInteger leftChoice) {
            if ((weakFilter.district1 != leftChoice || weakFilter.district2 != rightChoice) && _communityInputView) {
                [_communityInputView setValueOfView:@""];
            }
            weakFilter.district1 = leftChoice;
            weakFilter.district2 = rightChoice;
            
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
        __weak HouseAddSecondStepViewController *weakSelf = self;
        controller.onCancel = ^{
            HouseAddSecondStepViewController *strongSelf = weakSelf;
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

- (NSArray *)dataFactory:(NSMutableArray *)arrayM
{
    NSMutableArray *lastArray = [@[] mutableCopy];
    for (NSDictionary *dict in arrayM) {
        NSMutableDictionary *dictM = [@{} mutableCopy];
        dictM[@"title"] = dict[@"title"];
        NSMutableArray *subArray = [NSMutableArray arrayWithArray:dict[@"children"]];
        [subArray removeObjectAtIndex:0];
        dictM[@"children"] = subArray;
        [lastArray addObject:dictM];
    }
    [lastArray removeObjectAtIndex:0];
    return lastArray;
}

#pragma mark - 小区弹窗已经回调
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
            //小区返回的信息
            NSLog(@"community = %@",community);
            
            //LWL
            community_id =[NSNumber numberWithInteger: [community.communityId integerValue]];
            
            region_id =[NSNumber numberWithInteger: [community.region_id integerValue]];
            district_id =[NSNumber numberWithInteger: [community.district_id integerValue]];
            
            [inputView setValueOfView:community.community];
            
            _if_start =[community.if_start intValue];
            
//            _open_page_url = community.open_page_url;
            
            _open_page_url = [NSString stringWithFormat:@"%@&purpose=%@",community.open_page_url,self.purpose];

            if (_if_start == 1) {//为1时
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

#pragma mark -
#pragma next step btn action
- (void)nextStep
{
    [_currentElementView deSelect:nil];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.params];
    NSLog(@"params=%@",self.params);
    params = [self setReqParams:params];
   
    if (_if_start == 0 && [_inputDisks isEqualToString:@"不允许"]) {
        [EBAlert alertError:@"不允许录入散盘,请前往ERP进行申请" length:2.0f];
        return;
    }
    
    if (!params) {
        return;
    }
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self doneButtonIsClicked:nil];
    
    [EBAlert showLoading:nil];
    __weak HouseAddSecondStepViewController *weakSelf = self;
    [[EBHttpClient sharedInstance] houseRequest:params houseValidate:^(BOOL success, id result) {
        [EBAlert hideLoading];
        HouseAddSecondStepViewController *strongSelf = weakSelf;
        strongSelf.navigationItem.rightBarButtonItem.enabled = YES;
        
        if (!success) {
            [EBAlert alertError:result[@"desc"]];
            return;
        }
        NSArray *tmparr = result[@"validate"][@"houses"];
        if (tmparr.count > 0) {
            HouseClientExistViewController *controller = [HouseClientExistViewController new];
            controller.data = result;
            controller.title = self.navigationItem.title;
            controller.goon = ^(void) {
                HouseAddSecondStepViewController *strongSelf = weakSelf;
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

//下一个版本更新
- (void)doNextStep:(NSDictionary *)params
{
    HouseAddViewController *controller = [HouseAddViewController new];
    NSMutableDictionary *tmpparams = [NSMutableDictionary dictionaryWithDictionary:params];
    controller.house = self.house;
    controller.if_start = _if_start;//是否座栋规则
    controller.is_addHouse = YES;
    
    if (_if_start == YES) {
        controller.if_lock = _if_lock; //只有开启座栋规则才有锁定房号
        controller.floor = floor;
        controller.lists = lists;
        controller.rooms = rooms;
        controller.totle_floor = totle_floor;
        
        if (_if_lock == YES) {//房号锁定
            controller.room = bedrooms;
            controller.living_room = sittingrooms;
            controller.washroom = bathrooms;
            controller.balcony = balconies;
            controller.usable_area = [gross_area floatValue];
        }
    }
    if ([tmpparams.allKeys containsObject:@"unit_name"]) {
        if ([tmpparams[@"unit_name"] isEqualToString:@""]) {
            tmpparams[@"unit_name"] = @"单元";
        }
    }
    controller.params =[NSDictionary dictionaryWithDictionary:tmpparams];
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)validateElementView:(EBElementView *)view
{
    if ([view element].required)
    {
        if ([view isKindOfClass:EBPrefixView.class]) {
            EBPrefixElement *prefixElement = (EBPrefixElement *)[(EBPrefixView *)view element];
            if ([view respondsToSelector:@selector(valid)] && ![view valid]) {
                [EBAlert alertError:[NSString stringWithFormat:NSLocalizedString(@"house_add_alert_text_3", nil), prefixElement.prefix && prefixElement.prefix.length > 0 ? prefixElement.prefix : prefixElement.suffix]];
                return NO;
            }
            if ([view respondsToSelector:@selector(matchRegex)] && ![view matchRegex]) {
                [EBAlert alertError:[NSString stringWithFormat:NSLocalizedString(@"house_add_alert_text_4", nil), prefixElement.prefix && prefixElement.prefix.length > 0 ? prefixElement.prefix : prefixElement.suffix]];
                return NO;
            }
            if ([view isKindOfClass:EBRangeView.class] && ![[[(EBRangeView *)view minInputView] valueOfView] isEqualToString:@""] && ![[[(EBRangeView *)view maxInputView] valueOfView] isEqualToString:@""]) {
                CGFloat min = [[[(EBRangeView *)view minInputView] valueOfView] floatValue];
                CGFloat max = [[[(EBRangeView *)view maxInputView] valueOfView] floatValue];
                if (min > max) {
                    EBRangeView *rangeView = (EBRangeView*)view;
                    NSString *suffix = [(EBPrefixElement*)rangeView.maxInputView.element suffix];
                    [EBAlert alertError:[NSString stringWithFormat:@"%@不应该是从%f%@到%f%@", prefixElement.prefix && prefixElement.prefix.length > 0 ? prefixElement.prefix : prefixElement.suffix, min, suffix, max ,suffix]];
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
                    [EBAlert alertError:[NSString stringWithFormat:@"%@不应该是从%f%@到%f%@", prefixElement.prefix && prefixElement.prefix.length > 0 ? prefixElement.prefix : prefixElement.suffix, min, suffix, max , suffix]];
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

- (void)endEdit
{
    NSString *type = self.house.rentalState == EHouseRentalTypeRent ? @"rent" : @"sale";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.house.id, @"house_id", type, @"type", [NSNumber numberWithInt:2], @"chunk", nil];
    params = [self setReqParams:params];
    if (!params) {
        return;
    }
    
    [self doneButtonIsClicked:nil];
    [EBAlert showLoading:nil];
    __block HouseAddSecondStepViewController *weakSelf = self;
    [[EBHttpClient sharedInstance] houseRequest:params houseUpdate:^(BOOL success, id result) {
        [EBAlert hideLoading];
        if (success) {
            HouseAddSecondStepViewController *strongSelf = weakSelf;
            [[EBController sharedInstance] refreshHouseDetailWhenEdited:strongSelf];
//            [[EBHttpClient sharedInstance] houseRequest:@{@"id":strongSelf.house.id, @"force_refresh":@(YES),
//                                                          @"type":[EBFilter typeString:strongSelf.house.rentalState]}
//                                                 detail:^(BOOL success, id result){
//                                                     [EBAlert hideLoading];
//                                                     if (success)
//                                                     {
//                                                         strongSelf.house = result;
//                                                         [[EBCache sharedInstance] updateCacheByViewHouseDetail:strongSelf.house];
//                                                         id viewController = [self.navigationController.viewControllers objectAtIndex: ([self.navigationController.viewControllers count] -3)];
//                                                         if ([viewController isKindOfClass:[HouseDetailViewController class]])
//                                                         {
//                                                             HouseDetailViewController *temp = (HouseDetailViewController*)viewController;
//                                                             temp.houseDetail = result;
//                                                             dispatch_after(DISPATCH_TIME_NOW + NSEC_PER_SEC / 2, dispatch_get_main_queue(), ^
//                                                                            {
//                                                                                [self.navigationController popToViewController:temp animated:YES];
//                                                                            });
//                                                             
//                                                         }
//                                                     }
//            [EBAlert alertSuccess:NSLocalizedString(@"house_edit_alert_text_success", nil)];
//            [self.navigationController popViewControllerAnimated:YES];
//                                                 }];
        } else {
//            [EBAlert alertError:NSLocalizedString(@"house_edit_alert_text_failed", nil)];
        }
    }];
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
    
    NSString *district = @"", *region = @"";
    if (_filter.district1 > 0) {
        NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
        district = district1[@"title"];
        if (_filter.district2 > 0) {
            region = district1[@"children"][_filter.district2];
        }
    }
    //LWL
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.params];
    
    [params addEntriesFromDictionary:@{@"district": district, @"region": region, @"community": (_communityInputView ? [_communityInputView valueOfView] : @""),@"community_id":community_id,@"region_id":region_id,@"district_id":district_id,@"room_id":_document_id}];
    
//    [params addEntriesFromDictionary:@{@"district": district, @"region": region, @"community": (_communityInputView ? [_communityInputView valueOfView] : @""),@"community_id":community_id,@"room_id":_document_id}];
    if (region_id != nil) {
        [params setObject:region_id forKey:@"region_id"];
    }
    if (district_id != nil) {
        [params setObject:region_id forKey:@"district_id"];
    }
    
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
    if (self.editFlag && backAlert) {
        [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"edit_giveup_alert", nil) yes:NSLocalizedString(@"confirm_leave_condition_give_up", nil) action:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        return NO;
    }
    return YES;
}
@end
