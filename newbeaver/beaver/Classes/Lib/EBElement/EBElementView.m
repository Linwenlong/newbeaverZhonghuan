//
//  EBElementView.m
//  MyQuickDialog
//
//  Created by LiuLian on 7/22/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#import "EBElementView.h"
#import "EBElement.h"
#import "EBElementStyle.h"
#import "EBInputElement.h"
#import "EBInputView.h"
#import "EBTextareaView.h"
#import "EBComponentView.h"

@interface EBElementView()

@end

@implementation EBElementView
@synthesize requiredLabel, underlineView, tapGesture;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithStyle:(CGRect)frame element:(EBElement *)element style:(EBElementStyle *)style
{
    self = [super initWithFrame:frame];
    if (self) {
        self.element = element;
        self.style = style;
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

- (CGRect)contentFrame
{
    CGFloat requiredWidth;
    
    requiredWidth = self.requiredLabel ? self.requiredLabel.frame.size.width : 0;
    
    return CGRectMake(requiredWidth, 0, self.frame.size.width-requiredWidth, self.frame.size.height);
}

- (CGSize)actualSize:(NSString *)text constrainedToSize:(CGSize)size font:(UIFont *)font
{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_0)
    {
        return [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil].size;
    }
    else
    {
        return [text sizeWithFont:font constrainedToSize:size];
    }
}

- (void)drawView
{
    if (self.element.star == EBElementViewStarVisible) {
        self.frame = CGRectMake(self.frame.origin.x-RequiredLabelWidth, self.frame.origin.y, self.frame.size.width+RequiredLabelWidth, self.frame.size.height);
        [self initRequiredLabel];
    }
    if (self.style.underline) {
//        [self showUnderline];
        CGFloat x = self.element.star == 1 ? RequiredLabelWidth : 0;
        underlineView = [[UIView alloc] initWithFrame:CGRectMake(x, self.frame.size.height-0.5, self.frame.size.width-x, 0.5)];
        underlineView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:underlineView];
        [self bringSubviewToFront:underlineView];
    }
    
    if (!tapGesture) {
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelect:)];
        [self addGestureRecognizer:tapGesture];
    }
    
//    if (!setupFlag) {
//        [self setup];
//    }
}

- (void)showUnderline
{
    if (underlineView) {
        CGFloat x = 0;
        if (self.requiredLabel) {
            x = RequiredLabelWidth;
        }
        underlineView.frame = CGRectMake(x, self.frame.size.height-0.5, self.frame.size.width-x, 0.5);
    }
}

- (void)initRequiredLabel
{
    CGRect frame = CGRectMake(0, 0, RequiredLabelWidth, self.frame.size.height);
    requiredLabel = [[UILabel alloc] initWithFrame:frame];
    requiredLabel.text = @"*";
    requiredLabel.textColor = [UIColor redColor];
    requiredLabel.font = self.style.prefixFont;
    [self addSubview:requiredLabel];
}
//- (void)required
//{
//    self.frame = CGRectMake(self.frame.origin.x-10, self.frame.origin.y, self.frame.size.width+10, self.frame.size.height);
//    CGRect frame = CGRectMake(0, 0, 10, self.frame.size.height);
//    requiredLabel = [[UILabel alloc] initWithFrame:frame];
//    requiredLabel.text = @"*";
//    requiredLabel.textColor = [UIColor redColor];
//    [self addSubview:requiredLabel];
//    
//    [self setNeedsLayout];
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.element.star == EBElementViewStarVisible) {
        if (!self.requiredLabel) {
            self.frame = CGRectMake(self.frame.origin.x-RequiredLabelWidth, self.frame.origin.y, self.frame.size.width+RequiredLabelWidth, self.frame.size.height);
            [self initRequiredLabel];
        }
    } else {
        if (self.requiredLabel && [self.requiredLabel superview]) {
            self.frame = CGRectMake(self.frame.origin.x+RequiredLabelWidth, self.frame.origin.y, self.frame.size.width-RequiredLabelWidth, self.frame.size.height);
            [self.requiredLabel removeFromSuperview];
            self.requiredLabel = nil;
        }
    }
    
    [self showUnderline];
}

- (NSString *)valueOfView
{
    return @"";
}

- (void)setValueOfView:(id)value
{
    
}

- (void)enableView:(BOOL)enable
{
    if (enable) {
        [self addGestureRecognizer:tapGesture];
    } else {
        [self removeGestureRecognizer:tapGesture];
    }
}

- (void)onSelect:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewDidSelect:)]) {
        [self.delegate viewDidSelect:self];
    }
}

- (void)deSelect:(id)sender
{
    
}

+ (CGRect)defaultFrame
{
    return CGRectMake(0, 0, 360, 44);
}

@end
