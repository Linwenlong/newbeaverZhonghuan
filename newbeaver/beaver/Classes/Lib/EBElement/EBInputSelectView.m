//
//  EBInputSelectView.m
//  beaver
//
//  Created by LiuLian on 8/7/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "EBInputSelectView.h"
#import "EBInputView.h"
#import "EBSelectView.h"
#import "EBInputElement.h"
#import "RegexKitLite.h"
#import "EBElementStyle.h"

@implementation EBInputSelectView

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
    self.style.underline = NO;
    [super drawView];
    self.style.underline = YES;
    
    [(EBPrefixElement *)self.element setPrefix:[(EBPrefixElement *)self.inputView.element prefix]];
    self.inputView.style = self.style;
    self.selectView.style = self.style;
    
    CGFloat left = self.requiredLabel ? RequiredLabelWidth : 0;
    CGFloat width = self.frame.size.width - left;
    
    self.inputView.frame = CGRectMake(left, 0, width*2/3, self.frame.size.height);
    [self.inputView drawView];
    
    self.selectView.frame = CGRectMake(self.inputView.frame.origin.x+self.inputView.frame.size.width + 10, 0, width/3 - 10, self.frame.size.height);
    [self.selectView drawView];
    
    [self addSubview:self.inputView];
    [self addSubview:self.selectView];
    
    NSString *text = [(EBInputElement *)self.inputView.element text];
    if (text) {
        [self setValueOfView:text];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat left = self.requiredLabel ? RequiredLabelWidth : 0;
    CGFloat width = self.frame.size.width - left;
    
    self.inputView.frame = CGRectMake(left, 0, width*2/3, self.frame.size.height);
    [self.inputView setNeedsLayout];
    
    self.selectView.frame = CGRectMake(self.inputView.frame.origin.x+self.inputView.frame.size.width + 10, 0, width/3 - 10, self.frame.size.height);
    [self.selectView setNeedsLayout];
}

- (NSString *)valueOfView
{
    return [NSString stringWithFormat:@"%@;%@", [self.inputView valueOfView], [self.selectView valueOfView]];
}

- (void)setValueOfView:(id)value
{
    if (!value || [value isKindOfClass:NSNull.class]) {
        return;
    }
    if (value && [value isKindOfClass:NSString.class]) {
        NSArray *arr = [value componentsSeparatedByString:@";"];
        [self.inputView setValueOfView:arr[0]];
        [self.selectView setValueOfView:[value substringFromIndex:[value rangeOfString:@";"].location+1]];
    }
}

- (void)enableView:(BOOL)enable
{
    [super enableView:enable];
    [self.selectView enableView:enable];
    [self.inputView enableView:enable];
}

- (BOOL)matchRegex
{
    if (!self.element.reg || [self.element.reg isEqualToString:@""]) {
        return YES;
    }
    if ([[self.inputView valueOfView] isMatchedByRegex:self.element.reg]) {
        return YES;
    }
    return NO;
}

- (BOOL)valid
{
    if (self.element.required && [[self.inputView valueOfView] isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (void)onSelect:(id)sender
{
    [self.inputView becomeFirstResponder];
}

- (void)setDelegate:(id<EBElementViewDelegate>)delegate
{
    self.inputView.delegate = delegate;
    self.selectView.delegate = delegate;
}

@end
