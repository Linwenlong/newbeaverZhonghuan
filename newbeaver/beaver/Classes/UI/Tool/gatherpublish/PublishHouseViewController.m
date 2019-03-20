//
//  PublishHouseViewController.m
//  beaver
//
//  Created by LiuLian on 9/1/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "PublishHouseViewController.h"
#import "EBHttpClient.h"
#import "EBAlert.h"
#import "EBIconLabel.h"
#import "EBRegionElement.h"
#import "EBRegionView.h"
#import "EBFilter.h"
#import "EBElementStyle.h"
#import "EBSelectElement.h"
#import "EBSelectView.h"
#import "EBController.h"
#import "EBAssociateViewController.h"
#import "UIAlertView+Blocks.h"
//#import "UIActionSheet+Blocks.h"
#import "HousePhotoPreUploadViewController.h"
#import "EBHouse.h"
#import "PublishOrderPortViewController.h"
#import "EBHousePhoto.h"
#import "EBPreferences.h"
#import "EBContact.h"
#import "EBContactManager.h"
#import "EBCache.h"

@interface PublishHouseViewController () <UIActionSheetDelegate>
{
    UIView *_footerView;
    
    EBRegionView *_regionView;
    NSUInteger _regionIndex;
    EBSelectView *_districtSelectView;
    EBInputView *_communityInputView;
    EBTextareaView *_descTextareaView;
    EBInputView *_contactNameInputView;
    EBInputView *_contactTelInputView;
    NSString *_originalDesc;
    
    EBFilter *_filter;
    BOOL _backAlert;
}
@end

@implementation PublishHouseViewController

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
    NSLog(@"parm = %@",self.params);
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"编辑房源";
    [self addRightNavigationBtnWithTitle:NSLocalizedString(@"btn_process_next_title", nil) target:self action:@selector(nextStep)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
//    [self getPublishHouseEditor];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_showActionSheet) {
        _showActionSheet = NO;
//        __weak PublishHouseViewController *weakSelf = self;
//        NSMutableArray *buttons = [NSMutableArray new];
//        [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(@"rental_house_state_1", nil) action:^{
//            weakSelf.params[@"type"] = @"rent";
//            
//            [weakSelf getPublishHouseEditor];
//        }]];
//        [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(@"rental_house_state_2", nil) action:^{
//            weakSelf.params[@"type"] = @"sale";
//            
//            [weakSelf getPublishHouseEditor];
//        }]];
//        [[[UIActionSheet alloc] initWithTitle:nil buttons:buttons] showInView:self.view];
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"rental_house_state_1", nil), NSLocalizedString(@"rental_house_state_2", nil), nil];
        [actionSheet showInView:self.view];
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

- (void)getPublishHouseEditor
{
    __weak PublishHouseViewController *weakSelf = self;
    [EBAlert showLoading:nil];
    [[EBHttpClient sharedInstance] gatherPublishRequest:self.params publishHouseEditor:^(BOOL success, id result) {
        [EBAlert hideLoading];
        
        if (success) {
            PublishHouseViewController *strongSelf = weakSelf;
            strongSelf.navigationItem.rightBarButtonItem.enabled = YES;
            
            [strongSelf initParserContainer:result];
            
            for (UIView *view in strongSelf.parserContainerView.subviews) {
                if ([view isKindOfClass:EBElementView.class] && [[(EBElementView *)view element].eid isEqualToString:@"description"]) {
                    _descTextareaView = (EBTextareaView *)view;
                    _originalDesc = [_descTextareaView valueOfView];
                    break;
                }
            }
            
            EBPreferences *pref = [EBPreferences sharedInstance];
            EBContact *me = [[EBContactManager sharedInstance] contactById:pref.userId];
            
            for (UIView *view in strongSelf.parserContainerView.subviews) {
                if ([view isKindOfClass:EBElementView.class] && [[(EBElementView *)view element].eid isEqualToString:@"contact_name"]) {
                    _contactNameInputView = (EBInputView *)view;
                    if (!_contactNameInputView.valueOfView)
                    {
                        [_contactNameInputView setValueOfView:me.name];
                    }
                    else if(_contactNameInputView.valueOfView.length < 1)
                    {
                        [_contactNameInputView setValueOfView:me.name];
                    }
                    break;
                }
            }
            for (UIView *view in strongSelf.parserContainerView.subviews) {
                if ([view isKindOfClass:EBElementView.class] && [[(EBElementView *)view element].eid isEqualToString:@"contact_tel"]) {
                    _contactTelInputView = (EBInputView *)view;
                    if (!_contactTelInputView.valueOfView)
                    {
                        [_contactTelInputView setValueOfView:me.phone];
                    }
                    else if (_contactTelInputView.valueOfView.length < 1)
                    {
                        [_contactTelInputView setValueOfView:me.phone];
                    }
                    break;
                }
            }
            
            _regionIndex = 0;
            for (UIView *view in strongSelf.parserContainerView.subviews) {
                if ([view isKindOfClass:EBElementView.class]) {
                    _regionIndex++;
                }
                if ([view isMemberOfClass:EBRegionView.class]) {
                    _regionView = (EBRegionView *)view;
                    
                    break;
                }
            }
            if (_regionView) {
                [strongSelf initDistrictView];
            }
            
            if (result[@"param"][@"supplement"][@"pictures"]) {
                _erp_photo_urls = [NSMutableArray arrayWithArray:result[@"param"][@"supplement"][@"pictures"]];
            }//重新发布
            
            [self initFooterView];
        }
    }];
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

- (void)initDistrictView
{
    EBRegionElement *regionElement = (EBRegionElement *)_regionView.element;
    if (regionElement.count <= 0) {
        return;
    }
    
    _filter = [EBFilter new];
    [self updateFilter:_filter districtOne:regionElement.district districtTwo:regionElement.region];
//    NSArray *choices = [_filter choicesByIndex:0];
//    NSInteger lIndex = 0, rIndex = 0;
//    for (NSDictionary *lDic in choices) {
//        if ([(NSString *)lDic[@"title"] isEqualToString:regionElement.district]) {
//            for (NSString *str in lDic[@"children"]) {
//                if ([str isEqualToString:regionElement.region]) {
//                    break;
//                }
//                rIndex++;
//            }
//            break;
//        }
//        lIndex++;
//    }
//    if (lIndex == choices.count) {
//        lIndex = 0;
//    }
//    _filter.district1 = lIndex;
//    _filter.district2 = rIndex;
    
    NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
    NSString *title = @"";
    if (_filter.district1 > 0 && _filter.district2 > 0) {
        title = district1[@"title"];
        if (_filter.district2 > 0) {
            title = [title stringByAppendingFormat:@" %@", district1[@"children"][_filter.district2]];
        }
    }
    
    EBElementStyle *style = [EBElementStyle defaultStyle];
    EBSelectElement *selectElement = [EBSelectElement new];
    selectElement.placeholder = NSLocalizedString(@"house_text_district_0", nil);
    selectElement.prefix = NSLocalizedString(@"house_text_district_0", nil);
    selectElement.star = EBElementViewStarVisible;
    
    CGFloat dx = 25;
    _districtSelectView = [[EBSelectView alloc] initWithStyle:CGRectMake(dx, _regionView.top, self.parserContainerView.width-dx, _regionView.height) element:selectElement style:style];
    _districtSelectView.delegate = self;
    [self.parserContainerView addElementView:_districtSelectView atIndex:_regionIndex];
    [_districtSelectView drawView];
    [(EBSelectElement *)_districtSelectView.element setOptions:[NSArray arrayWithObjects:title, nil]];
    [_districtSelectView setValueOfView:[NSNumber numberWithInt:0]];
    
    EBInputElement *inputElement = [EBInputElement new];
    inputElement.placeholder = NSLocalizedString(@"house_text_community_0", nil);
    inputElement.prefix = NSLocalizedString(@"house_text_community_0", nil);
    inputElement.star = EBElementViewStarVisible;
    _communityInputView = [[EBInputView alloc] initWithStyle:CGRectMake(dx, _districtSelectView.bottom, self.parserContainerView.width-dx, _regionView.height) element:inputElement style:[EBElementStyle defaultStyle]];
    [self.parserContainerView addElementView:_communityInputView atIndex:_regionIndex+1];
    [_communityInputView drawView];
    [_communityInputView setValueOfView:regionElement.community];
    _communityInputView.delegate = self;
}

- (void)initFooterView
{
    if (_footerView) {
        _footerView.frame = CGRectMake(0, self.parserContainerView.height + 10, _footerView.width, _footerView.height);
        [self resizeContentSize];
        
        return;
    }
    
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.parserContainerView.height + 10, self.scrollView.width, 80)];
    [self.scrollView addSubview:_footerView];
    [self resizeContentSize];
    
    EBIconLabel *otherLabel = [[EBIconLabel alloc] initWithFrame:CGRectZero];
    otherLabel.iconPosition = EIconPositionTop;
    otherLabel.imageView.image = [UIImage imageNamed:@"im_more_0"];
    otherLabel.label.textColor = [EBStyle blackTextColor];
    otherLabel.label.font = [UIFont systemFontOfSize:14.0];
    otherLabel.label.text = [NSString stringWithFormat:@" 照片（%ld） ", _erp_photo_urls ? _erp_photo_urls.count : 0];
    otherLabel.gap = 2;
    otherLabel.tag = 10002;
    [_footerView addSubview:otherLabel];
    CGRect frame = [otherLabel currentFrame];
    //    otherLabel.frame = CGRectMake(footerView.width-frame.size.width-40.0, footerView.height-frame.size.height, frame.size.width, frame.size.height);
    otherLabel.frame = CGRectMake(_footerView.width/2-frame.size.width/2, _footerView.height/2-frame.size.height/2, frame.size.width, frame.size.height);
    UITapGestureRecognizer *otherTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(footerIconTap:)];
    [otherLabel addGestureRecognizer:otherTapGes];
}

#pragma mark - action
- (void)nextStep
{
    [self.currentElementView deSelect:nil];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.params];
    params = [self setReqParams:params];
    if (!params) {
        return;
    }
    
    if (_regionView) {
        EBRegionElement *regionElement = (EBRegionElement *)_regionView.element;
        if (regionElement.count > 0) {
            [self updateFilter:_filter districtOne:regionElement.district districtTwo:regionElement.region];
        }
    }
    
    NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
    if ((_filter.district1 > 0) && (_filter.district2 > 0)) {
        params[@"district"] = district1[@"title"];
        params[@"region"] = district1[@"children"][_filter.district2];
    }
    params[@"community"] = [_communityInputView valueOfView];
    
    PublishOrderPortViewController *controller = [PublishOrderPortViewController new];
    controller.params = [NSDictionary dictionaryWithDictionary:params];
    controller.photos = _erp_photo_urls ? [NSArray arrayWithArray:_erp_photo_urls] : [NSArray new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)footerIconTap:(id)sender
{
    if ([(UITapGestureRecognizer *)sender view].tag == 10002) {
        EBHouse *house = [EBHouse new];
        if (self.params[@"erp_house_id"]) {
            house.id = self.params[@"erp_house_id"];
        } else if (self.params[@"relate_house_id"]) {
            house.id = self.params[@"relate_house_id"];
        } else if (self.params[@"publish_id"]) {
            house.id = self.params[@"publish_id"];
        }
        if ([self.params[@"type"] isEqualToString:@"rent"]) {
            house.rentalState = EHouseRentalTypeRent;
        } else {
            house.rentalState = EHouseRentalTypeSale;
        }
        
        HousePhotoPreUploadViewController *controller = [HousePhotoPreUploadViewController new];
        controller.publishTag = YES;
        [self.navigationController pushViewController:controller animated:YES];
        NSMutableArray *urlArr = [NSMutableArray new];
        if (_erp_photo_urls && _erp_photo_urls.count > 0) {
            for (NSString *urlStr in _erp_photo_urls) {
                [urlArr addObject:[NSURL URLWithString:urlStr]];
            }
        }
        [controller uploadPhotos:urlArr forHouse:house getUpLoadPhotoBlock:^(NSArray *array) {
            if (!_erp_photo_urls) {
                _erp_photo_urls = [NSMutableArray new];
            }
            [_erp_photo_urls removeAllObjects];
            if (array && array.count > 0) {
                for (EBHousePhoto *photo in array) {
                    [_erp_photo_urls addObject:[photo.localUrl absoluteString]];
                }
            }
            [(EBIconLabel *)[_footerView viewWithTag:10002] label].text = [NSString stringWithFormat:@"照片（%ld）", _erp_photo_urls.count];
        }];
        
    }
}

#pragma mark - ebelementview delegate
- (void)selectViewShouldShowOptions:(EBSelectView *)selectView options:(NSArray *)options selectedIndex:(NSInteger)index
{
    _backAlert = YES;
    if (selectView == _districtSelectView) {
        [self keyboardWillHide];
        if (_regionView) {
            EBRegionElement *regionElement = (EBRegionElement *)_regionView.element;
            if (regionElement.count > 0) {
                [self updateFilter:_filter districtOne:regionElement.district districtTwo:regionElement.region];
            }
        }
        
        [[EBController sharedInstance] promptChoices:[_filter choicesByIndex:0] withRightChoice:_filter.district2 leftChoice:_filter.district1 title:NSLocalizedString(@"filter_district", nil) houseType:_filter.requireOrRentalType completion:^(NSInteger rightChoice, NSInteger leftChoice) {
            if ((_filter.district1 != leftChoice || _filter.district2 != rightChoice) && _communityInputView) {
                [_communityInputView setValueOfView:@""];
            }
            _filter.district1 = leftChoice;
            _filter.district2 = rightChoice;
            
            NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
            NSString *title = @"";
            if ((_filter.district1 > 0) && (_filter.district2 > 0)) {
                title = [NSString stringWithFormat:@"%@ %@", district1[@"title"], district1[@"children"][_filter.district2]];
            }
            
            [(EBSelectElement *)selectView.element setOptions:[NSArray arrayWithObjects:title, nil]];
            [selectView setValueOfView:[NSNumber numberWithInt:0]];
        }];
        
        return;
    } else {
        [super selectViewShouldShowOptions:selectView options:options selectedIndex:index];
    }
}

- (void)inputViewDidBeginEditing:(EBInputView *)inputView
{
    _backAlert = YES;
    if (inputView == _communityInputView) {
        [self keyboardWillHide];
        [inputView deSelect:nil];
        if (_filter.district1 > 0 && _filter.district2 > 0) {
            EBAssociateViewController *viewController = [[EBAssociateViewController alloc] init];
            
            if (_regionView) {
                EBRegionElement *regionElement = (EBRegionElement *)_regionView.element;
                if (regionElement.count > 0) {
                    [self updateFilter:_filter districtOne:regionElement.district districtTwo:regionElement.region];
                }
            }
            
            NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
            viewController.district = district1[@"title"];
            viewController.region = district1[@"children"][_filter.district2];
            viewController.hidesBottomBarWhenPushed = YES;
            viewController.handleSelection = ^(NSString *district, NSString *region, EBCommunity *community){
                [inputView setValueOfView:community.community];
            };
            [self.navigationController pushViewController:viewController animated:NO];
        } else {
            [EBAlert alertError:NSLocalizedString(@"pl_input_district", nil)];
        }
    } else {
        [super inputViewDidBeginEditing:inputView];
    }
}

- (void)checkViewDidChanged:(EBCheckView *)checkView
{
    _backAlert = YES;
    if ([checkView.element.eid isEqualToString:@"use_desc"] && _descTextareaView) {
        if (![[checkView valueOfView] boolValue]) {
            [_descTextareaView setValueOfView:@""];
        } else {
            [_descTextareaView setValueOfView:_originalDesc];
        }
    }
}

#pragma mark - actionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        self.params[@"type"] = @"rent";
        [self getPublishHouseEditor];
    } else if (buttonIndex == 1) {
        self.params[@"type"] = @"sale";
        [self getPublishHouseEditor];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - private method
- (void)resizeContentSize
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.parserContainerView.height+_footerView.height+10);
}

- (BOOL)shouldPopOnBack
{
    if (_backAlert)
    {
        [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"edit_giveup_alert", nil) yes:NSLocalizedString(@"confirm_leave_condition_give_up", nil) action:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        return NO;
    }
    return YES;
}

#pragma mark - ebelementview delegate
- (void)viewDidSelect:(EBElementView *)elementView
{
    _backAlert = YES;
    
    [super viewDidSelect:elementView];
}

- (void)textareaViewDidBeginEditing:(EBTextareaView *)textareaView
{
    _backAlert = YES;
    
    [super textareaViewDidBeginEditing:textareaView];
}

@end
