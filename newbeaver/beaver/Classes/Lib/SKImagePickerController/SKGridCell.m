//
//  SKGridCell.m
//  chow
//
//  Created by wangyuliang on 14-12-1.
//  Copyright (c) 2014年 eallcn. All rights reserved.
//

#import "SKGridCell.h"
#import "SKAsset.h"
#import "SKGridItem.h"
#import "SKImageController.h"

@interface SKGridCell ()
{
    NSMutableArray *_items;
}

@end

@implementation SKGridCell

@synthesize items = _items;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setItems:(NSMutableArray *)items
{
    @synchronized (self)
    {
        if (_items != items) {
            _items = items;
            
            for (UIView *view in [self.contentView subviews]) {
                [view removeFromSuperview];
            }
            
            CGRect frame = CGRectMake(SK_ITEM_GAP, SK_ITEM_GAP, SK_ITEM_WIDTH, SK_ITEM_WIDTH);
            
            _viewArrays = [[NSMutableArray alloc] init];
            for (SKAsset *skAsset in _items) {
                SKGridItem *gridItem = [[SKGridItem alloc] initWithSkAsset:skAsset frame:frame];
                gridItem.delegate = self.assetViewCtrl;
                [_viewArrays addObject:gridItem];
                [self addSubview:gridItem];
            }
        }
    }
}

#pragma mark - init
- (id)initWithViewCtrl:(SKAssetsViewController *)assetViewCtrl items:(NSMutableArray *)items identifier:(NSString *)identifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self) {
        self.assetViewCtrl = assetViewCtrl;
        self.items = items;
        
        UIView *emptyView = [[UIView alloc] init];
        self.backgroundView = emptyView;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = CGRectMake(SK_ITEM_GAP, SK_ITEM_GAP, SK_ITEM_WIDTH, SK_ITEM_WIDTH);
    CGFloat leftMargin = SK_ITEM_GAP;
    
    for (SKGridItem *gridItem in _viewArrays) {
        [gridItem loadImageFromAsset];
        [gridItem setFrame:frame];
        UITapGestureRecognizer *selectionGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:gridItem action:@selector(tap)];
        selectionGestureRecognizer.numberOfTapsRequired = 1;
        [gridItem addGestureRecognizer:selectionGestureRecognizer];
        
        frame.origin.x = frame.origin.x + frame.size.width + leftMargin;
    }
}


@end
