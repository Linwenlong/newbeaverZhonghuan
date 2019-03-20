//
//  EBRangeView.m
//  beaver
//
//  Created by LiuLian on 8/11/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "EBRangeView.h"
#import "EBInputView.h"
#import "EBInputElement.h"
#import "RegexKitLite.h"
#import "EBElementStyle.h"

@implementation EBRangeView

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
    [super drawView];
    
    [(EBPrefixElement *)self.element setPrefix:[(EBPrefixElement *)self.minInputView.element prefix]];
    
    self.minInputView.style = self.style;
    self.maxInputView.style = [EBElementStyle defaultStyle];
    self.maxInputView.style.padding = UIEdgeInsetsZero;
    
    CGFloat left = self.requiredLabel ? RequiredLabelWidth : 0;
    CGFloat width = self.frame.size.width - left;
    
    self.inputView.frame = CGRectMake(left, 0, width/2, self.frame.size.height);
    [self.minInputView drawView];
    
    self.maxInputView.frame = CGRectMake(self.minInputView.frame.origin.x+self.minInputView.frame.size.width, 0, width/2, self.frame.size.height);
    [self.maxInputView drawView];
    
    [self addSubview:self.minInputView];
    [self addSubview:self.maxInputView];
    
    NSString *text = [(EBInputElement *)self.minInputView.element text];
    if (text) {
        [self setValueOfView:text];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat left = self.requiredLabel ? RequiredLabelWidth : 0;
    CGFloat width = self.frame.size.width - left;
    
    self.minInputView.frame = CGRectMake(left, 0, width/2, self.frame.size.height);
    [self.minInputView setNeedsLayout];
    
    self.maxInputView.frame = CGRectMake(self.minInputView.frame.origin.x+self.minInputView.frame.size.width, 0, width/2, self.frame.size.height);
    [self.maxInputView setNeedsLayout];
}

- (NSString *)valueOfView
{
    if ([[self.minInputView valueOfView] isEqualToString:@""] && [[self.maxInputView valueOfView] isEqualToString:@""]) {
        return @"";
    }
    return [NSString stringWithFormat:@"%@-%@", [self.minInputView valueOfView], [self.maxInputView valueOfView]];
}

- (void)setValueOfView:(id)value
{
    if (!value || [value isKindOfClass:NSNull.class]) {
        return;
    }
    if (value && [value isKindOfClass:NSString.class]) {
        NSArray *arr = [value componentsSeparatedByString:@"-"];
        [self.minInputView setValueOfView:arr[0]];
        [self.maxInputView setValueOfView:arr[1]];
    }
}

- (void)enableView:(BOOL)enable
{
    [super enableView:enable];
    [self.minInputView enableView:enable];
    [self.maxInputView enableView:enable];
}

- (BOOL)matchRegex
{
    if (!self.element.reg || [self.element.reg isEqualToString:@""]) {
        return YES;
    }
    if ([[self.minInputView valueOfView] isMatchedByRegex:self.element.reg] && [[self.maxInputView valueOfView] isMatchedByRegex:self.element.reg]) {
        return YES;
    }
    return NO;
}

- (BOOL)valid
{
    if (self.element.required && [[self.minInputView valueOfView] isEqualToString:@""] && [[self.maxInputView valueOfView] isEqualToString:@""]) {
        return NO;
    }
//    if (![[self.minInputView valueOfView] isEqualToString:@""] && ![[self.maxInputView valueOfView] isEqualToString:@""] && [[self.minInputView valueOfView] floatValue] > [[self.maxInputView valueOfView] floatValue]) {
//        return NO;
//    }
    return YES;
}

- (void)onSelect:(id)sender
{
    [self.minInputView becomeFirstResponder];
}

- (void)setDelegate:(id<EBElementViewDelegate>)delegate
{
    self.minInputView.delegate = delegate;
    self.maxInputView.delegate = delegate;
}

@end
