//
//  SKGridItem.m
//  chow
//
//  Created by wangyuliang on 14-12-1.
//  Copyright (c) 2014年 eallcn. All rights reserved.
//

#import "SKGridItem.h"
#import "SKImageController.h"

@interface SKGridItem ()
{
    BOOL _selected;
    CGRect _itemFrame;
    
    UIImageView *_thumbnailImageView;
    UIView *_selectionView;
    UIImageView *_checkmarkImageView;
}

@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UIView *selectionView;
@property (nonatomic, strong) UIImageView *checkmarkImageView;

@end

@implementation SKGridItem

@synthesize skAsset = _skAsset, thumbnailImageView = _thumbnailImageView, selectionView = _selectionView, checkmarkImageView = _checkmarkImageView;

- (void)setSkAsset:(SKAsset *)skAsset
{
    @synchronized (self)
    {
        if (_skAsset != skAsset) {
            _skAsset = skAsset;
        }
    }
}

- (SKAsset *)skAsset
{
    SKAsset *ret = nil;
    @synchronized (self) { ret = _skAsset; }
    return ret;
}

#pragma mark - action
- (void)tap
{
    @synchronized (self)
    {
        _selected = _skAsset.select;
        BOOL selected = !_selected;
        if (selected) {
            if ([self.delegate respondsToSelector:@selector(skGridItemCanSelect:)])
            {
                if (![self.delegate skGridItemCanSelect:self])
                {
                    NSString *title = nil;
                    if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)) {
                        if (title == nil) {
                            title = @"";
                        }
                    }
                    
                    NSString *imgCount = [EBPreferences sharedInstance].image_num_limit;
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:[NSString stringWithFormat:NSLocalizedString(@"photo_add_warn", nil), [imgCount integerValue]] delegate:self cancelButtonTitle:NSLocalizedString(@"photo_add_confirm", nil) otherButtonTitles:nil];
                    
//                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"photo_add_warn",[imgCount integerValue] nil) delegate:self cancelButtonTitle:NSLocalizedString(@"photo_add_confirm", nil) otherButtonTitles:nil];
                    [alertView show];
                    return;
                }
            }
        }
        
        _selected = selected;
        _skAsset.select = selected;
        self.selectionView.hidden = !_selected;
        self.checkmarkImageView.hidden = !_selected;
        
        __weak SKGridItem *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(skGridItem:didChangeSelectionState:)])
            {
                [weakSelf.delegate performSelector:@selector(skGridItem:didChangeSelectionState:) withObject:weakSelf withObject:@(_selected)];
            }
        });
    }
}


#pragma mark - init
- (id)initWithSkAsset:(SKAsset *)skAsset frame:(CGRect)frame
{
    self = [super init];
    _itemFrame = frame;
    self.skAsset = skAsset;
    if (self) {
        _selected = skAsset.select;
        
        self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:self.thumbnailImageView];
        
        self.selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.selectionView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.selectionView];
        
        CGSize checkSize = [UIImage imageNamed:@"image_select_icon"].size;
        CGFloat scale = 0.9;
        self.checkmarkImageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - checkSize.width) * scale, (frame.size.height - checkSize.height) * scale, checkSize.width, checkSize.height)];
        [self addSubview:self.checkmarkImageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.thumbnailImageView.contentMode = UIViewContentModeScaleToFill;
    
    self.selectionView.alpha = .5f;
    self.selectionView.hidden = !_selected;
    
    self.checkmarkImageView.image = [UIImage imageNamed:@"image_select_icon"];
    self.checkmarkImageView.hidden = !_selected;
}

- (void)loadImageFromAsset
{
    self.thumbnailImageView.image = [UIImage imageWithCGImage:_skAsset.asset.thumbnail];
}

- (void)showCheck
{
    self.selectionView.hidden = NO;
    self.checkmarkImageView.hidden = NO;
}


@end
