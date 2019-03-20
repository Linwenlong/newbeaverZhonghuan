//
//  EBParserContainerView.m
//  beaver
//
//  Created by LiuLian on 7/31/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#define DateFormatter @"YYYY-MM-dd"
#define EBElementViewTag 10000

#import "EBParserContainerView.h"
#import "EBElementStyle.h"
#import "EBElement.h"
#import "EBElementView.h"
#import "EBInputView.h"
#import "EBTextareaView.h"
#import "EBSelectView.h"
#import "EBComponentView.h"
#import "EBInputElement.h"
#import "EBInputSelectView.h"
#import "EBRangeView.h"

@interface EBParserContainerView()

@property (nonatomic, weak) UIView *superView;
@property (nonatomic, weak) UIToolbar *toolbar;

@end

@implementation EBParserContainerView
@synthesize superView = _superView, toolbar = _toolbar;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.inputViews = [NSMutableArray new];
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

- (void)showInView:(UIView *)view toolbar:(UIToolbar *)toolbar
{
    if (!view) {
        return;
    }
    _superView = view;
    _toolbar = toolbar;
    [_superView addSubview:self];
}

#pragma mark -
#pragma mark EBElementParserDelegate
- (CGRect)elementFrame:(EBElementView *)elementView elementIndex:(NSUInteger)index
{
    CGFloat dy = 0, height = 50;
    NSArray *subs = [self subviews];
    if (subs.count > 0) {
        for (NSInteger i = subs.count - 1; i >= 0; i--) {
            UIView *subView = (UIView *)subs[i];
            if ([subView isKindOfClass:EBElementView.class]) {
                dy = subView.top + subView.height;
                break;
            }
        }
    }
    
    if ([elementView isKindOfClass:EBTextareaView.class]) {
        height = 150;
    }
    return CGRectMake(25, dy, self.width-30, height);
}

- (EBElementStyle *)elementStyle:(EBElementView *)elementView elementIndex:(NSUInteger)index
{
    return [EBElementStyle defaultStyle];
}

- (void)parserDidEndElement:(EBElementView *)elementView elementIndex:(NSUInteger)index
{
    [self addSubview:elementView];
    [elementView drawView];
}

- (void)parserDidEndData:(NSArray *)elements
{
    NSMutableArray *tmpViews = [NSMutableArray new];
    NSArray *subs = [self subviews];
    for (int i = 0; i < subs.count; i++) {
        if ([subs[i] isKindOfClass:EBElementView.class]) {
            if ([(EBElementView *)subs[i] style].merge) {
                if (tmpViews.count == 0 && i > 0) {
                    //                    [subs[i-1] removeFromSuperview];
                    [tmpViews addObject:subs[i-1]];
                }
                //                [subs[i] removeFromSuperview];
                [tmpViews addObject:subs[i]];
            } else if (tmpViews.count > 0) {
                EBComponentView *comView = [EBComponentView new];
                comView.elementViews = [NSMutableArray arrayWithArray:tmpViews];
                [comView drawView];
                //                [scrollView addSubview:comView];
                [self insertSubview:comView aboveSubview:tmpViews[0]];
                comView = nil;
                for (EBElementView *aview in tmpViews) {
                    [aview removeFromSuperview];
                }
                [tmpViews removeAllObjects];
            }
        }
    }
    if (tmpViews.count > 0) {
        EBComponentView *comView = [EBComponentView new];
        comView.elementViews = tmpViews;
        [comView drawView];
        //                [scrollView addSubview:comView];
        [self insertSubview:comView aboveSubview:tmpViews[0]];
        comView = nil;
        for (EBElementView *aview in tmpViews) {
            [aview removeFromSuperview];
        }
        [tmpViews removeAllObjects];
    }
    
    //remove prefixview
    for (UIView *view in self.subviews) {
        if ([view isMemberOfClass:EBPrefixView.class]) {
            [(EBPrefixView *)view element].visible = NO;
        }
    }
    [self resetElementViewFrame];
    
    [self setElementView];
}

#pragma mark -
#pragma public method
- (EBElementView *)showElementView:(NSArray *)eids
{
    EBElementView *tmpView = nil;
    NSString *eid = eids.count > 1 ? nil : eids[0];
    NSArray *subs = [self subviews];
    for (int i = 0; i < subs.count; i++) {
        if ([subs[i] isKindOfClass:EBElementView.class]) {
            tmpView = subs[i];
            if (eid) {
                if ([tmpView.element.eid isEqualToString:eid]) {
                    tmpView.element.visible = YES;
//                    if ([tmpView isKindOfClass:EBInputView.class] || [tmpView isKindOfClass:EBTextareaView.class]) {
//                        [tmpView onSelect:nil];
//                    }
                    break;
                }
            } else {
                if ([tmpView isKindOfClass:EBComponentView.class]) {
                    for (NSString *tmpid in eids) {
                        if ([tmpid isEqualToString:tmpView.element.eid]) {
                            tmpView.element.visible = YES;
//                            [tmpView onSelect:nil];
                            break;
                        }
                    }
                    break;
                }
            }
        }
    }
    [self resetElementViewFrame];
    
    return tmpView;
}

- (void)hideElementView:(NSArray *)eids
{
    EBElementView *tmpView = nil;
    NSString *eid = eids.count > 1 ? nil : eids[0];
    NSArray *subs = [self subviews];
    for (int i = 0; i < subs.count; i++) {
        if ([subs[i] isKindOfClass:EBElementView.class]) {
            tmpView = subs[i];
            if (eid) {
                if ([tmpView.element.eid isEqualToString:eid]) {
                    tmpView.element.visible = NO;
                    break;
                }
            } else {
                if ([tmpView isKindOfClass:EBComponentView.class]) {
                    for (NSString *tmpid in eids) {
                        if ([tmpid isEqualToString:tmpView.element.eid]) {
                            tmpView.element.visible = NO;
                            break;
                        }
                    }
                    break;
                }
            }
        }
    }
    [self resetElementViewFrame];
}

- (void)addElementView:(EBElementView *)view atIndex:(NSUInteger)index
{
    [self insertSubview:view atIndex:index];
    [self resetElementViewFrame];
}

#pragma mark -
#pragma private method
- (void)resetElementViewFrame
{
    NSArray *subs = [self subviews];
    CGFloat height = 0;
    for (int i = 0; i < subs.count; i++) {
        if ([subs[i] isKindOfClass:EBElementView.class]) {
            EBElementView *tmpView = (EBElementView *)subs[i];
            height += tmpView.height;
            tmpView.frame = CGRectOffset(tmpView.frame, 0, height-tmpView.height-tmpView.top);
            if (!tmpView.element.visible) {
                tmpView.hidden = YES;
                height -= tmpView.height;
            } else {
                tmpView.hidden = NO;
            }
        }
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

- (void)setElementView
{
    for (UIView *view in self.subviews) {
        if (self.controller) {
            [(EBElementView *)view setDelegate:self.controller];
        }
        if ([view isKindOfClass:EBInputView.class]) {
            EBInputView *elementView = (EBInputView *)view;
            [elementView setToolbar:_toolbar];
            [elementView showInView:_superView];
            [self.inputViews addObject:elementView];
        }
        if ([view isKindOfClass:EBTextareaView.class]) {
            EBTextareaView *elementView = (EBTextareaView *)view;
            [elementView setToolbar:_toolbar];
            [elementView showInView:_superView];
            [self.inputViews addObject:elementView];
        }
        if ([view isKindOfClass:EBComponentView.class]) {
            EBComponentView *elementView = (EBComponentView *)view;
            for (EBElementView *aview in elementView.elementViews) {
                aview.delegate = self.controller;
                if ([aview isKindOfClass:EBInputView.class]) {
                    [(EBInputView *)aview setToolbar:_toolbar];
                    [(EBInputView *)aview showInView:_superView];
                    [self.inputViews addObject:aview];
                }
                if ([aview isKindOfClass:EBTextareaView.class]) {
                    [(EBTextareaView *)aview setToolbar:_toolbar];
                    [(EBTextareaView *)aview showInView:_superView];
                    [self.inputViews addObject:aview];
                }
            }
        }
        if ([view isKindOfClass:EBInputSelectView.class]) {
            EBInputView *elementView = [(EBInputSelectView *)view inputView];
            [elementView setToolbar:_toolbar];
            [elementView showInView:_superView];
            [self.inputViews addObject:elementView];
        }
        if ([view isKindOfClass:EBRangeView.class]) {
            EBInputView *elementView = [(EBRangeView *)view minInputView];
            [elementView setToolbar:_toolbar];
            [elementView showInView:_superView];
            [self.inputViews addObject:elementView];
            
            EBInputView *elementView1 = [(EBRangeView *)view maxInputView];
            [elementView1 setToolbar:_toolbar];
            [elementView1 showInView:_superView];
            [self.inputViews addObject:elementView1];
        }
    }
}
@end
