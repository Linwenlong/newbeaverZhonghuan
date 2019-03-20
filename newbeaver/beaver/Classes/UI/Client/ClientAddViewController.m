//
//  ClientAddViewController.m
//  beaver
//
//  Created by LiuLian on 7/31/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "ClientAddViewController.h"
#import "EBParserContainerView.h"
#import "EBHttpClient.h"
#import "EBElementStyle.h"
#import "EBSelectElement.h"
#import "EBSelectView.h"
#import "EBInputView.h"
#import "EBTextareaView.h"
#import "EBComponentView.h"
#import "EBRegionView.h"
#import "EBRegionElement.h"
#import "EBIconLabel.h"
#import "EBSelectOptionsViewController.h"
#import "EBNavigationController.h"
#import "ExtraInfoViewController.h"
#import "EBFilter.h"
#import "EBController.h"
#import "EBAssociateViewController.h"
#import "EBAlert.h"
#import "RegexKitLite.h"
#import "EBClient.h"

@interface ClientAddViewController () <EBElementViewDelegate, EBSelectViewDelegate, EBInputViewDelegate, EBTextareaViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UIView *_footerView;
    NSMutableArray *_extra;
    
//    UIView *_districtContainerView;
    EBSelectView *_districtSelectView;
    EBFilter *_filter;
    
    UITableView *_communityTableView;
    NSMutableArray *_communities;
    EBRegionElement *_regionElement;
    
    BOOL backAlert;
}
@end

@implementation ClientAddViewController

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
    // Do any additional setup after loading the view.
    self.isShowEdit = YES;//显示是否编辑
    
    _filter = [EBFilter new];
    [self initDistrictView];
    
    _communities = [NSMutableArray new];
    [self initCommunityTableView];
    
    __weak ClientAddViewController *weakSelf = self;
    if (self.editFlag) {
        self.navigationItem.title =  NSLocalizedString(@"client_edit_detail_title", nil);
        [self addRightNavigationBtnWithTitle:NSLocalizedString(@"save", nil) target:self action:@selector(endEdit)];
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        NSString *type = self.client.rentalState == EClientRequireTypeRent ? @"rent" : @"sale";
        NSDictionary *params = @{@"client_id": self.client.id, @"type": type, @"chunk":[NSNumber numberWithInt:2]};
        
        __weak EBFilter *weakFilter = _filter;
        [[EBHttpClient sharedInstance] clientRequest:params clientEdit:^(BOOL success, id result) {
            if (success) {
                ClientAddViewController *strongSelf = weakSelf;
                strongSelf.navigationItem.rightBarButtonItem.enabled = YES;
                
                _extra = [NSMutableArray arrayWithArray:result[@"param"][@"extra"]];
                
                [strongSelf initParserContainer:result];
                
                for (UIView *view in strongSelf.parserContainerView.subviews) {
                    if ([view isMemberOfClass:EBRegionView.class]) {
//                        NSString *text = [(EBPrefixElement *)[(EBPrefixView *)view element] text];
//                        NSArray *arr = [text componentsSeparatedByString:@";"];
//                        NSString *tmpstr = nil;
//                        for (NSString *community in arr) {
//                            tmpstr = [community stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                            if (![tmpstr isEqualToString:@""]) {
//                                [self addCommunityAction:nil defaultValue:tmpstr];
//                            }
//                        }
                        _regionElement = (EBRegionElement *)[(EBRegionView *)view element];
                        NSArray *choices = [weakFilter choicesByIndex:0];
                        NSInteger lIndex = 0, rIndex = 0;
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
                        if (lIndex == choices.count) {
                            lIndex = 0;
                        }
                        weakFilter.district1 = lIndex;
                        weakFilter.district2 = rIndex;
                        if (_regionElement.community && _regionElement.community.length > 0) {
                            [_communities addObjectsFromArray:[_regionElement.community componentsSeparatedByString:@";"]];
                            if (_communities.count > 0) {
                                _districtSelectView.element.star = EBElementViewStarHidden;
                                [_districtSelectView setNeedsLayout];
                            }
                        }
                        [strongSelf resetCommunityTableViewFrame];
                        [_communityTableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                        
                        break;
                    }
                }
                
                strongSelf.parserContainerView.frame = CGRectMake(0, _communityTableView.bottom, strongSelf.scrollView.width, strongSelf.parserContainerView.height);
                
                [strongSelf initFooterView];
            } else {
                
            }
        }];
    } else {
        self.navigationItem.title = [NSString stringWithFormat:@"%@-%@", NSLocalizedString(@"client", nil), self.params[@"purpose"]];
        [self addRightNavigationBtnWithTitle:@"提交" target:self action:@selector(doSubmit)];
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [[EBHttpClient sharedInstance] clientRequest:@{@"type": self.params[@"type"], @"purpose": self.params[@"purpose"]} clientParameter:^(BOOL success, id result) {
            if (!success) {
                return;
            }
            self.navigationItem.rightBarButtonItem.enabled = YES;
            _extra = [NSMutableArray arrayWithArray:result[@"param"][@"extra"]];
            
            ClientAddViewController *strongSelf = weakSelf;
            [strongSelf initParserContainer:result];
            strongSelf.parserContainerView.frame = CGRectMake(0, _communityTableView.bottom, strongSelf.scrollView.width, strongSelf.parserContainerView.height);
            
            [strongSelf initFooterView];
            
            for (UIView *view in strongSelf.parserContainerView.subviews) {
                if ([view isMemberOfClass:EBRegionView.class]) {
                    _regionElement = (EBRegionElement *)[(EBRegionView *)view element];
                    
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

- (void)resetViews
{
    _footerView.frame = CGRectMake(0, self.parserContainerView.bottom, _footerView.width, _footerView.height);
    [self resizeContentSize];
}

#define AddCommunityViewTag 10000
#define CellContentViewTag 10000
- (void)initDistrictView
{
//    _districtContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.width, 88.0)];
//    [self.scrollView addSubview:_districtContainerView];
    
    CGFloat dx = 25, dy = 0, height = 44.0;
    EBElementStyle *style = [EBElementStyle defaultStyle];
    EBSelectElement *selectElement = [EBSelectElement new];
    selectElement.prefix = NSLocalizedString(@"client_require_district", nil);
    selectElement.star = EBElementViewStarVisible;
    _districtSelectView = [[EBSelectView alloc] initWithStyle:CGRectMake(dx, dy, self.scrollView.width-dx, height) element:selectElement style:style];
    _districtSelectView.delegate = self;
//    [_districtContainerView addSubview:_districtSelectView];
    [self.scrollView addSubview:_districtSelectView];
    [_districtSelectView drawView];
    
//    UIView *addCommunityView = [[UIView alloc] initWithFrame:CGRectMake(0, _districtSelectView.bottom, _districtContainerView.width, height)];
//    [_districtContainerView addSubview:addCommunityView];
//    addCommunityView.tag = AddCommunityViewTag;
//    UIButton *addCommunityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    addCommunityBtn.frame = CGRectMake(dx-20, addCommunityView.height/2-15, 30, 30);
//    [addCommunityBtn setBackgroundImage:[UIImage imageNamed:@"im_chat_add"] forState:UIControlStateNormal];
//    [addCommunityView addSubview:addCommunityBtn];
//    [addCommunityBtn addTarget:self action:@selector(addCommunityAction:defaultValue:) forControlEvents:UIControlEventTouchUpInside];
//    
//    EBPrefixView *elementView = [EBPrefixView new];
//    EBPrefixElement *prefixElement = [EBPrefixElement new];
//    prefixElement.prefix = NSLocalizedString(@"client_add_community_text", nil);
//    prefixElement.name = prefixElement.prefix;
//    elementView.element = prefixElement;
//    elementView.style = style;
//    elementView.style.prefixFontColor = [EBStyle blueTextColor];
//    elementView.frame = CGRectMake(60, 0, addCommunityView.width-60, addCommunityView.height);
//    [elementView drawView];
//    [addCommunityView addSubview:elementView];
//    elementView.delegate = self;
//    
//    [self hideAddCommunityView];
}

- (void)initCommunityTableView
{
    _communityTableView = [UITableView new];
    [self resetCommunityTableViewFrame];
    _communityTableView.delegate = self;
    _communityTableView.dataSource = self;
    _communityTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _communityTableView.editing = YES;
    [self.scrollView addSubview:_communityTableView];
}

- (void)resetCommunityTableViewFrame
{
    CGFloat height = 0, cellHeight = 44.0;
    if (_filter.district1 == 0 || _filter.district2 == 0) {
        height = _communities.count * cellHeight;
    } else {
        height = (_communities.count+1) * cellHeight;
    }
    _communityTableView.frame = CGRectMake(0, _districtSelectView.bottom, self.scrollView.width, height);
}

- (void)initFooterView
{
    if (_footerView) {
        _footerView.frame = CGRectMake(0, self.parserContainerView.bottom + 10, _footerView.width, _footerView.height);
        if (_extra.count > 0) {
            _footerView.hidden = NO;
            [self resizeContentSize];
        }
        else
        {
            _footerView.hidden = YES;
        }
        
        return;
    }
    
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.parserContainerView.bottom + 10, self.scrollView.width, 80)];
    [self.scrollView addSubview:_footerView];
    [self resizeContentSize];
    
    EBIconLabel *otherLabel = [[EBIconLabel alloc] initWithFrame:CGRectZero];
    otherLabel.iconPosition = EIconPositionTop;
    otherLabel.imageView.image = [UIImage imageNamed:@"im_chat_add"];
    otherLabel.label.textColor = [EBStyle blackTextColor];
    otherLabel.label.font = [UIFont systemFontOfSize:14.0];
    otherLabel.label.text = NSLocalizedString(@"other_info", nil);
    otherLabel.gap = 2;
    otherLabel.tag = 10002;
    [_footerView addSubview:otherLabel];
    CGRect frame = [otherLabel currentFrame];
    otherLabel.frame = CGRectMake(_footerView.width/2-frame.size.width/2, _footerView.height/2-frame.size.height/2, frame.size.width, frame.size.height);
    UITapGestureRecognizer *otherTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(footerIconTap:)];
    [otherLabel addGestureRecognizer:otherTapGes];
}

#pragma mark - EBElementView delegate
- (void)viewDidSelect:(EBElementView *)elementView
{
    backAlert = YES;
    
    if ([elementView isMemberOfClass:EBPrefixView.class] && elementView.tag == CellContentViewTag) {
//        [self addCommunityAction:elementView defaultValue:nil];
        [self addCommunityView];
    }
    
    [super viewDidSelect:elementView];
}

#pragma mark - EBSelectView delegate
- (void)selectViewShouldShowOptions:(EBSelectView *)selectView options:(NSArray *)options selectedIndex:(NSInteger)index
{
    if (selectView) {
        CGRect curFrame = selectView.frame;
        CGRect scrollFrame = self.scrollView.frame;
        CGFloat height;
        if (self.scrollView.contentSize.height - curFrame.origin.y > scrollFrame.size.height)
        {
            height = curFrame.origin.y;
        }
        else
        {
            height = self.scrollView.contentSize.height - scrollFrame.size.height;
        }
        [self.scrollView setContentOffset:CGPointMake(0, height)];
    }
    
    backAlert = YES;
    
    if (selectView == _districtSelectView) {
        __weak ClientAddViewController *weakSelf = self;
        __weak EBFilter *weakFilter = _filter;
        [[EBController sharedInstance] promptChoices:[_filter choicesByIndex:0] withRightChoice:_filter.district2 leftChoice:_filter.district1 title:NSLocalizedString(@"filter_district", nil) houseType:_filter.requireOrRentalType hidezero:YES completion:^(NSInteger rightChoice, NSInteger leftChoice) {
            weakFilter.district1 = leftChoice;
            weakFilter.district2 = rightChoice;
            if (weakFilter.district1 == 0 || weakFilter.district2 == 0) {
                [selectView setValueOfView:[NSNumber numberWithInt:-1]];
//                [weakSelf hideAddCommunityView];
//                return;
            } else {
                NSDictionary *district1 = [EBFilter rawDistrictChoices][weakFilter.district1];
                NSString *title = district1[@"title"];
                title = [title stringByAppendingFormat:@" %@", district1[@"children"][weakFilter.district2]];
                [(EBSelectElement *)selectView.element setOptions:[NSArray arrayWithObjects:title, nil]];
                [selectView setValueOfView:[NSNumber numberWithInt:0]];
            }
//            [weakSelf showAddCommunityView];
            [weakSelf resetCommunityTableViewFrame];
            [_communityTableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            [weakSelf resetFrame];
        }];
        
        return;
    }
    
    EBSelectOptionsViewController *controller = [[EBSelectOptionsViewController alloc] initWithData:selectView.element.name options:options selectedIndex:[(EBSelectElement *)selectView.element selectedIndex]];
    EBNavigationController *naviController = [[EBNavigationController alloc] initWithRootViewController:controller];
    __weak ClientAddViewController *weakSelf = self;
    controller.onCancel = ^{
        ClientAddViewController *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    };
    controller.onSelect = ^(NSInteger selectedIndex) {
        ClientAddViewController *strongSelf = weakSelf;
        [selectView setValueOfView:[NSNumber numberWithInteger:selectedIndex]];
        
        if ([(EBSelectElement *)selectView.element match]) {
            if ([[(EBSelectElement *)selectView.element match] isEqualToString:[selectView valueOfView]]) {
                EBElementView *elementView = [strongSelf.parserContainerView showElementView:[NSArray arrayWithObjects:[(EBSelectElement *)selectView.element display], nil]];
                [self resetViews];
                
                if ([elementView isKindOfClass:EBInputView.class] || [elementView isKindOfClass:EBTextareaView.class]) {
                    [elementView onSelect:nil];
                }
            } else {
                [strongSelf.parserContainerView hideElementView:[NSArray arrayWithObjects:[(EBSelectElement *)selectView.element display], nil]];
                [self resetViews];
            }
        }
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

#pragma mark - EBInputView delegate
- (void)inputViewDidBeginEditing:(EBInputView *)inputView
{
    backAlert = YES;
    
//    for (UIView *view in _districtContainerView.subviews) {
//        if (view == inputView.superview) {
        if (inputView.tag == CellContentViewTag) {
            CGRect rect = [inputView convertRect:inputView.bounds toView:_communityTableView];
            NSIndexPath *indexPath = [_communityTableView indexPathForRowAtPoint:CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2)];
            [self showCommunityController:inputView indexPath:indexPath];
            
            return;
        }
//    }
    
    [super inputViewDidBeginEditing:inputView];
}

- (void)textareaViewDidBeginEditing:(EBTextareaView *)textareaView
{
    backAlert = YES;
    
    [super textareaViewDidBeginEditing:textareaView];
}

- (void)checkViewDidChanged:(EBCheckView *)checkView
{
    backAlert = YES;
    
    [super checkViewDidChanged:checkView];
}

#pragma mark - submit action
- (void)doSubmit
{
    [self.currentElementView deSelect:nil];
    
    NSString *communityStr = @"";
//    for (UIView *view in _districtContainerView.subviews) {
//        if ([view isMemberOfClass:UIView.class]) {
//            for (UIView *subview in view.subviews) {
//                if ([subview isKindOfClass:EBInputView.class]) {
//                    if (![[(EBInputView *)subview valueOfView] isEqualToString:@""]) {
//                        communityStr = [communityStr stringByAppendingString:[NSString stringWithFormat:@"%@;", [(EBInputView *)subview valueOfView]]];
//                    }
//                }
//            }
//        }
//    }
    for (NSString *community in _communities) {
        if ([community isEqualToString:@""]) {
            [EBAlert alertError:NSLocalizedString(@"pl_input_community", nil)];
            return;
        }
    }
    for (NSString *community in _communities) {
        communityStr = [communityStr stringByAppendingString:[NSString stringWithFormat:@"%@;", community]];
    }
    if (communityStr.length == 0 && [[_districtSelectView valueOfView] isEqualToString:@""]) {
        [EBAlert alertError:NSLocalizedString(@"client_add_alert_text_0", nil)];
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.params];
    params = [self setReqParams:params];
    if (!params) {
        return;
    }
    if (communityStr.length > 0) {
        [params setObject:communityStr forKey:@"community"];
    } else {
        NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
        if (_filter.district2 > 0) {
            [params setObject:district1[@"children"][_filter.district2] forKey:@"community"];
        } else {
            [params setObject:district1[@"title"] forKey:@"community"];
        }
    }
    
    [self.currentElementView deSelect:nil];
    [EBAlert showLoading:nil];
    [[EBHttpClient sharedInstance] clientRequest:params clientSave:^(BOOL success, id result) {
        [EBAlert hideLoading];
        if (!success) {
            return;
        }
//      [EBAlert alertError:NSLocalizedString(@"client_add_alert_text_failed", nil)];
        [EBAlert alertSuccess:NSLocalizedString(@"client_add_alert_text_success", nil)];
        
        __block EBClient *client = [[EBClient alloc] init];
        NSString *clientId = (NSString*)result[@"id"];
        client.id = clientId;
        NSString *type = params[@"type"];
        if ([type isEqualToString:@"sale"])
        {
            client.rentalState = EClientRequireTypeBuy;
        }
        else if ([type isEqualToString:@"rent"])
        {
            client.rentalState = EClientRequireTypeRent;
        }
        else
        {
            client.rentalState = EClientRequireTypeBoth;
        }
        [[EBHttpClient sharedInstance] clientRequest:@{@"id":client.id, @"force_refresh":@(YES),
                                                       @"type":[EBFilter typeString:client.rentalState]}
                                              detail:^(BOOL success, id result)
         {
             if (success)
             {
                 client = result;
                 [[EBController sharedInstance] showClientDetailBackRoot:client];
             }
         }];
    }];
}

- (void)endEdit
{
    NSString *communityStr = @"";
//    for (UIView *view in _districtContainerView.subviews) {
//        if ([view isMemberOfClass:UIView.class]) {
//            for (UIView *subview in view.subviews) {
//                if ([subview isKindOfClass:EBInputView.class]) {
//                    if (![[(EBInputView *)subview valueOfView] isEqualToString:@""]) {
//                        communityStr = [communityStr stringByAppendingString:[NSString stringWithFormat:@"%@;", [(EBInputView *)subview valueOfView]]];
//                    }
//                }
//            }
//        }
//    }
    for (NSString *community in _communities) {
        if ([community isEqualToString:@""]) {
            [EBAlert alertError:NSLocalizedString(@"pl_input_community", nil)];
            return;
        }
    }
    for (NSString *community in _communities) {
        communityStr = [communityStr stringByAppendingString:[NSString stringWithFormat:@"%@;", community]];
    }
    if (communityStr.length == 0 && ![_districtSelectView valid]) {
        [EBAlert alertError:NSLocalizedString(@"client_add_alert_text_0", nil)];
        return;
    }
    
    NSString *type = self.client.rentalState == EClientRequireTypeRent ? @"rent" : @"sale";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.client.id, @"client_id", type, @"type", [NSNumber numberWithInt:2], @"chunk", nil];
    params = [self setReqParams:params];
    if (!params) {
        return;
    }
    
    if (communityStr.length > 0) {
        [params setObject:communityStr forKey:@"community"];
    } else {
        NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
        if (_filter.district2 > 0) {
            [params setObject:district1[@"children"][_filter.district2] forKey:@"community"];
        } else {
            [params setObject:district1[@"title"] forKey:@"community"];
        }
    }
    
    [self.currentElementView deSelect:nil];
    [EBAlert showLoading:nil];
    __weak ClientAddViewController *weakSelf = self;
    [[EBHttpClient sharedInstance] clientRequest:params clientUpdate:^(BOOL success, id result) {
        ClientAddViewController *strongSelf = weakSelf;
        [EBAlert hideLoading];
        if (success) {
            [[EBController sharedInstance] refreshClientDetailWhenEdited:strongSelf];
        } else {
//            [EBAlert alertError:NSLocalizedString(@"client_edit_alert_text_failed", nil)];
        }
    }];
}

#pragma mark - community action
- (void)addCommunityAction:(id)sender defaultValue:(NSString *)value
{
//    UIView *addCommunityView = [_districtContainerView viewWithTag:AddCommunityViewTag];
//    
//    UIView *communityView = [[UIView alloc] initWithFrame:CGRectMake(0, addCommunityView.top, _districtContainerView.width, 44.0)];
//    [_districtContainerView insertSubview:communityView aboveSubview:addCommunityView];
//    UIButton *deleteCommunityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    deleteCommunityBtn.frame = CGRectMake(10, communityView.height/2-15, 30, 30);
//    [deleteCommunityBtn setBackgroundImage:[UIImage imageNamed:@"im_chat_delete"] forState:UIControlStateNormal];
//    [communityView addSubview:deleteCommunityBtn];
//    [deleteCommunityBtn addTarget:self action:@selector(deleteCommunityAction:) forControlEvents:UIControlEventTouchUpInside];
//    
//    EBInputView *elementView = [EBInputView new];
//    EBInputElement *inputElement = [EBInputElement new];
//    inputElement.placeholder = NSLocalizedString(@"pl_input_community", nil);
//    elementView.element = inputElement;
//    EBElementStyle *inputStyle = [EBElementStyle new];
//    inputStyle.font = [UIFont systemFontOfSize:14.0];
//    inputStyle.underline = YES;
//    elementView.style = inputStyle;
//    elementView.delegate = self;
//    elementView.frame = CGRectMake(60, 0, communityView.width-60, communityView.height);
//    [elementView drawView];
//    if (value && [value isKindOfClass:NSString.class]) {
//        [elementView setValueOfView:value];
//    }
//    [communityView addSubview:elementView];
//
//    addCommunityView.frame = CGRectOffset(addCommunityView.frame, 0, communityView.height);
//    [self resetFrame:communityView.height];
//    
//    if (_districtSelectView.element.star == EBElementViewStarVisible) {
//        _districtSelectView.element.star = EBElementViewStarHidden;
//        [_districtSelectView setNeedsLayout];
//    }
}

- (void)deleteCommunityAction:(id)sender
{
//    UIView *communityView = [(UIView *)sender superview];
//    [communityView removeFromSuperview];
//    
//    for (UIView *view in _districtContainerView.subviews) {
//        if (view.top > communityView.top) {
//            view.frame = CGRectOffset(view.frame, 0, -communityView.height);
//        }
//    }
//    
//    [self resetFrame:-communityView.height];
//    
//    NSUInteger *count = 0;
//    for (UIView *view in _districtContainerView.subviews) {
//        if ([view isMemberOfClass:UIView.class]) {
//            for (UIView *subview in view.subviews) {
//                if ([subview isKindOfClass:EBInputView.class]) {
//                    count++;
//                }
//            }
//        }
//    }
//
//    if (count == 0 && _districtSelectView.element.star == EBElementViewStarHidden) {
//        _districtSelectView.element.star = EBElementViewStarVisible;
//        [_districtSelectView setNeedsLayout];
//    }
}

- (void)showAddCommunityView
{
//    UIView *addCommunityView = [_districtContainerView viewWithTag:AddCommunityViewTag];
//    if (!addCommunityView.hidden) {
//        return;
//    }
//    addCommunityView.hidden = NO;
//    [self resetFrame:addCommunityView.height];
}

- (void)hideAddCommunityView
{
//    
//    for (UIView *view in _districtContainerView.subviews) {
//        if ([view isMemberOfClass:UIView.class]) {
//            for (UIView *subview in view.subviews) {
//                if ([subview isKindOfClass:EBInputView.class]) {
//                    if ([[(EBInputView *)subview valueOfView] isEqualToString:@""]) {
//                        [self deleteCommunityAction:subview];
//                    }
//                }
//            }
//        }
//    }
    
//    UIView *addCommunityView = [_districtContainerView viewWithTag:AddCommunityViewTag];
//    if (addCommunityView.hidden) {
//        return;
//    }
//    addCommunityView.hidden = YES;
//    [self resetFrame:-addCommunityView.height];
}

- (void)resetFrame
{
//    _districtContainerView.frame = CGRectMake(_districtContainerView.left, _districtContainerView.top, _districtContainerView.width, _districtContainerView.height+dy);
    self.parserContainerView.frame = CGRectMake(self.parserContainerView.left, _communityTableView.bottom, self.parserContainerView.width, self.parserContainerView.height);
    _footerView.frame = CGRectMake(_footerView.left, self.parserContainerView.bottom, _footerView.width, _footerView.height);
    [self resizeContentSize];
}

- (void)showCommunityController:(EBInputView *)inputView indexPath:(NSIndexPath *)indexPath
{
    [self keyboardWillHide];
    [inputView deSelect:nil];
    
    if (_filter.district1 == 0 || _filter.district2 == 0) {
        [EBAlert alertError:NSLocalizedString(@"client_add_alert_text_0", nil)];
        return;
    }
    
    EBAssociateViewController *viewController = [[EBAssociateViewController alloc] init];
    viewController.hidesBottomBarWhenPushed = YES;
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
    viewController.handleSelection = ^(NSString *district, NSString *region, EBCommunity *community){
//        [inputView setValueOfView:community];
        _communities[indexPath.row] = community.community;
        [_communityTableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    };
    [self.navigationController pushViewController:viewController animated:NO];
}

#pragma mark - footerview icon tap action
- (void)footerIconTap:(UITapGestureRecognizer *)sender
{
    EBIconLabel *view = (EBIconLabel *)sender.view;
    switch (view.tag) {
        case 10002:
        {
            ExtraInfoViewController *controller = [[ExtraInfoViewController alloc] initWithData:_extra title:NSLocalizedString(@"other_info_controller_title", nil)];
            EBNavigationController *naviController = [[EBNavigationController alloc] initWithRootViewController:controller];
            [self presentViewController:naviController animated:YES completion:^{
                
            }];
            
            __weak ClientAddViewController *weakSelf = self;
            __weak EBParserContainerView *weakParserContainerView = self.parserContainerView;
            __weak __block ExtraInfoViewController *weakController = controller;
            controller.onSelect = ^(NSIndexPath *indexPath, NSDictionary *data) {
                EBParserContainerView *strongParserContainerView = weakParserContainerView;
                
                NSMutableArray *arr = [NSMutableArray arrayWithArray:_extra[indexPath.section]];
                [arr removeObjectAtIndex:indexPath.row];
                _extra[indexPath.section] = [NSArray arrayWithArray:arr];
                if (arr.count == 0) {
                    [_extra removeObjectAtIndex:indexPath.section];
                }
                
                EBElementView *elementView = [strongParserContainerView showElementView:data[@"fields"]];
                [self initFooterView];
                
                if ([elementView isKindOfClass:EBInputView.class] || [elementView isKindOfClass:EBTextareaView.class]) {
                    [elementView onSelect:nil];
                }
                __weak EBSelectView *weakView = (EBSelectView*)elementView;
                if ([elementView isKindOfClass:EBSelectView.class]) {
                    EBSelectView *strongView = weakView;
                    weakController.onDisappear = ^{
                        
                        [self selectViewShouldShowOptions:strongView options:[(EBSelectElement *)strongView.element options] selectedIndex:[(EBSelectElement *)strongView.element selectedIndex]];
                    };
                }
            };
            
            controller.onCancel = ^{
                ClientAddViewController *strongSelf = weakSelf;
                [strongSelf dismissViewControllerAnimated:YES completion:^{
                    
                }];
            };
            break;
        }
        default:
            break;
    }
}

#pragma mark - private method
- (void)resizeContentSize
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, _footerView.bottom+10);
}

#pragma mark - back popup
- (BOOL)shouldPopOnBack
{
    if (backAlert) {
        [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"edit_giveup_alert", nil) yes:NSLocalizedString(@"confirm_leave_condition_give_up", nil) action:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        return NO;
    }
    return YES;
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (_filter.district1 == 0 || _filter.district2 == 0) {
        count = _communities.count;
    } else {
        count = _communities.count + 1;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = nil;
    if ((_filter.district1 == 0 || _filter.district2 == 0) || indexPath.row < _communities.count) {
        identifier = @"RegionViewCell";
    } else {
        identifier = @"AddRegionViewCell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if ((_filter.district1 == 0 || _filter.district2 == 0) || indexPath.row < _communities.count) {
        EBInputView *inputView = (EBInputView *)[cell.contentView viewWithTag:CellContentViewTag];
        if (!inputView) {
            inputView = [EBInputView new];
            inputView.style = [EBElementStyle defaultStyle];
            EBInputElement *inputElement = [EBInputElement new];
            inputElement.placeholder = NSLocalizedString(@"pl_input_community", nil);
            inputElement.star = EBElementViewStarVisible;
            inputView.element = inputElement;
            inputView.frame = CGRectMake(RequiredLabelWidth, 0, tableView.frame.size.width-RequiredLabelWidth, 44.0);
            [inputView drawView];
            inputView.tag = CellContentViewTag;
            inputView.delegate = self;
            [cell.contentView addSubview:inputView];
        }
        [inputView setValueOfView:_communities[indexPath.row]];
    } else {
        EBPrefixView *elementView = (EBPrefixView *)[cell.contentView viewWithTag:CellContentViewTag];
        if (!elementView) {
            elementView = [EBPrefixView new];
            elementView.style = [EBElementStyle defaultStyle];
            EBPrefixElement *prefixElement = [EBPrefixElement new];
            prefixElement.prefix = NSLocalizedString(@"client_add_community_text", nil);
            prefixElement.name = prefixElement.prefix;
            elementView.element = prefixElement;
            elementView.style.prefixFontColor = [EBStyle blueTextColor];
            elementView.frame = CGRectMake(0, 0, tableView.frame.size.width, 44.0);
            [elementView drawView];
            elementView.tag = CellContentViewTag;
            elementView.delegate = self;
            [cell.contentView addSubview:elementView];
        }
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((_filter.district1 == 0 || _filter.district2 == 0) || indexPath.row < _communities.count) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleInsert;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self addCommunityView];
    } else {
        [self deleteCommunityView:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_filter.district1 == 0 || _filter.district2 == 0) {
        [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
        return;
    }
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.row < _communities.count) {
        [self showCommunityController:(EBInputView *)[cell.contentView viewWithTag:CellContentViewTag] indexPath:indexPath];
    } else {
        [self tableView:tableView commitEditingStyle:UITableViewCellEditingStyleInsert forRowAtIndexPath:indexPath];
    }
    [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)addCommunityView
{
    if (_communities.count >= _regionElement.count) {
        [EBAlert alertError:[NSString stringWithFormat:@"最多能添加%ld个小区", _regionElement.count]];
        return;
    }
    [_communities addObject:@""];
    if (_communities.count > 0 && _districtSelectView.element.star == EBElementViewStarVisible) {
        _districtSelectView.element.star = EBElementViewStarHidden;
        [_districtSelectView setNeedsLayout];
    }
    
    [self resetCommunityTableViewFrame];
    [_communityTableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self resetFrame];
}

- (void)deleteCommunityView:(NSInteger)row
{
    [_communities removeObjectAtIndex:row];
    if (_communities.count == 0 && _districtSelectView.element.star == EBElementViewStarHidden) {
        _districtSelectView.element.star = EBElementViewStarVisible;
        [_districtSelectView setNeedsLayout];
    }
    [self resetCommunityTableViewFrame];
    [_communityTableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self resetFrame];
}

@end
