//
//  EBListView.m
//  beaver
//
//  Created by 何 义 on 14-3-6.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBListView.h"
#import "EBStyle.h"
#import "EBViewFactory.h"
#import "EBFilterHeader.h"
#import "EBFilter.h"
#import "EGORefreshTableHeaderView.h"
#import "EBCompatibility.h"

@interface EBListView() <UITableViewDataSource, UITableViewDelegate, EBFilterHeaderDelegate, EGORefreshTableHeaderDelegate>
{
    EBFilterHeader *_filterHeader;
    UIButton *_footerButton;
    EGORefreshTableHeaderView *_refreshHeaderView;
}
@end

@implementation EBListView

- (void)startLoading
{
    [self initTableView];
    [self refreshList:NO];
    _loadInitialed = YES;
}

- (BOOL)addAndSelectItem:(id)item
{
    if ([_dataSource itemExist:item])
    {
        NSMutableArray *dataArray = _dataSource.dataArray;
        [dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            if ([[obj performSelector:@selector(id)] isEqualToString:[item performSelector:@selector(id)]])
            {
                [dataArray removeObject:obj];
                *stop = YES;
                [dataArray insertObject:obj atIndex:0];
                [_tableView reloadData];
            }
        }];

    }
    else
    {
        [_dataSource.dataArray insertObject:item atIndex:0];
        if (_dataSource.selectedSet)
        {
            [_dataSource.selectedSet addObject:item];
            [self updateFooterButton];
        }
        _isEmpty = NO;
        [_tableView reloadData];
    }

    return YES;
}

- (void)updateListState:(BOOL)emptyState
{
    _footerButton.superview.hidden = emptyState && [_tableView numberOfRowsInSection:0] == 1;
    if (_withoutLoadMore)
    {
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:_isEmpty ? CGRectZero : CGRectMake(0, 0, [EBStyle screenWidth], 40)];
    }
}

- (void)toggleSortView
{
    [_filterHeader toggleSortOrderView];
}

- (void)enableFooterButton:(NSString *)title target:(id)target action:(SEL)action
{
    _footBtStyle = 1;
    _footerButton = [EBViewFactory countButtonWithFrame:CGRectMake(20, 10, [EBStyle screenWidth]-40, 36) title:title target:target action:action];
    
    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 56, [EBStyle screenWidth], 56)];
    overlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    overlayView.userInteractionEnabled = YES;
    [self addSubview:overlayView];

    [overlayView addSubview:_footerButton];
    [self addSubview:overlayView];
    [self updateFooterButton];
}

- (void)enableFooterButtonForLog:(NSString *)title target:(id)target action:(SEL)action
{
    _footBtStyle = 2;
    CGRect buttonFrame = CGRectMake(20, 10, [EBStyle screenWidth] - 40, 52);
    
    _footerButton = [[UIButton alloc] initWithFrame:buttonFrame];
    [_footerButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIImage *bgN = [[UIImage imageNamed:@"btn_blue_normal"] stretchableImageWithLeftCapWidth:6 topCapHeight:6];
    UIImage *bgP = [[UIImage imageNamed:@"btn_blue_pressed"] stretchableImageWithLeftCapWidth:6 topCapHeight:6];
    UIImage *bgD = [[UIImage imageNamed:@"btn_disabled"] stretchableImageWithLeftCapWidth:6 topCapHeight:6];
    [_footerButton setBackgroundImage:bgN forState:UIControlStateNormal];
    [_footerButton setBackgroundImage:bgP forState:UIControlStateHighlighted];
    [_footerButton setBackgroundImage:bgD forState:UIControlStateDisabled];
    
    _footerButton.adjustsImageWhenHighlighted = NO;
    _footerButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_footerButton setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
    [_footerButton setTitleColor:[UIColor colorWithRed:69/255.f
                                                 green:114/255.f blue:169/255.f alpha:0.4] forState:UIControlStateDisabled];
    
    UILabel *counterLabel = [[UILabel alloc] init];
    counterLabel.textColor = [UIColor whiteColor];
    counterLabel.layer.cornerRadius = 9.0f;
    if ([EBCompatibility isIOS7Higher])
    {
        counterLabel.layer.backgroundColor = [EBStyle darkBlueTextColor].CGColor;
    }
    else
    {
        counterLabel.backgroundColor = [EBStyle darkBlueTextColor];
    }
    
    counterLabel.textAlignment = NSTextAlignmentCenter;
    counterLabel.font = [UIFont systemFontOfSize:12.0];
    counterLabel.tag = -1;
    counterLabel.text = @"0";
    [_footerButton addSubview:counterLabel];
    
    UIFont *font = [UIFont systemFontOfSize:14.0];
    CGSize titleSize = [EBViewFactory textSize:title font:font bounding:CGSizeMake(999, 999)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, titleSize.width, 18)];
    titleLabel.text = title;
    titleLabel.textColor = [EBStyle blueBorderColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.tag = -2;
    [_footerButton addSubview:titleLabel];
    
//    UIFont *fontComment = [UIFont systemFontOfSize:12.0];
//    CGSize commentSize = [EBViewFactory textSize:NSLocalizedString(@"send_reminder", nil) font:fontComment bounding:CGSizeMake(999, 999)];
    UILabel *labelComment = [[UILabel alloc] initWithFrame:CGRectMake(0, 27, _footerButton.width , 18)];
    labelComment.text = NSLocalizedString(@"send_reminder", nil);
    labelComment.textColor = [EBStyle blueBorderColor];
    labelComment.font = [UIFont systemFontOfSize:12];
    labelComment.textAlignment = NSTextAlignmentCenter;
    labelComment.tag = -3;
    [_footerButton addSubview:labelComment];
    
    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 72, [EBStyle screenWidth], 72)];
    overlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    overlayView.userInteractionEnabled = YES;
    [self addSubview:overlayView];
    
    [overlayView addSubview:_footerButton];
    [self addSubview:overlayView];
    [self updateFooterButton];
}

- (void)updateFooterButton
{
    NSInteger count = _dataSource.selectedSet.count;
    [EBViewFactory updateCountButton:_footerButton count:count];
    if(_footBtStyle != 1)
    {
        UILabel *commentLabel = (UILabel*) [_footerButton viewWithTag:-3];
        if(count == 0)
        {
            commentLabel.textColor = [_footerButton titleColorForState:UIControlStateDisabled];
        }
        else
        {
            commentLabel.textColor = [_footerButton titleColorForState:UIControlStateNormal];
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isEmpty || _isFailing)
    {
       return _tableView.frame.size.height;
    }
    if (!_withoutLoadMore && ![_dataSource hasMore] && [indexPath row] == [_dataSource numberOfRows])
    {
       return 44.0;
    }
    return [_dataSource heightOfRow:[indexPath row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] < [_dataSource numberOfRows])
    {
        [_dataSource tableView:tableView didSelectRow:[indexPath row]];
        if (tableView.editing)
        {
            [self updateFooterButton];
        }
        else
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] < [_dataSource numberOfRows])
    {
        [_dataSource tableView:tableView didDeselectRow:[indexPath row]];
        if (tableView.editing)
        {
            [self updateFooterButton];
        }
    }
}

//- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return NO;
//}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
   if ([indexPath row] == [_dataSource numberOfRows])
   {
       if ([_dataSource hasMore])
       {
           UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[cell viewWithTag:99];
           UILabel *label =  (UILabel *) [cell viewWithTag:100];
           [indicatorView startAnimating];

           _listStateListener(EEBListViewStateLoadingMore);
           [_dataSource loadMore:^(BOOL success, id result)
           {
               [indicatorView stopAnimating];
               if (success)
               {
                   label.hidden = YES;
                   [_tableView reloadData];
                   _listStateListener(EEBListViewStateLoadingSuccess);
               }
               else
               {
                   label.hidden = NO;
                   label.text = NSLocalizedString(@"loading_fail", nil);
                   _listStateListener(EEBListViewStateLoadingMoreError);
               }
           }];
       }
       else
       {
           [cell viewWithTag:100].hidden = NO;
       }
   }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //收藏的可以删除
    if ( _isCollected == YES) {
        return YES;
    }
    
    if (!_withoutLoadMore && [indexPath row] == [_dataSource numberOfRows])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isFailing || _isEmpty)
    {
        return 1;
    }
    NSInteger rawNum = [_dataSource numberOfRows];
    if (rawNum > 0)
    {
        return _withoutLoadMore ? rawNum : rawNum + 1;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (_isEmpty){
        static NSString *identifierEmpty = @"ebListViewEmptyCell";
        UITableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:identifierEmpty];
        if (emptyCell == nil)
        {
            emptyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierEmpty];
            emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if ([_dataSource respondsToSelector:@selector(emptyView:)])
            {
                UIView *emptyView = [_dataSource emptyView:self.bounds];
                if (emptyView)
                {
                    [emptyCell.contentView addSubview:[_dataSource emptyView:self.bounds]];
                }
                else
                {
                    [emptyCell.contentView addSubview:[self emptyView]];
                }
            }
            else
            {
              [emptyCell.contentView addSubview:[self emptyView]];
            }
        }
        return emptyCell;
    }

    if (_isFailing)
    {
        static NSString *identifierFailure = @"ebListViewFailureCell";
        UITableViewCell *failureCell = [tableView dequeueReusableCellWithIdentifier:identifierFailure];
        if (failureCell == nil)
        {
            failureCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierFailure];
            failureCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [failureCell.contentView addSubview:[self failureView]];
        }

        return failureCell;
    }

    if ([indexPath row] == [_dataSource numberOfRows])
    {
        return [EBViewFactory loadingMoreCellFor:_tableView cellHeight:[_dataSource heightOfRow:0] cellIdentifier:@"ebListLoadingCell"];
    }
    return [_dataSource tableView:tableView cellForRow:[indexPath row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_isFailing || _isEmpty)
    {
        return 0.0;
    }
    if ([_dataSource respondsToSelector:@selector(tableView:heightForHeaderInSection:)])
    {
        return [_dataSource tableView:tableView heightForHeaderInSection:section];
    }
    else
    {
        return 0.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_isFailing || _isEmpty)
    {
        return [[UIView alloc] init];
    }
    if ([_dataSource respondsToSelector:@selector(tableView:viewForHeaderInSection:)])
    {
        return [_dataSource tableView:tableView viewForHeaderInSection:section];
    }
    else
    {
        return [[UIView alloc] init];
    }
}


- (void)refreshList:(BOOL)force
{
    _listStateListener(EEBListViewStateReloading);
    if (!force)
    {
        [self showLoading];
    }
    [_dataSource refresh:force handler:^(BOOL success, id result)
    {
        [_tableView reloadData];
        if (_refreshHeaderView)
        {
            [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
        }
        
        if (success)
        {
            _isEmpty = [(NSArray *) result count] == 0;
            _isFailing = NO;

            _listStateListener(EEBListViewStateLoadingSuccess);
        }
        else
        {
            if (!force)
            {
                _isFailing = YES;
                _listStateListener(EEBListViewStateLoadingError);
            }
            else
            {
            }
        }
        [_tableView reloadData];
        [self updateListState:(_isFailing || _isEmpty)];
        [self hideLoadingView];
        if (_tableView.editing)
        {
            [self updateFooterButton];
        }
    }];
}

- (void)showReminder:(NSString *)hint
{
    UIView *hintView = [self viewWithTag:6785];
    if (!hintView)
    {
        hintView = [[UIView alloc] initWithFrame:[EBStyle viewPagerFrame]];
        hintView.tag = 6785;
        hintView.backgroundColor = [UIColor colorWithRed:1.0f green:169/255.0f blue:34/255.0f alpha:1.0];

        UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectOffset(hintView.frame, 10, 0)];
        hintLabel.backgroundColor = [UIColor clearColor];
        hintLabel.textColor = [UIColor whiteColor];
        hintLabel.font = [UIFont systemFontOfSize:12.0];
        hintLabel.tag = 88;
        [hintView addSubview:hintLabel];

        UIImageView *closeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert_error"]];
        closeIcon.userInteractionEnabled = YES;
        closeIcon.frame = CGRectMake(285, (hintView.frame.size.height - 23) / 2, 23, 23);
        [hintView addSubview:closeIcon];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeHint)];
        [closeIcon addGestureRecognizer:tapGestureRecognizer];

        hintView.frame = CGRectOffset(hintView.frame, 0, -hintView.frame.size.height);
        [self addSubview:hintView];
        [self bringSubviewToFront:hintView];
    }

    UILabel *hLabel = (UILabel *)[hintView viewWithTag:88];
    hLabel.text = hint;
    CGFloat yOffset = hintView.frame.size.height;
    [UIView animateWithDuration:0.2f animations:^
    {
        if (!_filterHeader.hidden)
        {
            _filterHeader.frame = CGRectMake(0, yOffset, _filterHeader.frame.size.width, _filterHeader.frame.size.height);
        }

        _tableView.frame = CGRectMake(0, yOffset + (!_filterHeader.hidden ? _filterHeader.frame.size.height : 0),
                self.bounds.size.width, self.bounds.size.height - yOffset);
        hintView.frame = [EBStyle viewPagerFrame];
    }];
}

- (void)closeHint
{
    UIView *hintView = [self viewWithTag:6785];
    [UIView animateWithDuration:0.2f animations:^
    {
        if (!_filterHeader.hidden)
        {
            _filterHeader.frame = CGRectMake(0, 0, _filterHeader.frame.size.width, _filterHeader.frame.size.height);
        }
        CGFloat dHeight =  !_filterHeader.hidden ? _filterHeader.frame.size.height : 0;
        _tableView.frame = CGRectMake(0, dHeight, self.bounds.size.width, self.bounds.size.height - dHeight);
        hintView.frame = CGRectOffset([EBStyle viewPagerFrame], 0 , -hintView.frame.size.height);
    }];
}

- (void)initTableView
{
    if (_tableView != nil)
    {
        return;
    }

    if (!_listStateListener)
    {
        self.listStateListener = ^(EEBListViewState state){};
    }

    CGFloat yOffset = 0.0;

    _filterHeader = [[EBFilterHeader alloc] initWithFrame:[EBStyle viewPagerFrame]];
    _filterHeader.delegate = self;
    [self addSubview:_filterHeader];
    _filterHeader.hidden = YES;

    if (_withFilter)
    {
       _filterHeader.filter = _dataSource.filter;
       _filterHeader.hidden = NO;
       yOffset = _filterHeader.frame.size.height;
    }
    else if (_isSearch)
    {
        _filterHeader.filter = _dataSource.filter;
        _filterHeader.hidden = YES;
    }

//    CGFloat bottomHeight = _footerButton == nil ? 0 : self.bounds.size.height - _footerButton.frame.origin.y;
    // Initialization code
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, yOffset, self.bounds.size.width,
            self.bounds.size.height - yOffset)];
    _tableView.backgroundView.alpha = 0;
//    if (_hideSeparator)
//    {
       _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    }
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self addSubview:_tableView];

    if (_isSelecting)
    {
        _tableView.allowsMultipleSelectionDuringEditing = YES;
        _tableView.allowsSelectionDuringEditing = YES;
        [_tableView setEditing:YES animated:NO];
//        _tableView.separatorInset = UIEdgeInsetsMake(0, 52, 0, 0);
    }

//    UIRefreshControl *refreshControl = [EBViewFactory refreshControlForTableView:_tableView];
////    [refreshControl setTintColor:[UIColor blackColor]];
//    [_tableView addSubview:refreshControl];
//    [refreshControl addTarget:self action:@selector(refreshList:) forControlEvents:UIControlEventValueChanged];
    if (!_withoutRefreshHeader)
    {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _tableView.frame.size.height,
                _tableView.frame.size.width, _tableView.frame.size.height)];
        _refreshHeaderView.delegate = self;
        [_tableView addSubview:_refreshHeaderView];
    }

    if (_footerButton)
    {
        [self bringSubviewToFront:[_footerButton superview]];
    }

    if (_withoutLoadMore)
    {
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 40)];
    }

    _listStateListener(EEBListViewStateInit);
}

#define EBLIST_TRANSITION_LOADING_TAG 999
#define EBLIST_TRANSITION_EMPTY_TAG 1000
#define EBLIST_TRANSITION_FAIL_TAG 1001
#define EBLIST_TRANSITION_INDICATOR_TAG 1002

#pragma -mark transition view

- (void)showLoading
{
    UIView *loadingView = [self viewWithTag:EBLIST_TRANSITION_LOADING_TAG];
    UIActivityIndicatorView *activityIndicatorView;
    if (loadingView == nil)
    {
        loadingView = [[UIView alloc] initWithFrame:self.bounds];
        loadingView.backgroundColor = [UIColor whiteColor];
        loadingView.tag = EBLIST_TRANSITION_LOADING_TAG;
        [self addSubview:loadingView];

        CGFloat activitySize = [EBStyle activityIndicatorSize];
        CGFloat activityOffsetY = [EBStyle loadingOffsetYInListView];
        activityIndicatorView = [[UIActivityIndicatorView alloc]
                initWithFrame:CGRectMake((self.bounds.size.width - activitySize) / 2,
                        activityOffsetY - _tableView.frame.origin.y, activitySize, activitySize)];
        activityIndicatorView.tag = EBLIST_TRANSITION_INDICATOR_TAG;
        activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [loadingView addSubview:activityIndicatorView];
        [loadingView addSubview:[self centerLabelWithFrame:CGRectMake(0, activityOffsetY + activitySize,
                self.bounds.size.width, 18.f) title:NSLocalizedString(@"loading", nil)]];
    }

    activityIndicatorView = (UIActivityIndicatorView *)[loadingView viewWithTag:EBLIST_TRANSITION_INDICATOR_TAG];
    [activityIndicatorView startAnimating];

    [loadingView setHidden:NO];
    [self bringSubviewToFront:loadingView];
}

- (UIView *)emptyView
{
    return [self viewWithImage:[UIImage imageNamed:@"loading_empty"] title:_emptyText
                    offsetY:[EBStyle emptyOffsetYInListView] tag:EBLIST_TRANSITION_EMPTY_TAG];
}

- (UIView *)failureView
{
    return [self viewWithImage:[UIImage imageNamed:@"loading_fail"] title:NSLocalizedString(@"loading_fail", nil)
                    offsetY:[EBStyle failOffsetYInListView] tag:EBLIST_TRANSITION_FAIL_TAG];
}

- (UIView *)viewWithImage:(UIImage *)image title:(NSString *)title offsetY:(CGFloat)offset tag:(NSInteger)tag
{
    UIView *transitionView = [[UIView alloc] initWithFrame:self.bounds];
    transitionView.backgroundColor = [UIColor whiteColor];
    transitionView.tag = tag;

    [self view:transitionView addCenterImageWithFrame:CGRectMake(0, offset, self.bounds.size.width, image.size.height)
         image:image title:title];

    return transitionView;
}

- (void)hideLoadingView
{
    // hide loading
    UIView *loadingView = [self viewWithTag:EBLIST_TRANSITION_LOADING_TAG];
    if (loadingView != nil)
    {
        UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[loadingView viewWithTag:EBLIST_TRANSITION_INDICATOR_TAG];
        [indicatorView stopAnimating];
    }
    [loadingView setHidden:YES];
//
//    [[self viewWithTag:EBLIST_TRANSITION_EMPTY_TAG] setHidden:YES];
//    [[self viewWithTag:EBLIST_TRANSITION_FAIL_TAG] setHidden:YES];
}

- (UILabel *)centerLabelWithFrame:(CGRect)frame title:(NSString *)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[EBStyle grayTextColor]];
    [label setText:title];
    label.numberOfLines = 3 ;
    [label setFont:[UIFont systemFontOfSize:14.f]];

    return label;
}

- (void)view:(UIView*)view addCenterImageWithFrame:(CGRect)frame image:(UIImage *)image title:(NSString *)title
{
//    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
//    [btn setImage:image forState:UIControlStateNormal];
//    [btn setImage:[image imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
//    btn.adjustsImageWhenHighlighted = NO;
//    [btn addTarget:self action:@selector(startLoading) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.image = image;
    [view addSubview:imageView];

    frame = CGRectOffset(frame, 0, frame.size.height + 5.0);
    [view addSubview:[self centerLabelWithFrame:frame title:title]];
}

#pragma -mark EBFilterHeaderDelegate

- (void)filterChoiceChanged:(NSInteger)filterIndex
{
     [self refreshList:NO];
}

- (void)popupViewWillShow
{
    UIView *hintView = [self viewWithTag:6785];
    if (hintView && !hintView.hidden)
    {
        [self bringSubviewToFront:hintView];
    }
}

#pragma -mark refreshHeader

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_refreshHeaderView)
    {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_refreshHeaderView)
    {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self refreshList:YES];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return NO; // should return if data source model is reloading
}

- (BOOL)dismissPopUpView
{
    return [_filterHeader dismissPopUpView];
}

@end
