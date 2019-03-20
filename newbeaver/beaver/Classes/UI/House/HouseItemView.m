//
// Created by 何 义 on 14-5-27.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "HouseItemView.h"
#import "EBIconLabel.h"
#import "EBStyle.h"
#import "RTLabel.h"
#import "EBController.h"
#import "EBHouse.h"
#import "EBPrice.h"
#import "EBHttpClient.h"
#import "EBContact.h"
#import "UIImageView+WebCache.h"
#import "EBFilter.h"
#import "EBAlert.h"

@implementation HouseItemView

#define HOUSE_ITEM_LEFT_FRAME  CGRectMake(15, 10, 200, 64.0)
#define HOUSE_ITEM_RIGHT_FRAME  CGRectMake([EBStyle screenWidth]-95, 10, 90, 64.0)
#define HOUSE_ITEM_MARK_FRAME  CGRectMake(284, 0, 44, 84)

#define HOUSE_ITEM_IMAGE_FRAME CGRectMake(0.0, 0.0, 64, 64.0)
#define HOUSE_ITEM_TITLE_FRAME CGRectMake(73.0, 0.0, 160, 16.0)

#define HOUSE_ITEM_DETAIL_FRAME CGRectMake(73.0, 20.0, 180, 50.0)

- (CGRect)firstTagFrame
{
    return CGRectMake(_rightPartView.frame.size.width - 31, 22, 31, 14);
}

- (id)initWithFrame:(CGRect)frame
{
//    self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 84.0)];
    self = [super initWithFrame:frame];
    if (self)
    {
        _leftPartView = [[UIView alloc] initWithFrame:HOUSE_ITEM_LEFT_FRAME];
        [self addSubview:_leftPartView];

        _imageView = [[UIImageView alloc] initWithFrame:HOUSE_ITEM_IMAGE_FRAME];
//        _imageView.adjustsImageWhenHighlighted = NO;
        [_imageView setImage:[UIImage imageNamed:@"pl_house"]];
//        [_imageView addTarget:self action:@selector(viewDetail:) forControlEvents:UIControlEventTouchUpInside];
        [_leftPartView addSubview:_imageView];

//        _rcmdIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rcmd_house"]];
//        _rcmdIcon.frame = CGRectOffset(_rcmdIcon.frame, 53, -2);
//        [_leftPartView addSubview:_rcmdIcon];

        _titleView = [[EBIconLabel alloc] initWithFrame:HOUSE_ITEM_TITLE_FRAME];
        _titleView.iconPosition = EIconPositionRight;
        _titleView.label.textColor = [EBStyle blackTextColor];
        _titleView.label.font = [UIFont boldSystemFontOfSize:14.0];
        _titleView.label.numberOfLines = 1;
        [_leftPartView addSubview:_titleView];

        _detailLabel = [[RTLabel alloc] initWithFrame:HOUSE_ITEM_DETAIL_FRAME];
        _detailLabel.font = [UIFont systemFontOfSize:12.0];
        _detailLabel.textColor = [EBStyle blackTextColor];
        _detailLabel.textAlignment = RTTextAlignmentLeft;
        _detailLabel.lineSpacing = 1.0f;
        [_leftPartView addSubview:_detailLabel];

        _rightPartView = [[UIView alloc] initWithFrame:HOUSE_ITEM_RIGHT_FRAME];
        [self addSubview:_rightPartView];
        _rentPriceView = [[EBIconLabel alloc] initWithFrame:CGRectZero];
        _rentPriceView.label.font = [UIFont systemFontOfSize:12.0];
        [_rightPartView addSubview:_rentPriceView];

        _sellPriceView = [[EBIconLabel alloc] initWithFrame:CGRectZero];
        _sellPriceView.label.font = [UIFont systemFontOfSize:12.0];
        [_rightPartView addSubview:_sellPriceView];

        _tagNew = [self tagImageView];
        _tagAccess = [self tagImageView];
        _tagRental = [self tagImageView];
        _tagUrgent = [self tagImageView];
        _tagUrgent.image = [UIImage imageNamed:@"tag_urgent"];
        
        _showImage = YES;
    }
    return self;
}

- (void)changeSize
{
    CGRect rightFrame = _rightPartView.frame;
    rightFrame = CGRectOffset(rightFrame, -20, 0);
    _rightPartView.frame = rightFrame;
    [self enableClickView];
}

- (void)viewDetail:(UIButton *)btn
{
    [[EBController sharedInstance] showHouseDetail:_house];
}

- (UIImageView *)tagImageView
{
    UIImageView *tagImageView = [[UIImageView alloc] initWithFrame:[self firstTagFrame]];
    tagImageView.contentMode = UIViewContentModeRight;
    [_rightPartView addSubview:tagImageView];
    return tagImageView;
}

- (void)setHouse:(EBHouse *)house
{
    _house  = house;
    [self setNeedsLayout];
}

#define HOUSE_ITEM_TAG_Y_OFFSET_UNIT 17
#define HOUSE_ITEM_TITLE_IMAGE_GAP 3

- (void)layoutTagViews
{
    CGRect tagFrame = [self firstTagFrame];
    if (_house.new)
    {
        _tagNew.frame = tagFrame;
        _tagNew.image = [UIImage imageNamed:@"tag_new"];
        tagFrame = CGRectOffset(tagFrame, 0, HOUSE_ITEM_TAG_Y_OFFSET_UNIT);
        _tagNew.hidden = NO;
    }
    else
    {
        _tagNew.hidden = YES;
    }

    _tagAccess.frame = tagFrame;
    _tagAccess.image = [UIImage imageNamed:[NSString stringWithFormat:@"tag_access_%ld" ,_house.access]];
    tagFrame = CGRectOffset(tagFrame, 0, HOUSE_ITEM_TAG_Y_OFFSET_UNIT);

    _tagRental.frame = tagFrame;
    if(_house.rentalState != 2)
    {
        _tagRental.hidden = NO;
        _tagRental.image = [UIImage imageNamed:[NSString stringWithFormat:@"tag_rental_%ld", _house.rentalState]];
    }
    else
    {
        _tagRental.hidden = YES;
    }

    if (_house.urgent)
    {
        if (_tagNew.hidden)
        {
            tagFrame = CGRectOffset(tagFrame, 0, HOUSE_ITEM_TAG_Y_OFFSET_UNIT);
        }
        else
        {
            tagFrame = CGRectOffset(tagFrame, _tagRental.hidden ? 0 : -_tagRental.image.size.width - 3.0, 0);
        }
        _tagUrgent.frame = tagFrame;
        _tagUrgent.hidden = NO;
    }
    else
    {
        _tagUrgent.hidden = YES;
    }
}

- (void)layoutTitleAndPrice
{
    CGFloat rightFrameWidth = _rightPartView.frame.size.width;

    CGRect frame = CGRectZero;
    if (_house.rentalState & EHouseRentalTypeSale)
    {
        _sellPriceView.hidden = NO;
        [self updatePriceView:_sellPriceView withText:
                [NSString stringWithFormat:NSLocalizedString(@"sell_price_amount", nil),
                                           _house.sellPrice.amount] diff:_house.sellPrice.diff];
        frame = _sellPriceView.currentFrame;
        frame.origin.x = rightFrameWidth - frame.size.width;
        frame.origin.y = 0;
        _sellPriceView.frame = frame;
    }
    else
    {
        _sellPriceView.hidden = YES;
    }

    if (_house.rentalState & EHouseRentalTypeRent)
    {
        _rentPriceView.hidden = NO;
        [self updatePriceView:_rentPriceView withText:[NSString stringWithFormat:@"%@%@",
                                                                                 _house.rentPrice.amount, _house.rentPrice.unit] diff:_house.rentPrice.diff];
        CGFloat offsetX = frame.size.width;
        frame.origin.x = rightFrameWidth - _rentPriceView.currentFrame.size.width - offsetX - 5.0;
        frame.origin.y = 0.0;
        frame.size.width = _rentPriceView.currentFrame.size.width;
        frame.size.height = _rentPriceView.currentFrame.size.height;
        _rentPriceView.frame = frame;
    }
    else
    {
        _rentPriceView.hidden = YES;
    }

    _titleView.maxWidth = _leftPartView.frame.size.width + frame.origin.x - _titleView.frame.origin.x - 30;
    _titleView.label.text = _house.title;
    if (_house.collected)
    {
        _titleView.gap = HOUSE_ITEM_TITLE_IMAGE_GAP;
        _titleView.imageView.image = [UIImage imageNamed:@"tag_collected"];
    }
    else
    {
        _titleView.imageView.image = nil;
        _titleView.gap = 0;
    }

    [_titleView setNeedsLayout];
}

- (void)setMarking:(BOOL)marking
{
    _marking = marking;
    CGRect rightFrame = _rightPartView.frame;
    if (marking)
    {
        rightFrame = CGRectOffset(rightFrame, -15, 0);
        _rightPartView.frame = rightFrame;
    }

    _markView = [[UIButton alloc] initWithFrame:CGRectOffset(HOUSE_ITEM_MARK_FRAME,
            rightFrame.origin.x - HOUSE_ITEM_RIGHT_FRAME.origin.x + 15, 0)];
    [_markView setImage:[UIImage imageNamed:@"star_unchecked"] forState:UIControlStateNormal];
    [_markView setImage:[UIImage imageNamed:@"star_checked"] forState:UIControlStateSelected];
    [_markView addTarget:self action:@selector(toggleCheck:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_markView];

    [self enableClickView];
}

- (void)enableClickView
{
    if (!_clickView)
    {
        _clickView = [[UIButton alloc] init];
        [self addSubview:_clickView];
        [_clickView addTarget:self action:@selector(viewDetail:) forControlEvents:UIControlEventTouchUpInside];
    }

    _clickView.frame = CGRectMake(_leftPartView.frame.origin.x, 0,
            _rightPartView.frame.size.width + _rightPartView.frame.origin.x - _leftPartView.frame.origin.x, 84);
}

- (void)toggleCheck:(UIButton *)btn
{
    [[EBHttpClient sharedInstance] clientRequest:@{@"client_id":_targetClientId,
            @"house_id":_house.id, @"type": [EBFilter typeString:_house.rentalState]}
                                       markState:_house.marked toggleMark:^(BOOL success, id result)
    {
        if (success)
        {
//            _house.marked = !_house.marked;
            if (self.changeMarkedStausBlock)
            {
                self.changeMarkedStausBlock(!_house.marked);
            }
            btn.selected = !btn.selected;
            [EBAlert alertSuccess:btn.selected ? NSLocalizedString(@"btn_marked", nil) : NSLocalizedString(@"mark_canceled", nil)];
        }
    }];
}

- (void)setSelecting:(BOOL)selecting
{
    _selecting = selecting;
    CGRect leftFrame = _leftPartView.frame;
    CGRect rightFrame = _rightPartView.frame;
    if (selecting)
    {
        _leftPartView.frame = CGRectOffset(leftFrame, -10, 0);
        rightFrame = CGRectOffset(rightFrame, -40, 0);
        _rightPartView.frame = rightFrame;
    }

    [self enableClickView];
}

- (void)updatePriceView:(EBIconLabel *)priceView withText:(NSString*)text diff:(CGFloat)diff
{
    priceView.label.text = text;
    if (diff > 0)
    {
        priceView.label.textColor = [EBStyle redTextColor];
        priceView.imageView.image = [UIImage imageNamed:@"trend_up"];
    }
    else if (diff < 0)
    {
        priceView.label.textColor = [EBStyle greenTextColor];
        priceView.imageView.image = [UIImage imageNamed:@"trend_down"];
    }
    else
    {
        priceView.label.textColor = [EBStyle grayTextColor];
        priceView.imageView.image = nil;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.image = nil;
    if (_house.cover.length > 0)
    {
        NSURL *url = [[NSURL alloc] initWithString:_house.cover];
        [_imageView setImageWithURL:url  placeholderImage:[UIImage imageNamed:@"pl_house"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            image = nil;
            [[SDImageCache sharedImageCache] removeImageForKey:[url absoluteString] fromDisk:NO];
        }];
    }
    else
    {
        [_imageView setImage:[UIImage imageNamed:@"pl_house"]];
    }
    _markView.selected = _house.marked;
    NSString *detailFormat = @"<font>%@</font>\r\n<font>%@</font>\r\n<font color='#a8a9aa'>%@</font>";
    NSString *agentInfo;
    if (_house.delegationAgent.department && _house.delegationAgent.department.length) {
        agentInfo = [NSString stringWithFormat:@"%@-%@", _house.delegationAgent.department, _house.delegationAgent.name];
    }else{
        agentInfo = [NSString stringWithFormat:@"%@", _house.delegationAgent.name];
    }
    if (_house.purpose == EHousePurposeTypeWorkshop ||_house.purpose == EHousePurposeTypeLand ||_house.purpose == EHousePurposeTypeCarport || _house.purpose == EHousePurposeTypeOfficeBuilding || _house.purpose == EHousePurposeTypeShop) {
        _detailLabel.text = [NSString stringWithFormat:detailFormat, _house.contractCode,
                             [NSString stringWithFormat:NSLocalizedString(@"house_detail_format1", nil), _house.area ], agentInfo];
    }else
        _detailLabel.text = [NSString stringWithFormat:detailFormat, _house.contractCode,
                                                   [NSString stringWithFormat:NSLocalizedString(@"house_detail_format", nil), _house.room, _house.hall, _house.area ], agentInfo];
    [self layoutTitleAndPrice];
    [self layoutTagViews];

//    _rcmdIcon.hidden = !_house.recommended;
}
@end
