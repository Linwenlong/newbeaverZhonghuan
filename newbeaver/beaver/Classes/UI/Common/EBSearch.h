//
//  SingleChoiceViewController.h
//  beaver
//
//  Created by 何 义 on 14-3-2.
//  Copyright (c) 2014年 eall. All rights reserved.
//

typedef NS_ENUM(NSInteger , EBSearchType)
{
    EBSearchTypeHouse = 0,
    EBSearchTypeClient = 1,
    EBSearchTypeContacts = 2,
    EBSearchTypeMessage = 3,
    EBSearchTypeLocation = 4,
};

typedef void (^TKeywordChange)(NSString *);

@interface EBSearch : NSObject

@property (nonatomic, readonly) UISearchDisplayController *displayController;
@property (nonatomic, assign) BOOL hidesTabBarWhenSearch;

- (void)setupSearchBarForController:(UIViewController *)controller;
- (void)searchHouse;
- (void)searchHouseWithSelection:(void(^)(NSArray *))selectionBlock;
- (void)searchClient;
- (void)searchClientWithSelection:(void(^)(NSArray *))selectionBlock;
- (void)searchContacts:(id<UITableViewDataSource>)dataSource delegate:(id<UITableViewDelegate>)delegate keywordChange:(TKeywordChange)change;
- (void)searchLocations:(id<UITableViewDataSource>)dataSource delegate:(id<UITableViewDelegate>)delegate keywordChange:(TKeywordChange)changeBlock searchClick:(TKeywordChange)searchBlock;

@end
