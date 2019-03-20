//
//  EBListView.h
//  beaver
//
//  Created by 何 义 on 14-3-6.
//  Copyright (c) 2014年 eall. All rights reserved.
//
#import "EBController.h"

@protocol EBListDataSource;
@class EBFilter;

typedef NS_ENUM(NSInteger , EEBListViewState)
{
    EEBListViewStateInit = 0,
    EEBListViewStateReloading = 1,
    EEBListViewStateLoadingMore = 2,
    EEBListViewStateLoadingSuccess = 3,
    EEBListViewStateLoadingError = 4,
    EEBListViewStateLoadingMoreError = 5
};

typedef NS_ENUM(NSInteger, FootButtonStyle)
{
    FootButtonStyleNormal = 1,
    FootButtonStyleCustom = 2
};

@interface EBListView : UIView

@property (nonatomic, assign) BOOL isCollected;

@property (nonatomic, copy) NSString *emptyText;
@property (nonatomic, assign) BOOL withFilter;
@property (nonatomic, assign) BOOL withoutLoadMore;
@property (nonatomic, readonly) BOOL loadInitialed;
@property (nonatomic) BOOL withoutRefreshHeader;
@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, assign) BOOL hideSeparator;
@property (nonatomic, strong) id<EBListDataSource> dataSource;
@property (nonatomic, assign) BOOL isSelecting;
@property (nonatomic, readonly) BOOL isEmpty;
@property (nonatomic, readonly) BOOL isFailing;
@property (nonatomic, readonly) FootButtonStyle footBtStyle;
@property (nonatomic, assign) BOOL isSearch;

@property (nonatomic, copy) void(^listStateListener)(EEBListViewState state);

//- (void)showLoading;
//- (void)showEmptyView;
//- (void)showFailureView;

- (void)startLoading;
- (void)refreshList:(BOOL)force;
- (void)toggleSortView;
- (BOOL)dismissPopUpView;
- (void)showReminder:(NSString *)hint;
- (void)enableFooterButton:(NSString *)title target:(id)target action:(SEL)action;
- (void)enableFooterButtonForLog:(NSString *)title target:(id)target action:(SEL)action;//adde by wyl 05-29
- (BOOL)addAndSelectItem:(id)item;

@end

@protocol EBListDataSource<NSObject>

@property(nonatomic, strong) EBFilter *filter;
@property (nonatomic, readonly) NSMutableSet *selectedSet;
@property (nonatomic, readonly) NSMutableArray *dataArray;

- (CGFloat)heightOfRow:(NSInteger)row;
- (NSInteger)numberOfRows;
- (BOOL)itemExist:(id)item;
- (void)tableView:(UITableView *)tableView didSelectRow:(NSInteger)row;
- (void)tableView:(UITableView *)tableView didDeselectRow:(NSInteger)row;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRow:(NSInteger)row;
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (void)refresh:(BOOL)force handler:(void (^)(BOOL success, id result))done;
- (void)loadMore:(void (^)(BOOL success, id result))done;
- (BOOL)hasMore;
- (UIView *)emptyView:(CGRect)frame;
- (void)clearData;

@end
