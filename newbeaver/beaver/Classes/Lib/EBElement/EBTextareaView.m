//
//  EBTextareaView.m
//  MyQuickDialog
//
//  Created by LiuLian on 7/23/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#define EBElementViewTag 20000

#import "EBTextareaView.h"
#import "EBTextareaElement.h"
#import "EBElementStyle.h"
#import "EBComponentView.h"
#import "EBInputView.h"

@interface EBTextareaView() <UITextViewDelegate>
{
    UITextView *inputTextView;
    UILabel *placeholderLabel;
    
    CGRect _originFrame;
    CGSize _keyboardSize;
}

@property (weak) id keyboardDidShowNotificationObserver;
@property (weak) id keyboardWillHideNotificationObserver;
@property (nonatomic, weak) UIView *superView;

@end

@implementation EBTextareaView
@synthesize toolbar = _toolbar, superView = _superView;

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
    EBTextareaElement *textareaElement;
    EBElementStyle *style;
    if (!self.element) {
        textareaElement = [EBTextareaElement new];
        self.element = textareaElement;
    } else {
        textareaElement = (EBTextareaElement *)self.element;
    }
    if (!self.style) {
        style = [EBElementStyle new];
        style.fontSize = FontSizeDefault;
        style.font = [UIFont systemFontOfSize:style.fontSize];
        style.fontColor = [UIColor darkTextColor];
        self.style = style;
    } else {
        style = self.style;
    }
    
    [super drawView];
    
    CGFloat dx = self.requiredLabel ? self.requiredLabel.frame.size.width : 0;
    
    inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(dx, 0, self.frame.size.width-dx, self.frame.size.height)];
    [self addSubview:inputTextView];
    inputTextView.delegate = self;
    inputTextView.font = style.font;
//    inputTextView.text = textareaElement.text;
    inputTextView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//    inputTextView.layer.borderWidth = 1.0;
//    inputTextView.layer.borderColor = [UIColor redColor].CGColor;
    CGSize size = [self actualSize:textareaElement.placeholder constrainedToSize:CGSizeMake(1000, 44) font:style.font];
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(dx+4, 8, size.width, size.height)];
    placeholderLabel.text = textareaElement.placeholder;
    placeholderLabel.font = style.font;
    placeholderLabel.textColor = [UIColor lightGrayColor];
//    placeholderLabel.layer.borderWidth = 1.0;
//    placeholderLabel.layer.borderColor = [UIColor blueColor].CGColor;
    if (!textareaElement.text || textareaElement.text.length == 0) {
        [self addSubview:placeholderLabel];
    }
    
    if (self.underlineView) {
        [self bringSubviewToFront:self.underlineView];
    }
    
    [self setValueOfView:textareaElement.text];
}

- (void)showInView:(UIView *)view
{
    if (view) {
        _superView = view;
        _originFrame = _superView.frame;
    }
    if (_toolbar) {
        [inputTextView setInputAccessoryView:_toolbar];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    inputTextView.frame = [self contentFrame];
}

- (NSString *)valueOfView
{
    return inputTextView.text;
}

- (void)setValueOfView:(id)value
{
    if (!value || [value isKindOfClass:NSNull.class]) {
        return;
    }
    inputTextView.text = value;
    if (inputTextView.text.length > 0 && [placeholderLabel superview]) {
        [placeholderLabel removeFromSuperview];
    } else if (inputTextView.text.length == 0 && ![placeholderLabel superview]) {
        [self addSubview:placeholderLabel];
    }
}

- (void)enableView:(BOOL)enable
{
    [super enableView:enable];
    inputTextView.editable = enable;
    inputTextView.userInteractionEnabled = enable;
}

- (BOOL)valid
{
    if (self.element.required && [[self valueOfView] isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (void)onSelect:(id)sender
{
    [inputTextView becomeFirstResponder];
}

- (void)deSelect:(id)sender
{
    [inputTextView resignFirstResponder];
}

#pragma mark -
#pragma textview delegate
- (void)textViewDidChange:(UITextView *)textView
{
    [(EBTextareaElement *)self.element setText:textView.text];
    if (textView.text.length > 0 && [placeholderLabel superview]) {
        [placeholderLabel removeFromSuperview];
    } else if (textView.text.length == 0 && ![placeholderLabel superview]) {
        [self addSubview:placeholderLabel];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(textareaViewDidBeginEditing:)]) {
        [(id<EBTextareaViewDelegate>)self.delegate textareaViewDidBeginEditing:self];
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
    
    [self animateFrame];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (!_superView) {
        return;
    }
    
    [textView resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self.keyboardDidShowNotificationObserver];
    [[NSNotificationCenter defaultCenter]removeObserver:self.keyboardWillHideNotificationObserver];
}

//- (void)setCursorLocation
//{
//    NSRange range;
//    range.location = 0;
//    range.length = 0;
//    inputTextView.selectedRange = range;
//inputTextView.textColor = [UIColor lightGrayColor];
//}

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
        [self animateFrame];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIScrollView *superScrollview = (UIScrollView *)_superView;
    CGFloat height;
//    if (superScrollview.contentSize.height - currentFrame.origin.y > _originFrame.size.height)
//    {
//        height = currentFrame.origin.y;
//    }
//    else
//    {
//        height = superScrollview.contentSize.height - _originFrame.size.height;
//    }
    if (superScrollview.contentSize.height - superScrollview.contentOffset.y > _originFrame.size.height) {
        height = superScrollview.contentOffset.y;
    }
    else
    {
        height = superScrollview.contentSize.height - _originFrame.size.height;
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
@end
