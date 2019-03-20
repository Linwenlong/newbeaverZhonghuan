//
//  AGIPCGridCell.m
//  AGImagePickerController
//
//  Created by Artur Grigor on 17.02.2012.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import "AGIPCGridCell.h"
#import "AGIPCGridItem.h"

#import "AGImagePickerController.h"
#import "AGImagePickerController+Helper.h"

@interface AGIPCGridCell ()
{
	NSArray *_items;
    __weak AGImagePickerController *_imagePickerController;
}

@end

@implementation AGIPCGridCell

#pragma mark - Properties

@synthesize items = _items, imagePickerController = _imagePickerController;

- (void)setItems:(NSArray *)items
{
    @synchronized (self)
    {
        if (_items != items)
        {
            _items = items;
            
            for (UIView *view in [self.contentView subviews])
            {
                if ([view isKindOfClass:AGIPCGridItem.class]) {
                    [view removeFromSuperview];
                }
            }
            
            for (ALAsset *asset in _items) {
                AGIPCGridItem *gridItem = [[AGIPCGridItem alloc] initWithImagePickerController:_imagePickerController asset:asset andDelegate:self];
                [self.contentView addSubview:gridItem];
            }
        }
    }
}

- (NSArray *)items
{
    NSArray *array = nil;
    
    @synchronized (self)
    {
        array = _items;
    }
    
    return array;
}

#pragma mark - Object Lifecycle

- (id)initWithImagePickerController:(AGImagePickerController *)imagePickerController assetsController:(AGIPCAssetsController *)assetsController items:(NSArray *)items andReuseIdentifier:(NSString *)identifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self)
    {
        self.imagePickerController = imagePickerController;
        self.assetsController = assetsController;
		self.items = items;
        
        UIView *emptyView = [[UIView alloc] init];
        self.backgroundView = emptyView;
	}
	
	return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    CGRect frame = self.imagePickerController.itemRect;
    CGFloat leftMargin = frame.origin.x;
    
    for (UIView *view in self.contentView.subviews) {
        if ([view isKindOfClass:AGIPCGridItem.class]) {
            AGIPCGridItem *gridItem = (AGIPCGridItem *)view;
            [gridItem loadImageFromAsset];
            
            [gridItem setFrame:frame];
            UITapGestureRecognizer *selectionGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:gridItem action:@selector(tap)];
            selectionGestureRecognizer.numberOfTapsRequired = 1;
            [gridItem addGestureRecognizer:selectionGestureRecognizer];
            
            frame.origin.x = frame.origin.x + frame.size.width + leftMargin;
            
            for (ALAsset *item in _assetsController.selectedAssets) {
                if (item == gridItem.asset) {
                    gridItem.selected = YES;
                    break;
                }
            }
        }
    }
}

#pragma mark - AGGridItemDelegate Methods

- (void)agGridItem:(AGIPCGridItem *)gridItem didChangeNumberOfSelections:(NSNumber *)numberOfSelections
{
    _assetsController.navigationItem.rightBarButtonItem.enabled = (numberOfSelections.unsignedIntegerValue > 0);
    NSInteger select = [_assetsController selectedAssets].count;
    NSString *format = NSLocalizedString(@"photo_select_leave_num", nil);
    _assetsController.labelLeaveNum.text = [NSString stringWithFormat:format, _imagePickerController.maximumNumberOfPhotosToBeSelected - select];
    //    [self changeSelectionInformation];
}

- (BOOL)agGridItemCanSelect:(AGIPCGridItem *)gridItem
{
    if (self.imagePickerController.selectionMode == AGImagePickerControllerSelectionModeSingle && self.imagePickerController.selectionBehaviorInSingleSelectionMode == AGImagePickerControllerSelectionBehaviorTypeRadio) {
        for (UIView *view in self.contentView.subviews) {
            if ([view isKindOfClass:AGIPCGridItem.class]) {
                AGIPCGridItem *gridItem = (AGIPCGridItem *)view;
                if (gridItem.selected)
                    gridItem.selected = NO;
            }
        }
        return YES;
    } else {
        if (self.imagePickerController.maximumNumberOfPhotosToBeSelected > 0)
            return ([_assetsController selectedAssets].count < self.imagePickerController.maximumNumberOfPhotosToBeSelected);
        else
            return YES;
    }
}

- (void)agGridItem:(AGIPCGridItem *)gridItem didChangeSelectionState:(NSNumber *)selected
{
    if ([selected boolValue]) {
        BOOL addFlag = YES;
        for (ALAsset *asset in _assetsController.selectedAssets) {
            if (asset == gridItem.asset) {
                addFlag = NO;
                break;
            }
        }
        if (addFlag) {
            [_assetsController.selectedAssets addObject:gridItem.asset];
        }
    } else {
        [_assetsController.selectedAssets removeObject:gridItem.asset];
    }
}

- (void)dealloc
{
    for (UIView *view in [self.contentView subviews])
    {
        [view removeFromSuperview];
    }
    
    _items = nil;
}

@end
