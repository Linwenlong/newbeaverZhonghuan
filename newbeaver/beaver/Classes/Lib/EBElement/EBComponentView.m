//
//  EBComponentView.m
//  beaver
//
//  Created by LiuLian on 7/27/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "EBComponentView.h"
#import "EBElementView.h"
#import "EBElement.h"
#import "EBElementStyle.h"
#import "EBPrefixElement.h"
#import "EBPrefixView.h"
#import "EBInputView.h"
#import "EBTextareaView.h"

@implementation EBComponentView
@synthesize elementViews;

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
    if (!elementViews || elementViews.count == 0) {
        return;
    }
    EBElementView *firstElementView = elementViews[0];
    
    if (!self.element) {
        self.element = [EBPrefixElement new];
    }
    if (!self.style) {
        self.style = firstElementView.style;
    }
    
    if ([firstElementView isMemberOfClass:EBPrefixView.class]) {
        if (elementViews.count > 1) {
            [(EBElementView *)elementViews[1] style].newline = NO;
        }
    } else {
        [(EBElementView *)elementViews[0] style].newline = NO;
    }
    
    int rows = 1;
    for (EBElementView *elementView in elementViews) {
        if (elementView.style.newline) {
            rows++;
        }
    }
    CGFloat paddingLeft = 0;
    if ([firstElementView isMemberOfClass:EBPrefixView.class]) {
        if (!self.element) {
            self.element = [EBPrefixElement new];
        }
        self.element.star = firstElementView.element.star;
        self.element.required = firstElementView.element.required;
        self.element.visible = firstElementView.element.visible;
        self.element.eid = firstElementView.element.eid;
        
        [(EBPrefixElement *)self.element setPrefix:[(EBPrefixElement *)firstElementView.element prefix]];
        CGFloat left = firstElementView.requiredLabel.frame.size.width;
        self.frame = CGRectMake(firstElementView.frame.origin.x + left, firstElementView.frame.origin.y, firstElementView.frame.size.width-left, rows*firstElementView.frame.size.height);
        
        [super drawView];
        
        [elementViews removeObject:firstElementView];
        paddingLeft = (self.requiredLabel ? self.requiredLabel.frame.size.width : 0) + (self.preLabel ? self.preLabel.frame.size.width : 0);
    } else {
        CGFloat dx = firstElementView.requiredLabel ? 0 : RequiredLabelWidth;
        self.frame = CGRectMake(firstElementView.frame.origin.x-dx, firstElementView.frame.origin.y, firstElementView.frame.size.width+dx, rows*firstElementView.frame.size.height);
    }
    
    NSUInteger cols = 0, tmpWidth = 0, tmpHeight = self.frame.size.height / rows, tmpx = 0;
    rows = 0;
    NSUInteger i = 0, j = 0;
    for (; i < elementViews.count; i++) {
        EBElementView *elementView = elementViews[i];
        if (elementView.style.newline) {
            rows++;
            cols = i - j;
            if (cols == 0) {
                continue;
            }
            tmpWidth = (self.frame.size.width - paddingLeft) / cols;
            for (NSUInteger k = 0; k < i - j; k++) {
                EBElementView *tmpView = elementViews[j+k];
                EBElementView *addView = [tmpView.class new];
                addView.element = tmpView.element;
                addView.style = tmpView.style;
                tmpx = tmpView.requiredLabel ? RequiredLabelWidth : 0;
                tmpx = ![firstElementView isMemberOfClass:EBPrefixView.class] && k == 0 ? RequiredLabelWidth : tmpx;
                addView.frame = CGRectMake(paddingLeft+tmpWidth*k+tmpx, (rows-1)*tmpHeight, tmpWidth-tmpx, tmpHeight);
                [addView drawView];
                [self addSubview:addView];
            }
            j = i;
        }
    }
    cols = i - j;
    if (cols > 0) {
        tmpWidth = (self.frame.size.width - paddingLeft) / cols;
        for (NSUInteger k = 0; k < i - j; k++) {
            EBElementView *tmpView = elementViews[j+k];
            EBElementView *addView = [tmpView.class new];
            addView.element = tmpView.element;
            addView.style = tmpView.style;
            tmpx = tmpView.requiredLabel ? RequiredLabelWidth : 0;
            tmpx = ![firstElementView isMemberOfClass:EBPrefixView.class] && k == 0 ? RequiredLabelWidth : tmpx;
            addView.frame = CGRectMake(paddingLeft+tmpWidth*k+tmpx, rows*tmpHeight, tmpWidth-tmpx, tmpHeight);
            [addView drawView];
            [self addSubview:addView];
        }
    }
    
    NSMutableArray *ebViews = [NSMutableArray new];
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:EBElementView.class]) {
            [ebViews addObject:view];
        }
    }
    elementViews = [NSMutableArray arrayWithArray:ebViews];
    [ebViews removeAllObjects];
    ebViews = nil;
    
    
    
    
    
//    if (!self.element) {
//        self.element = [EBPrefixElement new];
//    }
//    if (!self.style) {
//        self.style = firstElementView.style;
//    }
//    
//    if ([firstElementView isMemberOfClass:EBPrefixView.class]) {
//        if (elementViews.count > 1) {
//            [(EBElementView *)elementViews[1] style].newline = NO;
//        }
//    } else {
//        [(EBElementView *)elementViews[0] style].newline = NO;
//    }
//    
//    int rows = 1;
//    for (EBElementView *elementView in elementViews) {
//        if (elementView.style.newline) {
//            rows++;
//        }
//    }
//    self.element.required = firstElementView.element.required;
//    self.element.visible = firstElementView.element.visible;
//    self.element.eid = firstElementView.element.eid;
//    if ([firstElementView isMemberOfClass:EBPrefixView.class]) {
//        [(EBPrefixElement *)self.element setPrefix:[(EBPrefixElement *)firstElementView.element prefix]];
//        CGFloat left = self.element.required ? firstElementView.requiredLabel.frame.size.width : 0;
//        self.frame = CGRectMake(firstElementView.frame.origin.x + left, firstElementView.frame.origin.y, firstElementView.frame.size.width-left, rows*firstElementView.frame.size.height);
//    } else {
//        self.frame = CGRectMake(firstElementView.frame.origin.x, firstElementView.frame.origin.y, firstElementView.frame.size.width, rows*firstElementView.frame.size.height);
//    }
//    
//    [super drawView];
//    
//    if ([firstElementView isMemberOfClass:EBPrefixView.class]) {
//        [elementViews removeObject:firstElementView];
//    } else {
////        if ([elementViews[0] isKindOfClass:EBPrefixView.class]) {
////            [(EBPrefixElement *)[(EBPrefixView *)elementViews[0] element] setPrefix:nil];
////        }
//    }
//    [(EBElementView *)elementViews[0] style].newline = NO;
//    
//    CGFloat paddingLeft = (self.requiredLabel ? self.requiredLabel.frame.size.width : 0) + (self.preLabel ? self.preLabel.frame.size.width : 0);
//    
//    NSUInteger cols = 0, tmpWidth = 0, tmpHeight = self.frame.size.height / rows;
//    rows = 0;
//    NSUInteger i = 0, j = 0;
//    for (; i < elementViews.count; i++) {
//        EBElementView *elementView = elementViews[i];
//        if (elementView.style.newline) {
//            rows++;
//            cols = i - j;
//            if (cols == 0) {
//                continue;
//            }
//            tmpWidth = (self.frame.size.width - paddingLeft) / cols;
//            for (NSUInteger k = 0; k < i - j; k++) {
//                EBElementView *tmpView = elementViews[j+k];
//                EBElementView *addView = [tmpView.class new];
//                addView.element = tmpView.element;
//                addView.style = tmpView.style;
//                addView.style.padding = UIEdgeInsetsZero;
//                addView.element.required = NO;
////                if ([addView isKindOfClass:EBPrefixView.class]) {
////                    [(EBPrefixElement *)addView.element setPrefix:nil];
////                }
//                addView.frame = CGRectMake(paddingLeft+tmpWidth*k, (rows-1)*tmpHeight, tmpWidth, tmpHeight);
//                [addView drawView];
//                [self addSubview:addView];
//            }
//            j = i;
//        }
//    }
//    cols = i - j;
//    if (cols > 0) {
//        tmpWidth = (self.frame.size.width - paddingLeft) / cols;
//        for (NSUInteger k = 0; k < i - j; k++) {
//            EBElementView *tmpView = elementViews[j+k];
//            EBElementView *addView = [tmpView.class new];
//            addView.element = tmpView.element;
//            addView.style = tmpView.style;
//            addView.style.padding = UIEdgeInsetsZero;
//            addView.element.required = NO;
////            if ([addView isKindOfClass:EBPrefixView.class]) {
////                [(EBPrefixElement *)addView.element setPrefix:nil];
////            }
//            addView.frame = CGRectMake(paddingLeft+tmpWidth*k, rows*tmpHeight, tmpWidth, tmpHeight);
//            [addView drawView];
//            [self addSubview:addView];
//        }
//    }
//    
//    NSMutableArray *ebViews = [NSMutableArray new];
//    for (UIView *view in [self subviews]) {
//        if ([view isKindOfClass:EBElementView.class]) {
//            [ebViews addObject:view];
//        }
//    }
//    elementViews = [NSMutableArray arrayWithArray:ebViews];
//    [ebViews removeAllObjects];
//    ebViews = nil;
}

- (void)onSelect:(id)sender
{
    for (EBElementView *view in elementViews) {
        if ([view isKindOfClass:EBInputView.class] || [view isKindOfClass:EBTextareaView.class]) {
            [view onSelect:sender];
            break;
        }
    }
}

@end
