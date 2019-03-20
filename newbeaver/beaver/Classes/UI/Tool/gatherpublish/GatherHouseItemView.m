//
//  GatherHouseItemView.m
//  beaver
//
//  Created by ChenYing on 14-8-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "GatherHouseItemView.h"
#import "EBIconLabel.h"
#import "EBStyle.h"
#import "RTLabel.h"
#import "EBViewFactory.h"
#import "EBGatherHouse.h"
#import "UIImage+Alpha.h"
#import "EBTimeFormatter.h"
#import "NSDate+TimeAgo.h"
#import "EBController.h"
#import "EBAlert.h"
#import "GatherHouseDetailViewController.h"

@interface GatherHouseItemView()
{
    UIView *_numberView;
}
@end

@implementation GatherHouseItemView

#define GATHER_HOUSE_ITEM_HEADER_FRAME CGRectMake(15.0, 10.0, 290.0, 16.0)
#define GATHER_HOUSE_ITEM_TITLE_FRAME CGRectMake(15.0, 28.0, 240.0, 34.0)
#define GATHER_HOUSE_ITEM_ICON_LABEL_FRAME CGRectMake(0.0, 0.0, 0.0, 16.0)

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _titleView = [[UILabel alloc] initWithFrame:GATHER_HOUSE_ITEM_TITLE_FRAME];
        _titleView.textColor = [EBStyle blackTextColor];
        _titleView.font = [UIFont boldSystemFontOfSize:14.0];
        _titleView.numberOfLines = 2;
        [self addSubview:_titleView];
        
        _headerLabel = [[EBIconLabel alloc] initWithFrame:GATHER_HOUSE_ITEM_HEADER_FRAME];
        _headerLabel.label.font = [UIFont systemFontOfSize:12.0];
        _headerLabel.label.textColor = [EBStyle grayTextColor];
        _headerLabel.label.textAlignment = RTTextAlignmentLeft;
        _headerLabel.label.numberOfLines = 1;
        _headerLabel.iconPosition = EIconPositionRight;
        _headerLabel.maxWidth = 290.0;
        [self addSubview:_headerLabel];
        
        _footerLabel = [[RTLabel alloc] initWithFrame:CGRectMake(15.0, self.frame.size.height - 8.0 - 16.0 - 18.0, 240, 18.0)];
        _footerLabel.font = [UIFont systemFontOfSize:12.0];
        _footerLabel.textColor = [EBStyle blackTextColor];
        _footerLabel.textAlignment = RTTextAlignmentLeft;
        _footerLabel.lineSpacing = 0.0f;
        [self addSubview:_footerLabel];
        
        _numberView = [[UIView alloc] initWithFrame:CGRectMake(15.0, self.frame.size.height - 8.0 - 16.0, 290.0, 16.0)];
        _numberView.backgroundColor = [UIColor clearColor];
        
        _clickLabel = [[EBIconLabel alloc] initWithFrame:GATHER_HOUSE_ITEM_ICON_LABEL_FRAME];
        _clickLabel.label.font = [UIFont systemFontOfSize:12.0];
        _clickLabel.label.textColor = [UIColor colorWithRed:150.0/255.0 green:168.0/255.0 blue:195.0/255.0 alpha:1.0];
        _clickLabel.label.textAlignment = RTTextAlignmentLeft;
        _clickLabel.label.numberOfLines = 1;
        _clickLabel.iconPosition = EIconPositionLeft;
        _clickLabel.gap = 1.0;
        _clickLabel.imageView.image = [UIImage imageNamed:@"icon_click"];
        [_numberView addSubview:_clickLabel];
        
        _reportLabel = [[EBIconLabel alloc] initWithFrame:GATHER_HOUSE_ITEM_ICON_LABEL_FRAME];
        _reportLabel.label.font = [UIFont systemFontOfSize:12.0];
        _reportLabel.label.textColor = [UIColor colorWithRed:150.0/255.0 green:168.0/255.0 blue:195.0/255.0 alpha:1.0];
        _reportLabel.label.textAlignment = RTTextAlignmentLeft;
        _reportLabel.label.numberOfLines = 1;
        _reportLabel.iconPosition = EIconPositionLeft;
        _reportLabel.gap = 1.0;
        _reportLabel.imageView.image = [UIImage imageNamed:@"icon_report"];
        [_numberView addSubview:_reportLabel];
        
        _gatherLabel = [[EBIconLabel alloc] initWithFrame:GATHER_HOUSE_ITEM_ICON_LABEL_FRAME];
        _gatherLabel.label.font = [UIFont systemFontOfSize:12.0];
        _gatherLabel.label.textColor = [UIColor colorWithRed:150.0/255.0 green:168.0/255.0 blue:195.0/255.0 alpha:1.0];
        _gatherLabel.label.textAlignment = RTTextAlignmentLeft;
        _gatherLabel.label.numberOfLines = 1;
        _gatherLabel.iconPosition = EIconPositionLeft;
        _gatherLabel.gap = 1.0;
        _gatherLabel.imageView.image = [UIImage imageNamed:@"icon_gather"];
        [_numberView addSubview:_gatherLabel];
        [self addSubview:_numberView];
        
        _phoneButton = [EBViewFactory blueButtonWithFrame:CGRectMake([EBStyle screenWidth]-44.0f, (frame.size.height - 34.0) / 2, 34.0, 34.0) title:nil target:self action:@selector(phoneButtonClicked:)];
        UIImage *image = [UIImage imageNamed:@"btn_phone"];
        [_phoneButton setImage:image forState:UIControlStateNormal];
        [_phoneButton setImage:[image imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
        [self addSubview:_phoneButton];
        
        _tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(277.0, _phoneButton.frame.origin.y + _phoneButton.frame.size.height + 10.0, 26.0, 14.0)];
        _tagLabel.backgroundColor = [UIColor clearColor];
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        _tagLabel.layer.borderWidth = 0.5;
        _tagLabel.font = [UIFont systemFontOfSize:11.0];
        [self addSubview:_tagLabel];
        _tagLabel.hidden = YES;
    }
    return self;
}

- (void)phoneButtonClicked:(id *)sender
{
    if (_house.tel_type == EGatherHouseTelTypeImage)
    {
        GatherHouseDetailViewController *viewController = [[EBController sharedInstance] showGatherHouseDetail:_house];
        viewController.openPhoneSet = YES;
    }
    else
    {
        NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"tel:%@",_house.owner_tel];
        UIWebView *callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self addSubview:callWebview];
    }
}

- (void)setHouse:(EBGatherHouse *)house
{
    _house  = house;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    NSMutableArray *detailArray = [[NSMutableArray alloc] init];
    if (_house.port_name.length > 0)
    {
        [detailArray addObject:_house.port_name];
    }
    if (_house.owner_name.length > 0)
    {
        [detailArray addObject:_house.owner_name];
    }
    if (_house.create_time > 0)
    {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:_house.create_time];
        [detailArray addObject:[date dateTimeAgo]];
    }
    NSString *detail = [detailArray componentsJoinedByString:@"  "];
    _headerLabel.label.text = detail;
    [_headerLabel setNeedsLayout];
    if (_house.bookmarked)
    {
        _headerLabel.gap = 3.0;
        _headerLabel.imageView.image = [UIImage imageNamed:@"bookmark"];
    }
    else
    {
        _headerLabel.imageView.image = nil;
        _headerLabel.gap = 0;
    }
    CGFloat yOffset;
    CGRect frame = _titleView.frame;
    CGSize size = [EBViewFactory textSize:_house.title font:[UIFont boldSystemFontOfSize:14.0] bounding:CGSizeMake(240, 34)];
    frame.size.height = size.height;
    _titleView.frame = frame;
    _titleView.text = _house.title;
    yOffset = frame.origin.y + frame.size.height + 2;
    detailArray = [[NSMutableArray alloc] init];
    if (_house.community.length > 0)
    {
        NSMutableString *community = [[NSMutableString alloc] initWithString:_house.community];
       
        if (_house.community.length > 12)
        {
            community = [[NSMutableString alloc] initWithString:[community substringToIndex:12]];
            [community replaceCharactersInRange:NSMakeRange(community.length - 1, 1) withString:@"..."];
        }
        [detailArray addObject:community];
    }
    if (_house.total_price.length > 0)
    {
        [detailArray addObject:[NSString stringWithFormat:@"<font color='#ff0000'>%@</font>",[NSString stringWithFormat:(_house.type == EGatherHouseRentalTypeRent ? NSLocalizedString(@"gp_rent_price_format", nil) : NSLocalizedString(@"gp_sale_price_format", nil)),[self getFormatNumber:_house.total_price]]]];
    }
    if (_house.area.length > 0)
    {
        [detailArray addObject:[NSString stringWithFormat:NSLocalizedString(@"gp_area_format", nil), [self getFormatNumber:_house.area]]];
    }
    detail = [detailArray componentsJoinedByString:@"  "];
    _footerLabel.text = detail;
    
    CGFloat xOffset = 0.0;
    frame = _clickLabel.frame;
    CGFloat width = [EBViewFactory textSize:[NSString stringWithFormat:NSLocalizedString(@"gp_click_number_format", nil), _house.view_count] font:[UIFont systemFontOfSize:12.0] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
    frame.origin.x = xOffset;
    frame.size.width = width + 1.0 + 13.0;
    xOffset += frame.size.width + 15.0;
    _clickLabel.frame = frame;
    _clickLabel.label.text = [NSString stringWithFormat:NSLocalizedString(@"gp_click_number_format", nil), _house.view_count];
    
    width = [EBViewFactory textSize:[NSString stringWithFormat:NSLocalizedString(@"gp_report_number_format", nil), _house.report_count] font:[UIFont systemFontOfSize:12.0] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
    frame = _reportLabel.frame;
    frame.origin.x = xOffset;
    frame.size.width = width + 1.0 + 13.0;
    xOffset += frame.size.width + 15.0;
    _reportLabel.frame = frame;
    _reportLabel.label.text = [NSString stringWithFormat:NSLocalizedString(@"gp_report_number_format", nil), _house.report_count];
  
    width = [EBViewFactory textSize:[NSString stringWithFormat:NSLocalizedString(@"gp_gather_number_format", nil), _house.to_erp_count] font:[UIFont systemFontOfSize:12.0] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
    frame = _gatherLabel.frame;
    frame.origin.x = xOffset;
    frame.size.width = width + 1.0 + 13.0;
    xOffset += frame.size.width + 15.0;
    _gatherLabel.frame = frame;
    _gatherLabel.label.text = [NSString stringWithFormat:NSLocalizedString(@"gp_gather_number_format", nil), _house.to_erp_count];
    _phoneButton.hidden = _house.tel_type == EGatherHouseTelTypeMosaic;
    if (_showHouseType)
    {
        _tagLabel.hidden = NO;
        NSString *key = [NSString stringWithFormat:@"rental_house_state_%ld", _house.type];
        _tagLabel.text = NSLocalizedString(key, nil);
        if (_house.type == EGatherHouseRentalTypeSale)
        {
            _tagLabel.textColor = [UIColor colorWithRed:247./255.f green:72./255.f blue:61./255.f alpha:1.0];
            _tagLabel.layer.borderColor = [UIColor colorWithRed:247./255.f green:72./255.f blue:61./255.f alpha:1.0].CGColor;
        }
        else
        {
            _tagLabel.textColor = [UIColor colorWithRed:229./255.f green:71./255.f blue:254./255.f alpha:1.0];
            _tagLabel.layer.borderColor = [UIColor colorWithRed:229./255.f green:71./255.f blue:254./255.f alpha:1.0].CGColor;
        }
    }
    else
    {
        _tagLabel.hidden = YES;
    }
}

- (NSString *)getFormatNumber:(NSString *)number
{
    if (number.floatValue != HUGE_VAL && number.floatValue != -HUGE_VAL)
    {
        if ((NSInteger)(number.floatValue *100) % 100 == 0)
        {
            return [NSString stringWithFormat:@"%ld", number.integerValue];
        }
    }
    return number;
}

@end
