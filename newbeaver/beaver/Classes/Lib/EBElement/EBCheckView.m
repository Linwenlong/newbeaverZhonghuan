//
//  EBCheckView.m
//  beaver
//
//  Created by LiuLian on 7/27/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "EBCheckView.h"
#import "EBCheckElement.h"
#import "EBElementStyle.h"

@interface EBCheckView()
{
    UISwitch *switchView;
}
@end

@implementation EBCheckView

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
    EBCheckElement *checkElement;
    EBElementStyle *style;
    if (!self.element) {
        checkElement = [EBCheckElement new];
        self.element = checkElement;
    } else {
        checkElement = (EBCheckElement *)self.element;
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
    
    switchView = [UISwitch new];
    [switchView addTarget:self action:@selector(onSelect:) forControlEvents:UIControlEventTouchUpInside];
    switchView.frame = CGRectMake(self.frame.size.width - switchView.frame.size.width - 10, self.frame.size.height/2-switchView.frame.size.height/2, switchView.frame.size.width, switchView.frame.size.height);
    switchView.on = checkElement.checked;
    [self addSubview:switchView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    switchView.frame = CGRectMake(self.frame.size.width - switchView.frame.size.width - 10, self.frame.size.height/2-switchView.frame.size.height/2, switchView.frame.size.width, switchView.frame.size.height);;
}

- (NSString *)valueOfView
{
    return [NSString stringWithFormat:@"%d", switchView.on];
}

- (void)setValueOfView:(id)value
{
    if (!value || [value isKindOfClass:NSNull.class]) {
        return;
    }
    [switchView setOn:[value boolValue] animated:YES];
}

- (void)enableView:(BOOL)enable
{
    [super enableView:enable];
    switchView.enabled = enable;
}

- (BOOL)checked
{
    return [switchView isOn];
}

- (void)onSelect:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(checkViewDidChanged:)]) {
        [self.delegate checkViewDidChanged:self];
    }
}

@end
