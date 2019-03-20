//
//  ContactsViewController.m
//  beaver
//
//  Created by 何 义 on 14-2-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ContactsViewController.h"
#import "EBViewFactory.h"
#import "RTLabel.h"
#import "UIImageView+AFNetworking.h"
#import "GroupsViewController.h"
#import "EBSearch.h"
#import "EBContact.h"
#import "ProfileViewController.h"
#import "EBContactManager.h"
#import "EBPreferences.h"
#import "EBIMGroup.h"
#import "EBController.h"
#import "YBPopupMenu.h"

@interface ContactsViewController () <UITableViewDataSource, UITableViewDelegate,YBPopupMenuDelegate>
{
    NSArray *_sectionIndexTitles;
    NSMutableDictionary *_contactsMap;
    NSMutableSet *_selectedSet;
    UIButton *_sendButton;
    UITableView *_tableView;
}

@property (nonatomic, strong)YBPopupMenu *popupMenu;

@end

@implementation ContactsViewController

#define HEIGHT_BTN_AREA 56.0

- (void)loadView
{
    [super loadView];

    [self buildContactsMap:nil];

    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_search"] target:self action:@selector(searchContact:)];

    CGRect tableFrame = [EBStyle fullScrTableFrame:NO];

    if (self.contactsSelected)
    {
        tableFrame.size.height -= HEIGHT_BTN_AREA;

        _sendButton = [EBViewFactory countButtonWithFrame:CGRectMake(20, tableFrame.origin.y + tableFrame.size.height + 10,
                [UIScreen mainScreen].bounds.size.width - 40, 36) title:self.selectTitleButton target:self action:@selector(didSelectContacts:)];

        [self.view addSubview:_sendButton];
    }

    _tableView = [[UITableView alloc] initWithFrame:tableFrame];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];

    [self updateTableViewStyle:_tableView];

    _searchHelper = [[EBSearch alloc] init];
    [_searchHelper setupSearchBarForController:self];
    _searchHelper.displayController.searchResultsDelegate = self;
    _searchHelper.displayController.searchResultsDataSource = self;

    if (self.contactsSelected)
    {
        _tableView.allowsMultipleSelectionDuringEditing = YES;
        [_tableView setEditing:YES animated:YES];
        _selectedSet = [[NSMutableSet alloc] init];
        [self updateSendButtonState];
    }
}

- (void)dealloc
{
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}

- (NSInteger)sectionIdxForContact:(NSInteger)section
{
    NSInteger dx;
    if (_searchHelper.displayController.isActive)
    {
        dx = 0;
    }
    else
    {
        dx = self.contactsSelected ? (self.groupSelected ? 1 : 0) : 1;
    }


    return section - dx;
}

- (EBContact *)contactAtIndexPath:(NSIndexPath *)indexPath
{
   if (!_searchHelper.displayController.isActive && !self.contactsSelected && [indexPath section] == 0)
   {
       return [[EBContactManager sharedInstance] contactById:[indexPath row] == 1 ? [EBPreferences systemIMIDEALL] : [EBPreferences systemIMIDCompany]];
   }
   else
   {
       NSInteger sectionIndex = [self sectionIdxForContact:[indexPath section]];
       return _contactsMap[_sectionIndexTitles[sectionIndex]][[indexPath row]];
   }
}

//座机
- (void)buildPhoneContactsMap:(NSString *)keyword{
    NSArray *contacts;
    if (keyword)
    {
        contacts = [[EBContactManager sharedInstance] contactsPhoneByKeyword:keyword];
    }
    else
    {
        contacts = [[EBContactManager sharedInstance] allContacts];
    }
    
    contacts = [contacts sortedArrayUsingComparator:^(EBContact *contact1, EBContact *contact2){
        return  [contact1.pinyin compare:contact2.pinyin];
    }];
    
    _contactsMap = [[NSMutableDictionary alloc] init];
    for (EBContact *contact in contacts)
    {
        if (contact.special ||
            (self.contactsSelected && [self.filterContacts containsObject:contact]))
        {
            continue;
        }
        NSString *firstLetter = [[contact.pinyin substringToIndex:1] uppercaseString];
        NSMutableArray *subContacts = _contactsMap[firstLetter];
        if (subContacts == nil)
        {
            subContacts = [[NSMutableArray alloc] init];
            _contactsMap[firstLetter] = subContacts;
        }
        
        [subContacts addObject:contact];
    }
    _sectionIndexTitles = [[_contactsMap allKeys] sortedArrayUsingComparator:^(NSString *str1, NSString *str2){
        return [str1 compare:str2];
    }];
    
    if (!keyword && _tableView)
    {
        [_tableView reloadData];
    }
}

//门店
- (void)buildLwLContactsMap:(NSString *)keyword{
    NSArray *contacts;
    if (keyword)
    {
        contacts = [[EBContactManager sharedInstance] contactsLWLByKeyword:keyword];
    }
    else
    {
        contacts = [[EBContactManager sharedInstance] allContacts];
    }
    
    contacts = [contacts sortedArrayUsingComparator:^(EBContact *contact1, EBContact *contact2){
        return  [contact1.pinyin compare:contact2.pinyin];
    }];
    
    _contactsMap = [[NSMutableDictionary alloc] init];
    for (EBContact *contact in contacts)
    {
        if (contact.special ||
            (self.contactsSelected && [self.filterContacts containsObject:contact]))
        {
            continue;
        }
        NSString *firstLetter = [[contact.pinyin substringToIndex:1] uppercaseString];
        NSMutableArray *subContacts = _contactsMap[firstLetter];
        if (subContacts == nil)
        {
            subContacts = [[NSMutableArray alloc] init];
            _contactsMap[firstLetter] = subContacts;
        }
        
        [subContacts addObject:contact];
    }
    _sectionIndexTitles = [[_contactsMap allKeys] sortedArrayUsingComparator:^(NSString *str1, NSString *str2){
        return [str1 compare:str2];
    }];
    
    if (!keyword && _tableView)
    {
        [_tableView reloadData];
    }
}

- (void)buildContactsMap:(NSString *)keyword
{
    NSArray *contacts;
    if (keyword)
    {
       contacts = [[EBContactManager sharedInstance] contactsByKeyword:keyword];
    }
    else
    {
       contacts = [[EBContactManager sharedInstance] nonAllContacts];
    }

    contacts = [contacts sortedArrayUsingComparator:^(EBContact *contact1, EBContact *contact2){
        return  [contact1.pinyin compare:contact2.pinyin];
    }];

    _contactsMap = [[NSMutableDictionary alloc] init];
    for (EBContact *contact in contacts)
    {
        if (contact.special ||
                (self.contactsSelected && [self.filterContacts containsObject:contact]))
        {
            continue;
        }
        NSString *firstLetter = [[contact.pinyin substringToIndex:1] uppercaseString];
        NSMutableArray *subContacts = _contactsMap[firstLetter];
        if (subContacts == nil)
        {
            subContacts = [[NSMutableArray alloc] init];
            _contactsMap[firstLetter] = subContacts;
        }

        [subContacts addObject:contact];
    }
    _sectionIndexTitles = [[_contactsMap allKeys] sortedArrayUsingComparator:^(NSString *str1, NSString *str2){
        return [str1 compare:str2];
    }];

    if (!keyword && _tableView)
    {
        [_tableView reloadData];
    }
}

- (void)updateTableViewStyle:(UITableView *)tableView
{
    tableView.sectionIndexColor = [UIColor colorWithRed:0xa8/255.f green:0xb1/255.f blue:0xba/255.f alpha:1.0];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)ybPopupMenuDidSelectedAtIndex:(NSInteger)index ybPopupMenu:(YBPopupMenu *)ybPopupMenu{
    //点击了搜索
    
    if (index == 0) {
        _searchHelper.displayController.searchBar.placeholder = @"请输入姓名";
    }else{
        _searchHelper.displayController.searchBar.placeholder = @"请输入部门名或门店名";
    }
    [_searchHelper searchContacts:self delegate:self keywordChange:^(NSString *keyword)
        {
            if (index == 0) {
                  [self buildContactsMap:keyword];//按名字搜索
            }else if(index == 1){
                  [self buildLwLContactsMap:keyword];//按门店搜索
            }else{
                [self buildPhoneContactsMap:keyword];//按座机搜索
            }
         
           if (_sectionIndexTitles.count == 0){
               dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.001);
               dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                   for (UIView *v in _searchHelper.displayController.searchResultsTableView.subviews) {
                       if ([v isKindOfClass: [UILabel class]] &&
                               [[(UILabel*)v text] isEqualToString:@"No Results"])
                       {
                           UILabel *textView = (UILabel*)v;
                           textView.text = NSLocalizedString(@"No Results", nil);
                           break;
                       }
                   }
               });
           }
        }];
    
        [_tableView setContentOffset:_tableView.contentOffset animated:NO];
    
        [EBTrack event:EVENT_CLICK_COLLEAGUE_ADDRESSBOOK_SEARCH];
        [self updateTableViewStyle:_searchHelper.displayController.searchResultsTableView];
    
}

#define TITLES @[@"按名字搜索",@"按门店搜索",@"按座机搜索"]

#pragma mark - action
- (void)searchContact:(id)btn
{
//    _searchHelper.displayController.searchBar.placeholder
//    self.popupMenu = [YBPopupMenu showRelyOnView:self.navigationItem.rightBarButtonItem.customView titles:TITLES icons:nil menuWidth:120 delegate:self];
//    self.popupMenu = [YBPopupMenu showAtPoint:CGPointMake(kScreenW, 44) titles:TITLES icons:nil menuWidth:107 delegate:self];
//    self.popupMenu.dismissOnSelected = YES;
//    self.popupMenu.isShowShadow = YES;
//    self.popupMenu.delegate = self;
//    self.popupMenu.offset = 10;
//    self.popupMenu.type = YBPopupMenuTypeDefault;
     _searchHelper.displayController.searchBar.placeholder = @"请输入部门名或门店名或座机";
    [_searchHelper searchContacts:self delegate:self keywordChange:^(NSString *keyword)
    {
       [self buildContactsMap:keyword];
        
       if (_sectionIndexTitles.count == 0)
       {
           dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.001);
           dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
               for (UIView *v in _searchHelper.displayController.searchResultsTableView.subviews) {
                   if ([v isKindOfClass: [UILabel class]] &&
                           [[(UILabel*)v text] isEqualToString:@"No Results"])
                   {
                       UILabel *textView = (UILabel*)v;
                       textView.text = NSLocalizedString(@"No Results", nil);
                       break;
                   }
               }
           });
       }
    }];

    [_tableView setContentOffset:_tableView.contentOffset animated:NO];

    [EBTrack event:EVENT_CLICK_COLLEAGUE_ADDRESSBOOK_SEARCH];
    [self updateTableViewStyle:_searchHelper.displayController.searchResultsTableView];
}

#pragma -mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  68.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ((!self.contactsSelected && section == 0) || (self.contactsSelected && self.groupSelected && section == 0))
    {
        return 0;
    }
    else
    {
        return 23.0;
    }
}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleInsert
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *cellIdentifier = @"headerCell";

    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellIdentifier];
    if (header == nil)
    {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:cellIdentifier];
        header.textLabel.textColor = [EBStyle grayTextColor];

        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [UIColor colorWithRed:0xef/255.0f green:0xf2/255.0f blue:0xf7/255.0f alpha:1.0];
        header.backgroundView = backgroundView;
    }

    header.textLabel.text = _sectionIndexTitles[[self sectionIdxForContact:section]];

    return header;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_searchHelper.displayController.isActive)
    {
        return NO;
    }
    else if (self.groupSelected && self.contactsSelected && [indexPath section] == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    if (_is_Daily == YES) {
        if (!_searchHelper.displayController.isActive) {
            if (section == 0) {
                [EBAlert alertError:@"请选择经纪人" length:2.0f];
            }else{
                EBContact *contact = [self contactAtIndexPath:indexPath];
                self.returnBlock(contact.name,contact.userId);
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else{
            EBContact *contact = [self contactAtIndexPath:indexPath];
            self.returnBlock(contact.name,contact.userId);
            [self.navigationController popViewControllerAnimated:YES];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else{
        if (!self.contactsSelected)
        {
            if (!_searchHelper.displayController.isActive && section == 0 && [indexPath row] == 0)
            {
            GroupsViewController *controller = [[GroupsViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES   ];
            }
            else
            {
                EBContact *contact = [self contactAtIndexPath:indexPath];
                
                if (contact.special)
                {
                    [[EBController sharedInstance] startChattingWith:@[contact] popToConversation:NO];
                }
                else
                {
                    ProfileViewController *controller = [[ProfileViewController alloc] init];
                    controller.contact = contact;

                    [self.navigationController pushViewController:controller animated:YES];
                }
            }

            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        else
        {
            if (!_searchHelper.displayController.isActive && self.groupSelected && section == 0 && [indexPath row] == 0)
            {
            GroupsViewController *controller = [[GroupsViewController alloc] init];
            controller.groupSelected = ^(EBIMGroup *group){
                [self.navigationController popViewControllerAnimated:NO];
                self.groupSelected(group);
                };
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self.navigationController pushViewController:controller animated:YES   ];
            }
            else
            {
                EBContact *contact = [self contactAtIndexPath:indexPath];
                [_selectedSet addObject:contact];
                [self updateSendButtonState];
                if (_searchHelper.displayController.isActive)
                {
                    _searchHelper.displayController.active = NO;
                }
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.contactsSelected)
    {
        if (!_searchHelper.displayController.isActive && self.groupSelected && [indexPath section] == 0)
        {

        }
        else
        {
            if (_tableView == tableView)
            {
                [_selectedSet removeObject:[self contactAtIndexPath:indexPath]];
                [self updateSendButtonState];
            }
        }
    }
}

#pragma -mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_searchHelper.displayController.isActive)
    {
        return _sectionIndexTitles.count;
    }
    if (self.contactsSelected)
    {
        return _sectionIndexTitles.count + (self.groupSelected ? 1 : 0);
    }
    return _sectionIndexTitles.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_searchHelper.displayController.isActive)
    {
        if (!self.contactsSelected && section == 0)
        {
            return 3;
        }
        else if (self.contactsSelected && self.groupSelected && section == 0)
        {
            return 1;
        }
        else
        {
            return [_contactsMap[_sectionIndexTitles[[self sectionIdxForContact:section]]] count];
        }
    }
    else
    {
        return [_contactsMap[_sectionIndexTitles[[self sectionIdxForContact:section]]] count];
    }

}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (self.contactsSelected)
    {
        if (self.groupSelected)
        {
            return index + 1;
        }
        else
        {
            return index;
        }
    }
    else
    {
       return index + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];

    UITableViewCell *cell;
    if (!_searchHelper.displayController.isActive &&
            ((!self.contactsSelected && section == 0) || (self.contactsSelected && self.groupSelected && section == 0)))
    {
        static NSString *cellIdentifier = @"cellSection0";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

            UIImageView *avatarView = [EBViewFactory avatarImageView:48];
            avatarView.frame = CGRectOffset(avatarView.frame, 15, 10);
            avatarView.tag = 88;
            [cell.contentView addSubview:avatarView];
            avatarView.contentMode = UIViewContentModeCenter;

            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(72, 0, 300, 68)];
            label.font = [UIFont systemFontOfSize:16];
            label.textColor = [EBStyle blackTextColor];
            label.tag = 99;

            [cell.contentView addSubview:label];
            [cell.contentView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:68 leftMargin:72]];
        }

        [self updateSpecialCell:cell.contentView byIndex:row];
    }
    else
    {
        static NSString *cellIdentifier = @"cellSectionContact";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
           cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

           if (self.contactsSelected)
           {
               UIView *selectedBackView = [[UIView alloc] init];
               selectedBackView.layer.opacity = NO;
               [selectedBackView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:68 leftMargin:0]];
               cell.selectedBackgroundView = selectedBackView;
               [cell addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:68 leftMargin:0]];
           }
           else
           {
               [cell.contentView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:68 leftMargin:72]];
           }
        }

        EBContact *contact = [self contactAtIndexPath:indexPath];
        [self updateContactCellContentView:cell.contentView contact:contact];

        if ([_selectedSet containsObject:contact])
        {
            [tableView selectRowAtIndexPath:indexPath animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
        }

    }

    if (self.contactsSelected)
    {
        [EBViewFactory view:cell setSeparatorHidden:([self tableView:tableView numberOfRowsInSection:section] - 1 == row)];
        [EBViewFactory view:cell.selectedBackgroundView setSeparatorHidden:([self tableView:tableView numberOfRowsInSection:section] - 1 == row)];
    }
    else
    {
        [EBViewFactory view:cell.contentView setSeparatorHidden:([self tableView:tableView numberOfRowsInSection:section] - 1 == row)];
    }

    return cell;
}

- (void)updateContactCellContentView:(UIView *)contentView contact:(EBContact *)contact
{
    UIImageView *avatarView = (UIImageView *)[contentView viewWithTag:777];
    RTLabel *detail = (RTLabel *)[contentView viewWithTag:888];
    if (avatarView == nil)
    {
       avatarView = [EBViewFactory avatarImageView:48];
       avatarView.frame = CGRectOffset(avatarView.frame, 15, 10);
       avatarView.tag = 777;
       [contentView addSubview:avatarView];

       detail = [[RTLabel alloc] initWithFrame:CGRectMake(72, 16, 300, 48)];
       detail.tag = 888;
       [contentView addSubview:detail];
    }

    //通讯录
    avatarView.image = [EBViewFactory imageFromGender:contact.gender big:NO];
    detail.text = [NSString stringWithFormat:@"<font size=16 color='#444444'>%@</font>"
                                                     "  <font size=12 color='#b7b7b8'>%@</font>\r\n<font size=12 color='#444444'>%@</font>",
                                             contact.name, contact.department, contact.phone];
}

- (void)updateSpecialCell:(UIView *)contentView byIndex:(NSInteger)index
{
    UIImageView *avatarView = (UIImageView *)[contentView viewWithTag:88];
    UILabel *label = (UILabel *)[contentView viewWithTag:99];

    if (index == 0)
    {
        label.text = NSLocalizedString(@"im_saved_group", nil);
        avatarView.image = [UIImage imageNamed:@"avatar_group"];
        avatarView.layer.borderWidth = 1.0;
        avatarView.layer.borderColor = [UIColor colorWithRed:81/255.0 green:182.0/255.0f blue:210.0/255.09 alpha:1.0].CGColor;
    }
    else
    {
        EBContact *contact = [[EBContactManager sharedInstance] contactById:index == 1 ? [EBPreferences systemIMIDEALL] : [EBPreferences systemIMIDCompany]];
        avatarView.image = [UIImage imageNamed:contact.avatar];
        avatarView.layer.borderWidth = 0.0;
//        avatarView.layer.borderColor = nil;
        label.text = contact.name;
    }
}

- (void)updateSendButtonState
{
    [EBViewFactory updateCountButton:_sendButton count:_selectedSet.count];
}

- (void)didSelectContacts:(UIButton *)btn
{
   NSArray *contacts = [_selectedSet allObjects];
   self.contactsSelected(contacts);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
