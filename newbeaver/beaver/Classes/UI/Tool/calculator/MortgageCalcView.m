//
//  MortgageCalcView.m
//  beaver
//
//  Created by 何 义 on 14-2-28.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "MortgageCalcView.h"
#import "EBViewFactory.h"
#import "EBStyle.h"
#import "MHTextField.h"
#import "EBController.h"
#import "EBCompatibility.h"
#import "EBAlert.h"

#define CELL_SELECT_IDENTIFIER @"selectCell"
#define CELL_INPUT_IDENTIFIER @"inputCell"

@interface MortgageCalcView ()
{
    NSMutableArray *_textFields;
    NSMutableDictionary *_textFieldMap;
    MHTextField *_firstTextField;
}
@end

@implementation MortgageCalcView

@synthesize type, tableView = _tableView, delegate;

- (id)initWithFrame:(CGRect)frame withMortgageType:(EMortgageType)mortgageType
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _tableView = [[UITableView alloc]initWithFrame:self.bounds];
        _tableView.backgroundView.alpha = 0;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //        _tableView.separatorColor = [ECStyle grayLineColor];
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        [self addSubview:_tableView];
        
        self.type = mortgageType;
        
        _mortgageHelper = [[MortgageHelper alloc] init];
        _mortgageHelper.mortgageType = mortgageType;
        [_mortgageHelper updateItemSet];
        
        _textFieldMap = [[NSMutableDictionary alloc] init];
        _firstTextField = nil;
    }
    return self;
}

- (void)pushTextField:(MHTextField *)textField
{
    if (_textFields == nil)
    {
        _textFields = [[NSMutableArray alloc] init];
    }

    NSInteger idx = _textFields.count;
    textField.tag = idx;
    [_textFields addObject:textField];
    textField.textFields = _textFields;
}

#pragma mark -------table delegate-------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_mortgageHelper numberOfRows];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *item = [_mortgageHelper dataOfRow:[indexPath row]];
    EMortgageDataItem dataItem = [item[@"dataType"] integerValue];
    
    NSArray *choices = [self.mortgageHelper choicesByDataItem:dataItem];
    if (choices != nil)
    {
        [[EBController sharedInstance] promptChoices:choices withRightChoice:[item[@"value"] integerValue] leftChoice:0 title:item[@"title"] completion:^(NSInteger rightChoice, NSInteger leftChoice){
            item[@"value"] = @(rightChoice);
            if (dataItem == EMortgageDataItemCalcType)
            {
                _mortgageHelper.calcType = rightChoice;
            }
            _firstTextField = nil;
            [_tableView reloadData];
        }];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)checkTextViewBecomeFirst
{
    if (_firstTextField)
    {
        [_firstTextField becomeFirstResponder];
    }
}

#define MORT_MARGIN 15.0f
#define MORT_BTN_GAP 20.0f

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] init];

    [footerView addSubview:[EBViewFactory blueButtonWithFrame:CGRectMake(MORT_MARGIN, MORT_BTN_GAP,
            self.frame.size.width - 2 * MORT_MARGIN, 36.0) title:NSLocalizedString(@"calculate", nil) target:self
            action:@selector(calculate:)]];

    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 60;
}

#pragma mark ---table dataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dataItem = [_mortgageHelper dataOfRow:[indexPath row]];
    EMortgageRowType rowType = [dataItem[@"rowType"] integerValue];
    NSString *cellIdentifier =  rowType == EMortgageRowTypeInput ? CELL_INPUT_IDENTIFIER : CELL_SELECT_IDENTIFIER;
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell addSubview:[EBViewFactory defaultTableViewSeparator]];
        cell.textLabel.textColor = [EBStyle blackTextColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = dataItem[@"title"];

    if (rowType == EMortgageRowTypeInput)
    {
        MHTextField *textField = [self textFieldFromCell:cell unit:dataItem[@"unit"]];
        textField.scrollView = tableView;
//        textField.placeholder = dataItem[@"unit"];
        if ([dataItem[@"value"] integerValue] >= 0)
        {
            textField.text =  dataItem[@"value"];
        }
        else
        {
            textField.text = nil;
        }
        if (([cell.textLabel.text compare:NSLocalizedString(@"md_price_unit", nil)] == NSOrderedSame) ||
            ([cell.textLabel.text compare:NSLocalizedString(@"md_amount", nil)] == NSOrderedSame) ||
            ([cell.textLabel.text compare:NSLocalizedString(@"md_fund_amount", nil)] == NSOrderedSame))
        {
            if (textField.text == nil)
            {
                _firstTextField = textField;
            }
            else if (textField.text.length < 1)
            {
                _firstTextField = textField;
            }
        }

        EMortgageDataItem itemType = [dataItem[@"dataType"] integerValue];
        NSString *key = [NSString stringWithFormat:@"item_%ld", itemType];
        _textFieldMap[key] = textField;

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if  (rowType == EMortgageRowTypeSelect)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UILabel *valueView = [EBViewFactory valueViewFromCell:cell accessory:YES];
        valueView.text = [_mortgageHelper displayForDataItem:[dataItem[@"dataType"] integerValue]];
        if ([dataItem[@"dataType"] integerValue] == EMortgageDataItemInterestRate || [dataItem[@"dataType"] integerValue] == EMortgageDataItemInterestRateF)
        {
           valueView.numberOfLines = 2;
           valueView.font = [UIFont systemFontOfSize:12.0];
        }
        else
        {
            valueView.numberOfLines = 1;
            valueView.font = [UIFont systemFontOfSize:14.0];
        }

        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }

    return cell;
}

- (MHTextField *)textFieldFromCell:(UITableViewCell *)cell unit:(NSString *)unit
{
    MHTextField *textField = nil;
    UILabel *unitLabel = (UILabel *)[cell.contentView viewWithTag:88];
    for(UIView *subView in cell.contentView.subviews)
    {
        if ([subView isKindOfClass:[MHTextField class]])
        {
//            textField = (MHTextField*)subView;
            [subView removeFromSuperview];
            break;
        }
    }

    if (textField == nil)
    {
        textField = [[MHTextField alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        textField.delegate = self;
        textField.textAlignment = NSTextAlignmentRight;
        textField.contentMode = UIViewContentModeRight;
        textField.textColor = [EBStyle blueMainColor];
        textField.font = [UIFont systemFontOfSize:14.0f];
        textField.placeholderColor = [EBStyle grayTextColor];
        [textField setRequired:YES];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        [cell.contentView addSubview:textField];

        [self pushTextField:textField];
    }
    
    if (unitLabel == nil) {
        unitLabel = [[UILabel alloc] init];
        unitLabel.textColor = [EBStyle blueMainColor];
        unitLabel.font = [UIFont systemFontOfSize:14.0];
        unitLabel.tag = 88;
        [cell.contentView addSubview:unitLabel];
    }
    
    CGFloat xOffset = 64.0 + 15.0;//64是按最多4个字算的
    CGFloat y = 1.0,height=44.0;
    if (![EBCompatibility isIOS7Higher])
    {
        y = 13;
        height = 24;
    }

    unitLabel.text = unit;
    CGSize unitSz = [EBViewFactory textSize:unit font:[UIFont systemFontOfSize:14.0f] bounding:CGSizeMake(200, 999)];
    unitLabel.frame = CGRectMake(cell.width - unitSz.width - 15.0, 0, unitSz.width, 44);
    textField.frame = CGRectMake(xOffset, y, unitLabel.frame.origin.x - xOffset, height);

    return textField;
}

- (void)calculate:(UIButton *)btn
{
    for (UITextField *textField in _textFields) {
        [textField resignFirstResponder];
    }
    if ([_mortgageHelper calJudge])
    {
        [delegate calcView:self showResult:[_mortgageHelper calcResult]];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    for (NSString *key in _textFieldMap)
    {
        if (textField == _textFieldMap[key])
        {
            EMortgageDataItem itemType = [[key stringByReplacingOccurrencesOfString:@"item_" withString:@""] integerValue];
            if ([[textField text] length] > 0)
            {
                [_mortgageHelper updateItem:itemType value:[textField text]];
            }
            else
            {
                [_mortgageHelper updateItem:itemType value:@"-1"];
            }
            break;
        }
    }
}

@end

@interface MortgageHelper()
{
    NSArray *_itemSet;
}

@end

@implementation MortgageHelper

@synthesize mortgageType, calcType;

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)updateItemSet
{
    _itemSet = @[
                 [NSMutableDictionary dictionaryWithDictionary:@{@"title" : NSLocalizedString(@"md_paytype", nil), @"value" : @(EMortgagePayTypePrincipal), @"rowType" : @(EMortgageRowTypeSelect), @"dataType" : @(EMortgageDataItemPayType)}],
                 [NSMutableDictionary dictionaryWithDictionary:@{@"title" : NSLocalizedString(@"md_calctype", nil), @"value" : @(EMortgageCalcTypeAmount), @"rowType" : @(EMortgageRowTypeSelect), @"dataType" : @(EMortgageDataItemCalcType)}],
                 [NSMutableDictionary dictionaryWithDictionary:@{@"title" : NSLocalizedString(@"md_price_unit", nil), @"value" : @"10000", @"unit": NSLocalizedString(@"md_pl_money_per", nil), @"rowType" : @(EMortgageRowTypeInput), @"dataType" : @(EMortgageDataItemPriceUnit)}],
                 [NSMutableDictionary dictionaryWithDictionary:@{@"title" : NSLocalizedString(@"md_area", nil), @"value" : @"100", @"unit": NSLocalizedString(@"md_pl_area", nil),@"rowType" : @(EMortgageRowTypeInput), @"dataType" : @(EMortgageDataItemArea)}],
                 [NSMutableDictionary dictionaryWithDictionary:@{@"title" : NSLocalizedString(@"md_percent", nil), @"value" : @0, @"rowType" : @(EMortgageRowTypeSelect), @"dataType" : @(EMortgageDataItemPercent)}],
                 [NSMutableDictionary dictionaryWithDictionary:@{@"title" : NSLocalizedString(@"md_periods", nil), @"value" : @19, @"rowType" : @(EMortgageRowTypeSelect), @"dataType" : @(EMortgageDataItemPeriods)}],
                 [NSMutableDictionary dictionaryWithDictionary:@{@"title" : NSLocalizedString(@"md_interest_rate", nil), @"value" : @4, @"rowType" : @(EMortgageRowTypeSelect), @"dataType" : @(EMortgageDataItemInterestRate)}],
                 [NSMutableDictionary dictionaryWithDictionary:@{@"title" : NSLocalizedString(@"md_fund_amount", nil), @"value" : @"80", @"unit": NSLocalizedString(@"md_pl_money", nil), @"rowType" : @(EMortgageRowTypeInput), @"dataType" : @(EMortgageDataItemFundAmount)}],
                 [NSMutableDictionary dictionaryWithDictionary:@{@"title" : NSLocalizedString(@"md_commercial_amount", nil), @"value" : @"80", @"unit": NSLocalizedString(@"md_pl_money", nil),@"rowType" : @(EMortgageRowTypeInput), @"dataType" : @(EMortgageDataItemCommercialAmount)}],
                 [NSMutableDictionary dictionaryWithDictionary:@{@"title" : NSLocalizedString(@"md_amount", nil), @"value" : @"80", @"unit": NSLocalizedString(@"md_pl_money", nil),@"rowType" : @(EMortgageRowTypeInput), @"dataType" : @(EMortgageDataItemAmount)}],
                 [NSMutableDictionary dictionaryWithDictionary:@{@"title" : NSLocalizedString(@"md_interest_rate_f", nil), @"value" : @1, @"rowType" : @(EMortgageRowTypeSelect), @"dataType" : @(EMortgageDataItemInterestRateF)}],
                 ];
}

- (NSArray *)choicesByDataItem:(EMortgageDataItem)dataItem
{
    switch (dataItem)
    {
        case EMortgageDataItemPayType:
            return [MortgageHelper choicesPayType];
        case EMortgageDataItemCalcType:
            return [MortgageHelper choicesCalcType];
        case EMortgageDataItemPeriods:
            return [MortgageHelper choicesPeriods];
        case EMortgageDataItemPercent:
            return [MortgageHelper choicesPercent];
        case EMortgageDataItemInterestRate:
            return [self choicesInterestRate:EMortgageDataItemInterestRate];
        case EMortgageDataItemInterestRateF:
            return [self choicesInterestRate:EMortgageDataItemInterestRateF];
        default:
            return nil;
    }
}

+ (NSArray *)choicesPayType
{
    static NSArray *payTypes = nil;
    if (payTypes == nil)
    {
        payTypes = @[NSLocalizedString(@"md_paytype_interest", nil), NSLocalizedString(@"md_paytype_principal", nil)];
    }

    return payTypes;
}

+ (NSArray *)choicesCalcType
{
    static NSArray *calcTypes = nil;
    if (calcTypes == nil)
    {
        calcTypes = @[NSLocalizedString(@"md_calctype_amount", nil), NSLocalizedString(@"md_calctype_unit", nil)];
    }

    return calcTypes;
}

+ (NSArray *)choicesPercent
{
    static NSArray *percents = nil;
    if (percents == nil)
    {
        NSArray *percentNumbers = @[@9, @8, @7, @6, @5, @4, @3, @2];
        NSInteger capacity = percentNumbers.count;
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:capacity];
        NSString *format = NSLocalizedString(@"md_percent_format", nil);
        for (NSInteger i = 0; i < capacity; i++)
        {
            array[i] = [NSString stringWithFormat:format, [percentNumbers[i] integerValue]];
        }
        percents = array;
    }

    return percents;
}

+ (NSArray *)choicesPeriods
{
    static NSArray *periods = nil;
    if (periods == nil)
    {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:30];
        NSString *format = NSLocalizedString(@"md_periods_format", nil);
        for (NSInteger i = 1; i < 31; i++)
        {
            [array addObject:[NSString stringWithFormat:format, i, 12 * i]];
//            array[i] = [NSString stringWithFormat:format, i, 12 * i];
        }
        periods = array;
    }

    return periods;
}

- (NSArray *)interestRateConfigs:(EMortgageDataItem)item
{
    static NSArray *configs =nil;

    if (configs == nil)
    {
        configs = @[
                    @{@"date":@[@2015, @6, @28],
                      @"percent":@[@130, @120, @110, @105, @100, @90, @85, @70],
                      @"rate_f":@[@300, @350],
                      @"rate_c":@[@485, @525, @525, @540]},
                    @{@"date":@[@2015, @5, @11],
                      @"percent":@[@130, @120, @110, @105, @100, @90, @85, @70],
                      @"rate_f":@[@325, @375],
                      @"rate_c":@[@510, @550, @550, @565]},
                    @{@"date":@[@2015, @3, @1],
                      @"percent":@[@130, @120, @110, @105, @100, @90, @85, @70],
                      @"rate_f":@[@350, @400],
                      @"rate_c":@[@535, @575, @575, @590]},
                    @{@"date":@[@2014, @11, @22],
                      @"percent":@[@130, @120, @110, @105, @100, @90, @85, @70],
                      @"rate_f":@[@375, @425],
                      @"rate_c":@[@560, @600, @600, @615]},
                    @{@"date":@[@2012, @7, @6],
                      @"percent":@[@120, @110, @105, @100, @90, @85, @70],
                      @"rate_f":@[@400, @450],
                      @"rate_c":@[@600, @615, @640, @655]},
                    @{@"date":@[@2012, @6, @8],
                      @"percent":@[@120, @110, @105, @100, @90, @85, @70],
                      @"rate_f":@[@420, @470],
                      @"rate_c":@[@631, @640, @665, @680]},
                    @{@"date":@[@2011, @7, @7],
                      @"percent":@[@120, @110, @105, @100, @90, @85, @70],
                      @"rate_f":@[@445, @490],
                      @"rate_c":@[@656, @665 ,@690, @705]},
                    @{@"date":@[@2011, @4, @6],
                      @"percent":@[@120, @110, @100, @85, @70],
                      @"rate_f":@[@420, @470],
                      @"rate_c":@[@631, @640, @665, @680]},
                    @{@"date":@[@2011, @2, @9],
                      @"percent":@[@120, @110, @100, @85, @70],
                      @"rate_f":@[@400, @450],
                      @"rate_c":@[@606, @610, @645, @660]},
                    @{@"date":@[@2010, @12, @26],
                      @"percent":@[@120, @110, @100, @85, @70],
                      @"rate_f":@[@375, @430],
                      @"rate_c":@[@581, @585, @622, @640]},
                    @{@"date":@[@2010, @10, @20],
                      @"percent":@[@110, @100, @85, @70],
                      @"rate_f":@[@350, @405],
                      @"rate_c":@[@556, @560, @596, @614]},
                    @{@"date":@[@2008, @12, @23],
                      @"percent":@[@110, @100, @85, @70],
                      @"rate_f":@[@333, @387],
                      @"rate_c":@[@531, @540, @576, @594]},
                    ];
    }
    
    static NSArray *fconfigs =nil;
    
    if (fconfigs == nil)
    {
        fconfigs = @[
                     @{@"date":@[@2015, @6, @28],
                       @"percent":@[@110, @100],
                       @"rate_f":@[@300, @350],
                       @"rate_c":@[@485, @525, @525, @540]},
                     @{@"date":@[@2015, @5, @11],
                       @"percent":@[@110, @100],
                       @"rate_f":@[@325, @375],
                       @"rate_c":@[@510, @550, @550, @565]},
                     @{@"date":@[@2015, @3, @1],
                       @"percent":@[@110, @100],
                       @"rate_f":@[@350, @400],
                       @"rate_c":@[@535, @575, @575, @590]},
                     @{@"date":@[@2014, @11, @22],
                       @"percent":@[@110, @100],
                       @"rate_f":@[@375, @425],
                       @"rate_c":@[@560, @600, @600, @615]},
                     @{@"date":@[@2012, @7, @6],
                       @"percent":@[@110, @100],
                       @"rate_f":@[@400, @450],
                       @"rate_c":@[@600, @615, @640, @655]},
                     @{@"date":@[@2012, @6, @8],
                       @"percent":@[@110, @100],
                       @"rate_f":@[@420, @470],
                       @"rate_c":@[@631, @640, @665, @680]},
                     @{@"date":@[@2011, @7, @7],
                       @"percent":@[@110, @100],
                       @"rate_f":@[@445, @490],
                       @"rate_c":@[@656, @665 ,@690, @705]},
                     @{@"date":@[@2011, @4, @6],
                       @"percent":@[@110, @100],
                       @"rate_f":@[@420, @470],
                       @"rate_c":@[@631, @640, @665, @680]},
                     @{@"date":@[@2011, @2, @9],
                       @"percent":@[@110, @100],
                       @"rate_f":@[@400, @450],
                       @"rate_c":@[@606, @610, @645, @660]},
                     @{@"date":@[@2010, @12, @26],
                       @"percent":@[@110, @100],
                       @"rate_f":@[@375, @430],
                       @"rate_c":@[@581, @585, @622, @640]},
                     @{@"date":@[@2010, @10, @20],
                       @"percent":@[@110, @100],
                       @"rate_f":@[@350, @405],
                       @"rate_c":@[@556, @560, @596, @614]},
                     @{@"date":@[@2008, @12, @23],
                       @"percent":@[@110, @100],
                       @"rate_f":@[@333, @387],
                       @"rate_c":@[@531, @540, @576, @594]},
                     ];
    }
    
    if (item == EMortgageDataItemInterestRateF) {
        return fconfigs;
    }
    return configs;
}

- (NSArray *)choicesInterestRate:(EMortgageDataItem)item
{
    NSArray *rates = nil;
    if (rates == nil)
    {
        NSArray *configs = [self interestRateConfigs:item];
        NSString *format = NSLocalizedString(@"md_rate_format", nil);
        NSString *rateTop = NSLocalizedString(@"md_rate_top", nil);
        NSString *rateTopFormat1 = NSLocalizedString(@"md_rate_top_format1", nil);
        NSString *rateTopFormat2 = NSLocalizedString(@"md_rate_top_format2", nil);
        NSString *rateBase = NSLocalizedString(@"md_rate_base", nil);
        NSString *rateBottom = NSLocalizedString(@"md_rate_bottom", nil);
        NSString *rateBottomFormat = NSLocalizedString(@"md_rate_bottom_format", nil);

        NSMutableArray *array = [[NSMutableArray alloc] init];
        NSInteger idx = 0;
        for (NSDictionary *config in configs)
        {
            NSArray *date = config[@"date"];
            for (id percentObj in config[@"percent"])
            {
                NSInteger percent = [percentObj integerValue];
                NSString *rate = percent > 100 ? rateTop : (percent == 100 ? rateBase : rateBottom);
                NSString *rateFmt = @"";
                if (percent != 100)
                {
                    NSString *rateTopFormat = percent % 10 == 0 ? rateTopFormat1 : rateTopFormat2;
                    rateFmt = percent > 100 ? [NSString stringWithFormat:rateTopFormat, (CGFloat)percent / 100.f] :
                    (percent % 10 == 0 ? [NSString stringWithFormat:rateBottomFormat, percent / 10] :
                     [NSString stringWithFormat:rateBottomFormat, percent]);
                }
                NSDictionary *item = @{@"title":[NSString stringWithFormat:format, [date[0] integerValue],
                                                 [date[1] integerValue], [date[2] integerValue], rate, rateFmt],
                                       @"idx":@(idx), @"factor":@(percent)};
                [array addObject:item];
            }
            idx++;
        }
        
        rates = array;
    }
    
    return rates;
}

- (NSInteger)numberOfRows
{
//   return self.mortgageType == EMortgageTypeCombination ? 5 :(self.calcType == EMortgageCalcTypeUnit ? 7 : 5);
   return [[self dataIndexes] count];
}

-(void)updateItem:(EMortgageDataItem)dataItem value:(id)value
{
    NSMutableDictionary *item = _itemSet[dataItem];
    item[@"value"] = value;
}

-(NSDictionary *)currentInterestRateData:(EMortgageDataItem)item
{
    NSArray *interests = [self choicesInterestRate:item];
    NSDictionary *interestDic =  interests[[_itemSet[item][@"value"] integerValue]];
    NSInteger factor = [interestDic[@"factor"] integerValue];
    NSInteger idx = [interestDic[@"idx"] integerValue];
    NSDictionary *rateConfig = [self interestRateConfigs:item][idx];
    
    NSInteger years = [_itemSet[EMortgageDataItemPeriods][@"value"] integerValue] + 1;
    NSInteger fRate = [rateConfig[@"rate_f"][years > 5 ? 1 : 0] integerValue];
    NSInteger index = 0;
    if (years > 5) {
        index = 3;
    }
    else if (years > 3){
        index = 2;
    }
    else if (years > 1){
        index = 1;
    }
    NSInteger cRate = [rateConfig[@"rate_c"][index] integerValue];

    return @{
       @"factor" : @(factor),
       @"fRate"  : @(fRate),
       @"cRate"  : @(cRate)
    };
}

- (BOOL)calJudge
{
    if (self.mortgageType == EMortgageTypeCommercial)
    {
        if (self.calcType == EMortgageCalcTypeAmount)
        {
            if ([_itemSet[EMortgageDataItemAmount][@"value"] floatValue] < 0)
            {
                [EBAlert alertError:@"请输入贷款总额"];
                return NO;
            }
        }
        else
        {
            if ([_itemSet[EMortgageDataItemPriceUnit][@"value"] floatValue] < 0 && [_itemSet[EMortgageDataItemArea][@"value"] floatValue] < 0)
            {
                [EBAlert alertError:@"请输入单价和面积"];
                return NO;
            }
            else
            {
                if ([_itemSet[EMortgageDataItemPriceUnit][@"value"] floatValue] < 0)
                {
                    [EBAlert alertError:@"请输入单价"];
                    return NO;
                }
                if ([_itemSet[EMortgageDataItemArea][@"value"] floatValue] < 0)
                {
                    [EBAlert alertError:@"请输入面积"];
                    return NO;
                }
            }
            
        }
    }
    else if(self.mortgageType == EMortgageTypeFund)
    {
        if (self.calcType == EMortgageCalcTypeAmount)
        {
            if ([_itemSet[EMortgageDataItemAmount][@"value"] floatValue] < 0)
            {
                [EBAlert alertError:@"请输入贷款总额"];
                return NO;
            }
        }
        else
        {
            if ([_itemSet[EMortgageDataItemPriceUnit][@"value"] floatValue] < 0 && [_itemSet[EMortgageDataItemArea][@"value"] floatValue] < 0)
            {
                [EBAlert alertError:@"请输入单价和面积"];
                return NO;
            }else
            {
                if ([_itemSet[EMortgageDataItemPriceUnit][@"value"] floatValue] < 0)
                {
                    [EBAlert alertError:@"请输入单价"];
                    return NO;
                }
                if ([_itemSet[EMortgageDataItemArea][@"value"] floatValue] < 0)
                {
                    [EBAlert alertError:@"请输入面积"];
                    return NO;
                }
            }
        }
    }
    else if (self.mortgageType == EMortgageTypeCombination)
    {
        if ([_itemSet[EMortgageDataItemFundAmount][@"value"] floatValue] < 0 && [_itemSet[EMortgageDataItemCommercialAmount][@"value"] floatValue] < 0)
        {
            [EBAlert alertError:@"请输入公积金贷款和商业贷款"];
            return NO;
        }
        else
        {
            if ([_itemSet[EMortgageDataItemFundAmount][@"value"] floatValue] < 0)
            {
                [EBAlert alertError:@"请输入公积金贷款"];
                return NO;
            }
            if ([_itemSet[EMortgageDataItemCommercialAmount][@"value"] floatValue] < 0)
            {
                [EBAlert alertError:@"请输入商业贷款"];
                return NO;
            }
        }
    }return YES;
}

- (NSArray *)calcResult
{
    EMortgagePayType payType = [_itemSet[EMortgageDataItemPayType][@"value"] integerValue];
    NSInteger years = [_itemSet[EMortgageDataItemPeriods][@"value"] integerValue] + 1;
    NSInteger periods = 12 * years;
    
    NSInteger fRate = 0, cRate = 0, interestFactor = 0;
    NSDictionary *rateData = nil;
    if (self.mortgageType == EMortgageTypeFund) {
        rateData = [self currentInterestRateData:EMortgageDataItemInterestRateF];
        fRate = [rateData[@"fRate"] integerValue];
    } else if (self.mortgageType == EMortgageTypeCommercial) {
        rateData = [self currentInterestRateData:EMortgageDataItemInterestRate];
        cRate = [rateData[@"cRate"] integerValue];
    } else {
        //        rateData = [self currentInterestRateData:EMortgageDataItemInterestRateF];
        rateData = [self currentInterestRateData:EMortgageDataItemInterestRateF];
        fRate = [rateData[@"fRate"] integerValue];
        
        rateData = [self currentInterestRateData:EMortgageDataItemInterestRate];
        cRate = [rateData[@"cRate"] integerValue];
    }
    
    interestFactor = [rateData[@"factor"] integerValue];
    
    CGFloat fAmount = 0, cAmount = 0;
    if (self.mortgageType == EMortgageTypeCombination)
    {
        fAmount = [_itemSet[EMortgageDataItemFundAmount][@"value"] floatValue] * 10000;
        cAmount = [_itemSet[EMortgageDataItemCommercialAmount][@"value"] floatValue] * 10000;
    }
    else
    {
        CGFloat totalMortgage;
        if (self.calcType == EMortgageCalcTypeUnit)
        {
           CGFloat priceUnit = [_itemSet[EMortgageDataItemPriceUnit][@"value"] floatValue];
           CGFloat area = [_itemSet[EMortgageDataItemArea][@"value"] floatValue];
           CGFloat percent =   9 - [_itemSet[EMortgageDataItemPercent][@"value"] integerValue];
           totalMortgage = priceUnit * area * percent / 10;
        }
        else
        {
            totalMortgage = [_itemSet[EMortgageDataItemAmount][@"value"] floatValue] * 10000;
        }

        if (self.mortgageType == EMortgageTypeFund)
        {
            cRate = 0;
            fAmount = totalMortgage;
        }
        else
        {
            fRate = 0;
            cAmount = totalMortgage;
        }
    }

    return [self calcWithPayType:payType periods:periods fAmount:fAmount fRate:fRate cAmount:cAmount cRate:cRate factor:interestFactor];
}

- (NSArray *)calcWithPayType:(EMortgagePayType)payType periods:(NSInteger)periods fAmount:(CGFloat)fAmount fRate:(NSInteger)fRate
                     cAmount:(CGFloat)cAmount cRate:(NSInteger)cRate factor:(NSInteger)factor
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    CGFloat perFMonth = 0, perCMonth = 0, per = 0, totalMortgage = fAmount + cAmount, totalPayback = 0;
    NSMutableArray *monthPays = nil;
    if (payType == EMortgagePayTypeInterest)
    {
        perFMonth = [self moneyPerMonthWithPayType:payType rate:fRate amount:fAmount periods:periods current:0 factor:factor];
        perCMonth = [self moneyPerMonthWithPayType:payType rate:cRate amount:cAmount periods:periods current:0 factor:factor];

        per = perFMonth + perCMonth;
        totalPayback = per * periods;
    }
    else
    {
        monthPays = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < periods; i++)
        {
            perFMonth = [self moneyPerMonthWithPayType:payType rate:fRate amount:fAmount periods:periods current:i factor:factor];
            perCMonth = [self moneyPerMonthWithPayType:payType rate:cRate amount:cAmount periods:periods current:i factor:factor];

            per = perFMonth + perCMonth;
            totalPayback += per;
            [monthPays addObject:@(per)];
        }
    }

    [result addObject:@{@"title" : NSLocalizedString(@"md_result_total_mortgage", nil) , @"value" : [EBStyle formatMoney:totalMortgage]}];
    [result addObject:@{@"title" : NSLocalizedString(@"md_result_periods", nil) , @"value" : [NSString stringWithFormat:NSLocalizedString(@"md_periods_format", nil), periods / 12, periods]}];
    [result addObject:@{@"title" : NSLocalizedString(@"md_result_interest", nil) , @"value" :  [EBStyle formatMoney:totalPayback - totalMortgage]}];
    [result addObject:@{@"title" : NSLocalizedString(@"md_result_total_pay", nil) , @"value" :  [EBStyle formatMoney:totalPayback]}];
    if (monthPays == nil)
    {
        [result addObject:@{@"title" : NSLocalizedString(@"md_result_per_month", nil) , @"value" :  [EBStyle formatMoney:per]}];
    }
    else
    {
        [result addObject:@{@"title" : NSLocalizedString(@"md_result_plan_month", nil) , @"value" :  monthPays}];
    }

    return result;
}

- (CGFloat)moneyPerMonthWithPayType:(EMortgagePayType)payType rate:(NSInteger)rate
                             amount:(CGFloat)amount periods:(NSInteger)periods current:(NSInteger)curr factor:(NSInteger)factor
{
    if (rate <= 0)
    {
        return 0.0f;
    }
    CGFloat mRate = (CGFloat)rate * factor / 12000000;
    if (payType == EMortgagePayTypeInterest)
    {
        return amount * mRate * (1 + 1 / (pow(1 + mRate, periods) - 1));
    }
    else
    {
        return (amount / periods) * (1 - curr * mRate) + amount * mRate;
    }
}


- (NSArray *)dataIndexes
{
    if (self.mortgageType == EMortgageTypeCombination)
    {
        
        return @[@(EMortgageDataItemPayType), @(EMortgageDataItemFundAmount), @(EMortgageDataItemCommercialAmount),
                 @(EMortgageDataItemPeriods), @(EMortgageDataItemInterestRate), @(EMortgageDataItemInterestRateF)];
    }
    else if (self.mortgageType == EMortgageTypeFund)
    {
        if (self.calcType == EMortgageCalcTypeUnit)
        {
            return @[@(EMortgageDataItemPayType), @(EMortgageDataItemCalcType), @(EMortgageDataItemPriceUnit),
                     @(EMortgageDataItemArea),  @(EMortgageDataItemPercent), @(EMortgageDataItemPeriods), @(EMortgageDataItemInterestRateF)];
        }
        else
        {
            return @[@(EMortgageDataItemPayType), @(EMortgageDataItemCalcType),
                     @(EMortgageDataItemAmount), @(EMortgageDataItemPeriods), @(EMortgageDataItemInterestRateF)];
        }
    } else {
        if (self.calcType == EMortgageCalcTypeUnit)
        {
            return @[@(EMortgageDataItemPayType), @(EMortgageDataItemCalcType), @(EMortgageDataItemPriceUnit),
                     @(EMortgageDataItemArea),  @(EMortgageDataItemPercent), @(EMortgageDataItemPeriods), @(EMortgageDataItemInterestRate)];
        }
        else
        {
            return @[@(EMortgageDataItemPayType), @(EMortgageDataItemCalcType),
                     @(EMortgageDataItemAmount), @(EMortgageDataItemPeriods), @(EMortgageDataItemInterestRate)];
        }
    }
}

- (NSString *)displayForDataItem:(EMortgageDataItem)item
{
    NSDictionary *dataItem = _itemSet[item];
    NSInteger choice = [dataItem[@"value"] integerValue];
    NSArray *choices = [self choicesByDataItem:item];
    id choiceItem = choices[choice];
    if ([choiceItem isKindOfClass:[NSString class]])
    {
        return choiceItem;
    }
    else
    {
        if (item == EMortgageDataItemInterestRate || item == EMortgageDataItemInterestRateF)
        {
            NSDictionary *rateData = [self currentInterestRateData:item];
            
            NSInteger fRate = [rateData[@"fRate"] integerValue];
            NSInteger cRate = [rateData[@"cRate"] integerValue];
            NSInteger factor = [rateData[@"factor"] integerValue];
            
            if (item == EMortgageDataItemInterestRateF) {
                return [NSString stringWithFormat:NSLocalizedString(@"md_rate_format_single", nil), choiceItem[@"title"],
                        (CGFloat)fRate * factor / 10000];
            }
            return [NSString stringWithFormat:NSLocalizedString(@"md_rate_format_single", nil), choiceItem[@"title"],
                    (CGFloat)cRate * factor / 10000];
        }
        else
        {
            return choiceItem[@"title"];
        }
    }
}

- (NSMutableDictionary *)dataOfRow:(NSInteger)row
{
    NSInteger dataIndex = [[self dataIndexes][row] integerValue];
    return _itemSet[dataIndex];
}

@end
