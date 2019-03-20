//
//  TSEmojiView.m
//  TSEmojiView
//
//  Created by Shawn Ma on 7/24/12.
//  Copyright (c) 2012 Telenav Software, Inc. All rights reserved.
//

#import "TSEmojiView.h"

#define TSEMOJIVIEW_COLUMNS 7
#define TSEMOJIVIEW_SPACES  0.7
#define TSEMOJIVIEW_KEYTOP_WIDTH 82
#define TSEMOJIVIEW_KEYTOP_HEIGHT 111
#define TSKEYTOP_SIZE 40
#define TSEMOJI_SIZE 24

//==============================================================================
// TSEmojiViewLayer
//==============================================================================
@interface TSEmojiViewLayer : CALayer {
@private
    CGImageRef _keytopImage;
}
@property (nonatomic, retain) UIImage* emoji;
@end

@implementation TSEmojiViewLayer
@synthesize emoji = _emoji;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    _keytopImage = nil;
    _emoji = nil;
}

- (void)drawInContext:(CGContextRef)context
{
    //从后台返回需要重新获取图片,Fixes Bug
    _keytopImage = [[UIImage imageNamed:@"emoji_touch"] CGImage];
    
    UIGraphicsBeginImageContext(CGSizeMake(TSEMOJIVIEW_KEYTOP_WIDTH, TSEMOJIVIEW_KEYTOP_HEIGHT));
    CGContextTranslateCTM(context, 0.0, TSEMOJIVIEW_KEYTOP_HEIGHT);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0, 0, TSEMOJIVIEW_KEYTOP_WIDTH, TSEMOJIVIEW_KEYTOP_HEIGHT), _keytopImage);
    UIGraphicsEndImageContext();
    
    //
    UIGraphicsBeginImageContext(CGSizeMake(TSKEYTOP_SIZE, TSKEYTOP_SIZE));
    CGContextDrawImage(context, CGRectMake((TSEMOJIVIEW_KEYTOP_WIDTH - TSKEYTOP_SIZE) / 2 , 45, TSKEYTOP_SIZE, TSKEYTOP_SIZE), [_emoji CGImage]);
    UIGraphicsEndImageContext();
}

@end

//==============================================================================
// TSEmojiView
//==============================================================================
@interface TSEmojiView() {
    NSMutableArray *_emojiArray;

    NSInteger _touchedIndex;
    TSEmojiViewLayer *_emojiPadLayer;
}
@end

@implementation TSEmojiView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.exclusiveTouch = YES;
        self.multipleTouchEnabled = NO;
        //点击Layer
        _emojiPadLayer = [TSEmojiViewLayer layer];
        [self.layer addSublayer:_emojiPadLayer];
        _emojiPadLayer.zPosition = 9999;
        //背景透明
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)setEmojiKeys:(NSArray *)emojiKeys
{
    _emojiKeys = emojiKeys;
    _emojiArray = [[NSMutableArray alloc] initWithCapacity:emojiKeys.count];
    for (NSInteger i = 0; i < _emojiKeys.count; i++)
    {
        NSString *key = _emojiKeys[i];
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"emotion.bundle/%@", key]];
        [_emojiArray addObject:image];
    }
}

- (void)dealloc
{
    _delegate = nil;
    _emojiArray = nil;
    _emojiPadLayer = nil;
}

- (void)drawRect:(CGRect)rect
{
    int index =0;
    CGFloat adjust = 0;
    for(UIImage *image in _emojiArray)
    {
        NSInteger col = index % TSEMOJIVIEW_COLUMNS;
        NSInteger row = index / TSEMOJIVIEW_COLUMNS;
        adjust = row > 0 ? row * 5.0 : 0;
        float originX = (self.bounds.size.width / TSEMOJIVIEW_COLUMNS) * col + ((self.bounds.size.width / TSEMOJIVIEW_COLUMNS) - TSEMOJI_SIZE ) / 2;
        float originY = (self.bounds.size.width / TSEMOJIVIEW_COLUMNS) * row + adjust + ((self.bounds.size.width / TSEMOJIVIEW_COLUMNS) - TSEMOJI_SIZE ) / 2;
        [image drawInRect:CGRectMake(originX, originY, TSEMOJI_SIZE, TSEMOJI_SIZE)];
        index++;
    }

    float originX = (self.bounds.size.width / TSEMOJIVIEW_COLUMNS) * (index % TSEMOJIVIEW_COLUMNS) + ((self.bounds.size.width / TSEMOJIVIEW_COLUMNS) - 26 ) / 2;
    float originY = (index / TSEMOJIVIEW_COLUMNS) * (self.bounds.size.width / TSEMOJIVIEW_COLUMNS) + adjust + ((self.bounds.size.width / TSEMOJIVIEW_COLUMNS) - 16 ) / 2;
    [[UIImage imageNamed:@"emotion.bundle/fdelete"] drawInRect:CGRectMake(originX, originY, 26, 16)];
}

#pragma mark -
#pragma mark Actions
- (NSUInteger)indexWithEvent:(UIEvent*)event
{
    UITouch* touch = [[event allTouches] anyObject];
    NSUInteger x = [touch locationInView:self].x / (self.bounds.size.width / TSEMOJIVIEW_COLUMNS);
    NSUInteger y = [touch locationInView:self].y / (self.bounds.size.width / TSEMOJIVIEW_COLUMNS + 5);
    
    return x + (y * TSEMOJIVIEW_COLUMNS);
}

- (void)updateWithIndex:(NSUInteger)index
{
    if(index < _emojiArray.count) {
        _touchedIndex = index;
        
        if (_emojiPadLayer.opacity != 1.0) {
            _emojiPadLayer.opacity = 1.0;
        }
        
        float originX = (self.bounds.size.width / TSEMOJIVIEW_COLUMNS) * (index % TSEMOJIVIEW_COLUMNS) + ((self.bounds.size.width / TSEMOJIVIEW_COLUMNS) - TSEMOJI_SIZE ) / 2;
        float originY = (index / TSEMOJIVIEW_COLUMNS) * (self.bounds.size.width / TSEMOJIVIEW_COLUMNS) + ((self.bounds.size.width / TSEMOJIVIEW_COLUMNS) - TSEMOJI_SIZE ) / 2;
        
        [_emojiPadLayer setEmoji:[_emojiArray objectAtIndex:index]];
        [_emojiPadLayer setFrame:CGRectMake(originX - (TSEMOJIVIEW_KEYTOP_WIDTH - TSEMOJI_SIZE) / 2, originY - (TSEMOJIVIEW_KEYTOP_HEIGHT - TSEMOJI_SIZE), TSEMOJIVIEW_KEYTOP_WIDTH, TSEMOJIVIEW_KEYTOP_HEIGHT)];
        [_emojiPadLayer setNeedsDisplay];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSUInteger index = [self indexWithEvent:event];
    if(index < _emojiArray.count) {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        [self updateWithIndex:index];
        [CATransaction commit];
    }
    else if (index == _emojiArray.count)
    {
        _touchedIndex = index;
    }
    else
    {
        _touchedIndex = -1;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSUInteger index = [self indexWithEvent:event];
    if (_touchedIndex >=0 && _touchedIndex < _emojiArray.count && index != _touchedIndex) {
        [self updateWithIndex:index];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.delegate && _touchedIndex >= 0) {
        if ([self.delegate respondsToSelector:@selector(didTouchEmojiView:touchedEmoji:)]) {
            if (_touchedIndex < _emojiArray.count)
            {
                NSString *key = _emojiKeys[_touchedIndex];
                [self.delegate didTouchEmojiView:self touchedEmoji:_faceMap[key]];
            }
            else
            {
               [self.delegate didTouchEmojiViewBackspace:self];
            }
        }
    }
    _touchedIndex = -1;
    _emojiPadLayer.opacity = 0.0;
    [self setNeedsDisplay];
    [_emojiPadLayer setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchedIndex = -1;
    _emojiPadLayer.opacity = 0.0;
    [self setNeedsDisplay];
    [_emojiPadLayer setNeedsDisplay];
}

@end
