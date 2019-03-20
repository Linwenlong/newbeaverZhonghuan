//
//  EBInputView.m
//  MyQuickDialog
//
//  Created by LiuLian on 7/22/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#define DateFormatter @"YYYY-MM-dd"
#define DateRegex @"((^((1[8-9]\\d{2})|([2-9]\\d{3}))([-\\/\\._])(10|12|0?[13578])([-\\/\\._])(3[01]|[12][0-9]|0?[1-9])$)|(^((1[8-9]\\d{2})|([2-9]\\d{3}))([-\\/\\._])(11|0?[469])([-\\/\\._])(30|[12][0-9]|0?[1-9])$)|(^((1[8-9]\\d{2})|([2-9]\\d{3}))([-\\/\\._])(0?2)([-\\/\\._])(2[0-8]|1[0-9]|0?[1-9])$)|(^([2468][048]00)([-\\/\\._])(0?2)([-\\/\\._])(29)$)|(^([3579][26]00)([-\\/\\._])(0?2)([-\\/\\._])(29)$)|(^([1][89][0][48])([-\\/\\._])(0?2)([-\\/\\._])(29)$)|(^([2-9][0-9][0][48])([-\\/\\._])(0?2)([-\\/\\._])(29)$)|(^([1][89][2468][048])([-\\/\\._])(0?2)([-\\/\\._])(29)$)|(^([2-9][0-9][2468][048])([-\\/\\._])(0?2)([-\\/\\._])(29)$)|(^([1][89][13579][26])([-\\/\\._])(0?2)([-\\/\\._])(29)$)|(^([2-9][0-9][13579][26])([-\\/\\._])(0?2)([-\\/\\._])(29)$))"

#import "EBInputView.h"
#import "EBInputElement.h"
#import "EBElementStyle.h"
#import "EBComponentView.h"
#import "EBTextareaView.h"
#import "RegexKitLite.h"

@interface EBInputView() <UITextFieldDelegate>
{
//    UITextField *_inputTextField;
    UIDatePicker *_datePicker;
    
    CGRect _originFrame;
    CGSize _keyboardSize;
}

@property (weak) id keyboardDidShowNotificationObserver;
@property (weak) id keyboardWillHideNotificationObserver;
@property (nonatomic, weak) UIView *superView;

@end

@implementation EBInputView
@synthesize superView = _superView, toolbar = _toolbar;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)drawView
{
    EBInputElement *inputElement;
    EBElementStyle *style;
    if (!self.element) {
        inputElement = [EBInputElement new];
        self.element = inputElement;
    } else {
        inputElement = (EBInputElement *)self.element;
    }
    if (!self.style) {
        style = [EBElementStyle new];
        style.fontSize = FontSizeDefault;
        style.font = [UIFont systemFontOfSize:style.fontSize];
        style.fontColor = [UIColor darkTextColor];
        style.prefixFont = style.suffixFont = style.font;
        style.prefixFontColor = style.suffixFontColor = style.fontColor;
        self.style = style;
    } else {
        style = self.style;
    }
    
    [super drawView];
    
    CGFloat requiredWidth, prefixWidth, suffixImgWidth, suffixWidth;
    requiredWidth = prefixWidth = suffixImgWidth = suffixWidth = 0;
    
    requiredWidth = self.requiredLabel ? self.requiredLabel.frame.size.width : 0;
    prefixWidth = self.preLabel ? self.preLabel.frame.size.width : 0;
    suffixImgWidth = self.sufImageView ? self.sufImageView.frame.size.width : 0;
    suffixWidth = self.sufLabel ? self.sufLabel.frame.size.width : 0;
//    CGFloat marginLeft = style.padding.left == 0 ? requiredWidth + prefixWidth : style.padding.left + requiredWidth;
    CGFloat marginLeft = requiredWidth + prefixWidth;
    CGFloat marginRight = style.padding.right == 0 ? suffixWidth + suffixImgWidth : style.padding.right;
    _inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(marginLeft, 0, self.frame.size.width - marginLeft - marginRight, self.frame.size.height)];
//    _inputTextField.backgroundColor = [UIColor redColor];
    [self addSubview:_inputTextField];
    NSLog(@"element=%d",self.element.cannot_edit);
    if(self.element.cannot_edit){
        _inputTextField.userInteractionEnabled = NO;
    }
//    _inputTextField.text = inputElement.text ? [NSString stringWithFormat:@"%@", inputElement.text] : inputElement.text;
    _inputTextField.placeholder = inputElement.placeholder;
    _inputTextField.textAlignment = style.textAlignment;
    _inputTextField.textColor = style.fontColor;
    _inputTextField.font = style.font;
//    _inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _inputTextField.borderStyle = UITextBorderStyleNone;
    _inputTextField.delegate = self;
//    if (inputElement.inputType == kInputTypeNumber) {
//        inputTextField.keyboardType = UIKeyboardTypeNumberPad;
//    } else if (inputElement.inputType == kInputTypeText) {
//        inputTextField.keyboardType = UIKeyboardTypeDefault;
//    } else if(inputElement.inputType == kInputTypeDecimal) {
//        inputTextField.keyboardType = UIKeyboardTypeDecimalPad;
//    } else if(inputElement.inputType == kInputTypeEmail) {
//        inputTextField.keyboardType = UIKeyboardTypeEmailAddress;
//    } else if(inputElement.inputType == kInputTypePhone) {
//        inputTextField.keyboardType = UIKeyboardTypeNamePhonePad;
//    } else {
//        inputTextField.keyboardType = UIKeyboardTypeDefault;
//    }
    if (!inputElement.inputType || [inputElement.inputType isEqualToString:EBElementInputTypeText]) {
        _inputTextField.keyboardType = UIKeyboardTypeDefault;
    } else if ([inputElement.inputType isEqualToString:EBElementInputTypeNumber]) {
        _inputTextField.keyboardType = UIKeyboardTypeDecimalPad;
    } else if ([inputElement.inputType isEqualToString:EBElementInputTypePhone]) {
        _inputTextField.keyboardType = UIKeyboardTypePhonePad;
    } else if ([inputElement.inputType isEqualToString:EBElementInputTypeEmail]) {
        _inputTextField.keyboardType = UIKeyboardTypeEmailAddress;
    } else if ([inputElement.inputType isEqualToString:EBElementInputTypePassword]) {
        _inputTextField.secureTextEntry = YES;
    } else {
        _inputTextField.keyboardType = UIKeyboardTypeDefault;
    }
//    inputTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self setValueOfView:inputElement.text];
}

- (void)showInView:(UIView *)view
{
    if (view) {
        _superView = view;
        _originFrame = _superView.frame;
    }
    if (_toolbar) {
        [_inputTextField setInputAccessoryView:_toolbar];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _inputTextField.frame = [self contentFrame];
}

- (NSString *)valueOfView
{
    if ([[(EBInputElement *)self.element inputType] isEqualToString:EBElementInputTypeDate])
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY-MM-dd 0:0:0"];
        NSDate *date = [formatter dateFromString:_inputTextField.text];
        NSString *stringDate = [NSString stringWithFormat:@"%ld",(NSInteger)date.timeIntervalSince1970];
        return stringDate;
    }
    else
    {
        return [_inputTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
}

- (void)setValueOfView:(id)value
{
    if (!value || [value isKindOfClass:NSNull.class]) {
        return;
    }
    _inputTextField.text = value;
}

- (void)enableView:(BOOL)enable
{
    [super enableView:enable];
    _inputTextField.enabled = enable;
}

- (BOOL)matchRegex
{
    if (!self.element.reg || [self.element.reg isEqualToString:@""]) {
        return YES;
    }
    if ([[self valueOfView] isMatchedByRegex:self.element.reg]) {
        return YES;
    }
    return NO;
}

- (BOOL)valid
{
    if (self.element.required && [[self valueOfView] isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (void)setInputView:(UIView *)view
{
    [_inputTextField setInputView:view];
}

- (void)setToolbar:(UIToolbar *)toolbar
{
    _toolbar = toolbar;
    [_inputTextField setInputAccessoryView:_toolbar];
}

- (void)onSelect:(id)sender
{
    [_inputTextField becomeFirstResponder];
}

- (void)deSelect:(id)sender
{
    [_inputTextField resignFirstResponder];
}

#pragma mark -
#pragma textField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputViewDidBeginEditing:)]) {
        [(id<EBInputViewDelegate>)self.delegate inputViewDidBeginEditing:self];
    }
    if (!_superView) {
        return;
    }
    
    [self setKeyboardDidShowNotificationObserver:[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification *notification){
        [self keyboardDidShow:notification];
    }]];
    [self setKeyboardWillHideNotificationObserver:[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *notification){
        [self keyboardWillHide:notification];
    }]];
    
    [self selectInputView];
    [self animateFrame];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (!_superView) {
        return;
    }
    
    if ([[(EBInputElement *)self.element inputType] isEqualToString:EBElementInputTypeDate])
    {
        NSInteger time = (NSInteger)_datePicker.date.timeIntervalSince1970;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:time];
        NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
        [self setValueOfView:confromTimespStr];
    }
    
    [textField resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self.keyboardDidShowNotificationObserver];
    [[NSNotificationCenter defaultCenter]removeObserver:self.keyboardWillHideNotificationObserver];
}

#pragma mark - 
#pragma UIKeyboard notifications
- (void)keyboardDidShow:(NSNotification *)notification
{
    if (!_superView) {
        return;
    }
    NSDictionary* info = [notification userInfo];
    
    NSValue *aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    _keyboardSize = [aValue CGRectValue].size;
    
    if ([_superView isKindOfClass:UIScrollView.class]) {
        ((UIScrollView *)_superView).frame = CGRectMake(_originFrame.origin.x, _originFrame.origin.y, _originFrame.size.width, _originFrame.size.height-_keyboardSize.height);
    }
    [self animateFrame];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIScrollView *superScrollview = (UIScrollView *)_superView;
//    CGRect currentFrame = [self convertRect:self.bounds toView:superScrollview];
    CGFloat height;
    CGFloat contenFloat;
    if (superScrollview.contentSize.height < _originFrame.size.height) {
        contenFloat = _originFrame.size.height;
    }
    else
    {
        contenFloat = superScrollview.contentSize.height;
    }
//    if (contenFloat - currentFrame.origin.y > _originFrame.size.height)
//    {
////        height = currentFrame.origin.y;
//        height = superScrollview.contentOffset.y;
//    }
//    else
//    {
//        height = contenFloat - _originFrame.size.height;
//    }
    
    if (contenFloat - superScrollview.contentOffset.y > _originFrame.size.height) {
        height = superScrollview.contentOffset.y;
    }
    else
    {
        height = contenFloat - _originFrame.size.height;
    }
    _superView.frame = _originFrame;
    if ([_superView isKindOfClass:UIScrollView.class]) {
        [(UIScrollView *)_superView setContentOffset:CGPointMake(0, height) animated:YES];
    }
}

#pragma mark -
#pragma private method
- (void)animateFrame
{
    if (CGRectEqualToRect(_superView.frame, _originFrame)) {
        return;
    }
    CGRect frame = [self convertRect:self.bounds toView:_superView];
    if ([_superView isKindOfClass:UIScrollView.class]) {
        UIScrollView *sv = (UIScrollView *)_superView;
        CGFloat dy = (frame.origin.y + frame.size.height) - (sv.contentOffset.y + sv.frame.size.height);
        if (dy > 0) {
            [sv setContentOffset:CGPointMake(0, sv.contentOffset.y + dy) animated:YES];
            return;
        }
        dy = frame.origin.y - sv.contentOffset.y;
        if (dy < 0) {
            [sv setContentOffset:CGPointMake(0, sv.contentOffset.y + dy) animated:YES];
        }
        
    } else {
        CGFloat dy = (frame.origin.y + frame.size.height) - (_superView.frame.size.height - _keyboardSize.height);
        if (dy > 0) {
            [UIView animateWithDuration:0.5 animations:^{
                _superView.frame = CGRectOffset(_superView.frame, 0, -dy);
            }];
        }
        dy = _superView.frame.origin.y + frame.origin.y;
        if (dy < 0) {
            [UIView animateWithDuration:0.5 animations:^{
                _superView.frame = CGRectOffset(_superView.frame, 0, -dy);
            }];
        }
    }
}

- (void)selectInputView
{
    if ([[(EBInputElement *)self.element inputType] isEqualToString:EBElementInputTypeDate]) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        [_datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        if (![[self valueOfView] isEqualToString:@""] && [[self valueOfView] isMatchedByRegex:DateRegex]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:DateFormatter];
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [_datePicker setDate:[dateFormatter dateFromString:[self valueOfView]]];
        }
        if (![[self valueOfView] isEqualToString:@""]) {
            NSInteger time = [[self valueOfView] intValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
            [_datePicker setDate:date];
        }
        [(EBInputView *)self setInputView:_datePicker];
    }
}

- (void)datePickerValueChanged:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    
    NSDate *selectedDate = datePicker.date;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DateFormatter];
    
    [self setValueOfView:[dateFormatter stringFromDate:selectedDate]];
}
@end
