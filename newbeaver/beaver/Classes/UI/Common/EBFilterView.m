//
//  FilterView.m
//  beaver
//
//  Created by 何 义 on 14-3-3.
//  Copyright (c) 2014年 eall. All rights reserved.
//
#import <sys/ucred.h>
#import "EBFilterView.h"
#import "EBViewFactory.h"
#import "EBStyle.h"
#import "EBRadioGroup.h"
#import "MHTextField.h"
#import "EBFilter.h"
#import "EBCondition.h"
#import "EBController.h"
#import "EBAssociateViewController.h"
#import "EBCache.h"
#import "EBBusinessConfig.h"
#import "EBBaseModel.h"
#import "HouseTypeTableViewController.h"

#define COLLECTION_CELL_LABEL_IDENTIFIER  @"collectionLabelIdentifier"
#define COLLECTION_CELL_PHOTO_IDENTIFIER  @"collectionPhotoIdentifier"
#define COLLECTION_CELL_TextField_IDENTIFIER  @"collectionTextFieldIdentifier"

//明天

@interface EBFilterView()
{
    NSArray *_filters;
    NSMutableArray *_textFields;
    NSMutableArray *_communities;
    BOOL _isCustom;
    MHTextField *_conditionName;
    UITableView *_tableView;
    UICollectionView *_collectionView;
    NSMutableDictionary *_textFieldsMap;
    NSMutableArray *_communitiesIds;
    UITextField *_floorMinTextfield;
    UITextField *_floorMaxTextfield;
    NSInteger _currentIndex;
    
    UITextField *_block;//座栋
    UITextField *_unit_name;//单元
    UITextField *_room_code;//房号
    
}
@property (nonatomic,strong)NSArray *arr;
@property (nonatomic,strong)UIButton *btn;
@property (nonatomic,strong)NSString *houseTypeStr;
@end

@implementation EBFilterView
-(NSArray *)arr{
    
    if (_arr == nil) {
        _arr = [NSArray array];
    }
    return _arr;
}
-(id)initWithFrame:(CGRect)frame custom:(BOOL)custom;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        _isCustom = custom;

        _tableView = [[UITableView alloc] initWithFrame:self.bounds];
        _tableView.scrollsToTop = NO;
        _tableView.backgroundView.alpha = 0;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.editing = YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_tableView];
        _tableView.allowsSelectionDuringEditing = YES;

        _filter = [[EBFilter alloc] init];

        _tableView.tableHeaderView = [self buildTableHeaderView];
        if (!_isCustom)
        {
            _tableView.tableFooterView = [self buildTableFooterView];
        }

        _filters = @[
//                    @{@"title":NSLocalizedString(@"filter_rental", nil), @"image":[UIImage imageNamed:@"filter_rental"], @"key":@"rental", @"default": @0},
                    @{@"title":NSLocalizedString(@"filter_district", nil),
                      @"image":[UIImage imageNamed:@"filter_district"],
                      @"key":@"district", @"default": @0},
                    @{@"title":NSLocalizedString(@"filter_price", nil),
                      @"image":[UIImage imageNamed:@"filter_price"],
                      @"key":@"price", @"default": @0},
                    @{@"title":NSLocalizedString(@"filter_room", nil),
                      @"image":[UIImage imageNamed:@"filter_room"],
                      @"key":@"room", @"default": @0},
                    @{@"title":NSLocalizedString(@"filter_area", nil),
                      @"image":[UIImage imageNamed:@"filter_area"],
                      @"key":@"area", @"default": @0},
                    @{@"title":NSLocalizedString(@"filter_photo", nil),
                      @"image":[UIImage imageNamed:@"filter_area"],
                      @"key":@"photo", @"default": @0}
//                    @{@"title":NSLocalizedString(@"filter_towards", nil), @"image":[UIImage imageNamed:@"filter_toward"], @"key":@"towards", @"default": @0},
                    ];

        _textFieldsMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame custom:(BOOL)custom withIsHouseView:(BOOL)isHouseView
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        _isCustom = custom;
        _isHouseView = isHouseView;
        _tableView = [[UITableView alloc] initWithFrame:self.bounds];
        _tableView.scrollsToTop = NO;
        _tableView.backgroundView.alpha = 0;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.editing = YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_tableView];
        _tableView.allowsSelectionDuringEditing = YES;
        
        _filter = [[EBFilter alloc] init];
        
        _tableView.tableHeaderView = [self buildTableHeaderView];
        if (!_isCustom)
        {
            _tableView.tableFooterView = [self buildTableFooterView];
        }
        
        _filters = @[
                     //                    @{@"title":NSLocalizedString(@"filter_rental", nil), @"image":[UIImage imageNamed:@"filter_rental"], @"key":@"rental", @"default": @0},
                     @{@"title":NSLocalizedString(@"filter_district", nil),
                       @"image":[UIImage imageNamed:@"filter_district"],
                       @"key":@"district", @"default": @0},
                     @{@"title":NSLocalizedString(@"filter_price", nil),
                       @"image":[UIImage imageNamed:@"filter_price"],
                       @"key":@"price", @"default": @0},
                     @{@"title":NSLocalizedString(@"filter_room", nil),
                       @"image":[UIImage imageNamed:@"filter_room"],
                       @"key":@"room", @"default": @0},
                     @{@"title":NSLocalizedString(@"filter_area", nil),
                       @"image":[UIImage imageNamed:@"filter_area"],
                       @"key":@"area", @"default": @0},
                    @{@"title":NSLocalizedString(@"filter_renovate", nil), @"image":[UIImage imageNamed:@"filter_toward"], @"key":@"renovate", @"default": @0},
                     @{@"title":NSLocalizedString(@"filter_photo", nil),
                       @"image":[UIImage imageNamed:@"filter_area"],
                       @"key":@"photo", @"default": @0},//2018
                     @{@"title":NSLocalizedString(@"filter_status", nil), @"image":[UIImage imageNamed:@"filter_toward"], @"key":@"house_status", @"default": @0},
                     @{@"title":NSLocalizedString(@"filter_status", nil), @"image":[UIImage imageNamed:@"filter_toward"], @"key":@"block", @"default": @0},
                     @{@"title":NSLocalizedString(@"filter_status", nil), @"image":[UIImage imageNamed:@"filter_toward"], @"key":@"unit", @"default": @0},
                     @{@"title":NSLocalizedString(@"filter_status", nil), @"image":[UIImage imageNamed:@"filter_toward"], @"key":@"room", @"default": @0},
//                    @{@"title":NSLocalizedString(@"filter_renovate", nil), @"image":[UIImage imageNamed:@"filter_toward"], @"key":@"renovate", @"default": @0},
                     ];
        
        _textFieldsMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    return  [self initWithFrame:frame custom:NO];
}

- (void)setFilter:(EBFilter *)filter
{
    _filter = filter;
    _tableView.tableHeaderView = [self buildTableHeaderView];
    [_tableView reloadData];
}

- (void)setCustomCondition:(EBCondition *)customCondition
{
    _customCondition = customCondition;
    _filter = _customCondition.filter;
    _communities = [NSMutableArray arrayWithArray:_customCondition.communities];
    _tableView.tableHeaderView = [self buildTableHeaderView];
    _tableView.tableFooterView = [self buildTableFooterView];
    [_tableView reloadData];
}

- (void)syncCondition
{
    if (_filter.purposeIndex == 3 || _filter.purposeIndex == 4)
    {
        _filter.roomIndex = 0;
    }
    for (UITextField *field in _textFields)
    {
        [field resignFirstResponder];
    }
    for (NSInteger i = 0; i < _communities.count; i++)
    {
        NSString *value = _communities[i];
        if (value.length == 0)
        {
           [_communities removeObjectAtIndex:i];
        }
    }
    _filter.reservedCondition = @{@"community":[_communities componentsJoinedByString:@";"]};
    _customCondition.communities = _communities;
    _customCondition.title = _conditionName.text;
}

- (UIView *)buildTableHeaderView
{
    UIView *headerView = [[UIView alloc] init];

    CGFloat yOffset = 15.0;
    if (_isCustom)
    {
        _conditionName = [[MHTextField alloc] initWithFrame:CGRectMake(15.0, yOffset, 290, 34)];
        _conditionName.font = [UIFont systemFontOfSize:16.0f];
        _conditionName.placeholderColor = [EBStyle grayTextColor];
        _conditionName.placeholder = _filterType == EFilterTypeGatherHouse ? NSLocalizedString(@"pl_subscription_name", nil) : NSLocalizedString(@"pl_custom_condition_name", nil);
        [_conditionName setRequired:YES];
        [self pushTextField:_conditionName];
        [headerView addSubview:_conditionName];
        _conditionName.text = _customCondition.title;

        yOffset += _conditionName.frame.size.height;
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15.0, yOffset, [EBStyle screenWidth] - 15.f, 0.5f)];
        line.backgroundColor = [EBStyle grayClickLineColor];
        [headerView addSubview:line];

        yOffset += 20;
        if (_isHouseView) {
            yOffset-=54;
            _conditionName.alpha=0;
            line.alpha=0;
        }
    }

    // type
    _houseTypeStr = @"";
    EBRadioGroup *radioGroup = [[EBRadioGroup alloc] initWithFrame:CGRectMake(15, yOffset, [EBStyle screenWidth] - 20.f, 25)];
    radioGroup.radios = _filterType == EFilterTypeClient ? [EBFilter rawClientRequireTypeChoices] : [EBFilter rawHouseRentalTypeChoices];
    radioGroup.checkBlock = ^(NSInteger checked){
        if (_filter.requireOrRentalType != checked + 1)
        {
            _filter.requireOrRentalType = checked + 1;
            _filter.priceIndex = 0;
            [_tableView reloadData];
            [_collectionView reloadData];
        }
    };
    radioGroup.selectedIndex = _filter.requireOrRentalType - 1;
    [headerView addSubview:radioGroup];
    yOffset += 35;

    if (_filterType != EFilterTypeGatherHouse)
    {
        // belong
        radioGroup = [[EBRadioGroup alloc] initWithFrame:CGRectMake(15, yOffset, [EBStyle screenWidth] - 20.f, 25)];
        radioGroup.radios = [EBFilter rawBelongChoices];
        
        radioGroup.selectedIndex = _filter.belongIndex - 1;
        radioGroup.checkBlock = ^(NSInteger checked){
            _filter.belongIndex = checked + 1;
        };
        [headerView addSubview:radioGroup];
        yOffset += 35;
    }

    if (_filterType == EFilterTypeHouse)
    {
        
        radioGroup = [[EBRadioGroup alloc] initWithFrame:CGRectMake(15, yOffset, [EBStyle screenWidth] - 20.f, 35)];
        radioGroup.radios = [EBFilter rawPurposeChoices];
        
        radioGroup.selectedIndex = _filter.purposeIndex - 1;
        radioGroup.checkBlock = ^(NSInteger checked){
            
            EBBusinessConfig *config = [[EBCache sharedInstance]objectForKey: EB_CACHE_KEY_CONFIG];
            EBConfiguration *ration = config.houseConfig;
            NSDictionary *dict = ration.housingType;
            
            NSString *str = [EBFilter rawPurposeChoices][checked][@"title"];
            self.arr = dict[str];
            _filter.purposeIndex = checked + 1;
            [_collectionView reloadData];
            if ([str isEqualToString:@"所有"]) {
                _houseTypeStr = @"";
                _btn.userInteractionEnabled = NO;
                [_btn setTitle:@"已选择所有类型" forState:UIControlStateNormal];
            }else{
                _btn.userInteractionEnabled = YES;
                if (_currentIndex!=checked+1) {
                    [_btn setTitle:@"请选择" forState:UIControlStateNormal];
                    _houseTypeStr = @"";
                    
                }
            }
            _currentIndex = checked+1;
            
        };
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(25, radioGroup.bottom, [EBViewFactory textSize:@"类型" font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].width, 30)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [EBStyle darkRedTextColor];
        label.text = @"类型";
        UIButton *typeBtn = [[UIButton alloc]initWithFrame:CGRectMake(label.right+25,radioGroup.bottom,[UIScreen mainScreen].bounds.size.width-label.right, 30)];
        [typeBtn addTarget:self action:@selector(clickTypeBtn) forControlEvents:UIControlEventTouchUpInside];
        typeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        typeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _btn = typeBtn;
        _btn.userInteractionEnabled = NO;
        [typeBtn setTitle:@"已选择所有类型" forState:UIControlStateNormal];
        [typeBtn setTitleColor:[EBStyle grayTextColor] forState:UIControlStateNormal];
        [headerView addSubview:label];
        [headerView addSubview:typeBtn];
        [headerView addSubview:radioGroup];
        yOffset += 35;
        
    }
    
    if (!_isCustom) {
        headerView.frame = CGRectMake(0.0, 0.0, [EBStyle screenWidth], yOffset);
    }else {
        headerView.frame = CGRectMake(0.0, 0.0, [EBStyle screenWidth], yOffset+40);
    }
    
    
    return headerView;
}
-(void)clickTypeBtn{
    
    HouseTypeTableViewController *tabV = [[HouseTypeTableViewController alloc]init];
    tabV.houseTypeChoiceArr = self.arr;
    tabV.tableView.separatorStyle = NO;
    [[EBController sharedInstance].currentNavigationController pushViewController:tabV animated:YES];
    void(^myblock)(NSString *str)=^(NSString *str){
        [_btn setTitle:str forState:UIControlStateNormal];
        self.houseTypeStr = str;
    };
    tabV.myblock = myblock;
    
}


- (void)pushTextField:(MHTextField *)textField
{
    if (_textFields == nil)
    {
        _textFields = [[NSMutableArray alloc] init];
    }

    NSInteger idx = _textFields.count;
    textField.tag = idx;
    [_textFields addObject:textField];
    textField.textFields = _textFields;
}

- (void)setFilterType:(EFilterType)filterType
{
    _filterType = filterType;
    _tableView.tableHeaderView = [self buildTableHeaderView];
    _tableView.tableFooterView = [self buildTableFooterView];
    [_tableView reloadData];
}

- (void)filter:(UIButton *)btn
{
    NSMutableArray *arrayM = [[NSMutableArray alloc]init];
    for (NSInteger i =0 ; i<_communitiesIds.count; i++) {
        NSString * str = _communitiesIds[i];
        if (str&&[str length]> 0) {
            [arrayM addObject:str];
        }
    }
    if (_isCustom) {
        _filter.floorMinAndfloorMaxWithhouserType = @{@"floor_min":_floorMinTextfield.text,@"floor_max":_floorMaxTextfield.text,@"house_type":_houseTypeStr};
        
        //赋值座栋、单元、房号
        _filter.block = _block.text;
        _filter.unit_name = _unit_name.text;
        _filter.room_code = _room_code.text;
    }
    _filter.communitiesIds = [arrayM componentsJoinedByString:@";"];
    [self.delegate filterView:self filter:_filter];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (section == 0)
//    {
//        return 10.0;
//    }
    return 0.0;
}

#pragma mark - UITableViewDelegate
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 60.f;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    if (_isCustom && section == 1)
    {
         [self tableView:tableView commitEditingStyle:UITableViewCellEditingStyleInsert forRowAtIndexPath:indexPath];
    }
}
#define FILTER_MARGIN 15.0f
#define FILTER_BTN_GAP 20.0f

//房源列表添加 小区筛选
- (void )buildTableFooterViewForHouseView
{
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 66)];

    [footerView addSubview:[EBViewFactory blueButtonWithFrame:CGRectMake(FILTER_MARGIN, FILTER_BTN_GAP,
                                                                         self.frame.size.width - 2 * FILTER_MARGIN, 36.0) title:NSLocalizedString(@"filter", nil) target:self
                                                       action:@selector(filter:)]];
    _tableView.tableFooterView = footerView;

    
}
- (UIView *)buildTableFooterView;
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 66)];
    if (_isCustom)
    {
       if (_customCondition.id > 0)
       {
           [footerView addSubview:[EBViewFactory redButtonWithFrame:CGRectMake(FILTER_MARGIN, FILTER_BTN_GAP,
                   self.frame.size.width - 2 * FILTER_MARGIN, 36.0) title:NSLocalizedString(@"delete", nil) target:self
                   action:@selector(filter:)]];
       }
    }
    else
    {
        [footerView addSubview:[EBViewFactory blueButtonWithFrame:CGRectMake(FILTER_MARGIN, FILTER_BTN_GAP,
                self.frame.size.width - 2 * FILTER_MARGIN, 36.0) title:NSLocalizedString(@"filter", nil) target:self
                action:@selector(filter:)]];
    }

    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isCustom && indexPath.section == 1 )
    {
        return 44.0;
    }
    if (_filterType == EFilterTypeClient || _filterType == EFilterTypeGatherHouse)
    {
        return 88.0;
    }
    return 176.0+88.0;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isCustom && section == 1)
    {
        NSInteger count = _communities.count;
        return count >= 3 ? 3 : count + 1;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _isCustom ? 2 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if (_isCustom && [indexPath section] == 1)
    {
       if (row == _communities.count)
       {
           static NSString *cellIdentifier =  @"addCell";
           UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
           if (cell == nil)
           {
               cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
               [cell addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:44.0f leftMargin:54.0]];
               UIImage *addImage = [UIImage imageNamed:@"btn_add"];

               UIImageView *addImgView = [[UIImageView alloc] initWithImage:addImage];
               addImgView.frame = CGRectOffset(addImgView.frame, 12, 22 - addImage.size.height / 2);
               [cell addSubview:addImgView];

               UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, 200, 44)];
               label.textColor = [EBStyle darkBlueTextColor];
               label.backgroundColor = [UIColor clearColor];
               label.font = [UIFont systemFontOfSize:14.0];
               label.text = NSLocalizedString(@"assign_community", nil);
               [cell addSubview:label];
           }

           return cell;
       }
       else
       {
           return [self tableView:tableView communityCellForRow:row];
       }
    }
    else
    {
       UITableViewCell *filterCell =  [self tableView:tableView filterCellForRow:row];
//       if (row == _filters.count - 1 && !tableView.isEditing)
//       {
//           [tableView setEditing:YES];
//       }
       return filterCell;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView filterCellForRow:(NSInteger)row
{
    static NSString *cellIdentifier =  @"filterCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                                              self.frame.size.width, 176.0f) collectionViewLayout:layout];
        _collectionView.scrollsToTop = NO;
       
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:COLLECTION_CELL_LABEL_IDENTIFIER];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:COLLECTION_CELL_PHOTO_IDENTIFIER];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:COLLECTION_CELL_TextField_IDENTIFIER];
        
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell1"];
        [cell.contentView addSubview:_collectionView];
    }
    CGRect frame = _collectionView.frame;
    if (_filterType == EFilterTypeClient)
    {
        frame.size.height = 88.0;
    }
    else
    {
        frame.size.height = 176.0+88.0;
        //+44.0; //2018
    }
    _collectionView.frame = frame;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView communityCellForRow:(NSInteger)row
{
    static NSString *cellIdentifier =  @"communityCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//        [cell setEditing:YES];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:44 leftMargin:[EBStyle separatorLeftMargin]]];
    }

    MHTextField *textField = [self textFieldFromCell:cell];
    textField.text = _communities[row];
//    textField.scrollView = tableView;
    NSString *community = _communities[row];

    _textFieldsMap[@(row)] = textField;
    if (community.length == 0)
    {
//        [textField becomeFirstResponder];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        if (_communities == nil)
        {
            _communities = [[NSMutableArray alloc] init];
        }
        [_communities addObject:@""];
        if (_communitiesIds == nil)
        {
            _communitiesIds = [[NSMutableArray alloc] init];
        }
        [_communitiesIds addObject:@""];
    }
    else if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [_communities removeObjectAtIndex:row];
        [_communitiesIds removeObjectAtIndex:row];
        [_textFields removeObject:_textFieldsMap[@(row)]];
        [_textFieldsMap removeObjectForKey:@(row)];
        
    }

    [tableView reloadSections:[[NSIndexSet alloc] initWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isCustom && [indexPath section] == 1)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isCustom && [indexPath section] == 1)
    {
        return YES;
    }
    else
    {
        return NO;
    }
//    [tableView setAllowsSelectionDuringEditing:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isCustom && [indexPath section] == 1)
    {
        return [indexPath row] < _communities.count ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
    }
    else
    {
        return UITableViewCellEditingStyleNone;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0){
        if (_filterType == EFilterTypeClient || _filterType == EFilterTypeGatherHouse)
        {
            return _filters.count - 1;
        }
        else
        {
            return _filters.count;
        }
    }else if (section == 1){
        return 1;
    }else{
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSInteger row = [indexPath row];
        NSString *identifier;
        //这里做文章
//        identifier = row == 4 ? COLLECTION_CELL_PHOTO_IDENTIFIER : COLLECTION_CELL_LABEL_IDENTIFIER;
        //lwl
        
        
        if (row > 6) {
            identifier = COLLECTION_CELL_TextField_IDENTIFIER;
            
            UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
            [cell addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:44.0f width:130.0f leftMargin:15.0f]];
//            cell.contentView.backgroundColor = [UIColor yellowColor];
            UIView *view = [cell.contentView viewWithTag:999];
            if (view) {
                [view removeFromSuperview];
                view = nil;
            }
            view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
            view.tag = 999;
            
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 0.0,
                                                                            30, 44.0f)];
            [valueLabel setTextColor:[EBStyle darkRedTextColor]];
            [valueLabel setFont:[UIFont systemFontOfSize:14.0f]];
            
            valueLabel.backgroundColor = [UIColor clearColor];
            
            UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake( CGRectGetMaxX(valueLabel.frame)+10, (view.height-25)/2, [EBViewFactory textSize:@"最低楼层" font:[UIFont boldSystemFontOfSize:14] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].width, 25)];
            textField.textAlignment = NSTextAlignmentCenter;
            textField.font = [UIFont systemFontOfSize:14];
            textField.placeholder = @"请输入";
            [view addSubview:textField];
            [view addSubview:valueLabel];
            textField.tag = row;
            [cell.contentView addSubview:view];
            
            if (row == 7) {
                valueLabel.text = @"座栋";
                _block = textField;
                [_block addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventEditingChanged];
                _block.text = _filter.block;
            }else if (row == 8){
                valueLabel.text = @"单元";
                _unit_name = textField;
                [_unit_name addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventEditingChanged];
                _unit_name.text = _filter.unit_name;
            }else if (row == 9){
                valueLabel.text = @"房号";
                _room_code = textField;
                [_room_code addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventEditingChanged];
                _room_code.text = _filter.room_code;
            }
            
            
            return cell;
        }else{
            identifier = row == 5 ? COLLECTION_CELL_PHOTO_IDENTIFIER : COLLECTION_CELL_LABEL_IDENTIFIER;
            
            UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
            [cell addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:44.0f width:130.0f leftMargin:15.0f]];
            [self updateCell:cell forIndexPath:indexPath withIdentifier:identifier];
            return cell;
        }
        
    }else if (indexPath.section ==1){
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell1" forIndexPath:indexPath];
        //    [cel addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:44.0f width:[UIScreen mainScreen].bounds.size.width leftMargin:15.0f]];
        UIView *view = [cell.contentView viewWithTag:888];
        if (view) {
            [view removeFromSuperview];
            view = nil;
        }
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
        view.tag = 888;
        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 0.0,
            30, 44.0f)];
        [valueLabel setTextColor:[EBStyle darkRedTextColor]];
        [valueLabel setFont:[UIFont systemFontOfSize:14.0f]];
        valueLabel.text = @"楼层";
        valueLabel.backgroundColor = [UIColor clearColor];
        UITextField *floorMinTextField = [[UITextField alloc]initWithFrame:CGRectMake((view.width-40*2)/3, (view.height-25)/2, [EBViewFactory textSize:@"最低楼层" font:[UIFont boldSystemFontOfSize:14] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].width, 25)];
        UITextField *floorMaxTextField = [[UITextField alloc]initWithFrame:CGRectMake((view.width-40*2)*2/3, (view.height-25)/2, [EBViewFactory textSize:@"最低楼层" font:[UIFont boldSystemFontOfSize:14] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].width, 25)];
        floorMinTextField.textAlignment = NSTextAlignmentCenter;
        floorMaxTextField.textAlignment = NSTextAlignmentCenter;
        floorMaxTextField.font = [UIFont systemFontOfSize:14];
        floorMinTextField.font = [UIFont systemFontOfSize:14];
        floorMinTextField.placeholder = @"最低楼层";
        floorMaxTextField.placeholder = @"最高楼层";
        floorMinTextField.keyboardType = UIKeyboardTypeNumberPad;
        floorMaxTextField.keyboardType = UIKeyboardTypeNumberPad;
        floorMaxTextField.text = _floorMaxTextfield.text;
        floorMinTextField.text = _floorMinTextfield.text;
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(floorMinTextField.right+8, floorMinTextField.centerY, floorMaxTextField.left-floorMinTextField.right-16, 0.5)];
        lineView.backgroundColor = [EBStyle darkRedTextColor];
        [view addSubview:lineView];
        
        _floorMaxTextfield = floorMaxTextField;
        _floorMinTextfield = floorMinTextField;
        _floorMinTextfield.delegate = self;
        _floorMaxTextfield.delegate = self;
        [view addSubview:floorMaxTextField];
        [view addSubview:floorMinTextField];
        [view addSubview:valueLabel];
        [view addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:44.0f width:[UIScreen mainScreen].bounds.size.width leftMargin:15.0f]];
        [cell.contentView addSubview:view];
        NSLog(@"%f %f",cell.contentView.frame.origin.x,view.left);
        return cell;
    }else{
        
    }
    return nil;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width/2, 44.0f);
    }else if (indexPath.section == 1)
    {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, 44.0f);
    }else{
        return CGSizeZero;
    }}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
    
    NSInteger row = indexPath.row;
    NSDictionary *filter = _filters[row];
    NSInteger rChoice,lChoice=0;
    if (row == 0)
    {
        lChoice = _filter.district1;
        rChoice = _filter.district2;
    }
    else
    {
        rChoice = [_filter choiceByIndex:row];
    }
    NSArray *choices = [_filter choicesByIndex:row];
    if (choices != nil)
    {
        [[EBController sharedInstance] promptChoices:choices withRightChoice:rChoice leftChoice:lChoice title:filter[@"title"]
                                           houseType:_filter.requireOrRentalType
                                          completion:^(NSInteger rightChoice, NSInteger leftChoice)
        {
            if (row == 0)
            {
                _filter.district1 = leftChoice;
                _filter.district2 = rightChoice;
            }
            else
            {
                [_filter setChoice:rightChoice byIndex:row];
            }
            [collectionView reloadData];
        }];
        }
    }
    else if (indexPath.section == 1){
        
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_filter.purposeIndex == 3 ||_filter.purposeIndex == 4)
    {
        if (indexPath.row == 2)
        {
            return NO;
        }
    }
    return YES;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    if (textField.tag != 0)
    {
        [textField resignFirstResponder];
        _tableView.contentOffset = CGPointZero;
        EBAssociateViewController *viewController = [[EBAssociateViewController alloc] init];
        viewController.hidesBottomBarWhenPushed = YES;
        if (_filter.district1 == 0)
        {
            viewController.district = @"";
            viewController.region = @"";
        }
        else if (_filter.district2 == 0)
        {
            NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
            viewController.district = district1[@"title"];
            viewController.region = @"";
        }
        else
        {
            NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
            viewController.district = district1[@"title"];
            viewController.region = district1[@"children"][_filter.district2];
        }
        viewController.handleSelection = ^(NSString *district, NSString *region, EBCommunity *community){
            textField.text = community.community;
    
            for (id key in _textFieldsMap)
            {
                if (_textFieldsMap[key] == textField)
                {
                    _communities[[key integerValue]] = textField.text;
                    _communitiesIds[[key integerValue]] = community.communityId;
                    break;
                }
            }
        };
        [[EBController sharedInstance].currentNavigationController pushViewController:viewController animated:NO];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    
//    for (id key in _textFieldsMap)
//    {
//         if (_textFieldsMap[key] == textField)
//         {
//             _communities[[key integerValue]] = textField.text;
//         }
//    }
}


#pragma mark - UISwitch Action


-(void)hasPhotoSwitchValueChanged:(id)sender
{
    UISwitch *hasPhotoSwitch = sender;
    _filter.hasPhoto = hasPhotoSwitch.isOn;
}

#pragma mark - Private


- (void)changeValue:(UITextField *)textField{
    NSLog(@"监听到了");
    if (textField.tag == 7) {
        _filter.block = textField.text;
    }else if (textField.tag == 8){
        _filter.unit_name = textField.text;
    }else{
        _filter.room_code = textField.text;
    }
}


- (MHTextField *)textFieldFromCell:(UITableViewCell *)cell
{
    MHTextField *textField = nil;
    for(UIView *subView in cell.contentView.subviews)
    {
        if ([subView isKindOfClass:[MHTextField class]])
        {
            textField = (MHTextField*)subView;
            break;
        }
    }

    if (textField == nil)
    {
        CGFloat xOffset = 15.0;
        textField = [[MHTextField alloc] initWithFrame:CGRectMake(xOffset, 0.0,
                cell.contentView.frame.size.width - xOffset - 15.0, 44.0)];
//        textField.hideToolBar = YES;
        textField.textColor = [EBStyle blackTextColor];
        textField.font = [UIFont systemFontOfSize:16.0f];
        textField.placeholderColor = [EBStyle grayTextColor];
        textField.delegate = self;
        textField.placeholder = NSLocalizedString(@"pl_input_community", nil);
        [textField setRequired:YES];
        [cell.contentView addSubview:textField];

        [self pushTextField:textField];
    }

    return textField;
}

- (void)updateCell:(UICollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath withIdentifier:(NSString *)identifier
{
    
    
    
    
    if (![cell.contentView viewWithTag:99])
    {
        UIView *view = [[UIView alloc] initWithFrame:cell.bounds];
        view.tag = 99;
        [cell.contentView addSubview:view];
        
        CGFloat xValue = 25.0;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xValue, 0.0,43.0f, 44.0f)];
        [titleLabel setTextColor:[EBStyle darkBlueTextColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.tag = 88;
        [view addSubview:titleLabel];
        
        if ([identifier isEqualToString:COLLECTION_CELL_LABEL_IDENTIFIER])
        {
            CGFloat xValue = 69.0;
            CGFloat rightMargin = 30.0;
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(xValue, 0.0,
                                                                            view.frame.size.width - xValue - rightMargin, 44.0f)];
            [valueLabel setTextColor:[EBStyle cellValueTextColor]];
            [valueLabel setFont:[UIFont systemFontOfSize:14.0f]];
            valueLabel.backgroundColor = [UIColor clearColor];
            [view addSubview:valueLabel];
            
            UIImageView *accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(view.frame.size.width - 30, 15.75, 8.0, 12.5)];
            [view addSubview:accessoryView];
        }
        else
        {
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(0.0f, 0.0f,0.0f, 0.0f)];
            CGRect frame = switchView.frame;
            frame.origin.x = view.frame.size.width - 13.0-frame.size.width;
            frame.origin.y = (view.frame.size.height - frame.size.height)/2;
            switchView.frame = frame;
            [switchView addTarget:self action:@selector(hasPhotoSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
            [view addSubview:switchView];
        }
    }
    UIView *contentView = [cell.contentView viewWithTag:99];
    
    NSInteger row = [indexPath row];
    NSDictionary *filter = _filters[row];
    NSInteger idx = [_filter choiceByIndex:row];
    if ([identifier isEqualToString:COLLECTION_CELL_LABEL_IDENTIFIER])
    {
        for (UIView *view in contentView.subviews)
        {
            if ([view isKindOfClass:[UILabel class]])
            {
                UILabel *label = (UILabel *)view;
                if (label.tag == 88)
                {
                    label.text = filter[@"title"];
                    
                    
                    
                    if ([self collectionView:_collectionView shouldSelectItemAtIndexPath:indexPath])
                    {
                        label.textColor = [EBStyle darkBlueTextColor];
                    }
                    else
                    {
                        label.textColor = [EBStyle grayTextColor];
                    }
                    
                    
                }
                else
                {
                    if (row == 0)
                    {
                        NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
                        NSString *title = district1[@"title"];
                        if (_filter.district2 > 0)
                        {
                            title = [title stringByAppendingFormat:@" %@", district1[@"children"][_filter.district2]];
                        }
                        label.text = title;
                    }
                    else
                    {
                        NSDictionary *valueDic = [_filter choicesByIndex:row][idx];
                        label.text = valueDic[@"title"];
                    }
                    
                    //处理颜色
                    if (row == 6) {
                        if (idx == 1)
                        {
                            label.textColor = [EBStyle grayTextColor];
                        }
                        else
                        {
                            label.textColor = [EBStyle cellValueTextColor];
                        }
                    }else{
                    
                        if (idx == 0)
                        {
                            label.textColor = [EBStyle grayTextColor];
                        }
                        else
                        {
                            label.textColor = [EBStyle cellValueTextColor];
                        }
                    }
                    
                    if (![self collectionView:_collectionView shouldSelectItemAtIndexPath:indexPath])
                    {
                        label.textColor = [EBStyle grayTextColor];
                    }
                }
            }
            else if ([view isKindOfClass:[UIImageView class]])
            {
                UIImageView *imageView = (UIImageView *)view;
                if ([self collectionView:_collectionView shouldSelectItemAtIndexPath:indexPath])
                {
                    imageView.image = [UIImage imageNamed:@"accessory_arrow_blue"];
                }
                else
                {
                    imageView.image = [UIImage imageNamed:@"accessory_arrow"];
                }
            }
        }
    }
    else
    {
        for (UIView *view in contentView.subviews)
        {
            if ([view isKindOfClass:[UILabel class]])
            {
                UILabel *label = (UILabel *)view;
                label.text = filter[@"title"];
            }
            else if ([view isKindOfClass:[UISwitch class]])
            {
                UISwitch *hasPhotoSwitch = (UISwitch *)view;
                [hasPhotoSwitch setOn:_filter.hasPhoto];
            }
        }
    }
}

#pragma mark - filter data
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
