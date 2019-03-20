//
// Created by 何 义 on 14-4-3.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBRecordingHUD.h"

@interface EBRecordingHUD ()

@property (nonatomic, copy) TAudioAmpBlock ampBlock;
@property (nonatomic, strong, readonly) NSTimer *ampTimer;

@property (nonatomic, strong, readonly) UIWindow *overlayWindow;
@property (nonatomic, strong, readonly) UIView *hudView;
@property (nonatomic, strong, readonly) UIView *microPhoneView;
@property (nonatomic, strong, readonly) UIView *releaseHintView;

@end


@implementation EBRecordingHUD

@synthesize overlayWindow, hudView, microPhoneView, releaseHintView, ampTimer;


+ (EBRecordingHUD*)sharedView
{
    static dispatch_once_t once;
    static EBRecordingHUD *sharedView;
    dispatch_once(&once, ^ { sharedView = [[EBRecordingHUD alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}

+ (void)showWithAmpBlock:(TAudioAmpBlock)ampBlock
{
    [[EBRecordingHUD sharedView] showWithAmpBlock:ampBlock];
}

+ (void)showRecording
{
    [[EBRecordingHUD sharedView] showRecording];
}

+ (void)showReleaseHint
{
    [[EBRecordingHUD sharedView] showReleaseHint];
}

+ (void)dismiss
{
    [[EBRecordingHUD sharedView] dismiss];
}

- (void)dealloc
{

}

#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }

    return self;
}
//
//- (void)drawRect:(CGRect)rect
//{
//
//    CGContextRef context = UIGraphicsGetCurrentContext();
//
//    size_t locationsCount = 2;
//    CGFloat locations[2] = {0.0f, 1.0f};
//    CGFloat colors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
//    CGColorSpaceRelease(colorSpace);
//
//    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
//    float radius = MIN(self.bounds.size.width , self.bounds.size.height) ;
//    CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
//    CGGradientRelease(gradient);
//}

- (void)showRecording
{
    self.microPhoneView.hidden = NO;
    self.releaseHintView.hidden = YES;
    if (ampTimer)
    {
        [ampTimer invalidate];
        ampTimer = nil;
    }

    ampTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                target:self selector:@selector(updateAmp) userInfo:nil repeats:YES];
}

- (void)updateAmp
{
    NSInteger amp = self.ampBlock();
    if (microPhoneView)
    {
        UIImageView *imageView = (UIImageView *)[microPhoneView viewWithTag:1];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"im_recording_%ld", amp]];
    }
}

- (void)showReleaseHint
{
    self.microPhoneView.hidden = YES;
    self.releaseHintView.hidden = NO;
    if (ampTimer)
    {
        [ampTimer invalidate];
        ampTimer = nil;
    }
}

-(void)showWithAmpBlock:(TAudioAmpBlock)ampBlock
{
    self.ampBlock = ampBlock;

    CGFloat hudWidth = 167;
    CGFloat hudHeight = 167;

    self.hudView.bounds = CGRectMake(0, 0, hudWidth, hudHeight);

    [self showRecording];

    [self showHUD];
}

- (void)positionHUD
{

    CGRect orientationFrame = [UIScreen mainScreen].bounds;

    CGFloat activeHeight = orientationFrame.size.height;

    CGFloat posY = floor(activeHeight * 0.45);
    CGFloat posX = orientationFrame.size.width / 2;

    [self moveToPoint:CGPointMake(posX, posY) rotateAngle:0.0];
}

- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle
{
    self.hudView.transform = CGAffineTransformMakeRotation(angle);
    self.hudView.center = newCenter;
}

- (void)showHUD {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!self.superview)
            [self.overlayWindow addSubview:self];

        [self.overlayWindow makeKeyAndVisible];
        [self positionHUD];

        if(self.alpha != 1) {
            self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1.3, 1.3);

            [UIView animateWithDuration:0.15
                                  delay:0
                                options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1/1.3, 1/1.3);
                                 self.alpha = 1;
                             }
                             completion:NULL];
        }

        [self setNeedsDisplay];
    });
}


- (void)dismiss
{
    dispatch_async(dispatch_get_main_queue(), ^{

        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 0.8, 0.8);
                             self.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             if(self.alpha == 0) {
                                 [[NSNotificationCenter defaultCenter] removeObserver:self];
                                 [hudView removeFromSuperview];
                                 hudView = nil;
                                 microPhoneView = nil;
                                 releaseHintView = nil;

                                 if (ampTimer)
                                 {
                                     [ampTimer invalidate];
                                     ampTimer = nil;
                                 }

                                 // Make sure to remove the overlay window from the list of windows
                                 // before trying to find the key window in that same list
                                 NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[UIApplication sharedApplication].windows];
                                 [windows removeObject:overlayWindow];
                                 overlayWindow = nil;

                                 [windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *stop) {
                                     if([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
                                         [window makeKeyWindow];
                                         *stop = YES;
                                     }
                                 }];

                                 // uncomment to make sure UIWindow is gone from app.windows
                                 //NSLog(@"%@", [UIApplication sharedApplication].windows);
                                 //NSLog(@"keyWindow = %@", [UIApplication sharedApplication].keyWindow);
                             }
                         }];
    });
}


#pragma mark - Getters

- (UIWindow *)overlayWindow
{
    if(!overlayWindow)
    {
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.userInteractionEnabled = NO;
    }
    return overlayWindow;
}

- (UIView *)hudView
{
    if(!hudView) {
        hudView = [[UIView alloc] initWithFrame:CGRectZero];
        hudView.layer.cornerRadius = 10;
        hudView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        hudView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
                UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);

        [self addSubview:hudView];
    }
    return hudView;
}

- (UIView *)microPhoneView
{
    if (!microPhoneView)
    {
        CGRect frame = CGRectMake(0, 0, 167, 167);
        microPhoneView = [[UIView alloc] initWithFrame:frame];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, frame.size.width, 80)];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.tag = 1;
        imageView.image = [UIImage imageNamed:@"im_recording_0"];
        [microPhoneView addSubview:imageView];

        UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 28, frame.size.width, 13)];
        hintLabel.backgroundColor = [UIColor clearColor];
        hintLabel.font = [UIFont systemFontOfSize:12.0];
        hintLabel.textAlignment = NSTextAlignmentCenter;
        hintLabel.textColor = [UIColor whiteColor];
        hintLabel.text = NSLocalizedString(@"im_microphone_hint", nil);
        hintLabel.tag = 2;
        [microPhoneView addSubview:hintLabel];

        [self.hudView addSubview:microPhoneView];
    }

    return microPhoneView;
}

- (UIView *)releaseHintView
{
   if (!releaseHintView)
   {
       CGRect frame = CGRectMake(0, 0, 167, 167);
       releaseHintView = [[UIView alloc] initWithFrame:frame];

       UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, frame.size.width, 80)];
       imageView.contentMode = UIViewContentModeCenter;
       imageView.tag = 1;
       imageView.image = [UIImage imageNamed:@"im_recording_release"];
       [releaseHintView addSubview:imageView];

       imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, frame.size.height - 34, frame.size.width - 20, 24)];
       imageView.image = [[UIImage imageNamed:@"im_release_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 5, 12, 5)];
       [releaseHintView addSubview:imageView];

       UILabel *hintLabel = [[UILabel alloc] initWithFrame:imageView.frame];
       hintLabel.backgroundColor = [UIColor clearColor];
       hintLabel.font = [UIFont systemFontOfSize:12.0];
       hintLabel.textAlignment = NSTextAlignmentCenter;
       hintLabel.textColor = [UIColor whiteColor];
       hintLabel.text = NSLocalizedString(@"im_microphone_hint_release", nil);
       [releaseHintView addSubview:hintLabel];

       [self.hudView addSubview:releaseHintView];
   }

    return releaseHintView;
}

@end