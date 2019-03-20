//
//  KWProgressCircleView.m
//  KWProgressCircleViewDemo
//
//  Created by 凯文马 on 15/12/16.
//  Copyright © 2015年 kevin. All rights reserved.
//

#import "KWProgressCircleView.h"

@interface KWProgressCircleView ()

@property (nonatomic, assign) BOOL showPercentText;

@property (nonatomic, assign) BOOL animation;

@property (nonatomic, strong) UILabel *percentLabel;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) CGFloat timeInterval;

@property (nonatomic, assign) CGFloat timerPercent;

@end

@implementation KWProgressCircleView

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.tintColor = [UIColor grayColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.tintColor = [UIColor grayColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // 修改绘制尺寸
    CGFloat value = rect.size.width > rect.size.height ? rect.size.height - self.lineWidth : rect.size.width - self.lineWidth;
    CGFloat radius = value * 0.5f;
    CGPoint circlePoint = CGPointMake(rect.size.width * 0.5f, rect.size.height * 0.5f);
    
    // 开始绘制背景
    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ref, self.lineWidth);
    [self.tintColor set];
    CGContextAddArc(ref, circlePoint.x, circlePoint.y, radius, 0, 2 * M_PI, 0);
    CGContextStrokePath(ref);
    if (!self.animation) {
        
        // 开始绘制比例
        CGFloat circleOffset = 0.f;
        for (NSInteger i = 0 ; i < self.percents.count; i++) {
            KWProgressComponent *component = self.percents[i];
            if (![component isKindOfClass:[KWProgressComponent class]]) return;
            CGFloat from = circleOffset;
            CGFloat to = circleOffset + [self circleValueFromPercent:component.percent];
            circleOffset = to;
            NSLog(@"%f -> %f",from,to);
            [component.color set];
            CGContextAddArc(ref, circlePoint.x, circlePoint.y, radius, from, to, 0);
            CGContextStrokePath(ref);
        }
    }
}

+ (instancetype)progressCircleViewWithPercents:(NSArray *)percents frame:(CGRect)frame
{
    KWProgressCircleView *view = [[KWProgressCircleView alloc] initWithFrame:frame];
    view.percents = percents;
    return view;
}

+ (instancetype)progressCircleViewWithPercents:(NSArray *)percents
{
    return [self progressCircleViewWithPercents:percents frame:CGRectZero];
}

+ (instancetype)progressCircleViewWithPercent:(KWProgressComponent *)percent withPercentText:(BOOL)text andAnimation:(BOOL)animation
{
    KWProgressCircleView *view = [KWProgressCircleView progressCircleViewWithPercents:@[percent]];
    view.showPercentText = text;
    view.animation = animation;
    return view;
}



- (CGFloat)lineWidth
{
    if (!_lineWidth) {
        _lineWidth = 2.f;
    }
    return _lineWidth;
}

- (void)startAnimationWithTimeInterval:(CGFloat)timeInterval
{
    if (self.percents.count != 1 || ![self.percents.firstObject isKindOfClass:[KWProgressComponent class]]) return;
    // 先移除图层
    if (self.shapeLayer) {
        [self.shapeLayer removeFromSuperlayer];
        self.shapeLayer = nil;
    }
    self.timeInterval = timeInterval;
    // 开始绘制
    KWProgressComponent *com = self.percents.firstObject;
    //创建出CAShapeLayer
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.frame = self.layer.bounds;//设置shapeLayer的尺寸和位置
    self.shapeLayer.position = self.center;
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;//填充颜色为ClearColor
    
    self.shapeLayer.lineWidth = self.lineWidth;
    self.shapeLayer.strokeColor = [com.color CGColor];
    
    CGRect rect = self.bounds;
    
    CGFloat value = rect.size.width > rect.size.height ? rect.size.height - self.lineWidth : rect.size.width - self.lineWidth;

    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.lineWidth * 0.5, self.lineWidth * 0.5, value, value)];
    
    //让贝塞尔曲线与CAShapeLayer产生联系
    self.shapeLayer.path = circlePath.CGPath;
    self.shapeLayer.strokeStart = 0.f;
    self.shapeLayer.strokeEnd = 0.f;
    //添加并显示
    [self.layer addSublayer:self.shapeLayer];
    self.timerPercent = 0.f;
    if (self.showPercentText) {
        CGFloat fontSize = value * 0.2f - 3.f;
        CGRect temp = self.percentLabel.frame;
        temp.size.height = fontSize + 3.f;
        temp.size.width -= 6;
        self.percentLabel.frame = temp;
        self.percentLabel.center = CGPointMake(self.frame.size.width * 0.5f, self.frame.size.height * 0.5f);
        self.percentLabel.textColor = com.color;
        self.percentLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    }
    [self startTimer];
}

# pragma mark - Timer

- (void)startTimer
{
    if (!self.timer) {
        if (self.timeInterval < 0.001f) {
            self.timeInterval = 0.001f;
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(timeActions) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timeActions
{
    KWProgressComponent *com = self.percents.firstObject;
    if (self.timerPercent < com.percent) {
        self.timerPercent += 0.1;
        self.shapeLayer.strokeEnd = self.timerPercent;
        
        // 改变文字显示
        if (self.showPercentText) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                __block NSString *text = [NSString stringWithFormat:@"%.2f%%",self.timerPercent * 100];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.percentLabel.text = text;
                });
            });
        }
        
    } else {
        [self stopTimer];
    }
}

# pragma mark - private

- (CGFloat)circleValueFromPercent:(CGFloat)percent
{
    if (percent >= 1.f) {
        return M_PI * 2;
    }
    return M_PI * 2 * percent;
}

- (UILabel *)percentLabel
{
    if (!_percentLabel) {
        _percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.lineWidth, self.lineWidth, self.bounds.size.width - 2 * self.lineWidth, self.bounds.size.height - 2 * self.lineWidth)];
        _percentLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_percentLabel];
    }
    return _percentLabel;
}

@end


@implementation KWProgressComponent

+ (instancetype)componentWithPercent:(CGFloat)percent color:(UIColor *)color
{
    KWProgressComponent *com = [[KWProgressComponent alloc] init];
    com.percent = percent;
    com.color = color;
    return com;
}

@end