//
//  SingleChoiceViewController.m
//  beaver
//
//  Created by 何 义 on 14-3-2.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBSingleChoiceView.h"
#import "EBViewFactory.h"
#import "EBStyle.h"
#import "EBFilter.h"
#import "EBAlert.h"

@interface EBSingleChoiceView () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_rightTableView;
    UITableView *_leftTableView;
    UIButton *_dismissButton;
    NSArray *_leftArray;
    NSArray *_rightArray;
    UITextField *_downTextField;
    UITextField *_upTextField;
    CustomConditionType _customType;
}
@end

@implementation EBSingleChoiceView

#define HEIGHT_EXTRA 68.0
#define WIDTH_LEFT_TABLE_WIDTH 115.0

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _rightTableView = [[UITableView alloc]initWithFrame:[EBStyle fullScrTableFrame:NO]];
        _rightTableView.backgroundView.alpha = 0;
        _rightTableView.dataSource = self;
        _rightTableView.delegate = self;
        _rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_rightTableView];
        [self setTouchBackDisabled:NO];
    }

    return self;
}

- (void)setFooterText:(NSString *)footerText
{
    _footerText = footerText;
    if (footerText)
    {
        CGSize sz = [EBViewFactory textSize:footerText font:[UIFont systemFontOfSize:12.0] bounding:CGSizeMake(300, CGFLOAT_MAX)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 300, sz.height + 10)];

        label.text = footerText;
        label.numberOfLines = 0;
        label.textColor = [EBStyle grayTextColor];
        label.font = [UIFont systemFontOfSize:12.0];

        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], label.frame.size.height)];
        [footer addSubview:label];

        _rightTableView.tableFooterView = footer;
    }
    else
    {
        _rightTableView.tableFooterView = nil;
    }
}

- (void)setHeaderText:(NSString *)headerText
{
    _footerText = headerText;
    if (headerText)
    {
        CGSize sz = [EBViewFactory textSize:headerText font:[UIFont systemFontOfSize:12.0] bounding:CGSizeMake(300, CGFLOAT_MAX)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 300, sz.height + 10)];

        label.text = headerText;
        label.numberOfLines = 0;
        label.textColor = [EBStyle grayTextColor];
        label.font = [UIFont systemFontOfSize:12.0];

        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], label.frame.size.height)];
        [header addSubview:label];

        _rightTableView.tableHeaderView = header;
    }
    else
    {
        _rightTableView.tableHeaderView = nil;
    }
}

- (void)setTouchBackDisabled:(BOOL)touchBackDisabled
{
    _touchBackDisabled = touchBackDisabled;
    if (_touchBackDisabled)
    {
        self.backgroundColor = [UIColor clearColor];
        [_dismissButton removeFromSuperview];
        _dismissButton = nil;
    }
    else
    {
        if (_dismissButton == nil)
        {
            self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
            _dismissButton = [[UIButton alloc] initWithFrame:self.bounds];
            [self addSubview:_dismissButton];
            [self sendSubviewToBack:_dismissButton];
            [_dismissButton addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)ensureLeftTableExist
{
    if (_leftTableView == nil)
    {
        CGRect leftFrame = [EBStyle fullScrTableFrame:NO];
        leftFrame.size.width = WIDTH_LEFT_TABLE_WIDTH;
        _leftTableView = [[UITableView alloc]initWithFrame:leftFrame];
//        _leftTableView.backgroundView.alpha = 0;
        _leftTableView.dataSource = self;
        _leftTableView.delegate = self;
        _leftTableView.backgroundView.backgroundColor = [UIColor colorWithWhite:246/255.0f alpha:1.0];
        _leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _leftTableView.hidden = YES;
//        _leftTableView.separatorInset = UIEdgeInsetsZero;
        [self addSubview:_leftTableView];
    }
}

- (BOOL)useLeftTableView
{
    if (_choices.count > 0)
    {
        [self ensureLeftTableExist];
        id obj = _choices[0];
        if ([obj isKindOfClass:[NSDictionary class]])
        {
           NSDictionary *item = (NSDictionary *)obj;
           if (item[@"children"] && [item[@"children"] isKindOfClass:[NSArray class]])
           {
               _leftArray = _choices;
               _rightArray = _choices[_leftIndex][@"children"];
               return YES;
           }
        }
    }

    _leftArray = nil;

    return NO;
}

- (void)setChoices:(NSArray *)choices
{
    NSLog(@"choices = %@",choices);
    if ([self.title isEqualToString:NSLocalizedString(@"filter_area", @"filter_area")])
    {
        _customType = CustomArea;
    }
    else if ([self.title isEqualToString:NSLocalizedString(@"filter_price", @"filter_price")])
    {
        if (self.houseType == 1)
        {
            _customType = CustomPriceRent;
        }
        else
        {
            _customType = CustomPriceSale;
        }
    }
    else
    {
        _customType = CustomNone;
    }
    _choices = choices;

//    CGRect leftFrame = _leftTableView.frame;
    if ([self useLeftTableView])
    {
        _leftTableView.hidden = NO;

        CGRect rightFrame = _rightTableView.frame;
        rightFrame.origin.x = WIDTH_LEFT_TABLE_WIDTH;
        rightFrame.size.width = self.frame.size.width - WIDTH_LEFT_TABLE_WIDTH;
        _rightTableView.frame = rightFrame;

        [_leftTableView reloadData];
        [_leftTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_leftIndex inSection:0] animated:YES
                              scrollPosition:UITableViewScrollPositionTop];
    }
    else
    {
        _leftTableView.hidden = YES;
        CGRect rightFrame = _rightTableView.frame;
        rightFrame.origin.x = 0;
        rightFrame.size.width = self.frame.size.width;
        _rightTableView.frame = rightFrame;

        _rightArray = _choices;
    }

    if (!_touchBackDisabled)
    {
//        NSInteger rows = _leftArray.count > _rightArray.count ? _leftArray.count : _rightArray.count;
        NSInteger rightArrayCount = [self tableView:_rightTableView numberOfRowsInSection:0];
        NSInteger rows = _leftArray.count > rightArrayCount ? _leftArray.count : rightArrayCount;
        CGFloat newHeight = 44.0 * rows;
        if (newHeight > self.frame.size.height - HEIGHT_EXTRA)
        {
            newHeight = self.frame.size.height - HEIGHT_EXTRA;
        }
        _rightTableView.frame = CGRectMake(_rightTableView.frame.origin.x, _rightTableView.frame.origin.y, _rightTableView.frame.size.width, newHeight);
        _leftTableView.frame = CGRectMake(_leftTableView.frame.origin.x, _leftTableView.frame.origin.y, _leftTableView.frame.size.width, newHeight);
    }

   [_rightTableView reloadData];

   if (_rightArray.count > 0 && _rightIndex >= 0)
   {
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC / 2), dispatch_get_main_queue(), ^
       {
           [_rightTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_rightIndex inSection:0]
                                  atScrollPosition:UITableViewScrollPositionTop animated:YES];
       });
   }
}

- (void) tapped:(UIButton *) btn
{
     self.makeChoice(-1 , -1);
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_hideRowZero) {
        if (indexPath.row == 0) {
            return 0;
        }
    }
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _leftTableView)
    {
        return _leftArray.count;
    }
    else
    {
        if (_customType != CustomNone)
        {
            return _rightArray.count + 1;
        }
        else
        {
            return _rightArray.count;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _rightTableView)
    {
        if (indexPath.row == _rightArray.count && _customType != CustomNone)
        {
            _rightIndex = [indexPath row];
            if (_customType == CustomPriceRent || _customType == CustomPriceSale)
            {
                [self showCustomCondtionAlertView:NSLocalizedString(@"price_custom_title", @"price_title")];
            }
            else if(_customType == CustomArea)
            {
                [self showCustomCondtionAlertView:NSLocalizedString(@"area_custom_title", @"area_title")];
            }
        }
        else
        {
            _rightIndex = [indexPath row];
            [tableView reloadData];
            self.makeChoice(_rightIndex, _leftIndex);
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        _leftIndex = [indexPath row];
        _rightIndex = -1;
        _rightArray = _leftArray[_leftIndex][@"children"];
        [_rightTableView reloadData];
        if (_rightArray.count > 0)
        {
            [_rightTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                   atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
//    self.makeChoice(self.selectedIndex);
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = tableView == _leftTableView ? @"leftCell" : @"rightCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];

        cell.textLabel.textColor = [EBStyle blackTextColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        if (tableView == _leftTableView)
        {
            UIView *backgroundView = [[UIView alloc] init];
            backgroundView.backgroundColor = [UIColor colorWithWhite:246/255.f alpha:1.0];

            UIView *rightLine = [[UIView alloc] initWithFrame:CGRectMake(114.5, 0, 0.5, 44)];
            rightLine.backgroundColor = [EBStyle grayUnClickLineColor];
            [backgroundView addSubview:rightLine];
            cell.backgroundView = backgroundView;

            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];

            UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 115, 0.5)];
            topLine.backgroundColor = [EBStyle grayUnClickLineColor];
            [view addSubview:topLine];

            UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 44.5, 115, 0.5)];
            bottomLine.backgroundColor = [EBStyle grayUnClickLineColor];
            [view addSubview:bottomLine];

            cell.selectedBackgroundView = view;

            [cell addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:44 leftMargin:0]];

            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 115.0, 44.0)];
            titleLabel.textColor = [EBStyle blackTextColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.font = [UIFont systemFontOfSize:14.0];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.tag = 1001;
            [cell addSubview:titleLabel];
            
//            cell.textLabel.backgroundColor = [UIColor clearColor];
        }
        else
        {
            [cell addSubview:[EBViewFactory defaultTableViewSeparator]];
        }
    }

    [self tableView:tableView updateCell:cell atRow:[indexPath row]];
    if (_hideRowZero && indexPath.row == 0) {
        cell.hidden = YES;
    }
    else
    {
        cell.hidden = NO;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView updateCell:(UITableViewCell *)cell atRow:(NSInteger)row
{
    NSArray *array = tableView == _leftTableView ? _leftArray : _rightArray;
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1001];
    if (titleLabel == nil)
    {
        titleLabel = cell.textLabel;
    }
    if (row == array.count && _customType != CustomNone)
    {
        if (_customType == CustomPriceRent || _customType == CustomPriceSale)
        {
            titleLabel.text = NSLocalizedString(@"price_custom_cell", @"price");
        }
        else if(_customType == CustomArea)
        {
            titleLabel.text = NSLocalizedString(@"area_custom_cell", @"area");
        }
    }
    else
    {
        id item = array[row];
        
        if ([item isKindOfClass:[NSDictionary class]])
        {
            titleLabel.text = item[@"title"];
        }
        else if ([item isKindOfClass:[NSString class]])
        {
            titleLabel.text = item;
        }
    }
    
    if (_rightTableView == tableView && row == _rightIndex)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if (_downTextField.text.length == 0 || _upTextField.text.length == 0)
        {
            [self showEmptyErrorAlertView];
            return;
        }
        NSInteger downValue = [_downTextField.text integerValue];
        NSInteger upValue =  [_upTextField.text integerValue];
        if (downValue > upValue)
        {
            [self showErrorAlertView];
            return;
        }
        if (downValue == 0 && upValue == 0)
        {
            _rightIndex = 0;
        }
        else
        {
            if (_customType == CustomPriceRent)
            {
                _rightIndex = [EBFilter ensureRentPriceExist:downValue up:upValue];
            }
            else if (_customType == CustomPriceSale)
            {
                _rightIndex = [EBFilter ensureSalePriceExist:downValue up:upValue];
            }
            else if (_customType == CustomArea)
            {
                _rightIndex = [EBFilter ensureAreaExist:downValue up:upValue];
            }
        }
        self.makeChoice(_rightIndex, _leftIndex);
        [_rightTableView reloadData];
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        _downTextField = [alertView textFieldAtIndex:0];
        _upTextField = [alertView textFieldAtIndex:1];
        [_upTextField setSecureTextEntry:NO];
    }
    _downTextField.keyboardType = UIKeyboardTypeNumberPad;
    _upTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    if (_customType == CustomPriceRent)
    {
        _downTextField.placeholder = NSLocalizedString(@"price_rent_custom_down", @"down");
        _upTextField.placeholder = NSLocalizedString(@"price_rent_custom_up", @"up");
    }
    else if(_customType == CustomPriceSale)
    {
        _downTextField.placeholder = NSLocalizedString(@"price_sale_custom_down", @"down");
        _upTextField.placeholder = NSLocalizedString(@"price_sale_custom_up", @"up");
    }
    else if(_customType == CustomArea)
    {
        _downTextField.placeholder = NSLocalizedString(@"area_custom_down", @"down");
        _upTextField.placeholder = NSLocalizedString(@"area_custom_up", @"up");
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    [_downTextField becomeFirstResponder];
}

#pragma mark- Private Method

- (void)showErrorAlertView
{
    if (_customType == CustomPriceRent || _customType == CustomPriceSale)
    {
        [EBAlert alertError:NSLocalizedString(@"alert_custom_price", nil)];

    }
    else if(_customType == CustomArea)
    {
        [EBAlert alertError:NSLocalizedString(@"alert_custom_area", nil)];
    }
}

- (void)showEmptyErrorAlertView
{
    if (_customType == CustomPriceRent || _customType == CustomPriceSale)
    {
        [EBAlert alertError:NSLocalizedString(@"alert_empty_price", nil)];
        
    }
    else if(_customType == CustomArea)
    {
        [EBAlert alertError:NSLocalizedString(@"alert_empty_area", nil)];
    }
}

- (void)showCustomCondtionAlertView:(NSString *)title
{
    NSString *temp = nil;
    if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
        if (temp == nil) {
            temp = @"";
        }
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:temp message:title delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"cancel") otherButtonTitles:NSLocalizedString(@"confirm", @"confirm"), nil];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
    {
        UIView *view = [self alertViewCustomInputViewForEight];
        [alertView setValue:view forKey:@"accessoryView"];
    }
    else if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        UIView *view = [self alertViewCustomInputView];
        [alertView setValue:view forKey:@"accessoryView"];
    }
    else
    {
        alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    }
    [alertView show];
}

- (UIView *)alertViewCustomInputView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15.0, 0.0, 240.0, 60.5)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderWidth = 0.5;
    view.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    
    _downTextField = [[UITextField alloc] initWithFrame:CGRectMake(6.0, 0.0, 232, 30)];
    _downTextField.font = _upTextField.font = [UIFont systemFontOfSize:13.0];
    _upTextField = [[UITextField alloc] initWithFrame:CGRectMake(6.0, 30.5, 232, 30)];
    _upTextField.font = [UIFont systemFontOfSize:13.0];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 30.0, 240.0, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];

    [view addSubview:_downTextField];
    [view addSubview:lineView];
    [view addSubview:_upTextField];
    return view;
}

- (UIView *)alertViewCustomInputViewForEight
{
    UIView *groundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 80.5)];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15.0, 0.0, 240.0, 60.5)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderWidth = 0.5;
    view.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    
    _downTextField = [[UITextField alloc] initWithFrame:CGRectMake(6.0, 0.0, 232, 30)];
    _downTextField.font = _upTextField.font = [UIFont systemFontOfSize:13.0];
    _upTextField = [[UITextField alloc] initWithFrame:CGRectMake(6.0, 30.5, 232, 30)];
    _upTextField.font = [UIFont systemFontOfSize:13.0];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 30.0, 240.0, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    
    [view addSubview:_downTextField];
    [view addSubview:lineView];
    [view addSubview:_upTextField];
    [groundView addSubview:view];
    return groundView;
}

@end
