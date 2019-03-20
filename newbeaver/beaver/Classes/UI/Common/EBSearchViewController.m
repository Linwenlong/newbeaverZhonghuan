//
// Created by 何 义 on 14-7-3.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBSearchViewController.h"
#import "EBRadioGroup.h"
#import "EBFilter.h"
#import "HouseListViewController.h"
#import "ClientListViewController.h"
#import "EBViewFactory.h"
#import "RTLabel.h"

@interface EBSearchTextField : UITextField
{

}

@end

@interface EBSearchViewController()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
{
    EBSearchTextField *_keywordTextField;
    EBRadioGroup *_radioGroup;
    UISwitch *_imageSwitch;
    UITableView *_tableView;
}
@end

@implementation EBSearchViewController
- (void)loadView
{
    [super loadView];

    CGFloat yOffset = 0.0;

    UIView *statusBarBg = [[UIView alloc] initWithFrame:CGRectMake(0, yOffset, [EBStyle screenWidth], 20)];
    statusBarBg.backgroundColor = [UIColor blackColor];
    [self.view addSubview:statusBarBg];

    [self setupNavBar];
    [self setupTableView];
}

- (void)setupTableView
{
   CGRect tableFrame = [EBStyle fullScrTableFrame:NO];

   tableFrame.size.height -= 108;
   tableFrame.origin.y += 108;

   _tableView = [[UITableView alloc] initWithFrame:tableFrame];
   _tableView.delegate = self;
   _tableView.dataSource = self;
   _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   [self.view addSubview:_tableView];
}

- (void)setupNavBar
{
    CGFloat yOffset = 20.0;
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0, yOffset, [EBStyle screenWidth], 88)];
    navBar.backgroundColor = [UIColor colorWithWhite:248/255.0f alpha:1.0];

    _keywordTextField = [[EBSearchTextField alloc] initWithFrame:CGRectMake(7, 7, [EBStyle screenWidth] - 65, 30)];
    _keywordTextField.backgroundColor = [UIColor colorWithWhite:222/255.0f alpha:1.0];
    _keywordTextField.layer.cornerRadius = 4.0f;
    _keywordTextField.clearButtonMode = UITextFieldViewModeAlways;
    _keywordTextField.enablesReturnKeyAutomatically = YES;
    [navBar addSubview:_keywordTextField];
    _keywordTextField.delegate = self;

    if (_searchType <= EBSearchTypeClient)
    {
        _keywordTextField.returnKeyType = UIReturnKeyDone;
    }
    else
    {
        _keywordTextField.returnKeyType = UIReturnKeySearch;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keywordTextFieldTextChanged:) name:UITextFieldTextDidChangeNotification object:_keywordTextField];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(_keywordTextField.right, 0, 65, 44)];
    [cancelButton setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [cancelButton setTitleColor:[EBStyle darkBlueTextColor] forState:UIControlStateNormal];
    [navBar addSubview:cancelButton];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:14.0];

    [cancelButton addTarget:self action:@selector(cancelSearch:) forControlEvents:UIControlEventTouchUpInside];

    UIView *underView = [self underSearchView];
    underView.frame = CGRectOffset(underView.frame, 0, 44);
    [navBar addSubview:underView];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 44, [EBStyle screenWidth], 0.5)];
    line.backgroundColor = [EBStyle grayUnClickLineColor];
    [navBar addSubview:line];

    [self.view addSubview:navBar];
}

- (void)cancelSearch:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (UIView *)underSearchView
{
    UIView *underView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 44)];
    underView.backgroundColor = [UIColor clearColor];

    _radioGroup = [[EBRadioGroup alloc] initWithFrame:CGRectMake(15, 9.5, 200, 25)];
    _radioGroup.radios = [self rentalChoices];
    _radioGroup.selectedIndex = 1;
    [underView addSubview:_radioGroup];

    if (self.searchType == EBSearchTypeHouse)
    {
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_dash_line"]];
        line.center = CGPointMake(195, 22);
        [underView addSubview:line];

        UILabel *withImage = [[UILabel alloc] initWithFrame:CGRectMake([EBStyle screenWidth] - 120, 0, 50, 44)];
        withImage.backgroundColor = [UIColor clearColor];
        withImage.textColor = [EBStyle darkBlueTextColor];
        withImage.font = [UIFont systemFontOfSize:14.0];
        withImage.text = NSLocalizedString(@"search_with_image", nil);
        [underView addSubview:withImage];
        
        if ([EBStyle isUnder_iPhone5])
        {
            _imageSwitch = [[UISwitch alloc] initWithFrame:CGRectMake([EBStyle screenWidth] - 120 + 21, 8.5, 79, 27)];
            withImage.frame = CGRectMake(176, 0, 50, 44);
        }
        else
        {
            _imageSwitch = [[UISwitch alloc] initWithFrame:CGRectMake([EBStyle screenWidth] - 120 + 50, 7.5, 50, 30)];
        }
        
        [underView addSubview:_imageSwitch];
    }

    return underView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [_keywordTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];


    EBFilter *filter = [[EBFilter alloc] init];
    filter.keyword = _keywordTextField.text;
    filter.requireOrRentalType = _radioGroup.selectedIndex + 1;

    NSArray *prompts = [self prompts];
    filter.keywordType = prompts[row][@"value"];
    NSLog(@"keywordType=%@",prompts[row][@"value"]);

    if (_searchType == EBSearchTypeHouse)
    {
        filter.hasPhoto = _imageSwitch.on;
        HouseListViewController *listViewController =
                [[EBController sharedInstance] showHouseListWithType:EHouseListTypeSearch filter:filter title:NSLocalizedString(@"search_result", nil) client:nil];
        listViewController.handleSelections = self.handleSelections;
    }
    else if (_searchType == EBSearchTypeClient)
    {
       ClientListViewController *listViewController = [[EBController sharedInstance] showClientListWithType:EClientListTypeSearch filter:filter title:NSLocalizedString(@"search_result", nil) house:nil];
        listViewController.handleSelections = self.handleSelections;
    }

//    [_displayController.searchBar resignFirstResponder];
//   }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_keywordTextField resignFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *text = _keywordTextField.text;
    if (text && text.length > 0)
    {
        return [self prompts].count;
    }
    else
    {
        return 0;
    }

}

- (NSArray *)prompts
{
    return self.searchType == EBSearchTypeHouse ? [EBFilter rawHouseKeywordTypeChoices] : [EBFilter rawClientKeywordTypeChoices];
}

- (NSArray *)rentalChoices
{
    return self.searchType == EBSearchTypeHouse ? [EBFilter rawHouseRentalTypeChoices] : [EBFilter rawClientRequireTypeChoices];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSString *identifier = @"searchCell";

    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell addSubview:[EBViewFactory defaultTableViewSeparator]];
        cell.textLabel.textColor = [EBStyle blackTextColor];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        RTLabel *titleLabel = [[RTLabel alloc] initWithFrame:CGRectMake(15, 13, 300, 18)];
        titleLabel.tag = 99;
        titleLabel.textColor = [EBStyle blackTextColor];
        [cell.contentView addSubview:titleLabel];
    }

    NSArray *prompts = [self prompts];

    RTLabel *titleLabel = (RTLabel *)[cell.contentView viewWithTag:99];
    titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"search_prompt_format", nil),
                                                 prompts[row][@"title"], _keywordTextField.text];

    return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    [_tableView reloadData];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_keywordTextField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [_tableView reloadData];
    return YES;
}

#pragma mark - Selector

- (void)keywordTextFieldTextChanged:(id)sender
{
    [_tableView reloadData];
}

@end

@implementation EBSearchTextField

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 5.0, 3.0);
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 5.0, 3.0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 5.0, 3.0);
}

@end