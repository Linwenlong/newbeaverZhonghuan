//
//  IanProgressLoadingView.m
//  chowRent
//
//  Created by ian on 15/10/16.
//  Copyright © 2015年 eallcn. All rights reserved.
//

#import "IanProgressLoadingView.h"

static NSUInteger const IANhubViewWith = 100;
static NSUInteger const IANhubViewHeight = 100;
static NSUInteger const IANloadingImageViewWith = 101/3;
static NSUInteger const IANloadingImageViewHeight = 61/3;
static NSUInteger const IANProgressLabelWidth = 100;
static NSUInteger const IANProgressLabelHeight = 17;

@interface IanProgressLoadingView()

@property (nonatomic, strong) UIView *hudView;
@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, strong) UILabel *progressLabel;

@end

@implementation IanProgressLoadingView

- (instancetype)initProgressView
{
    self = [super init];
    if (self) {
        self = [[[self class] alloc]init];
        self.frame = [UIScreen mainScreen].bounds;
        self.userInteractionEnabled = YES;
        [self creatProgressView];
    }
    return self;
}

- (void)changeProgressText:(NSString *)text
{
    if (!_progressLabel) {
        return;
    }
    _progressLabel.text = text;
}

- (void)creatProgressView
{
    self.hudView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self addSubview:self.hudView];
    [self addSubview:self.loadingImageView];
    [self addSubview:self.progressLabel];
}

- (UIImageView *)loadingImageView
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:@"Loading" withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];
    if (!_loadingImageView) {
        _loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - IANloadingImageViewWith/2, self.bounds.size.height/2 - IANloadingImageViewHeight/2, IANloadingImageViewWith, IANloadingImageViewHeight)];
        NSMutableArray *imgArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 25; i++) {
            UIImage *image = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:[NSString stringWithFormat:@"whiteLoading%d", i] ofType:@"png"]];
            [imgArray addObject:image];
        }
        for(int i = 24; i >= 0; i--){
            UIImage *image = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:[NSString stringWithFormat:@"whiteLoading%d", i] ofType:@"png"]];
            [imgArray addObject:image];
        }
        self.loadingImageView.backgroundColor = [UIColor clearColor];
        self.loadingImageView.animationImages = imgArray;
        self.loadingImageView.animationDuration = 0.6f;
        [self addSubview:self.loadingImageView];
        [self.loadingImageView startAnimating];
    }
    return _loadingImageView;
}

- (UIView *)hudView
{
    if (!_hudView) {
        _hudView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - IANhubViewWith/2, self.bounds.size.height/2 - IANhubViewHeight/2, IANhubViewWith, IANhubViewHeight)];
        _hudView.clipsToBounds = YES;
        _hudView.layer.cornerRadius = 10;
    }
    return _hudView;
}

- (UILabel *)progressLabel
{
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - IANProgressLabelWidth/2, self.bounds.size.height/2 - IANProgressLabelHeight/2 + 28, IANProgressLabelWidth, IANProgressLabelHeight)];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.font  = [UIFont systemFontOfSize:12.0f];
        _progressLabel.textColor = [UIColor whiteColor];
    }
    return _progressLabel;
}

@end
