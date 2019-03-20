//
//  ParserContainerViewController.m
//  beaver
//
//  Created by LiuLian on 8/7/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "ParserContainerViewController.h"
#import "EBSelectOptionsViewController.h"
#import "EBNavigationController.h"
#import "EBSelectElement.h"
#import "EBComponentView.h"
#import "EBAlert.h"
#import "EBElementView.h"
#import "RegexKitLite.h"
#import "EBTextareaView.h"
#import "EBRangeView.h"
//#import "EBParserContainerView.h"

@interface ParserContainerViewController ()

@end

@implementation ParserContainerViewController

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
    _scrollView = [[UIScrollView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    [self.view addSubview:_scrollView];
    
    [self initToolbar];
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

- (void)keyboardWillHide
{
    _scrollView.frame = [EBStyle fullScrTableFrame:NO];
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}


- (void)initParserContainer:(id)result lifts:(NSInteger)lifts rooms:(NSInteger)rooms floor:(NSInteger)floor totleFloor:(NSInteger)totleFloor room:(NSInteger)room living_room:(NSInteger)living_room washroom:(NSInteger)washroom balcony:(NSInteger)balcony area:(CGFloat)usable_area{
    NSLog(@"self.add = %d",self.is_addHouse);
    _parserContainerView = [[EBParserContainerView alloc] initWithFrame:CGRectMake(0, 0, _scrollView.width, _scrollView.height)];
    _parserContainerView.controller = self;
    //        [scrollView addSubview:_parserContainerView];
    [_parserContainerView showInView:_scrollView toolbar:_toolbar];
    EBElementParser *parser = [EBElementParser new];
    parser.is_addHouse = self.is_addHouse;//是否是新增房源
    parser.if_start = self.if_start;
    parser.if_lock = self.if_lock;
    parser.delegate = _parserContainerView;
    [parser parse:result[@"param"][@"base"] lifts:lifts rooms:rooms floor:floor totleFloor:totleFloor room:room living_room:living_room washroom:washroom balcony:balcony area:usable_area];

}


//lwl 开启了座栋规则 房号未锁定
- (void)initParserContainer:(id)result lifts:(NSInteger)lifts rooms:(NSInteger)rooms floor:(NSInteger)floor totleFloor:(NSInteger)totleFloor{
    NSLog(@"self.add = %d",self.is_addHouse);
    _parserContainerView = [[EBParserContainerView alloc] initWithFrame:CGRectMake(0, 0, _scrollView.width, _scrollView.height)];
    _parserContainerView.controller = self;
    //        [scrollView addSubview:_parserContainerView];
    [_parserContainerView showInView:_scrollView toolbar:_toolbar];
    EBElementParser *parser = [EBElementParser new];
    parser.is_addHouse = self.is_addHouse;//是否是新增房源
    parser.if_start = self.if_start;
    parser.if_lock = self.if_lock;
    parser.delegate = _parserContainerView;
    [parser parse:result[@"param"][@"base"] lifts:lifts rooms:rooms floor:floor totleFloor:totleFloor];
}

//- (void)initParserContainer:(id)result lifts:(NSInteger)lifts rooms:(NSInteger)rooms{
//    _parserContainerView = [[EBParserContainerView alloc] initWithFrame:CGRectMake(0, 0, _scrollView.width, _scrollView.height)];
//    _parserContainerView.controller = self;
//    //        [scrollView addSubview:_parserContainerView];
//    [_parserContainerView showInView:_scrollView toolbar:_toolbar];
//    EBElementParser *parser = [EBElementParser new];
//    parser.delegate = _parserContainerView;
//    [parser parse:result[@"param"][@"base"] lifts:lifts rooms:rooms];
//}

//没有开启座栋规则
- (void)initParserContainer:(id)result
{
    _parserContainerView = [[EBParserContainerView alloc] initWithFrame:CGRectMake(0, 0, _scrollView.width, _scrollView.height)];
    _parserContainerView.controller = self;
    //        [scrollView addSubview:_parserContainerView];
    [_parserContainerView showInView:_scrollView toolbar:_toolbar];
    EBElementParser *parser = [EBElementParser new];
    parser.is_addHouse = self.is_addHouse;
    parser.if_start = self.if_start;
    parser.if_lock = self.if_lock;
    parser.delegate = _parserContainerView;
    [parser parse:result[@"param"][@"base"]];
}

- (void)resetViews
{
    
}

- (NSMutableDictionary *)setReqParams:(NSMutableDictionary *)params
{
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
    
    //    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.params];
    for (UIView *view in _parserContainerView.subviews) {
        if ([view isKindOfClass:EBElementView.class] && [(EBElementView *)view element].visible) {
            if ([view isMemberOfClass:EBComponentView.class]) {
                for (UIView *subview in view.subviews) {
                    if ([subview isKindOfClass:EBElementView.class] && [(EBElementView *)subview element].eid && ![[(EBElementView *)subview element].eid isEqualToString:@""]) {
                        [params setObject:[(EBElementView *)subview valueOfView] forKey:[(EBElementView *)subview element].eid];
                    }
                }
            } else {
                if ([(EBElementView *)view element].eid && ![[(EBElementView *)view element].eid isEqualToString:@""]) {
                    [params setObject:[(EBElementView *)view valueOfView] forKey:[(EBElementView *)view element].eid];
                }
            }
        }
    }
    return params;
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
                    [EBAlert alertError:[NSString stringWithFormat:@"%@不应该是从%@%@到%@%@", prefixElement.prefix && prefixElement.prefix.length > 0 ? prefixElement.prefix : prefixElement.suffix, [[(EBRangeView *)view minInputView] valueOfView], suffix, [[(EBRangeView *)view maxInputView] valueOfView] , suffix]];
                    return NO;
                }
            }
        } else {
            if ([view respondsToSelector:@selector(valid)] && ![view valid]) {
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
                    [EBAlert alertError:[NSString stringWithFormat:@"%@不应该是从%@%@到%@%@", prefixElement.prefix && prefixElement.prefix.length > 0 ? prefixElement.prefix : prefixElement.suffix, [[(EBRangeView *)view minInputView] valueOfView], suffix, [[(EBRangeView *)view maxInputView] valueOfView] , suffix]];
                    return NO;
                }
            }
        }
    }
    return YES;
}

#pragma mark - EBSelectView delegate
- (void)selectViewShouldShowOptions:(EBSelectView *)selectView options:(NSArray *)options selectedIndex:(NSInteger)index
{
    EBSelectOptionsViewController *controller = [[EBSelectOptionsViewController alloc] initWithData:selectView.element.name options:options selectedIndex:[(EBSelectElement *)selectView.element selectedIndex]];
    EBNavigationController *naviController = [[EBNavigationController alloc] initWithRootViewController:controller];
    __weak ParserContainerViewController *weakSelf = self;
    controller.onCancel = ^{
        ParserContainerViewController *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    };
    controller.onSelect = ^(NSInteger selectedIndex) {
        ParserContainerViewController *strongSelf = weakSelf;
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
    _currentElementView = inputView;
    [self setBarButtonNeedsDisplayAtIndex:[_parserContainerView.inputViews indexOfObject:_currentElementView]];
}

#pragma mark - EBTextareaView delegate
- (void)textareaViewDidBeginEditing:(EBTextareaView *)textareaView
{
    _currentElementView = textareaView;
    [self setBarButtonNeedsDisplayAtIndex:[_parserContainerView.inputViews indexOfObject:_currentElementView]];
}

- (void)viewDidSelect:(EBElementView *)elementView
{
    
}

- (void)checkViewDidChanged:(EBCheckView *)checkView
{
    
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
@end
