//
//  workbenchBtn.m
//  chowRentAgent
//
//  Created by zhaoyao on 15/12/7.
//  Copyright (c) 2015年 eallcn. All rights reserved.
//

#import "workbenchBtn.h"
#import "EBUtil.h"
#import "EBStyle.h"
#import "UIImage+Alpha.h"
#import "EBViewFactory.h"
#import "UIImageView+WebCache.h"

@interface workbenchBtn()
{
    NSString *_title;
    UIImage *_imgN;
    UIImage *_imgH;
    
    UIImageView *_imageView;
    UILabel *_titleLabel;
}
@property (nonatomic, strong) UILabel *badgeLabel;
@end

@implementation workbenchBtn

- (id)initWithTitle:(NSString *)title imageN:(UIImage *)imgN imageH:(UIImage *)imgH frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _title = title;
        if (imgH) {
            _imgH = imgH;
        } else {
            _imgH = [imgN imageByApplyingAlpha:0.4f];
        }
        _imgN = imgN;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imgN.size.width, imgN.size.height)];
        _imageView.center = CGPointMake(self.width * 0.5f, self.height * 0.5);
        _imageView.top -= ((8 + 15) * 0.5);
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.image = _imgN;
        [self addSubview:_imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, _imageView.bottom + 8, frame.size.width, 15)];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [EBStyle blackTextColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = title;
        [self addSubview:label];
        _titleLabel = label;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title imageUrl:(NSString *)url frame:(CGRect)frame
{
    if (self = [self initWithFrame:frame]) {
        _title = title;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _imageView.center = CGPointMake(self.width * 0.5f, self.height * 0.5);
        _imageView.top -= ((8 + 15) * 0.5);
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        __weak __typeof(self) weakSelf = self;
        [_imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            __strong __typeof(self) safeSelf = weakSelf;
            safeSelf->_imgN = image;
            safeSelf->_imgH = [image imageByApplyingAlpha:0.4f];
        }];
        [self addSubview:_imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, _imageView.bottom + 8, frame.size.width, 15)];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [EBStyle blackTextColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = title;
        [self addSubview:label];
        _titleLabel = label;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.center = CGPointMake(self.width * 0.5f, self.height * 0.5);
    _imageView.top -= ((8 + 15) * 0.5);
    _titleLabel.frame = CGRectMake(0, _imageView.bottom + 8, self.frame.size.width, 15);
    if (_badgeLabel) {
        _badgeLabel.center = CGPointMake(_imageView.right - 2, _imageView.top);
    }
}

- (void)setBadge:(NSInteger)badge
{
    _badge = badge;
    if (_badge == 0) {
        self.badgeLabel.hidden = YES;
    } else {
        self.badgeLabel.hidden = NO;
        NSString *text = [NSString stringWithFormat:@"%lu",(unsigned long)badge];
        if (badge == workBenchBtnPointBadge) {
            text = @"";
        }
        CGFloat width = [EBViewFactory textSize:text font:[UIFont systemFontOfSize:10] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
        self.badgeLabel.height = badge == workBenchBtnPointBadge ? 10 : 13 + 2 * 2;
        self.badgeLabel.width = MAX(width,self.badgeLabel.height);
        self.badgeLabel.text = text;
        self.badgeLabel.layer.cornerRadius = _badgeLabel.height * 0.5f;
    }
}

- (void)addPointBadge
{
    self.badge = workBenchBtnPointBadge;
}

- (void)removeBadge
{
    self.badge = 0;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    UIImage *img = highlighted ? _imgH : _imgN;
    _imageView.image = img;
    _titleLabel.textColor = highlighted ? [[EBStyle blackTextColor] colorWithAlphaComponent:0.4f] : [EBStyle blackTextColor];
    if (_badgeLabel) {
        _badgeLabel.textColor = highlighted ? [[UIColor whiteColor] colorWithAlphaComponent:0.4f] : [UIColor whiteColor];
        _badgeLabel.backgroundColor = highlighted ? [[UIColor redColor] colorWithAlphaComponent:0.4f] : [UIColor redColor];
    }
}

- (void)addBorderWithType:(workbenchBtnBorderType)type
{
    if (type & workbenchBtnBorderTop) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.5)];
        line.backgroundColor = [EBStyle grayUnClickLineColor];
        [self addSubview:line];
    }
    if (type & workbenchBtnBorderLeft) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5, self.height)];
        line.backgroundColor = [EBStyle grayUnClickLineColor];
        [self addSubview:line];
    }
    if (type & workbenchBtnBorderBottom) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 0.5, self.width, 0.5)];
        line.backgroundColor = [EBStyle grayUnClickLineColor];
        [self addSubview:line];
    }
    if (type & workbenchBtnBorderRight) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(self.width - 0.5, 0, 0.5f, self.height)];
        line.backgroundColor = [EBStyle grayUnClickLineColor];
        [self addSubview:line];
    }
}

- (UILabel *)badgeLabel
{
    if (!_badgeLabel) {
        _badgeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _badgeLabel.font = [UIFont systemFontOfSize:10];
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        _badgeLabel.backgroundColor = [UIColor redColor];
        _badgeLabel.textColor = [UIColor whiteColor];
        _badgeLabel.layer.masksToBounds = YES;
        [self addSubview:_badgeLabel];
    }
    return _badgeLabel;
}

@end
