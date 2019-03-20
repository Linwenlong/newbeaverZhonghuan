//
//  UnderLineLabel.m
//  beaver
//
//  Created by wangyuliang on 14-8-14.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "UnderLineLabel.h"

@implementation UnderLineLabel
@synthesize highlightedColor = _highlightedColor;
@synthesize shouldUnderline = _shouldUnderline;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)init
{
    if (self = [super init]) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}

- (void)setShouldUnderline:(BOOL)shouldUnderline
{
    _shouldUnderline = shouldUnderline;
    if (_shouldUnderline) {
        [self setup];
    }
}

- (void)drawRect:(CGRect)rect
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [super drawRect:rect];
    if (self.shouldUnderline) {
        NSLog(@"走到了这里");
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGSize fontSize =[self.text sizeWithFont:self.font
                                        forWidth:self.frame.size.width
                                   lineBreakMode:NSLineBreakByTruncatingTail];
        
        CGContextSetStrokeColorWithColor(ctx, self.textColor.CGColor);  // set as the text's color
        CGContextSetLineWidth(ctx, 1.0f);
        
        CGPoint leftPoint = CGPointMake(0,
                                        (self.frame.size.height - fontSize.height) / 2.0 + fontSize.height + 1.5);
        CGPoint rightPoint = CGPointMake(fontSize.width,
                                         (self.frame.size.height - fontSize.height) / 2.0 + fontSize.height + 1.5);
        CGContextMoveToPoint(ctx, leftPoint.x, leftPoint.y);
        CGContextAddLineToPoint(ctx, rightPoint.x, rightPoint.y);
        CGContextStrokePath(ctx);
    }
}

- (void)setText:(NSString *)text andCenter:(CGPoint)center
{
    [super setText:text];
    CGSize fontSize =[self.text sizeWithFont:self.font
                                    forWidth:200
                               lineBreakMode:NSLineBreakByTruncatingTail];
    NSLog(@"%f   %f", fontSize.width, fontSize.height);
    [self setNumberOfLines:0];
//    [self setFrame:CGRectMake(0, 0, fontSize.width, fontSize.height)];
//    [self setCenter:center];
}

- (void)setTitleColor:(UIColor*)color
{
    [super setTextColor:color];
    _orginalColor = color;
}

- (void)setup
{
    [self setUserInteractionEnabled:TRUE];
    _actionView = [[UIControl alloc] initWithFrame:self.bounds];
    [_actionView setBackgroundColor:[UIColor clearColor]];
    [_actionView addTarget:self action:@selector(appendHighlightedColor) forControlEvents:UIControlEventTouchDown];
    [_actionView addTarget:self
                    action:@selector(removeHighlightedColor)
          forControlEvents:UIControlEventTouchCancel |
     UIControlEventTouchUpInside |
     UIControlEventTouchDragOutside |
     UIControlEventTouchUpOutside];
    [self addSubview:_actionView];
    [self sendSubviewToBack:_actionView];
}

- (void)addTarget:(id)target action:(SEL)action
{
    [_actionView addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)appendHighlightedColor
{
    self.textColor = self.highlightedColor;
//    self.backgroundColor = self.highlightedColor;
}

- (void)removeHighlightedColor
{
    self.textColor = _orginalColor;
//    self.backgroundColor = [UIColor clearColor];
}

@end
