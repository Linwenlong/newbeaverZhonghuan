//
// Created by 何 义 on 14-4-24.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBRecordingButton.h"


@interface EBRecordingButton()
{
    UIImageView *_backgroundView;
    UILabel *_titleLabel;
}
@end

@implementation EBRecordingButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.userInteractionEnabled = YES;
        [self setMultipleTouchEnabled:NO];
        [self setExclusiveTouch:YES];

        _backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"im_btn_recording"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 5, 15, 5)]
                                            highlightedImage:[[UIImage imageNamed:@"im_btn_recording_p"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 5, 15, 5)]];
        _backgroundView.frame = CGRectInset(self.bounds, 0, (frame.size.height - 30) / 2);

        _titleLabel = [[UILabel alloc] initWithFrame:_backgroundView.frame];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        _titleLabel.textColor = [UIColor colorWithRed:0x30/255.f green:0x4c/255.f blue:0x7a/255.f alpha:1.0];
        _titleLabel.text = NSLocalizedString(@"recording_press", nil);

        [self addSubview:_backgroundView];
        [self addSubview:_titleLabel];

        _backgroundView.userInteractionEnabled = NO;
        _titleLabel.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
   _backgroundView.highlighted = highlighted;

   if (highlighted)
   {
       _titleLabel.text = NSLocalizedString(@"recording_release", nil);
       _titleLabel.textColor = [UIColor whiteColor];
   }
   else
   {
       _titleLabel.text = NSLocalizedString(@"recording_press", nil);
       _titleLabel.textColor = [UIColor colorWithRed:0x30/255.f green:0x4c/255.f blue:0x7a/255.f alpha:1.0];
   }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchOutside = NO;
    DDLogDebug(@"touches began");
    [self setHighlighted:YES];
    self.eventBlock(ERecordingButtonEventTouchesBegin);
    _stillTouching = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _stillTouching = NO;
    _touchOutside = NO;
    DDLogDebug(@"touches end");
    [self setHighlighted:NO];
    if (_touchOutside)
    {
        self.eventBlock(ERecordingButtonEventTouchesCanceled);
    }
    else
    {
        self.eventBlock(ERecordingButtonEventTouchesEnd);
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _stillTouching = NO;
    _touchOutside = NO;
    DDLogDebug(@"touches cancelled");
    [self setHighlighted:NO];
    self.eventBlock(ERecordingButtonEventTouchesCanceled);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    DDLogDebug(@"touches moved");
    UITouch *touch = [[event allTouches] anyObject];

    CGPoint pt = [touch locationInView:self];
    DDLogDebug(@"%.0f, %.0f", pt.x, pt.y);

    if ([touch locationInView:self].y < 0 && !_touchOutside)
    {
        _touchOutside = YES;
        [self setHighlighted:NO];
        self.eventBlock(ERecordingButtonEventTouchesMoveOut);
    }

    if ([touch locationInView:self].y >= 0 && _touchOutside)
    {
        _touchOutside = NO;
        [self setHighlighted:YES];
        self.eventBlock(ERecordingButtonEventTouchesMoveIn);
    }
}

@end