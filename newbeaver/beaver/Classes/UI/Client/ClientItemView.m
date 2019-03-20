//
//  ClientItemView.m
//  beaver
//
//  Created by wangyuliang on 14-5-20.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ClientItemView.h"
#import "EBAlert.h"

@implementation ClientItemView

#define CLIENT_ITEM_LEFT_FRAME  CGRectMake(15, 10, 200, 68.0)
#define CLIENT_ITEM_RIGHT_FRAME  CGRectMake([EBStyle screenWidth] - 105, 10, 90, 68.0)

#define CLIENT_ITEM_MARK_FRAME  CGRectMake(284, 0, 44, 84)

#define CLIENT_ITEM_LAST_NAME_FRAME CGRectMake(0.0, 8.0, 48, 48.0)
#define CLIENT_LAST_NAME_CONTENT_FRAME CGRectMake(0.0, 0.0, 48, 48.0)
#define CLIENT_ITEM_TITLE_FRAME CGRectMake(57.0, 0.0, 80, 16.0)

#define CLIENT_ITEM_DETAIL_FRAME CGRectMake(57.0, 20.0, 180, 55.0)
#define CLIENT_ITEM_TAG_Y_OFFSET_UNIT 17
#define CLIENT_ITEM_TITLE_IMAGE_GAP 3

#define CLIENT_ITEM_STATUS_FRAME CGRectMake(-33, 0.0, 123, 16.0)



- (id)initWithFrame:(CGRect)frame
{
//    self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 84.0)];
    self = [super initWithFrame:frame]; //! wyl
    if (self)
    {
        _leftPartView = [[UIView alloc] initWithFrame:CLIENT_ITEM_LEFT_FRAME];
        [self addSubview:_leftPartView];
        
        _lastNameLabel = [EBViewFactory lastNameLabel];
        _lastNameLabel.frame = CLIENT_LAST_NAME_CONTENT_FRAME;
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CLIENT_ITEM_LAST_NAME_FRAME];
        [btn addSubview:_lastNameLabel];
        [btn addTarget:self action:@selector(viewDetail:) forControlEvents:UIControlEventTouchUpInside];
        [_leftPartView addSubview:btn];
        
//        _rcmdIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rcmd_client"]];
//        _rcmdIcon.frame = CGRectOffset(_rcmdIcon.frame, 34, 8);
//        [_leftPartView addSubview:_rcmdIcon];
        
        _nameView = [[EBIconLabel alloc] initWithFrame:CLIENT_ITEM_TITLE_FRAME];
        _nameView.iconPosition = EIconPositionRight;
        _nameView.label.textColor = [EBStyle blackTextColor];
        _nameView.label.font = [UIFont boldSystemFontOfSize:14.0];
        [_leftPartView addSubview:_nameView];
        
        _detailLabel = [[RTLabel alloc] initWithFrame:CLIENT_ITEM_DETAIL_FRAME];
        _detailLabel.font = [UIFont systemFontOfSize:12.0];
        _detailLabel.textColor = [EBStyle blackTextColor];
        _detailLabel.textAlignment = RTTextAlignmentLeft;
        _detailLabel.lineSpacing = 0.0f;
        [_leftPartView addSubview:_detailLabel];
        
        _rightPartView = [[UIView alloc] initWithFrame:CLIENT_ITEM_RIGHT_FRAME];
        [self addSubview:_rightPartView];
        
        _statusLabel = [[UILabel alloc] initWithFrame:CLIENT_ITEM_STATUS_FRAME];
        _statusLabel.font = [UIFont systemFontOfSize:12.0];
        _statusLabel.textColor = [UIColor colorWithRed:138/255.0 green:151/255.0 blue:181.0/255 alpha:1.0];
        _statusLabel.textAlignment = NSTextAlignmentRight;
        [_rightPartView addSubview:_statusLabel];
        
        _tagAccess = [self tagImageView];
        _tagFullPaid = [self tagImageView];
        _tagFullPaid.image = [UIImage imageNamed:@"tag_price_full"];
        _tagRental = [self tagImageView];
        _tagUrgent = [self tagImageView];
        _tagUrgent.image = [UIImage imageNamed:@"tag_urgent"];
    }
    return self;
}


- (CGRect)firstTagFrame
{
    return CGRectMake(_rightPartView.frame.size.width - 31, 22, 31, 14);
}

- (UIImageView *)tagImageView
{
    UIImageView *tagImageView = [[UIImageView alloc] initWithFrame:[self firstTagFrame]];
    tagImageView.contentMode = UIViewContentModeRight;
    [_rightPartView addSubview:tagImageView];
    return tagImageView;
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
    
    _markView = [[UIButton alloc] initWithFrame:CGRectOffset(CLIENT_ITEM_MARK_FRAME,
                                                             rightFrame.origin.x - CLIENT_ITEM_RIGHT_FRAME.origin.x + 15, 0)];
    [_markView setImage:[UIImage imageNamed:@"star_unchecked"] forState:UIControlStateNormal];
    [_markView setImage:[UIImage imageNamed:@"star_checked"] forState:UIControlStateSelected];
    [_markView addTarget:self action:@selector(toggleCheck:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_markView];
    
    if (_clickView)
    {
        _clickView.frame = CGRectMake(_leftPartView.frame.origin.x, 0,
                                      _rightPartView.frame.size.width + _rightPartView.frame.origin.x - _leftPartView.frame.origin.x, 84);
    }
}

- (void)moveLocation
{
    CGRect rightFrame = _rightPartView.frame;
    rightFrame = CGRectOffset(rightFrame, -25, 0);
    _rightPartView.frame = rightFrame;
    
//    _markView = [[UIButton alloc] initWithFrame:CGRectOffset(CLIENT_ITEM_MARK_FRAME,
//                                                             rightFrame.origin.x - CLIENT_ITEM_RIGHT_FRAME.origin.x + 15, 0)];
//    [_markView setImage:[UIImage imageNamed:@"star_unchecked"] forState:UIControlStateNormal];
//    [_markView setImage:[UIImage imageNamed:@"star_checked"] forState:UIControlStateSelected];
//    [_markView addTarget:self action:@selector(toggleCheck:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:_markView];
//    
//    if (_clickView)
//    {
//        _clickView.frame = CGRectMake(_leftPartView.frame.origin.x, 0,
//                                      _rightPartView.frame.size.width + _rightPartView.frame.origin.x - _leftPartView.frame.origin.x, 84);
//    }
}

- (void)toggleCheck:(UIButton *)btn
{
    [[EBHttpClient sharedInstance] clientRequest:@{@"client_id":_client.id,
                                                   @"house_id":_targetHouseId, @"type": [EBFilter typeString:_client.rentalState]}
                                       markState:_client.marked toggleMark:^(BOOL success, id result)
     {
         if (success)
         {
//             _client.marked = !_client.marked;
             if (self.changeMarkedStausBlock)
             {
                 self.changeMarkedStausBlock(!_client.marked);
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
        _rightPartView.frame = CGRectOffset(rightFrame, -40, 0);
    }
    
    [self enableClickView];
}

- (void)setClient:(EBClient *)client
{
    _client  = client;
    [self setNeedsLayout];
}

- (void)layoutTagViews
{
    _tagAccess.image = [UIImage imageNamed:[NSString stringWithFormat:@"tag_access_%ld" ,_client.access]];
    
    CGFloat xOffset = 0;
    if (_client.fullPaid)
    {
        [self positionTag:_tagFullPaid];
        xOffset += _tagFullPaid.frame.size.width + CLIENT_ITEM_TITLE_IMAGE_GAP;
    }
    else
    {
        _tagFullPaid.hidden = YES;
    }
    
    if (_client.urgent)
    {
        [self positionTag:_tagUrgent];
        _tagUrgent.frame = CGRectOffset(_tagUrgent.frame, - xOffset, 0);
        xOffset += _tagUrgent.frame.size.width + CLIENT_ITEM_TITLE_IMAGE_GAP;
    }
    else
    {
        _tagUrgent.hidden = YES;
    }
    
    if (_client.rentalState == EClientRequireTypeRent)
    {
        _tagRental.image = [UIImage imageNamed:@"tag_rental_1"];
    }
    else if(_client.rentalState == EClientRequireTypeBoth)
    {
        _tagRental.image = [UIImage imageNamed:[NSString stringWithFormat:@"tag_rental_0%ld", _client.rentalState]];
    }
    [self positionTag:_tagRental];
    _tagRental.frame = CGRectOffset(_tagRental.frame, -xOffset, 0);
    
}

- (void)viewDetail:(UIButton *)btn
{
    if (_clickView == btn && self.clickBlock)
    {
        self.clickBlock(_client);
    }
    else
    {
        [[EBController sharedInstance] showClientDetail:_client];
    }
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

- (void)positionTag:(UIImageView *)tag
{
    tag.hidden = NO;
    tag.frame = CGRectMake(90 - tag.image.size.width, 22 +  CLIENT_ITEM_TAG_Y_OFFSET_UNIT,
                           tag.image.size.width, tag.image.size.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSString *priceFormat = _client.rentalState == EClientRequireTypeRent ?
    NSLocalizedString(@"rent_price_amount", nil) : NSLocalizedString(@"buy_price_amount", nil);
    NSString *priceInfo = [NSString stringWithFormat:priceFormat, [_client.priceRange[0] floatValue], [_client.priceRange[1] floatValue]];
    NSString *agentInfo;
    if (_client.delegationAgent.department && _client.delegationAgent.department.length) {
        agentInfo = [NSString stringWithFormat:@"%@-%@", _client.delegationAgent.department, _client.delegationAgent.name];
    }else{
        agentInfo = [NSString stringWithFormat:@"%@", _client.delegationAgent.name];
    }
    NSString *detailFormat = NSLocalizedString(@"client_require_format", nil);
    _detailLabel.text = [NSString stringWithFormat:detailFormat,
                         _client.roomRange[0], _client.roomRange[1], _client.areaRange[0], _client.areaRange[1],
                         _client.districts[0], priceInfo, agentInfo];
    
    _statusLabel.text = _client.status;
    _lastNameLabel.text = _client.name.length > 1 ? [_client.name substringToIndex:1] : _client.name;
    
    //    NSString *genderFormat = [NSString stringWithFormat:@"gender_format_%@", _client.gender];
    _nameView.label.text = _client.name;
    if (_client.collected)
    {
        _nameView.imageView.image = [UIImage imageNamed:@"tag_collected"];
        _nameView.gap = 3.0;
    }
    else
    {
        _nameView.imageView.image = nil;
        _nameView.gap = 0.0;
    }
    [_nameView setNeedsLayout];
    
    _markView.selected = _client.marked;
//    _rcmdIcon.hidden = !_client.recommended;
    [self layoutTagViews];
}

@end
