//
//  PublishHouseItemView.m
//  beaver
//
//  Created by wangyuliang on 14-9-3.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "PublishHouseItemView.h"
#import "EBViewFactory.h"
#import "EBStyle.h"
#import "NSDate+TimeAgo.h"
#import "FSImageViewer.h"

@implementation PublishHouseItemView

#define PUBLISH_HOUSE_PHOTO_FRAME CGRectMake(15.0, 14.0, 64.0, 64.0)
#define PUBLISH_HOUSE_PORT_FRAME CGRectMake(85.0, 10.0, 100.0, 17.0)
#define PUBLISH_HOUSE_TIME_FRAME_RECORD CGRectMake(145.0, 10.0, 160.0, 17.0)
#define PUBLISH_HOUSE_TIME_FRAME_ORDER CGRectMake(145.0, 10.0, 170.0, 17.0)
#define PUBLISH_HOUSE_TITLE_FRAME CGRectMake(85.0, 30.0, 160.0, 34.0)
#define PUBLISH_HOUSE_CONTENT_FRAME CGRectMake(85.0, 68.0, 220.0, 17.0)
#define PUBLISH_HOUSE_ERROR_FRAME CGRectMake(85.0, 88.0, 220.0, 0.0)

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _photoView = [[UIImageView alloc] initWithFrame:PUBLISH_HOUSE_PHOTO_FRAME];
        _photoView.image = [UIImage imageNamed:@"pl_house"];
        [self addSubview:_photoView];
        
        _portView = [[UILabel alloc] initWithFrame:PUBLISH_HOUSE_PORT_FRAME];
        _portView.textColor = [EBStyle grayTextColor];
        _portView.font = [UIFont systemFontOfSize:12.0];
        _portView.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_portView];
        
        _timeView = [[UILabel alloc] initWithFrame:PUBLISH_HOUSE_TIME_FRAME_RECORD];
        _timeView.textColor = [EBStyle grayTextColor];
        _timeView.textAlignment = NSTextAlignmentRight;
        _timeView.font = [UIFont systemFontOfSize:12.0];
        [self addSubview:_timeView];
        
        _titleView = [[UILabel alloc] initWithFrame:PUBLISH_HOUSE_TITLE_FRAME];
        _titleView.textColor = [EBStyle blackTextColor];
        _titleView.numberOfLines = 2;
        _titleView.font = [UIFont boldSystemFontOfSize:14.0];
        [self addSubview:_titleView];
        
        _contentView = [[UILabel alloc] initWithFrame:PUBLISH_HOUSE_CONTENT_FRAME];
        _contentView.textColor = [EBStyle grayTextColor];
        _contentView.font = [UIFont systemFontOfSize:12.0];
        _contentView.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_contentView];
        
        CGFloat extend = 15;
        
        _refreshView = [[UIView alloc] init];
        UIImageView *refreshImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_refresh"]];
        _refreshView.frame = CGRectOffset(refreshImageView.frame, self.width - 15 - refreshImageView.frame.size.width, 30);
        _refreshView.frame = CGRectMake(_refreshView.frame.origin.x - extend, _refreshView.frame.origin.y - extend, _refreshView.frame.size.width + 2 * extend, _refreshView.frame.size.height + 2 * extend);
        refreshImageView.frame = CGRectOffset(refreshImageView.frame, extend, extend);
        _refreshView.backgroundColor = [UIColor clearColor];
        [_refreshView addSubview:refreshImageView];
        [self addSubview:_refreshView];
        _refreshView.userInteractionEnabled = YES;
        UITapGestureRecognizer *refreshTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refresh:)];
        refreshTapGes.numberOfTapsRequired = 1;
        [_refreshView addGestureRecognizer:refreshTapGes];
        
        _tipView = [[UIView alloc] init];
        UIImageView *tipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_warning"]];
        _tipView.frame = CGRectOffset(tipImageView.frame, self.width - 15 - tipImageView.frame.size.width, 30);
        _tipView.frame = CGRectMake(_tipView.frame.origin.x - extend, _tipView.frame.origin.y - extend, _tipView.frame.size.width + 2 * extend, _tipView.frame.size.height + 2 * extend);
        tipImageView.frame = CGRectOffset(tipImageView.frame, extend, extend);
        _tipView.backgroundColor = [UIColor clearColor];
        [_tipView addSubview:tipImageView];
        _tipView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tipTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tip:)];
        tipTapGes.numberOfTapsRequired = 1;
        [_tipView addGestureRecognizer:tipTapGes];
        [self addSubview:_tipView];
        
        _activeView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(_tipView.frame.origin.x + extend, _tipView.frame.origin.y + extend, tipImageView.frame.size.width, tipImageView.frame.size.height)];
//        _activeView.center = CGPointMake(_refreshView.frame.origin.x + _refreshView.frame.size.width / 2.0, _refreshView.frame.origin.y + _refreshView.frame.size.height / 2.0);
        _activeView.color = [UIColor grayColor];
        [self addSubview:_activeView];
        
        _errorView = [[UILabel alloc] initWithFrame:PUBLISH_HOUSE_ERROR_FRAME];
        _errorView.textColor = [UIColor colorWithRed:211/255.f green:68/255.f blue:68/255.f alpha:1.0];
//        _errorView.textColor = [UIColor colorWithRed:205/255.f green:68/255.f blue:68/255.f alpha:1.0];
        _errorView.font = [UIFont systemFontOfSize:12.0];
        _errorView.textAlignment = NSTextAlignmentLeft;
        _errorView.numberOfLines = 0;
        [self addSubview:_errorView];
        
        _line = [EBViewFactory tableViewSeparatorWithRowHeight:self.frame.size.height - 0.5 leftMargin:5.0];
        [self addSubview:_line];
    }
    return self;
}

- (void)setPublishHouse:(NSDictionary *)publishHouse
{
    _publishHouse  = publishHouse;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //!图片加载 pictures
    NSString *pictureUrlStr = nil;
    if (![_publishHouse[@"house"][@"cover"] isKindOfClass:[NSNull class]])
    {
        pictureUrlStr = _publishHouse[@"house"][@"cover"];
    }
    if (pictureUrlStr && pictureUrlStr.length > 0)
    {
        [[FSImageLoader sharedInstance] loadImageForURL:[NSURL URLWithString:pictureUrlStr] image:^(UIImage *image, NSError *error) {
            if (!error) {
                _photoView.image = image;
                image = nil;
            }
        }];
    }
    
    NSString *portName = nil;
    if (![_publishHouse[@"port_name"] isKindOfClass:[NSNull class]])
    {
        portName = _publishHouse[@"port_name"];
    }
    _portView.text = portName;
    
    NSString *title = nil;
    if (![_publishHouse[@"house"][@"title"] isKindOfClass:[NSNull class]])
    {
        title = _publishHouse[@"house"][@"title"];
    }
    _titleView.text = title;
    
    NSMutableArray *contentArray = [[NSMutableArray alloc] init];
    NSString *community = nil;
    if (![_publishHouse[@"house"][@"community"] isKindOfClass:[NSNull class]])
    {
        community = _publishHouse[@"house"][@"community"];
    }
    if (community && community.length > 0)
    {
        [contentArray addObject:community];
    }
    NSString *price = nil;
    if (![_publishHouse[@"house"][@"total_price"] isKindOfClass:[NSNull class]])
    {
        price = _publishHouse[@"house"][@"total_price"];
    }
    NSString *type = nil;
    if (![_publishHouse[@"type"] isKindOfClass:[NSNull class]])
    {
        type = _publishHouse[@"type"];
    }
    if (price > 0)
    {
        [contentArray addObject:[NSString stringWithFormat:([type isEqualToString:@"rent"] ? NSLocalizedString(@"gp_rent_price_format", nil) : NSLocalizedString(@"gp_sale_price_format", nil)),[self getFormatNumber:price]]];
    }
    NSString *area = nil;
    if (![_publishHouse[@"house"][@"area"] isKindOfClass:[NSNull class]])
    {
        area = _publishHouse[@"house"][@"area"];
    }
    if (area && area.length > 0)
    {
        [contentArray addObject:[NSString stringWithFormat:NSLocalizedString(@"gp_area_format", nil), [self getFormatNumber:area]]];
    }
    _contentView.text = [contentArray componentsJoinedByString:@"  "];
    
    if (_showItemType == EPublishHouseItemRecord)
    {
        if (![_publishHouse[@"update_time"] isKindOfClass:[NSNull class]])
        {
            NSString *time;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[_publishHouse[@"update_time"] intValue]];
            time = [date dateTimeAgo];
            _timeView.textColor = [EBStyle grayTextColor];
            _timeView.text = time;
        }
    }
    
    if (_showItemType == EPublishHouseItemRecord)
    {
        _timeView.frame = PUBLISH_HOUSE_TIME_FRAME_RECORD;
        if (_touchTag == 0)
        {
            _refreshView.hidden = YES;
            _tipView.hidden = YES;
            [_activeView startAnimating];
            _activeView.hidden = NO;
            _timeView.textColor = [EBStyle redTextColor];
            _timeView.text = NSLocalizedString(@"正在发布", nil);
        }
        else if(_touchTag == 1)
        {
            _refreshView.hidden = NO;
            _tipView.hidden = YES;
            [_activeView stopAnimating];
            _activeView.hidden = YES;
        }
        else if (_touchTag == 2)
        {
            _refreshView.hidden = YES;
            _tipView.hidden = NO;
            [_activeView stopAnimating];
            _activeView.hidden = YES;
        }
        else if (_touchTag == 3)
        {
            _refreshView.hidden = YES;
            _tipView.hidden = YES;
            [_activeView startAnimating];
            _activeView.hidden = NO;
        }
        if (_touchTag == 2)
        {
            NSString *error = NSLocalizedString(@"publish_record_fail_tip", nil);
            if (![_publishHouse[@"error_info"] isKindOfClass:[NSNull class]]) {
                NSString *temp = _publishHouse[@"error_info"];
                if (temp.length > 0)
                {
                    error = [NSString stringWithFormat:NSLocalizedString(@"publish_record_fail_tip_format", nil), _publishHouse[@"error_info"]];
                    //                    error = _publishHouse[@"error_info"];
                }
            }
            CGSize textSize = [EBViewFactory textSize:error font:[UIFont systemFontOfSize:12.0] bounding:CGSizeMake(220, 60)];
            CGFloat height = 36;
            if (textSize.height < 36)
            {
                height = textSize.height;
            }
            _errorView.frame = CGRectMake(_errorView.frame.origin.x, _errorView.frame.origin.y, _errorView.frame.size.width, height);
            _errorView.text = error;
        }
        else
        {
            _errorView.frame = CGRectMake(_errorView.frame.origin.x, _errorView.frame.origin.y, _errorView.frame.size.width, 0);
            _errorView.text = nil;
        }
    }
    else
    {
        _timeView.frame = PUBLISH_HOUSE_TIME_FRAME_ORDER;
        _refreshView.hidden = YES;
        _tipView.hidden = YES;
        [_activeView stopAnimating];
        _activeView.hidden = YES;
        _timeView.textColor = [EBStyle redTextColor];
        if (![_publishHouse[@"order_time"] isKindOfClass:[NSNull class]])
        {
            NSInteger time = [_publishHouse[@"order_time"] intValue];
            NSString *timeStr = [self transformDate:time];
            _timeView.text = timeStr;
        }
        
        _errorView.frame = CGRectMake(_errorView.frame.origin.x, _errorView.frame.origin.y, _errorView.frame.size.width, 0);
        _errorView.text = nil;
    }
    _line.frame = CGRectMake(_line.frame.origin.x, self.frame.size.height - 0.5, _line.frame.size.width, _line.frame.size.height);
}

- (void)refreshItemView
{
    if(_touchTag == 1)
    {
        _refreshView.hidden = NO;
        _tipView.hidden = YES;
        [_activeView stopAnimating];
        _activeView.hidden = YES;
        if (![_publishHouse[@"update_time"] isKindOfClass:[NSNull class]])
        {
            NSString *time;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[_publishHouse[@"update_time"] intValue]];
            time = [date dateTimeAgo];
            _timeView.textColor = [EBStyle grayTextColor];
            _timeView.text = time;
        }
    }
    else if (_touchTag == 2)
    {
        _refreshView.hidden = YES;
        _tipView.hidden = NO;
        [_activeView stopAnimating];
        _activeView.hidden = YES;
        if (![_publishHouse[@"update_time"] isKindOfClass:[NSNull class]])
        {
            NSString *time;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[_publishHouse[@"update_time"] intValue]];
            time = [date dateTimeAgo];
            _timeView.textColor = [EBStyle grayTextColor];
            _timeView.text = time;
        }
    }
    else if (_touchTag == 3)
    {
        _refreshView.hidden = YES;
        _tipView.hidden = YES;
        [_activeView startAnimating];
        _activeView.hidden = NO;
        _timeView.textColor = [EBStyle redTextColor];
        _timeView.text = NSLocalizedString(@"正在刷新中", nil);
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

#pragma mark - action
- (void)refresh:(UITapGestureRecognizer*)sender
{
    _touchTag = 3;
    [self refreshItemView];
    if (self.delegate)
    {
        [self.delegate refreshTouchTag:_row tag:_touchTag handlback:^(BOOL sucess)
        {
            _touchTag = 1;
            [self layoutSubviews];
        }];
        
    }
}

- (void)tip:(UITapGestureRecognizer*)sender
{
    if (self.delegate)
    {
        [self.delegate refreshTouchTag:_row tag:_touchTag handlback:nil];
    }
    [self refreshItemView];
//    _touchTag = 1;
}

- (NSString*)transformDate:(NSInteger)timeDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeDate];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    NSArray *array = [confromTimespStr componentsSeparatedByString:@" "];
    NSString *text = nil;
    if([array count] > 1)
    {
        NSArray *dateArray = [array[0] componentsSeparatedByString:@"-"];
        NSArray *timeArray = [array[1] componentsSeparatedByString:@":"];
        NSInteger month = [dateArray[1] intValue];
        NSInteger date = [dateArray[2] intValue];
        NSString *hour = timeArray[0];
        NSString *minute = timeArray[1];
        text = [NSString stringWithFormat:@"预约%ld月%ld日 %@:%@发布", month,date,hour,minute];
    }
    else
    {
        text = [NSString stringWithFormat:@"%ld", timeDate];
    }
    return text;
}


@end
