//
// Created by 何 义 on 14-3-9.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBIconLabel.h"
#import "EBViewFactory.h"

@implementation EBIconLabel

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _label = [[UILabel alloc] init];
        _label.numberOfLines = 0;
        _label.backgroundColor = [UIColor clearColor];
        [self addSubview:_label];
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_imageView];
        _maxWidth = 300;
    }

    return self;
}

- (CGRect)currentFrame
{
    UIFont *font = _label.font;
    CGSize imageSize = _imageView.image.size;
    CGFloat heightLimit = MAXFLOAT;
    if (_label.numberOfLines == 1)
    {
        CGSize singleLineSz = [EBViewFactory textSize:@"A" font:font bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        heightLimit = singleLineSz.height;
    }
    CGSize labelSize = [EBViewFactory textSize:_label.text font:font bounding:CGSizeMake(_maxWidth - _gap - imageSize.width, heightLimit)];
    if (_maxWidth > 0.0f)
    {
        if (_iconPosition == EIconPositionLeft || _iconPosition == EIconPositionRight)
        {
            if (labelSize.width + _gap + imageSize.width > _maxWidth)
            {
                labelSize.width = _maxWidth - _gap - imageSize.width;
            }
            CGFloat height = labelSize.height > imageSize.height ? labelSize.height : imageSize.height;
            return CGRectMake(self.frame.origin.x, self.frame.origin.y, labelSize.width + _gap + imageSize.width, height);
        }
        else
        {
            if (labelSize.width > _maxWidth)
            {
                labelSize.width = _maxWidth;
            }
            if (imageSize.width > _maxWidth)
            {
                imageSize.width = _maxWidth;
            }
        }
    }

    if (_iconPosition == EIconPositionLeft || _iconPosition == EIconPositionRight)
    {
        CGFloat height = labelSize.height > imageSize.height ? labelSize.height : imageSize.height;
        return CGRectMake(self.frame.origin.x, self.frame.origin.y, labelSize.width + _gap + imageSize.width, height);
    }
    else
    {
        CGFloat height = labelSize.height + imageSize.height + _gap;
        CGFloat width  = imageSize.width > labelSize.width ? imageSize.width : labelSize.width;
        return  CGRectMake(self.frame.origin.x, self.frame.origin.y, width, height);
    }
}

- (void)layoutSubviews
{
    UIFont *font = _label.font;
    CGSize imageSize = _imageView.image.size;
    CGFloat heightLimit = MAXFLOAT;
    CGSize labelSize = CGSizeZero;
    if (_label.numberOfLines == 1)
    {
        CGSize singleLineSz = [EBViewFactory textSize:@"A" font:font bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        heightLimit = singleLineSz.height;
    }
    labelSize = [EBViewFactory textSize:_label.text font:font bounding:CGSizeMake(_maxWidth - _gap - imageSize.width, heightLimit)];
    if (_maxWidth > 0.0f)
    {
        if (_iconPosition == EIconPositionLeft || _iconPosition == EIconPositionRight)
        {
            if (labelSize.width + _gap + imageSize.width > _maxWidth)
            {
                labelSize.width = _maxWidth - _gap - imageSize.width;
            }
        }
        else
        {
            if (labelSize.width > _maxWidth)
            {
                labelSize.width = _maxWidth;
            }
            if (imageSize.width > _maxWidth)
            {
                imageSize.width = _maxWidth;
            }
        }
    }

    if (_iconPosition == EIconPositionLeft || _iconPosition == EIconPositionRight)
    {
        CGFloat height = labelSize.height > imageSize.height ? labelSize.height : imageSize.height;
        if (_iconPosition == EIconPositionLeft)
        {
            _imageView.frame = CGRectMake(0, 0, imageSize.width, _iconVerticalCenter ? height : imageSize.height);
            _label.frame = CGRectMake(imageSize.width + _gap, 0, labelSize.width, height);
        }
        else if (_iconPosition == EIconPositionRight)
        {
            _label.frame = CGRectMake(0, 0, labelSize.width, height);
            _imageView.frame = CGRectMake(labelSize.width + _gap, 0, imageSize.width, height);
        }
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, labelSize.width + _gap + imageSize.width, height);
    }
    else
    {
        _label.textAlignment = NSTextAlignmentCenter;
        _imageView.contentMode = UIViewContentModeCenter;

        CGFloat height = labelSize.height + imageSize.height + _gap;
        CGFloat width  = imageSize.width > labelSize.width ? imageSize.width : labelSize.width;
        if (_iconPosition == EIconPositionBottom)
        {
            _label.frame = CGRectMake(0, 0, width, labelSize.height);
            _imageView.frame = CGRectMake(0, labelSize.height + _gap, width, imageSize.height);
        }
        else if (_iconPosition == EIconPositionTop)
        {
            _label.frame = CGRectMake(0, imageSize.height + _gap, width, labelSize.height);
            _imageView.frame = CGRectMake(0, 0, width, imageSize.height);
        }

        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, height);
    }
}

@end