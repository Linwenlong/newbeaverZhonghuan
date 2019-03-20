//
//  EBElementParser.m
//  MyQuickDialog
//
//  Created by LiuLian on 7/24/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#define EBElementParserKeyId @"id"
#define EBElementParserKeyType @"type"
#define EBElementParserKeyName @"name"
#define EBElementParserKeyStar @"star"
#define EBElementParserKeyRequired @"required"
#define EBElementParserKeyDesc @"desc"
#define EBElementParserKeyValues @"values"
#define EBElementParserKeyPlaceholder @"placeholder"
//#define EBElementParserKeySuffix @"suffix"
//#define EBElementParserKeyText @"text"
#define EBElementParserKeyInputType @"input_type"
#define EBElementParserKeyReg @"reg"
#define EBElementParserKeyUnderline @"underline"
#define EBElementParserKeyMerge @"merge"
#define EBElementParserKeyNewline @"newline"
#define EBElementParserKeyVisible @"visible"
#define EBElementParserKeyCurrentValue @"current_value"
#define EBElementParserKeyCannot_edit  @"cannot_edit"
#import <objc/message.h>
#import "EBElementParser.h"
#import "EBElementStyle.h"
#import "EBElementView.h"
#import "EBInputView.h"
#import "EBInputElement.h"
#import "EBSelectView.h"
#import "EBSelectElement.h"
#import "EBTextareaView.h"
#import "EBTextareaElement.h"
#import "EBCheckElement.h"
#import "EBCheckView.h"
#import "EBInputSelectView.h"
#import "EBRangeView.h"
#import "EBRegionElement.h"
#import "EBRegionView.h"

@interface EBElementParser ()

@property (nonatomic, assign) NSInteger lifts;      //梯
@property (nonatomic, assign) NSInteger rooms;      //户
@property (nonatomic, assign) NSInteger floor;      //楼层
@property (nonatomic, assign) NSInteger totleFloor; //总楼层

//房号锁定
@property (nonatomic, assign) CGFloat usable_area;      //使用面积
@property (nonatomic, assign) NSInteger room;      //室
@property (nonatomic, assign) NSInteger living_room;      //厅
@property (nonatomic, assign) NSInteger washroom;      //卫
@property (nonatomic, assign) NSInteger balcony; //阳台

@end


@implementation EBElementParser
@synthesize delegate;


//开启了楼盘字典 房号锁定
- (void)parse:(NSArray *)elements lifts:(NSInteger)lifts rooms:(NSInteger)rooms floor:(NSInteger)floor totleFloor:(NSInteger)totleFloor room:(NSInteger)room living_room:(NSInteger)living_room washroom:(NSInteger)washroom balcony:(NSInteger)balcony area:(CGFloat)usable_area{
    _lifts = lifts;
    _rooms = rooms;
    _floor = floor;
    _totleFloor = totleFloor;
    _room = room;
    _living_room = living_room;
    _washroom = washroom;
    _balcony = balcony;
    _usable_area = usable_area;
    [self parse:elements];
}

//开启了楼盘字典 房号未锁定
- (void)parse:(NSArray *)elements lifts:(NSInteger)lifts rooms:(NSInteger)rooms floor:(NSInteger)floor totleFloor:(NSInteger)totleFloor{
    _lifts = lifts;
    _rooms = rooms;
    _floor = floor;
    _totleFloor = totleFloor;
    [self parse:elements];
}


- (void)parse:(NSArray *)elements
{
    NSUInteger index = 0;
    for (NSDictionary *element in elements) {
        NSString *type = [element objectForKey:EBElementParserKeyType];
        if (!type || [type isEqualToString:@""]) {
            type = @"tmp";
        }
        NSString *method = [self method:type];
        if (!method) {
            continue;
        }
        SEL methodSel = NSSelectorFromString(method);
        if (![self respondsToSelector:methodSel]) {
            continue;
        }
        
        EBElementView* (*action)(id, SEL, id, NSUInteger) = (EBElementView* (*)(id, SEL, id, NSUInteger)) objc_msgSend;
        EBElementView *elementView = action(self, methodSel, element, index);
//        EBElementView *elementView = objc_msgSend(self, methodSel, element, index);
        index++;
        if (delegate && [delegate respondsToSelector:@selector(parserDidEndElement:elementIndex:)]) {
            [delegate parserDidEndElement:elementView elementIndex:index];
        }
    }
    
    if (delegate && [delegate respondsToSelector:@selector(parserDidEndData:)]) {
        [delegate parserDidEndData:elements];
    }
}

- (NSString *)method:(NSString *)type
{
    NSDictionary *typeMethod = @{@"tmp": @"createTmpView::", @"input": @"createInputView::", @"select": @"createSelectView::", @"textarea": @"createTextareaView::", @"check": @"createCheckView::", @"date": @"createDateView::", @"contact": @"createContactView::", @"multi_select": @"createMultiSelectView::", @"input_and_select": @"createInputSelectView::", @"region": @"createRegionView::", @"range": @"createRangeView::"};
    return typeMethod[type];
}

- (NSUInteger)elementIndex:(NSDictionary *)element index:(NSUInteger)index
{
    return [element objectForKey:EBElementParserKeyMerge] ? index : ++index;
}

- (EBElementView *)createTmpView:(NSDictionary *)element :(NSUInteger)index
{
    EBPrefixView *elementView = [EBPrefixView new];
    EBPrefixElement *prefixElement = [EBPrefixElement new];
    prefixElement.eid = [element objectForKey:EBElementParserKeyId];
    prefixElement.prefix = [element objectForKey:EBElementParserKeyName];
    prefixElement.name = prefixElement.prefix;
    id star = [element objectForKey:EBElementParserKeyStar];
    prefixElement.star = star ? [star integerValue] : 0;
    id required = [element objectForKey:EBElementParserKeyRequired];
    prefixElement.required = required ? [required boolValue] : NO;
    id visible = [element objectForKey:EBElementParserKeyVisible];
    prefixElement.visible = visible ? [visible boolValue] : YES;
    prefixElement.text = [element objectForKey:EBElementParserKeyCurrentValue];
    elementView.element = prefixElement;
    if (delegate && [delegate respondsToSelector:@selector(elementStyle:elementIndex:)]) {
        elementView.style = [delegate elementStyle:elementView elementIndex:index];
    } else {
        elementView.style = [EBElementStyle defaultStyle];
    }
    if (delegate && [delegate respondsToSelector:@selector(elementFrame:elementIndex:)]) {
        elementView.frame = [delegate elementFrame:elementView elementIndex:index];
    } else {
        elementView.frame = [EBElementView defaultFrame];
    }
//    [elementView drawView];
    return elementView;
}

//创建输入框
- (EBElementView *)createInputView:(NSDictionary *)element :(NSUInteger)index
{
    EBInputView *inputView = [EBInputView new];
//    inputView.userInteractionEnabled = NO;
    EBInputElement *inputElement = [EBInputElement new];
    inputElement.eid = [element objectForKey:EBElementParserKeyId];
    inputElement.prefix = [element objectForKey:EBElementParserKeyName];
    inputElement.name = inputElement.prefix;
    inputElement.cannot_edit = [element objectForKey:EBElementParserKeyCannot_edit];
    id star = [element objectForKey:EBElementParserKeyStar];
    inputElement.star = star ? [star integerValue] : 0;
    id required = [element objectForKey:EBElementParserKeyRequired];
    inputElement.required = required ? [required boolValue] : NO;
    inputElement.placeholder = [element objectForKey:EBElementParserKeyPlaceholder];
    inputElement.reg = [element objectForKey:EBElementParserKeyReg];
    inputElement.suffix = [element objectForKey:EBElementParserKeyDesc];
    inputElement.inputType = [element objectForKey:EBElementParserKeyInputType];
    id visible = [element objectForKey:EBElementParserKeyVisible];
    inputElement.visible = visible ? [visible boolValue] : YES;
    
    //梯
    if (self.is_addHouse == YES) {//新增房源
        if (self.if_start == YES) {//开启了座栋规则
            if (self.if_lock == YES) {//多加了户型跟使用面积
                if ([element.allKeys containsObject:@"desc"] && [element[@"desc"] isEqualToString:@"梯"]) {
                    inputElement.cannot_edit = YES;
                    inputElement.text = [NSString stringWithFormat:@"%ld",_lifts];
                }else if ([element.allKeys containsObject:@"desc"] && [element[@"desc"] isEqualToString:@"户"]) {
                    inputElement.cannot_edit = YES;
                    inputElement.text = [NSString stringWithFormat:@"%ld",_rooms];
                }else if ([element.allKeys containsObject:@"desc"] && [element[@"desc"] isEqualToString:@"楼层"]){
                    inputElement.cannot_edit = YES;
                    inputElement.text = [NSString stringWithFormat:@"%ld",_floor];
                }else if ([element.allKeys containsObject:@"desc"] && [element[@"desc"] isEqualToString:@"总楼层"]){
                    inputElement.cannot_edit = YES;
                    inputElement.text = [NSString stringWithFormat:@"%ld",_totleFloor];
                }else if ([element.allKeys containsObject:@"desc"] && [element[@"desc"] isEqualToString:@"室"]) {
                    inputElement.cannot_edit = YES;
                    inputElement.text = [NSString stringWithFormat:@"%ld",_room];
                }else if ([element.allKeys containsObject:@"desc"] && [element[@"desc"] isEqualToString:@"厅"]){
                    inputElement.cannot_edit = YES;
                    inputElement.text = [NSString stringWithFormat:@"%ld",_living_room];
                }else if ([element.allKeys containsObject:@"desc"] && [element[@"desc"] isEqualToString:@"卫"]){
                    inputElement.cannot_edit = YES;
                    inputElement.text = [NSString stringWithFormat:@"%ld",_washroom];
                }else if ([element.allKeys containsObject:@"desc"] && [element[@"desc"] isEqualToString:@"阳台"]){
                    inputElement.cannot_edit = YES;
                    inputElement.text = [NSString stringWithFormat:@"%ld",_balcony];
                }else if ([element.allKeys containsObject:@"name"] && [element[@"name"] isEqualToString:@"建筑面积"]){
                    inputElement.cannot_edit = YES;
                    inputElement.text = [NSString stringWithFormat:@"%.02f",_usable_area];
                }else{
                   
                    inputElement.text = [element objectForKey:EBElementParserKeyCurrentValue];
                }
            }else{
                if ([element.allKeys containsObject:@"desc"] && [element[@"desc"] isEqualToString:@"梯"]) {
                    inputElement.cannot_edit = YES;
                    inputElement.text = [NSString stringWithFormat:@"%ld",_lifts];
                }else if ([element.allKeys containsObject:@"desc"] && [element[@"desc"] isEqualToString:@"户"]) {
                    inputElement.cannot_edit = YES;
                    inputElement.text = [NSString stringWithFormat:@"%ld",_rooms];
                }else if ([element.allKeys containsObject:@"desc"] && [element[@"desc"] isEqualToString:@"楼层"]){
                    inputElement.cannot_edit = YES;
                    inputElement.text = [NSString stringWithFormat:@"%ld",_floor];
                }else if ([element.allKeys containsObject:@"desc"] && [element[@"desc"] isEqualToString:@"总楼层"]){
                    inputElement.cannot_edit = YES;
                    inputElement.text = [NSString stringWithFormat:@"%ld",_totleFloor];
                }else{
                    inputElement.text = [element objectForKey:EBElementParserKeyCurrentValue];
                }
            }
        }else{//没有开启座栋规则
           inputElement.text = [element objectForKey:EBElementParserKeyCurrentValue];
        }
    }else{//编辑房源
         inputElement.text = [element objectForKey:EBElementParserKeyCurrentValue];
        if (self.if_start) {//开启了座栋规则 七要素不能修改
            NSArray *tmp = @[@"梯",@"户",@"楼层",@"总楼层",@"室",@"厅",@"卫",@"阳台"];
            if ([element.allKeys containsObject:@"desc"] &&
                [tmp containsObject:element[@"desc"]]) {
                inputElement.cannot_edit = YES;
            }
        }
    }
  
    inputView.element = inputElement;
    if (delegate && [delegate respondsToSelector:@selector(elementStyle:elementIndex:)]) {
        inputView.style = [delegate elementStyle:inputView elementIndex:index];
//        inputView.style.underline = (BOOL)[element objectForKey:EBElementParserKeyUnderline];
    } else {
        inputView.style = [EBElementStyle defaultStyle];
    }
    inputView.style.merge = (BOOL)[element objectForKey:EBElementParserKeyMerge];
    inputView.style.newline = (BOOL)[element objectForKey:EBElementParserKeyNewline];
    if (delegate && [delegate respondsToSelector:@selector(elementFrame:elementIndex:)]) {
        inputView.frame = [delegate elementFrame:inputView elementIndex:index];
    } else {
        inputView.frame = [EBElementView defaultFrame];
    }
//    [inputView drawView];
    
    return inputView;
}

- (EBElementView *)createSelectView:(NSDictionary *)element :(NSUInteger)index
{
    EBSelectView *selectView = [EBSelectView new];
    EBSelectElement *selectElement = [EBSelectElement new];
    selectElement.eid = [element objectForKey:EBElementParserKeyId];
    selectElement.prefix = [element objectForKey:EBElementParserKeyName];
    selectElement.name = selectElement.prefix;
    id star = [element objectForKey:EBElementParserKeyStar];
    selectElement.star = star ? [star integerValue] : 0;
    id required = [element objectForKey:EBElementParserKeyRequired];
    selectElement.required = required ? [required boolValue] : NO;
    selectElement.options = (NSArray *)[element objectForKey:EBElementParserKeyValues];
    selectElement.placeholder = [element objectForKey:EBElementParserKeyPlaceholder];
    id visible = [element objectForKey:EBElementParserKeyVisible];
    selectElement.visible = visible ? [visible boolValue] : YES;
    selectElement.display = [element objectForKey:@"display"];
    selectElement.match = [element objectForKey:@"match"];
    selectElement.text = [element objectForKey:EBElementParserKeyCurrentValue];
    selectView.element = selectElement;
    if (delegate && [delegate respondsToSelector:@selector(elementStyle:elementIndex:)]) {
        selectView.style = [delegate elementStyle:selectView elementIndex:index];
//        selectView.style.underline = (BOOL)[element objectForKey:EBElementParserKeyUnderline];
    } else {
        selectView.style = [EBElementStyle defaultStyle];
    }
    selectView.style.merge = (BOOL)[element objectForKey:EBElementParserKeyMerge];
    selectView.style.newline = (BOOL)[element objectForKey:EBElementParserKeyNewline];
    if (delegate && [delegate respondsToSelector:@selector(elementFrame:elementIndex:)]) {
        selectView.frame = [delegate elementFrame:selectView elementIndex:index];
    } else {
        selectView.frame = [EBElementView defaultFrame];
    }
//    [selectView drawView];
    
    return selectView;
}

- (EBElementView *)createMultiSelectView:(NSDictionary *)element :(NSUInteger)index
{
    EBSelectView *selectView = [EBSelectView new];
    EBSelectElement *selectElement = [EBSelectElement new];
    selectElement.eid = [element objectForKey:EBElementParserKeyId];
    selectElement.multiSelect = YES;
    selectElement.selectedIndexes = [NSArray new];
    selectElement.prefix = [element objectForKey:EBElementParserKeyName];
    selectElement.name = selectElement.prefix;
    id star = [element objectForKey:EBElementParserKeyStar];
    selectElement.star = star ? [star integerValue] : 0;
    id required = [element objectForKey:EBElementParserKeyRequired];
    selectElement.required = required ? [required boolValue] : NO;
    selectElement.options = (NSArray *)[element objectForKey:EBElementParserKeyValues];
    selectElement.placeholder = [element objectForKey:EBElementParserKeyPlaceholder];
    id visible = [element objectForKey:EBElementParserKeyVisible];
    selectElement.visible = visible ? [visible boolValue] : YES;
    selectElement.text = [element objectForKey:EBElementParserKeyCurrentValue];
    selectView.element = selectElement;
    if (delegate && [delegate respondsToSelector:@selector(elementStyle:elementIndex:)]) {
        selectView.style = [delegate elementStyle:selectView elementIndex:index];
        //        selectView.style.underline = (BOOL)[element objectForKey:EBElementParserKeyUnderline];
    } else {
        selectView.style = [EBElementStyle defaultStyle];
    }
    selectView.style.merge = (BOOL)[element objectForKey:EBElementParserKeyMerge];
    selectView.style.newline = (BOOL)[element objectForKey:EBElementParserKeyNewline];
    if (delegate && [delegate respondsToSelector:@selector(elementFrame:elementIndex:)]) {
        selectView.frame = [delegate elementFrame:selectView elementIndex:index];
    } else {
        selectView.frame = [EBElementView defaultFrame];
    }
    //    [selectView drawView];
    
    return selectView;
}

- (EBElementView *)createTextareaView:(NSDictionary *)element :(NSUInteger)index
{
    EBTextareaView *textareaView = [EBTextareaView new];
    EBTextareaElement *textareaElement = [EBTextareaElement new];
    textareaElement.eid = [element objectForKey:EBElementParserKeyId];
    id star = [element objectForKey:EBElementParserKeyStar];
    textareaElement.star = star ? [star integerValue] : 0;
    id required = [element objectForKey:EBElementParserKeyRequired];
    textareaElement.required = required ? [required boolValue] : NO;
    textareaElement.placeholder = [element objectForKey:EBElementParserKeyName];
    id visible = [element objectForKey:EBElementParserKeyVisible];
    textareaElement.visible = visible ? [visible boolValue] : YES;
    textareaElement.text = [element objectForKey:EBElementParserKeyCurrentValue];
    textareaView.element = textareaElement;
    if (delegate && [delegate respondsToSelector:@selector(elementStyle:elementIndex:)]) {
        textareaView.style = [delegate elementStyle:textareaView elementIndex:index];
//        textareaView.style.underline = (BOOL)[element objectForKey:EBElementParserKeyUnderline];
    } else {
        textareaView.style = [EBElementStyle defaultStyle];
    }
    if (delegate && [delegate respondsToSelector:@selector(elementFrame:elementIndex:)]) {
        textareaView.frame = [delegate elementFrame:textareaView elementIndex:index];
    } else {
        textareaView.frame = [EBElementView defaultFrame];
    }
//    [textareaView drawView];
    
    return textareaView;
}

- (EBElementView *)createCheckView:(NSDictionary *)element :(NSUInteger)index
{
    EBCheckView *checkView = [EBCheckView new];
    EBCheckElement *checkElement = [EBCheckElement new];
    checkElement.eid = [element objectForKey:EBElementParserKeyId];
    checkElement.prefix = [element objectForKey:EBElementParserKeyName];
    checkElement.name = checkElement.prefix;
    id star = [element objectForKey:EBElementParserKeyStar];
    checkElement.star = star ? [star integerValue] : 0;
    id required = [element objectForKey:EBElementParserKeyRequired];
    checkElement.required = required ? [required boolValue] : NO;
    id visible = [element objectForKey:EBElementParserKeyVisible];
    checkElement.visible = visible ? [visible boolValue] : YES;
    id checked = [element objectForKey:EBElementParserKeyCurrentValue];
    checkElement.checked = checked ? [checked boolValue] : NO;
    checkView.element = checkElement;
    if (delegate && [delegate respondsToSelector:@selector(elementStyle:elementIndex:)]) {
        checkView.style = [delegate elementStyle:checkView elementIndex:index];
    } else {
        checkView.style = [EBElementStyle defaultStyle];
    }
    checkView.style.merge = (BOOL)[element objectForKey:EBElementParserKeyMerge];
    checkView.style.newline = (BOOL)[element objectForKey:EBElementParserKeyNewline];
    if (delegate && [delegate respondsToSelector:@selector(elementFrame:elementIndex:)]) {
        checkView.frame = [delegate elementFrame:checkView elementIndex:index];
    } else {
        checkView.frame = [EBElementView defaultFrame];
    }
//    [checkView drawView];
    
    return checkView;
}

- (EBElementView *)createDateView:(NSDictionary *)element :(NSUInteger)index
{
    EBInputView *inputView = [EBInputView new];
    EBInputElement *inputElement = [EBInputElement new];
    inputElement.eid = [element objectForKey:EBElementParserKeyId];
    inputElement.prefix = [element objectForKey:EBElementParserKeyName];
    inputElement.name = inputElement.prefix;
    id star = [element objectForKey:EBElementParserKeyStar];
    inputElement.star = star ? [star integerValue] : 0;
    id required = [element objectForKey:EBElementParserKeyRequired];
    inputElement.required = required ? [required boolValue] : NO;
    inputElement.placeholder = [element objectForKey:EBElementParserKeyPlaceholder];
    inputElement.reg = [element objectForKey:EBElementParserKeyReg];
    inputElement.suffix = [element objectForKey:EBElementParserKeyDesc];
    inputElement.inputType = EBElementInputTypeDate;
    id visible = [element objectForKey:EBElementParserKeyVisible];
    inputElement.visible = visible ? [visible boolValue] : YES;
    
    NSInteger time = [(NSString*)[element objectForKey:EBElementParserKeyCurrentValue] intValue];
    if (time == 0) {
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        time = [date timeIntervalSince1970];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    
    inputElement.text = confromTimespStr;
    inputView.element = inputElement;
    if (delegate && [delegate respondsToSelector:@selector(elementStyle:elementIndex:)]) {
        inputView.style = [delegate elementStyle:inputView elementIndex:index];
        //        inputView.style.underline = (BOOL)[element objectForKey:EBElementParserKeyUnderline];
    } else {
        inputView.style = [EBElementStyle defaultStyle];
    }
    inputView.style.merge = (BOOL)[element objectForKey:EBElementParserKeyMerge];
    inputView.style.newline = (BOOL)[element objectForKey:EBElementParserKeyNewline];
    if (delegate && [delegate respondsToSelector:@selector(elementFrame:elementIndex:)]) {
        inputView.frame = [delegate elementFrame:inputView elementIndex:index];
    } else {
        inputView.frame = [EBElementView defaultFrame];
    }
//    [inputView drawView];
    
    return inputView;
}

- (EBElementView *)createContactView:(NSDictionary *)element :(NSUInteger)index
{
    EBInputView *inputView = [EBInputView new];
    EBInputElement *inputElement = [EBInputElement new];
    inputElement.eid = [element objectForKey:EBElementParserKeyId];
    inputElement.prefix = [element objectForKey:EBElementParserKeyName];
    inputElement.name = inputElement.prefix;
    id star = [element objectForKey:EBElementParserKeyStar];
    inputElement.star = star ? [star integerValue] : 0;
    id required = [element objectForKey:EBElementParserKeyRequired];
    inputElement.required = required ? [required boolValue] : NO;
    inputElement.placeholder = [element objectForKey:EBElementParserKeyPlaceholder];
    inputElement.reg = [element objectForKey:EBElementParserKeyReg];
    inputElement.suffix = [element objectForKey:EBElementParserKeyDesc];
    inputElement.inputType = EBElementInputTypeContact;
    id visible = [element objectForKey:EBElementParserKeyVisible];
    inputElement.visible = visible ? [visible boolValue] : YES;
    inputElement.text = [element objectForKey:EBElementParserKeyCurrentValue];
    inputView.element = inputElement;
    if (delegate && [delegate respondsToSelector:@selector(elementStyle:elementIndex:)]) {
        inputView.style = [delegate elementStyle:inputView elementIndex:index];
        //        inputView.style.underline = (BOOL)[element objectForKey:EBElementParserKeyUnderline];
    } else {
        inputView.style = [EBElementStyle defaultStyle];
    }
    inputView.style.merge = (BOOL)[element objectForKey:EBElementParserKeyMerge];
    inputView.style.newline = (BOOL)[element objectForKey:EBElementParserKeyNewline];
    if (delegate && [delegate respondsToSelector:@selector(elementFrame:elementIndex:)]) {
        inputView.frame = [delegate elementFrame:inputView elementIndex:index];
    } else {
        inputView.frame = [EBElementView defaultFrame];
    }
//    [inputView drawView];
    
    return inputView;
}

- (EBElementView *)createInputSelectView:(NSDictionary *)element :(NSUInteger)index
{
    EBInputSelectView *inputSelectView = [EBInputSelectView new];
    
    EBPrefixElement *tmpElement = [EBPrefixElement new];
    tmpElement.eid = [element objectForKey:EBElementParserKeyId];
    id star = [element objectForKey:EBElementParserKeyStar];
    tmpElement.star = star ? [star integerValue] : 0;
    id required = [element objectForKey:EBElementParserKeyRequired];
    tmpElement.required = required ? [required boolValue] : NO;
    id visible = [element objectForKey:EBElementParserKeyVisible];
    tmpElement.visible = visible ? [visible boolValue] : YES;
    inputSelectView.element = tmpElement;
    
    EBInputView *inputView = [EBInputView new];
    EBInputElement *inputElement = [EBInputElement new];
    inputElement.prefix = [element objectForKey:EBElementParserKeyName];
    inputElement.name = inputElement.prefix;
    inputElement.placeholder = [element objectForKey:EBElementParserKeyPlaceholder];
    inputElement.reg = [element objectForKey:EBElementParserKeyReg];
    inputElement.suffix = [element objectForKey:EBElementParserKeyDesc];
    inputElement.inputType = [element objectForKey:EBElementParserKeyInputType];
    inputElement.text = [element objectForKey:EBElementParserKeyCurrentValue];
    inputView.element = inputElement;
    
    EBSelectView *selectView = [EBSelectView new];
    EBSelectElement *selectElement = [EBSelectElement new];
    selectElement.selectedIndexes = [NSArray new];
    selectElement.options = (NSArray *)[element objectForKey:EBElementParserKeyValues];
    selectElement.placeholder = [element objectForKey:EBElementParserKeyPlaceholder];
//    selectElement.text = [element objectForKey:EBElementParserKeyCurrentValue];
    selectView.element = selectElement;
    
    inputSelectView.inputView = inputView;
    inputSelectView.selectView = selectView;
    
    if (delegate && [delegate respondsToSelector:@selector(elementStyle:elementIndex:)]) {
        inputSelectView.style = [delegate elementStyle:inputSelectView elementIndex:index];
    } else {
        inputSelectView.style = [EBElementStyle defaultStyle];
    }
    inputSelectView.style.merge = (BOOL)[element objectForKey:EBElementParserKeyMerge];
    inputSelectView.style.newline = (BOOL)[element objectForKey:EBElementParserKeyNewline];
    if (delegate && [delegate respondsToSelector:@selector(elementFrame:elementIndex:)]) {
        inputSelectView.frame = [delegate elementFrame:inputSelectView elementIndex:index];
    } else {
        inputSelectView.frame = [EBElementView defaultFrame];
    }
    
    return inputSelectView;
}

- (EBElementView *)createRegionView:(NSDictionary *)element :(NSUInteger)index
{
//    EBPrefixView *elementView = [EBPrefixView new];
//    EBPrefixElement *prefixElement = [EBPrefixElement new];
//    prefixElement.eid = [element objectForKey:EBElementParserKeyId];
//    prefixElement.prefix = [element objectForKey:EBElementParserKeyName];
//    prefixElement.name = prefixElement.prefix;
//    prefixElement.star = [(NSNumber *)[element objectForKey:EBElementParserKeyStar] integerValue];
//    prefixElement.required = (BOOL)[element objectForKey:EBElementParserKeyRequired];
//    prefixElement.visible = [element objectForKey:EBElementParserKeyVisible] ? NO :YES;
//    NSInteger count = [element objectForKey:@"count"];
//    NSString *district = [element objectForKey:@"district"];
//    district = district ? district : @"";
//    NSString *region = [element objectForKey:@"region"];
//    region = region ? region : @"";
//    NSString *community = [element objectForKey:@"community"];
//    community = community ? community : @"";
//    prefixElement.text = [NSString stringWithFormat:@"%@;%@;%@", district, region, community];
//    elementView.element = prefixElement;
//    if (delegate && [delegate respondsToSelector:@selector(elementStyle:elementIndex:)]) {
//        elementView.style = [delegate elementStyle:elementView elementIndex:index];
//    } else {
//        elementView.style = [EBElementStyle defaultStyle];
//    }
//    if (delegate && [delegate respondsToSelector:@selector(elementFrame:elementIndex:)]) {
//        elementView.frame = [delegate elementFrame:elementView elementIndex:index];
//    } else {
//        elementView.frame = [EBElementView defaultFrame];
//    }
//    //    [elementView drawView];
//    return elementView;
    
    EBRegionView *regionView = [EBRegionView new];
    EBRegionElement *regionElement = [EBRegionElement new];
    regionElement.eid = [element objectForKey:EBElementParserKeyId];
    id star = [element objectForKey:EBElementParserKeyStar];
    regionElement.star = star ? [star integerValue] : 0;
    id required = [element objectForKey:EBElementParserKeyRequired];
    regionElement.required = required ? [required boolValue] : NO;
    regionElement.visible = NO;
    id count = [element objectForKey:@"count"];
    regionElement.count = count ? [count integerValue] : 1;
    regionElement.district = [element objectForKey:@"district"];
    regionElement.region = [element objectForKey:@"region"];
    regionElement.community = [element objectForKey:@"community"];
    regionView.element = regionElement;
    if (delegate && [delegate respondsToSelector:@selector(elementStyle:elementIndex:)]) {
        regionView.style = [delegate elementStyle:regionView elementIndex:index];
    } else {
        regionView.style = [EBElementStyle defaultStyle];
    }
    if (delegate && [delegate respondsToSelector:@selector(elementFrame:elementIndex:)]) {
        regionView.frame = [delegate elementFrame:regionView elementIndex:index];
    } else {
        regionView.frame = [EBElementView defaultFrame];
    }
    return regionView;
}

- (EBElementView *)createRangeView:(NSDictionary *)element :(NSUInteger)index
{
    EBRangeView *rangeView = [EBRangeView new];
    
    EBPrefixElement *tmpElement = [EBPrefixElement new];
    tmpElement.eid = [element objectForKey:EBElementParserKeyId];
    id star = [element objectForKey:EBElementParserKeyStar];
    tmpElement.star = star ? [star integerValue] : 0;
    id required = [element objectForKey:EBElementParserKeyRequired];
    tmpElement.required = required ? [required boolValue] : NO;
    id visible = [element objectForKey:EBElementParserKeyVisible];
    tmpElement.visible = visible ? [visible boolValue] : YES;
    rangeView.element = tmpElement;
    
    EBInputView *inputView = [EBInputView new];
    EBInputElement *inputElement = [EBInputElement new];
    inputElement.prefix = [element objectForKey:EBElementParserKeyName];
    inputElement.name = inputElement.prefix;
    inputElement.placeholder = [element objectForKey:EBElementParserKeyPlaceholder];
    inputElement.reg = [element objectForKey:EBElementParserKeyReg];
    inputElement.inputType = [element objectForKey:EBElementParserKeyInputType];
    inputElement.inputType = inputElement.inputType ? inputElement.inputType : EBElementInputTypeNumber;
    inputElement.text = [element objectForKey:EBElementParserKeyCurrentValue];
    inputView.element = inputElement;
    
    EBInputView *inputView1 = [EBInputView new];
    EBInputElement *inputElement1 = [EBInputElement new];
    inputElement1.prefix = @"至";
    inputElement1.name = inputElement1.prefix;
    inputElement1.placeholder = [element objectForKey:EBElementParserKeyPlaceholder];
    inputElement1.reg = [element objectForKey:EBElementParserKeyReg];
    inputElement1.suffix = [element objectForKey:EBElementParserKeyDesc];
    inputElement1.inputType = [element objectForKey:EBElementParserKeyInputType];
    inputElement1.inputType = inputElement1.inputType ? inputElement1.inputType : EBElementInputTypeNumber;
    inputElement1.text = [element objectForKey:EBElementParserKeyCurrentValue];
    inputView1.element = inputElement1;
    
    rangeView.minInputView = inputView;
    rangeView.maxInputView = inputView1;
    
    if (delegate && [delegate respondsToSelector:@selector(elementStyle:elementIndex:)]) {
        rangeView.style = [delegate elementStyle:rangeView elementIndex:index];
    } else {
        rangeView.style = [EBElementStyle defaultStyle];
    }
    rangeView.style.merge = (BOOL)[element objectForKey:EBElementParserKeyMerge];
    rangeView.style.newline = (BOOL)[element objectForKey:EBElementParserKeyNewline];
    if (delegate && [delegate respondsToSelector:@selector(elementFrame:elementIndex:)]) {
        rangeView.frame = [delegate elementFrame:rangeView elementIndex:index];
    } else {
        rangeView.frame = [EBElementView defaultFrame];
    }
    
    return rangeView;
}
@end
