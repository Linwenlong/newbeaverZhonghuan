//
//  CategoryDataSource.m
//  beaver
//
//  Created by 何 义 on 14-3-7.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "CategoryDataSource.h"
#import "EBHttpClient.h"
#import "EBHouseCategory.h"
#import "EBStyle.h"
#import "EBViewFactory.h"
#import "EBController.h"
#import "EBPreferences.h"
#import "EBFilter.h"
#import "UIImage+Alpha.h"
#import "EBCondition.h"
#import "CustomConditionViewController.h"
#import "HouseListViewController.h"
#import "EBAlert.h"
#import "GatherHouseListViewController.h"

@interface CategoryDataSource()
{
    NSMutableArray *_dataArray;
    NSInteger _customBoundary;
}
@end

@interface CategoryItemView : UIView

@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UILabel *detailLabel;
@property (nonatomic, readonly) UILabel *countLabel;
@property (nonatomic, readonly) UILabel *tagLabel;
@property (nonatomic, readonly) UIButton *bg;
@property (nonatomic, readonly) UIImageView *arrow;

@property (nonatomic, strong) EBHouseCategory *category;

@property(nonatomic, assign) ECategoryDataSourceType categoryType;

@end

@implementation CategoryDataSource

- (NSInteger)numberOfRows
{
    if (_dataArray.count > 0)
    {
        return _dataArray.count + (_categoryType == ECategoryDataSourceTypeGatherHouse ? 1 : 2);
    }
    else
    {
        return 1;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRow:(NSInteger)row
{

}

- (void)tableView:(UITableView *)tableView didSelectRow:(NSInteger)row
{

}

- (CGFloat)heightOfRow:(NSInteger)row
{
    if (row == 0)
    {
        return 40.0;
    }
    else if (row == _customBoundary + 1 && _categoryType == ECategoryDataSourceTypeHouse)
    {
//            return _customBoundary == 0 ? 26 : 28.5;
        return 26;
    }
    else
    {
//            return 85;
        NSInteger itemIndex = row > _customBoundary ? row - 2 : row - 1;
        EBHouseCategory *category = _dataArray[itemIndex];

        if (category.cellHeight <= 0.0)
        {
            CGSize contentSize = [EBViewFactory textSize:category.des
                                                    font:[UIFont systemFontOfSize:12] bounding:CGSizeMake([UIScreen mainScreen].bounds.size.width - 30 -70, 999)];

            category.cellHeight =  54 + contentSize.height;
        }

        return category.cellHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRow:(NSInteger)row
{
    UITableViewCell *cell;
    if (row == 0)
    {
        static NSString *cellIdentifier0 = @"cellIdentifier0";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier0];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 12.5, _categoryType == ECategoryDataSourceTypeGatherHouse ? 86 : 114, 27)];
            UIImage *addImage = [UIImage imageNamed:@"btn_add_green"];
            [btn setImage:addImage forState:UIControlStateNormal];
            [btn setImage:[addImage imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
            [btn setTitle:_categoryType == ECategoryDataSourceTypeGatherHouse ? NSLocalizedString(@"add_subscription", nil) : NSLocalizedString(@"category_add_custom", nil) forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
            [btn setTitleColor:[EBStyle lightGreenTextColor] forState:UIControlStateNormal];
            [btn setTitleColor:[EBStyle shallowLightGreenTextColor] forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(addCustomCondition:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 99;
            [cell addSubview:btn];
        }
        return cell;
    }

    if (row == _customBoundary + 1 && _categoryType == ECategoryDataSourceTypeHouse)
    {
        static NSString *cellIdentifier2 = @"cellIdentifier2";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 10, 300.0, 16.0)];
            label.tag = 99;
            label.font = [UIFont systemFontOfSize:14.0];
            label.textColor = [EBStyle grayTextColor];
            
            label.text = [NSString stringWithFormat:NSLocalizedString(@"category_nearby_format", nil), [EBPreferences sharedInstance].storeName];
            [cell addSubview:label];
        }

        return cell;
    }

    static NSString *cellIdentifier1 = @"cellIdentifier1";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
    CategoryItemView *itemView;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];

        itemView = [[CategoryItemView alloc] initWithFrame:CGRectZero];
        itemView.tag = 88;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addSubview:itemView];
    }
    else
    {
        itemView = (CategoryItemView *)[cell viewWithTag:88];
    }
    itemView.categoryType = _categoryType;

    NSInteger itemIndex = row > _customBoundary ? row - 2 : row - 1;
    itemView.category = _dataArray[itemIndex];

    return cell;
}

- (void)addCustomCondition:(UIButton *)btn
{
    if (_categoryType == ECategoryDataSourceTypeGatherHouse)
    {
        [EBTrack event:EVENT_CLICK_COLLECT_POST_SUBSCRIBE_ADD];
        if (_customBoundary >= 10)
        {
            [EBAlert alertWithTitle:nil message:NSLocalizedString(@"alert_max_subscription_account", nil) confirm:^
             {
                 
             }];
            return;
        }
        EBCondition *condition = [[EBCondition alloc] init];
        condition.filter = [[EBFilter alloc] init];
        [[EBController sharedInstance] showCustomCondition:condition customType:ECustomConditionViewTypeGatherHouse];
    }
    else if (_categoryType == ECategoryDataSourceTypeHouse)
    {
        if (_customBoundary >= 10)
        {
            [EBAlert alertWithTitle:nil message:NSLocalizedString(@"custom_condition_limit", nil) confirm:^
             {
                 
             }];
            return;
        }
        
        [EBTrack event:EVENT_CLICK_ADD_FEATURED_HOUSE_FILTER];
        EBCondition *condition = [[EBCondition alloc] init];
        condition.filter = [[EBFilter alloc] init];
        [[EBController sharedInstance] showCustomCondition:condition customType:ECustomConditionViewTypeHouse];
    }
}

- (void)refresh:(BOOL)force handler:(void (^)(BOOL success, id result))done
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"force_refresh"] = @(force);

    if (_categoryType == ECategoryDataSourceTypeGatherHouse)
    {
        [[EBHttpClient sharedInstance] gatherPublishRequest:params subscriptionList:^(BOOL success, id result)
        {
            if (success)
            {
                _dataArray = result;
                _customBoundary = _dataArray.count;
//                for (EBHouseCategory *category in _dataArray)
//                {
//                    category.isCustom = YES;
//                }
            }
            done(success, result);
        }];
    }
    else if (_categoryType == ECategoryDataSourceTypeHouse)
    {
        [[EBHttpClient sharedInstance] houseRequest:params specialCategory:^(BOOL success, id result)
         {
             if (success)
             {
                 _dataArray = result;
                 _customBoundary = 0;
                 for (EBHouseCategory *category in _dataArray)
                 {
                     if (!category.isCustom)
                     {
                         break;
                     }
                     _customBoundary++;
                 }
             }
             done(success, result);
         }];
    }
}

- (UIView *)emptyView:(CGRect)frame
{
    if (_categoryType == ECategoryDataSourceTypeGatherHouse)
    {
        UIImage *image = [UIImage imageNamed:@"loading_empty"];
        UIView *transitionView = [[UIView alloc] initWithFrame:frame];
        transitionView.backgroundColor = [UIColor whiteColor];
        
        CGRect tempFrame = CGRectMake(0, [EBStyle emptyOffsetYInListView], frame.size.width, image.size.height);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:tempFrame];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.image = image;
        [transitionView addSubview:imageView];
        
        tempFrame = CGRectOffset(tempFrame, 0, tempFrame.size.height + 5.0);
        UILabel *label = [[UILabel alloc] initWithFrame:tempFrame];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:[EBStyle grayTextColor]];
        [label setText:NSLocalizedString(@"empty_subscription", nil)];
        [label setFont:[UIFont systemFontOfSize:14.f]];
        label.numberOfLines = 2;
        [transitionView addSubview:label];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 12.5, 86, 27)];
        UIImage *addImage = [UIImage imageNamed:@"btn_add_green"];
        [btn setImage:addImage forState:UIControlStateNormal];
        [btn setImage:[addImage imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
        [btn setTitle:NSLocalizedString(@"add_subscription", nil) forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [btn setTitleColor:[EBStyle lightGreenTextColor] forState:UIControlStateNormal];
        [btn setTitleColor:[EBStyle shallowLightGreenTextColor] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(addCustomCondition:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 99;
        [transitionView addSubview:btn];
        
        return transitionView;
    }
    return nil;
}

@end

@interface CategoryItemView()
{
    UIImage *_bgCustomImage;
    UIImage *_bgCustomHighlightImage;
    UIImage *_bgImage;
    UIImage *_bgHighlightImage;
    UIImage *_arrowCustomImage;
    UIImage *_arrowImage;
}
@end

@implementation CategoryItemView

#define CATEGORY_ITEM_TAG_FRAME     CGRectMake(10.0, 11.0, 30.0, 18.0)
#define CATEGORY_ITEM_TITLE_FRAME1  CGRectMake(10.0, 10.0, [UIScreen mainScreen].bounds.size.width - 30 -10, 20.0)
#define CATEGORY_ITEM_TITLE_FRAME2  CGRectMake(43.0, 10.0, [UIScreen mainScreen].bounds.size.width - 30 -43, 20.0)
#define CATEGORY_ITEM_DETAIL_FRAME1 CGRectMake(12.0, 34.0, [UIScreen mainScreen].bounds.size.width - 30 -70, 35.0)
#define CATEGORY_ITEM_DETAIL_FRAME2 CGRectMake(10.0, 34.0, [UIScreen mainScreen].bounds.size.width - 30 -70, 35.0)
#define CATEGORY_ITEM_COUNT_FRAME   CGRectMake([UIScreen mainScreen].bounds.size.width - 30 - 16 -50, 34.0, 50.0, 14.0)
#define CATEGORY_ITEM_ARROW_FRAME   CGRectMake([UIScreen mainScreen].bounds.size.width - 30 - 16, 34.0, 8.0, 12.5)

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(15.0, 10.0, [UIScreen mainScreen].bounds.size.width - 30, 75.0)];
    if (self)
    {
       _bg = [[UIButton alloc] initWithFrame:self.bounds];
        
       [_bg addTarget:self action:@selector(categorySelected:) forControlEvents:UIControlEventTouchUpInside];
        _bgImage = [[UIImage imageNamed:@"bg_category"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
       _bgCustomImage = [[UIImage imageNamed:@"bg_category_custom"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
       _bgHighlightImage = [[UIImage imageNamed:@"bg_category_p"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
       _bgCustomHighlightImage = [[UIImage imageNamed:@"bg_category_custom_p"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];

       [self addSubview:_bg];
       [self sendSubviewToBack:_bg];

        _tagLabel = [[UILabel alloc] initWithFrame:CATEGORY_ITEM_TAG_FRAME];
        _tagLabel.backgroundColor = [UIColor clearColor];
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        _tagLabel.layer.borderWidth = 0.5;
        _tagLabel.font = [UIFont systemFontOfSize:13.0];
        [self addSubview:_tagLabel];
        _tagLabel.hidden = YES;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CATEGORY_ITEM_TITLE_FRAME1];
       _titleLabel.textColor = [EBStyle blueTextColor];
       _titleLabel.font = [UIFont systemFontOfSize:18.0];
       _titleLabel.backgroundColor = [UIColor clearColor];
       [self addSubview:_titleLabel];

       _detailLabel = [[UILabel alloc] initWithFrame:CATEGORY_ITEM_DETAIL_FRAME1];
       _detailLabel.textColor = [EBStyle blackTextColor];
       _detailLabel.backgroundColor = [UIColor clearColor];
//       _detailLabel.userInteractionEnabled = NO;

//        [EBDebug showFrame:_detailLabel];
       _detailLabel.numberOfLines = 0;
       _detailLabel.lineBreakMode = NSLineBreakByCharWrapping;
//       _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
       _detailLabel.font = [UIFont systemFontOfSize:12.0];

       [self addSubview:_detailLabel];

       _countLabel = [[UILabel alloc] initWithFrame:CATEGORY_ITEM_COUNT_FRAME];
       _countLabel.textColor = [EBStyle blueTextColor];
       _countLabel.textAlignment = NSTextAlignmentRight;
       _countLabel.font = [UIFont systemFontOfSize:16.0];
       _countLabel.backgroundColor = [UIColor clearColor];
       [self addSubview:_countLabel];

        _arrow = [[UIImageView alloc] initWithFrame:CATEGORY_ITEM_ARROW_FRAME];
        _arrowImage = [UIImage imageNamed:@"accessory_arrow_blue"];
        _arrowCustomImage = [UIImage imageNamed:@"accessory_arrow_custom"];
        _arrow.contentMode = UIViewContentModeCenter;
        [self addSubview:_arrow];

    }
    return self;
}

- (void)categorySelected:(UIButton *)btn
{
    if (_categoryType == ECategoryDataSourceTypeGatherHouse)
    {
        EBCondition *condition = [[EBCondition alloc] init];
        condition.title = _category.title;
        [condition parseValuesFrom:_category.condition];
        condition.id = _category.id;
        EBFilter *filter = condition.filter;
        filter.subscriptionId = _category.id;
        NSString *type = NSLocalizedString(@"rental_house_state_2", nil);
        if ([_category.condition[@"type"] isEqualToString:@"rent"])
        {
            type = NSLocalizedString(@"rental_house_state_1", nil);
        }
        GatherHouseListViewController *viewController =
        [[EBController sharedInstance] showGatherHouseListWithType:EGatherHouseListTypeSpecial filter:filter title:[NSString stringWithFormat:@"[%@] %@",type,_category.title]];
        viewController.condition = condition;
//        _category.count = @"0";
//        [self setNeedsLayout];
        return;
    }
    if (_category.isCustom)
    {
        EBCondition *condition = [[EBCondition alloc] init];
        condition.title = _category.title;
        [condition parseValuesFrom:_category.condition];
        HouseListViewController *viewController =
        [[EBController sharedInstance] showHouseListWithType:EHouseListTypeSpecialCustom filter:condition.filter title:_category.title client:nil];
        viewController.condition = condition;
    }
    else
    {
        EBFilter *filter = [[EBFilter alloc] init];
        filter.reservedCondition = _category.condition;
        [[EBController sharedInstance] showHouseListWithType:EHouseListTypeSpecial filter:filter title:_category.title client:nil];
    }
}

- (void)setCategory:(EBHouseCategory *)category
{
    _category = category;

    if (_category.cellHeight <= 0)
    {
        CGSize contentSize = [EBViewFactory textSize:category.des
                                                font:[UIFont systemFontOfSize:12] bounding:CGSizeMake([UIScreen mainScreen].bounds.size.width - 30 -70, 999)];

        _category.cellHeight =  54 + contentSize.height;
    }

//    CGRect frame = self.frame;
//    frame.size.height = _category.cellHeight - 10;

    self.frame = CGRectMake(15.0, 10.0, [UIScreen mainScreen].bounds.size.width - 30, _category.cellHeight - 10);

    _bg.frame = self.bounds;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_categoryType == ECategoryDataSourceTypeGatherHouse)
    {
        _titleLabel.frame = CATEGORY_ITEM_TITLE_FRAME2;
        _tagLabel.hidden = NO;
        _tagLabel.text = _category.condition[@"type"];
        if ([_category.condition[@"type"] isEqualToString:@"sale"])
        {
            _tagLabel.text = NSLocalizedString(@"rental_house_state_2", nil);
            _tagLabel.textColor = [UIColor colorWithRed:247./255.f green:72./255.f blue:61./255.f alpha:1.0];
            _tagLabel.layer.borderColor = [UIColor colorWithRed:247./255.f green:72./255.f blue:61./255.f alpha:1.0].CGColor;
        }
        else
        {
            _tagLabel.text = NSLocalizedString(@"rental_house_state_1", nil);
            _tagLabel.textColor = [UIColor colorWithRed:229./255.f green:71./255.f blue:254./255.f alpha:1.0];
            _tagLabel.layer.borderColor = [UIColor colorWithRed:229./255.f green:71./255.f blue:254./255.f alpha:1.0].CGColor;
        }
        if (_category.count.length == 0 || [_category.count isEqualToString:@"0"])
        {
            _countLabel.hidden = YES;
        }
        else
        {
            _countLabel.hidden = NO;
        }
    }
    else
    {
        _tagLabel.hidden = YES;
        _countLabel.hidden = NO;
    }
    _countLabel.text = _category.count;
    _titleLabel.text = _category.title;
    _detailLabel.text = _category.des;
    CGRect detailFrame = CATEGORY_ITEM_DETAIL_FRAME2;
    detailFrame.size.height = _category.cellHeight - 54;
    _detailLabel.frame = detailFrame;

    CGRect countFrame = _countLabel.frame;
    CGRect arrowFrame = _arrow.frame;

    countFrame.origin.y = (_category.cellHeight - 10 - _countLabel.frame.size.height) / 2;
    arrowFrame.origin.y = (_category.cellHeight - 10 - _arrow.frame.size.height) / 2;

    _countLabel.frame = countFrame;
    _arrow.frame = arrowFrame;

    if (_category.isCustom || _categoryType == ECategoryDataSourceTypeGatherHouse)
    {
        _arrow.image = _arrowCustomImage;
        _titleLabel.textColor = [EBStyle lightGreenTextColor];
        _countLabel.textColor = [EBStyle lightGreenTextColor];
        [_bg setBackgroundImage:_bgCustomImage forState:UIControlStateNormal];
        [_bg setBackgroundImage:_bgCustomHighlightImage forState:UIControlStateHighlighted];
    }
    else
    {
        _arrow.image = _arrowImage;
        _titleLabel.textColor = [EBStyle blueTextColor];
        _countLabel.textColor = [EBStyle blueTextColor];
        [_bg setBackgroundImage:_bgImage forState:UIControlStateNormal];
        [_bg setBackgroundImage:_bgHighlightImage forState:UIControlStateHighlighted];
    }
}

@end