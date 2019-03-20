//
//  SingleChoiceViewController.m
//  beaver
//
//  Created by 何 义 on 14-3-2.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBViewFactory.h"
#import "EBStyle.h"
#import "EBSearch.h"
#import "EBFilter.h"
#import "EBRadioGroup.h"
#import "RTLabel.h"
#import "EBController.h"
#import "EBCompatibility.h"
#import "HouseListViewController.h"
#import "EBSearchViewController.h"

#define ANIMATION_DURATION 0.2


@interface EBSearch() <UISearchDisplayDelegate, UISearchBarDelegate>
{
   UISearchBar *_searchBar;
   EBSearchType _searchType;
   TKeywordChange _changeBlock;
   TKeywordChange _searchBlock;
}
@end

@implementation EBSearch

- (void)setupSearchBarForController:(UIViewController *)controller
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 44)];
    _searchBar.layer.opacity = 0;
//    _searchBar.tintColor = [UIColor colorWithRed:0xde/255.0f green:0xe0/255.0f blue:0xe3/255.0f alpha:1.0];
    _searchBar.translucent = NO;
    _searchBar.delegate = self;
    [controller.view addSubview:_searchBar];

//    _searchBar.showsScopeBar;

    [EBCompatibility configAppearanceForSearchBar:_searchBar];

    _displayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:controller];
    _displayController.delegate = self;
    _displayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _displayController.searchResultsTitle = @"empty";
}

- (void)searchHouse
{
//    _searchBar.placeholder = @"请输入...";
    [self showSearch:EBSearchTypeHouse];
}

- (void)searchHouseWithSelection:(void(^)(NSArray *))selectionBlock
{
    [self showSearch:EBSearchTypeHouse withSelection:selectionBlock];
}

- (void)searchClient
{
    [self showSearch:EBSearchTypeClient];
}

- (void)searchClientWithSelection:(void(^)(NSArray *))selectionBlock
{
    [self showSearch:EBSearchTypeClient withSelection:selectionBlock];
}

- (void)searchContacts:(id<UITableViewDataSource>)dataSource delegate:(id<UITableViewDelegate>)delegate keywordChange:(TKeywordChange)change;
{
    _displayController.searchResultsDelegate = delegate;
    _displayController.searchResultsDataSource = dataSource;
    _changeBlock = change;
    [self showSearch:EBSearchTypeContacts];
}

- (void)searchLocations:(id<UITableViewDataSource>)dataSource delegate:(id<UITableViewDelegate>)delegate
          keywordChange:(TKeywordChange)inputBlock
            searchClick:(TKeywordChange)searchBlock
{
    _displayController.searchResultsDelegate = delegate;
    _displayController.searchResultsDataSource = dataSource;
    _changeBlock = inputBlock;
    _searchBlock = searchBlock;
    [self showSearch:EBSearchTypeLocation];
}

- (void)showSearch:(EBSearchType)searchType
{
    [self showSearch:searchType withSelection:nil];
}

- (void)showSearch:(EBSearchType)searchType withSelection:(void(^)(NSArray *))selectionBlock
{
    _searchType = searchType;

    NSString *plType = [NSString stringWithFormat:@"pl_search_%ld", searchType];

    if (searchType < EBSearchTypeContacts)
    {
        EBSearchViewController *searchViewController = [[EBSearchViewController alloc] init];
        searchViewController.searchType = searchType;
        searchViewController.handleSelections = selectionBlock;
        searchViewController.hidesBottomBarWhenPushed = YES;

        [[EBController sharedInstance].currentNavigationController
                pushViewController:searchViewController animated:NO];
    }
    else
    {
//        _searchBar.placeholder = NSLocalizedString(plType, nil);
        [_searchBar becomeFirstResponder];

        [UIView animateWithDuration:ANIMATION_DURATION animations:^
        {
            _searchBar.layer.opacity = 1.0;
        } completion:^(BOOL completion){
//        [UIApplication sharedApplication].statusBar = UIStatusBarStyleBlackTranslucent;
        }];
        if (_hidesTabBarWhenSearch)
        {
            [[EBController sharedInstance] hideTabBar];
        }

        _displayController.searchResultsTableView.contentOffset = CGPointMake(0, 0);

        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
}

#pragma mark - UISearchDisplayDelegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (_searchType > EBSearchTypeClient && _changeBlock)
    {
        _changeBlock(searchString);
    }

   return YES;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    BOOL isIos7 = floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1;
    _searchBar.showsCancelButton = YES;
    UIView *viewTop = isIos7 ? _searchBar.subviews[0] : _searchBar;
    NSString *classString = isIos7 ? @"UINavigationButton" : @"UIButton";

    for (UIView *subView in viewTop.subviews)
    {
        if ([subView isKindOfClass:NSClassFromString(classString)])
        {
            UIButton *cancelButton = (UIButton*)subView;
            [cancelButton setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
        }
    }
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [UIView animateWithDuration:ANIMATION_DURATION animations:^
    {
       _searchBar.layer.opacity = 0.0;
    } completion:^(BOOL completion){
//       [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }];
    if (_hidesTabBarWhenSearch)
    {
        [[EBController sharedInstance] showTabBar];
    }

    if (_changeBlock)
    {
        _changeBlock(nil);
    }

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{

}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (_searchBlock)
    {
        _searchBlock(_displayController.searchBar.text);
    }
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void) keyboardWillHide {
    UITableView *tableView = self.displayController.searchResultsTableView;
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    
    if ([EBCompatibility isIOS7Higher]) {
        [tableView setContentInset:UIEdgeInsetsMake(0, 0, 215, 0)];
    }
}


@end
