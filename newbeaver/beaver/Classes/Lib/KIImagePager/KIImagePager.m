//
//  KIImagePager.m
//  KIImagePager
//
//  Created by Marcus Kida on 07.04.13.
//  Copyright (c) 2013 Marcus Kida. All rights reserved.
//

#define kPageControlHeight  30
#define kOverlayWidth       50
#define kOverlayHeight      15
#define kCaptionLabelHeight 58

#import "AFNetworkReachabilityManager.h"
#import <sys/ucred.h>
#import "KIImagePager.h"
#import "UIImageView+WebCache.h"
#import "EBStyle.h"

@interface KIImagePager () <UIScrollViewDelegate>
{
    __weak id <KIImagePagerDataSource> _dataSource;
    __weak id <KIImagePagerDelegate> _delegate;
    
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    UILabel *_countLabel;
    UILabel *_captionLabel;
    UIView *_imageCounterBackground;
    NSTimer *_slideshowTimer;
    NSUInteger _slideshowTimeInterval;
    NSMutableDictionary *_activityIndicators;
    
    BOOL _indicatorDisabled;
}
@end

@implementation KIImagePager

@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize contentMode = _contentMode;
@synthesize pageControl = _pageControl;
@synthesize indicatorDisabled = _indicatorDisabled;

//- (id)initWithFrame:(CGRect)frame
//{
//    if ((self = [super initWithFrame:frame])) {
//        // Initialization code
////        [self initialize];
//    }
//    return self;
//}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        // Initialization code
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
}

- (void) layoutSubviews
{
    [self initialize];
}

#pragma mark - General
- (void) initialize
{
    self.clipsToBounds = YES;
    self.slideshowShouldCallScrollToDelegate = YES;
    self.captionBackgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.captionTextColor = [UIColor whiteColor];
    self.captionFont = [UIFont systemFontOfSize:16.0f];
    self.hidePageControlForSinglePages = YES;
    
    [self initializeScrollView];
    [self initializePageControl];
    if(!_imageCounterDisabled) {
        [self initalizeImageCounter];
    }
    [self initializeCaption];
    [self loadData];
}

- (UIColor *) randomColor
{
    return [UIColor colorWithHue:(arc4random() % 256 / 256.0)
                      saturation:(arc4random() % 128 / 256.0) + 0.5
                      brightness:(arc4random() % 128 / 256.0) + 0.5
                           alpha:1];
}

- (void) initalizeImageCounter
{
    _imageCounterBackground = [[UIView alloc] initWithFrame:CGRectMake(_scrollView.frame.size.width-(kOverlayWidth-4),
                                                                       _scrollView.frame.size.height-kOverlayHeight,
                                                                       kOverlayWidth,
                                                                       kOverlayHeight)];
    _imageCounterBackground.backgroundColor = [UIColor whiteColor];
    _imageCounterBackground.alpha = 0.7f;
    _imageCounterBackground.layer.cornerRadius = 5.0f;

    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
    [icon setImage:[UIImage imageNamed:@"KICamera"]];
    icon.center = CGPointMake(_imageCounterBackground.frame.size.width-18, _imageCounterBackground.frame.size.height/2);
    [_imageCounterBackground addSubview:icon];

    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    [_countLabel setTextAlignment:NSTextAlignmentCenter];
    [_countLabel setBackgroundColor:[UIColor clearColor]];
    [_countLabel setTextColor:[UIColor blackColor]];
    [_countLabel setFont:[UIFont systemFontOfSize:11.0f]];
    _countLabel.center = CGPointMake(15, _imageCounterBackground.frame.size.height/2);
    [_imageCounterBackground addSubview:_countLabel];

    [self addSubview:_imageCounterBackground];
}

- (void) initializeCaption
{
    if (_captionLabel) {
        [_captionLabel removeFromSuperview];
    }
    _captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _scrollView.frame.size.height - kCaptionLabelHeight,
            _scrollView.frame.size.width, kCaptionLabelHeight)];
    [_captionLabel setBackgroundColor:self.captionBackgroundColor];
    [_captionLabel setTextColor:self.captionTextColor];
    [_captionLabel setFont:self.captionFont];

    _captionLabel.alpha = 0.7f;
    _captionLabel.layer.cornerRadius = 5.0f;
    
    [self addSubview:_captionLabel];
}

- (void) reloadData
{
    if([_slideshowTimer isValid])
    {
        [_slideshowTimer invalidate];
    }
    for (UIView *view in _scrollView.subviews)
        [view removeFromSuperview];
    
    [self loadData];
    [self checkWetherToToggleSlideshowTimer];
}

#pragma mark - ScrollView Initialization
- (void) initializeScrollView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.autoresizingMask = self.autoresizingMask;
    [self addSubview:_scrollView];
}

- (void) loadData
{
    NSArray *aImageUrls = [_dataSource arrayWithImages];
    _activityIndicators = [NSMutableDictionary new];
    
    [self updateCaptionLabelForImageAtIndex:0];
    
    if([aImageUrls count] > 0) {
        [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width * [aImageUrls count],
                                               _scrollView.frame.size.height)];
        
        for (int i = 0; i < [aImageUrls count]; i++) {
            CGRect imageFrame = CGRectMake(_scrollView.frame.size.width * i, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
            [imageView setBackgroundColor:[UIColor clearColor]];
            [imageView setContentMode:[_dataSource contentModeForImage:i]];
            [imageView setTag:i];
            
            if ([_dataSource respondsToSelector:@selector(isVideoAtIndex:)] && [_dataSource isVideoAtIndex:i]) {
                UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_video_play"]];
                iconImageView.center = CGPointMake(imageView.width * 0.5, imageView.height * 0.5);
                [imageView addSubview:iconImageView];
            }

            if([aImageUrls[i] isKindOfClass:[UIImage class]]) {
                // Set ImageView's Image directly
                [imageView setImage:(UIImage *)aImageUrls[i]];
            } else {
                __weak UIImageView *weakImageView = imageView;
                [imageView setImageWithURL:[[NSURL alloc] initWithString:aImageUrls[i]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                    [[SDImageCache sharedImageCache] removeImageForKey:[[[NSURL alloc] initWithString:aImageUrls[i]] absoluteString] fromDisk:NO];
                    if (weakImageView && image == nil && error == nil && cacheType == SDImageCacheTypeNone && [AFNetworkReachabilityManager sharedManager].reachable) {
                        UILabel *label = [[UILabel alloc] initWithFrame:weakImageView.bounds];
                        label.userInteractionEnabled = NO;
                        label.textAlignment = NSTextAlignmentCenter;
                        label.text = NSLocalizedString(@"tap_to_download", nil);
                        label.tag = 88;
                        label.font = [UIFont systemFontOfSize:12.0];
                        label.textColor = [EBStyle grayTextColor];
                        [weakImageView addSubview:label];
                        [weakImageView bringSubviewToFront:label];
                    }
                    image = nil;
                }];
            }
            
            // Add GestureRecognizer to ImageView
            UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                                  initWithTarget:self
                                                                  action:@selector(imageTapped:)];
            [singleTapGestureRecognizer setNumberOfTapsRequired:1];
            [imageView addGestureRecognizer:singleTapGestureRecognizer];
            [imageView setUserInteractionEnabled:YES];
            
            [_scrollView addSubview:imageView];
        }
        
        [_countLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)[[_dataSource arrayWithImages] count]]];
        _pageControl.numberOfPages = [(NSArray *)[_dataSource arrayWithImages] count];
    } else {
        UIImageView *blankImage = [[UIImageView alloc] initWithFrame:_scrollView.frame];
        [blankImage setImage:[_dataSource placeHolderImageForImagePager]];
        [_scrollView addSubview:blankImage];
    }
}

- (void) imageTapped:(UITapGestureRecognizer *)sender
{
    UIImageView *imageView = (UIImageView *)[sender view];
    UILabel *hintLabel = (UILabel *)[imageView viewWithTag:88];
    if (hintLabel) {
       if ([hintLabel.text isEqualToString:NSLocalizedString(@"tap_to_download", nil)]) {
           hintLabel.text = NSLocalizedString(@"image_downloading", nil);
           __weak UIView *weakSelf = self;
           NSString *imageUrl = [_dataSource arrayWithImages][imageView.tag];
           [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[[NSURL alloc] initWithString:imageUrl]
                                                                 options:nil progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
               if (image && finished) {
                   [[SDImageCache sharedImageCache] storeImage:image recalculateFromImage:NO imageData:data forKey:imageUrl toDisk:YES];
                   if (weakSelf) {
                       [hintLabel removeFromSuperview];
                       imageView.image = image;
                       [imageView setNeedsLayout];
                   }
               }
           }];
       }
    } else {
        if([_delegate respondsToSelector:@selector(imagePager:didSelectImageAtIndex:)]) {
            [_delegate imagePager:self didSelectImageAtIndex:imageView.tag];
        }
    }

}

- (void) setIndicatorDisabled:(BOOL)indicatorDisabled
{
    if(indicatorDisabled) {
        [_pageControl removeFromSuperview];
    } else {
        [self addSubview:_pageControl];
    }
    
    _indicatorDisabled = indicatorDisabled;
}

- (void)setImageCounterDisabled:(BOOL)imageCounterDisabled
{
    if (imageCounterDisabled) {
        [_imageCounterBackground removeFromSuperview];
    } else {
        [self addSubview:_imageCounterBackground];
    }
    
    _imageCounterDisabled = imageCounterDisabled;
}

#pragma mark - PageControl Initialization
- (void)initializePageControl
{
    CGRect pageControlFrame = CGRectMake(0, 0, _scrollView.frame.size.width, kPageControlHeight);
    _pageControl = [[UIPageControl alloc] initWithFrame:pageControlFrame];
    _pageControl.center = self.pageControlCenter;
    _pageControl.userInteractionEnabled = NO;
    [self addSubview:_pageControl];
}

#pragma mark - ScrollView Delegate;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if([_slideshowTimer isValid]) {
        [_slideshowTimer invalidate];
    }
    [self checkWetherToToggleSlideshowTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    long currentPage = lround((float)scrollView.contentOffset.x / scrollView.frame.size.width);
    _pageControl.currentPage = currentPage;
    
    [self updateCaptionLabelForImageAtIndex:currentPage];
    [self fireDidScrollToIndexDelegateForPage:currentPage];
}

#pragma mark - Delegate Helper
- (void) updateCaptionLabelForImageAtIndex:(NSUInteger)index
{
    if ([_dataSource respondsToSelector:@selector(captionForImageAtIndex:)]) {
        if ([[_dataSource captionForImageAtIndex:index] length] > 0) {
            [_captionLabel setHidden:NO];
            [_captionLabel setText:[NSString stringWithFormat:@" %@", [_dataSource captionForImageAtIndex:index]]];
            return;
        }
    }
    [_captionLabel setHidden:NO];
}

- (void) fireDidScrollToIndexDelegateForPage:(NSUInteger)page
{
    if([_delegate respondsToSelector:@selector(imagePager:didScrollToIndex:)]) {
        [_delegate imagePager:self didScrollToIndex:page];
    }
}

#pragma mark - Slideshow
- (void) slideshowTick:(NSTimer *)timer
{
    NSUInteger nextPage = 0;
    if([_pageControl currentPage] < ([[_dataSource arrayWithImages] count] - 1)) {
        nextPage = [_pageControl currentPage] + 1;
    }

    [_scrollView scrollRectToVisible:CGRectMake(self.frame.size.width * nextPage, 0, self.frame.size.width, self.frame.size.width) animated:YES];
    [_pageControl setCurrentPage:nextPage];
    
    [self updateCaptionLabelForImageAtIndex:nextPage];
    
    if (self.slideshowShouldCallScrollToDelegate) {
        [self fireDidScrollToIndexDelegateForPage:nextPage];
    }
}

- (void) checkWetherToToggleSlideshowTimer
{
    if (_slideshowTimeInterval > 0) {
        if ([(NSArray *)[_dataSource arrayWithImages] count] > 1) {
            _slideshowTimer = [NSTimer scheduledTimerWithTimeInterval:_slideshowTimeInterval target:self selector:@selector(slideshowTick:) userInfo:nil repeats:YES];
        }
    }
}

#pragma mark - Setter / Getter
- (void) setSlideshowTimeInterval:(NSUInteger)slideshowTimeInterval
{
    _slideshowTimeInterval = slideshowTimeInterval;
    
    if([_slideshowTimer isValid]) {
        [_slideshowTimer invalidate];
    }
    [self checkWetherToToggleSlideshowTimer];
}

- (NSUInteger) slideshowTimeInterval
{
    return _slideshowTimeInterval;
}

- (void) setCaptionBackgroundColor:(UIColor *)captionBackgroundColor
{
    [_captionLabel setBackgroundColor:captionBackgroundColor];
    _captionBackgroundColor = captionBackgroundColor;
}

- (void) setCaptionTextColor:(UIColor *)captionTextColor
{
    [_captionLabel setTextColor:captionTextColor];
    _captionTextColor = captionTextColor;
}

- (void) setCaptionFont:(UIFont *)captionFont
{
    [_captionLabel setFont:captionFont];
    _captionFont = captionFont;
}

- (void) setHidePageControlForSinglePages:(BOOL)hidePageControlForSinglePages
{
    _hidePageControlForSinglePages = hidePageControlForSinglePages;
    if (hidePageControlForSinglePages) {
        if ([(NSArray *)[_dataSource arrayWithImages] count] < 2) {
            [_pageControl setHidden:YES];
            return;
        }
    }
    [_pageControl setHidden:NO];
}

- (void) setPageControlCenter:(CGPoint)pageControlCenter
{
    _pageControlCenter = pageControlCenter;

    _pageControl.center = pageControlCenter;
}

- (NSUInteger) currentPage
{
    return [_pageControl currentPage];
}

- (void) setCurrentPage:(NSUInteger)currentPage
{
    [self setCurrentPage:currentPage animated:YES];
}

- (void) setCurrentPage:(NSUInteger)currentPage animated:(BOOL)animated
{
    NSAssert((currentPage < [(NSArray *)[_dataSource arrayWithImages] count]), @"currentPage must not exceed maximum number of images");
    
    [_pageControl setCurrentPage:currentPage];
    [_scrollView scrollRectToVisible:CGRectMake(self.frame.size.width * currentPage, 0, self.frame.size.width, self.frame.size.width) animated:animated];
}

- (void)clearData
{
    _scrollView.delegate = nil;
    if([_slideshowTimer isValid])
    {
        [_slideshowTimer invalidate];
    }
    for (UIView *view in _scrollView.subviews) {
        [view removeFromSuperview];
        if ([view isKindOfClass:UIImageView.class]) {
            [(UIImageView *)view setImage:nil];
        }
    }
}

- (void)dealloc
{
    _scrollView.delegate = nil;
}

@end
