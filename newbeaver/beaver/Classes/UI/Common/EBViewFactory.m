//
//  WidgetFactory.m
//  beaver
//
//  Created by 何 义 on 14-2-28.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBViewFactory.h"
#import "EBStyle.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Alpha.h"
#import "QRCodeEncoder.h"
#import "EBPhoneButton.h"
#import "EBCache.h"
#import "EBCompatibility.h"
#import "EBHouse.h"
#import "EBClient.h"
#import "NIAttributedLabel.h"
#import "LWLScrollView.h"

@implementation EBViewFactory

+ (UIButton *)blueButtonWithFrame:(CGRect)frame title:(NSString *)title target:(id)target action:(SEL)selector
{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    UIImage *bgN = [[UIImage imageNamed:@"btn_blue_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 10, 15, 10)];
    UIImage *bgP = [[UIImage imageNamed:@"btn_blue_pressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 10, 15, 10)];
    UIImage *bgD = [[UIImage imageNamed:@"btn_disabled"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 10, 15, 10)];
    
    [btn setBackgroundImage:bgN forState:UIControlStateNormal];
    [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
    [btn setBackgroundImage:bgD forState:UIControlStateDisabled];

    btn.adjustsImageWhenHighlighted = NO;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
    [btn setTitleColor:AppMainColor(0.4) forState:UIControlStateDisabled];
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];

    return btn;
}

+ (UIButton *)countButtonWithFrame:(CGRect)frame title:(NSString *)title target:(id)target action:(SEL)action
{
    UIButton *btn = [EBViewFactory blueButtonWithFrame:frame title:nil target:target action:action];

    UILabel *counterLabel = [[UILabel alloc] init];
    counterLabel.textColor = [UIColor whiteColor];
    counterLabel.layer.cornerRadius = 9.0f;
    if ([EBCompatibility isIOS7Higher])
    {
        counterLabel.layer.backgroundColor = [EBStyle darkBlueTextColor].CGColor;
    }
    else
    {
        counterLabel.backgroundColor = [EBStyle darkBlueTextColor];
    }

    counterLabel.textAlignment = NSTextAlignmentCenter;
    counterLabel.font = [UIFont systemFontOfSize:12.0];
    counterLabel.tag = -1;
    counterLabel.text = @"0";
    [btn addSubview:counterLabel];

    UIFont *font = [UIFont systemFontOfSize:14.0];
    CGSize titleSize = [EBViewFactory textSize:title font:font bounding:CGSizeMake(999, 999)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, titleSize.width, 18)];
    titleLabel.textColor = [EBStyle blueTextColor];
    titleLabel.text = title;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = font;
    titleLabel.tag = -2;
    [btn addSubview:titleLabel];

    return btn;
}

+ (void)updateCountButton:(UIButton *)btn count:(NSInteger)count
{
    UILabel *counterLabel = (UILabel *)[btn viewWithTag:-1];
    UILabel *titleLabel = (UILabel *)[btn viewWithTag:-2];

    CGSize counterSize;
    if (count == 0)
    {
        [btn setEnabled:NO];
        counterSize = CGSizeMake(-10, 18);
        counterLabel.hidden = YES;
        titleLabel.textColor = [btn titleColorForState:UIControlStateDisabled];
    }
    else
    {
        [btn setEnabled:YES];
        counterLabel.hidden = NO;
        counterLabel.text = [NSString stringWithFormat:@"%ld", count];
        counterSize = [EBViewFactory textSize:counterLabel.text font:counterLabel.font bounding:CGSizeMake(999, 999)];
        if (counterSize.width < 18.0)
        {
            counterSize.width = 18.0;
        }
        titleLabel.textColor = [btn titleColorForState:UIControlStateNormal];
    }

    CGSize titleSize = titleLabel.frame.size;

    CGFloat xOffset = ([EBStyle screenWidth]-40 - counterSize.width - titleSize.width - 10) / 2;
    counterLabel.frame = CGRectMake(xOffset, 9, counterSize.width, 18);
    xOffset += counterSize.width + 10;
    titleLabel.frame = CGRectMake(xOffset, 9, titleSize.width, 18);
}

+ (UIButton *)redButtonWithFrame:(CGRect)frame title:(NSString *)title target:(id)target action:(SEL)selector
{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    UIImage *bgN = [[UIImage imageNamed:@"btn_red_n"] stretchableImageWithLeftCapWidth:6 topCapHeight:1];
    UIImage *bgP = [[UIImage imageNamed:@"btn_red_p"] stretchableImageWithLeftCapWidth:6 topCapHeight:1];
    UIImage *bgD = [[UIImage imageNamed:@"btn_disabled"] stretchableImageWithLeftCapWidth:6 topCapHeight:1];
    [btn setBackgroundImage:bgN forState:UIControlStateNormal];
    [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
    [btn setBackgroundImage:bgD forState:UIControlStateDisabled];

    btn.adjustsImageWhenHighlighted = NO;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[EBStyle redTextColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRed:255/255.f green:69/255.f blue:0/255.f alpha:0.4] forState:UIControlStateDisabled];
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];

    return btn;
}

+ (UIButton *)lightGreenButtonWithFrame:(CGRect)frame title:(NSString *)title target:(id)target action:(SEL)selector
{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    UIImage *bgN = [[UIImage imageNamed:@"btn_green_normal"] stretchableImageWithLeftCapWidth:6 topCapHeight:1];
    UIImage *bgP = [[UIImage imageNamed:@"btn_green_pressed"] stretchableImageWithLeftCapWidth:6 topCapHeight:1];
    [btn setBackgroundImage:bgN forState:UIControlStateNormal];
    [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
    btn.adjustsImageWhenHighlighted = NO;

    [btn titleLabel].font = [UIFont systemFontOfSize:14.0];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[EBStyle lightGreenTextColor] forState:UIControlStateNormal];
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];

    return btn;
}

+ (UIView *)tableViewSeparatorWithRowHeight:(CGFloat)height leftMargin:(CGFloat)leftMargin
{
    CGFloat lineHeight = [EBStyle separatorLineHeight];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, height - lineHeight, [EBStyle screenWidth], lineHeight)];
    line.backgroundColor = [EBStyle grayUnClickLineColor];
    line.tag = -87;

    return line;
}

+ (UIView *)tableViewSeparatorWithRowHeight:(CGFloat)height width:(CGFloat)width leftMargin:(CGFloat)leftMargin
{
    CGFloat lineHeight = [EBStyle separatorLineHeight];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, height - lineHeight, width, lineHeight)];
    line.backgroundColor = [EBStyle grayUnClickLineColor];
    line.tag = -87;
    
    return line;
}

+ (void)view:(UIView *)view setSeparatorHidden:(BOOL)hidden
{
    [view viewWithTag:-87].hidden = hidden;
}

+ (UIView *)defaultTableViewSeparator
{
    return [EBViewFactory tableViewSeparatorWithRowHeight:44.0f leftMargin:[EBStyle separatorLeftMargin]];
}

+ (UILabel *)valueViewFromCell:(UITableViewCell *)cell accessory:(BOOL)accessory
{
    UILabel *valueView = (UILabel *)[cell.contentView viewWithTag:99];
    if (valueView == nil)
    {
        CGFloat xValue = 115.0;
        CGFloat rightMargin = accessory ? 30.0 : 20.0;
        valueView = [[UILabel alloc] initWithFrame:CGRectMake(xValue, 0.0,
                cell.contentView.frame.size.width - xValue - rightMargin, 44.0f)];
//        [valueView setTextAlignment:NSTextAlignmentRight];
        [valueView setTextColor:[EBStyle blueMainColor]];
        [valueView setFont:[UIFont systemFontOfSize:14.0f]];
        valueView.tag = 99;
        [cell.contentView addSubview:valueView];
        valueView.backgroundColor = [UIColor clearColor];
    }

    return valueView;
}

+ (UIScrollView *)pagerScrollView:(BOOL)inTab
{
    CGRect viewFrame = [EBStyle fullScrTableFrame:inTab];
    CGFloat pagerHeight = [EBStyle viewPagerHeight];
    viewFrame.origin.y = pagerHeight;
    viewFrame.size.height -= pagerHeight;

    LWLScrollView *scrollView = [[LWLScrollView alloc] initWithFrame:viewFrame];
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.showsHorizontalScrollIndicator = NO;

    return scrollView;
}

+ (UIRefreshControl *)refreshControlForTableView:(UITableView *)tableView
{
    UITableViewController *controller = [[UITableViewController alloc] init];
    controller.tableView = tableView;

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    controller.refreshControl = refreshControl;
    return refreshControl;
}

+ (UIImageView *)imageViewWithFrame:(CGRect)frame url:(NSString *)url
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    [imageView setImageWithURL:[[NSURL alloc] initWithString:url] placeholderImage:nil];
    return imageView;
}

+ (CGSize)textSize:(NSString *)text font:(UIFont *)font bounding:(CGSize)size
{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_0)
    {
        CGRect rect = [text boundingRectWithSize:size
                                         options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                      attributes:@{NSFontAttributeName : font} context:nil];

//        CGRect stringRect = [txt boundingRectWithSize:CGSizeMake(maxWidth, maxHeight)
//                                              options:NSStringDrawingUsesLineFragmentOrigin
//                                           attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14] }
//                                              context:nil];

        return CGRectIntegral(rect).size;
    }
    else
    {
        return [text sizeWithFont:font
                     constrainedToSize:size];
    }
}

+ (UILabel *)lastNameLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];

    label.layer.borderColor = [EBStyle grayTextColor].CGColor;
    label.layer.borderWidth = 1.f;
    label.layer.cornerRadius = 24.0f;
    label.layer.masksToBounds = YES;

    label.backgroundColor = [UIColor whiteColor];

    label.textColor = [EBStyle blackTextColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:30.0];

    return label;
}

+ (UIImageView *)avatarImageView:(CGFloat)size
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size, size)];

    imageView.contentMode = UIViewContentModeScaleAspectFill;
//    imageView.layer.borderColor = [EBStyle grayUnClickLineColor].CGColor;
//    imageView.layer.borderWidth = 1.0;
    imageView.layer.cornerRadius = size / 2;
    imageView.layer.masksToBounds = YES;

    return imageView;
}

+ (UIButton *)avatarImageButton:(CGFloat)size
{
    UIButton *imageView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size, size)];

//    imageView.contentMode = UIViewContentModeCenter;
//    imageView.layer.borderWidth = 1.0;
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = size / 2;
    imageView.layer.masksToBounds = YES;

    return imageView;
}

+ (UIButton *)accessPhoneNumberBtn:(NSInteger)remainTimes  isHouse:(BOOL)isHouse
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, [EBStyle screenWidth]-30, 57)];
    UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
    UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
    [btn setBackgroundImage:bgN forState:UIControlStateNormal];
    [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];

    btn.adjustsImageWhenHighlighted = NO;
    [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];

    if (remainTimes >= 0)
    {
//        EBIconLabel *iconLabel = [[EBIconLabel alloc] init];
//        iconLabel.imageView.image = [UIImage imageNamed:@"icon_phone"];
//        iconLabel.iconPosition = EIconPositionLeft;
//        iconLabel.gap = 5;
//        iconLabel.iconVerticalCenter = YES;
//        iconLabel.label.textColor = [EBStyle blueTextColor];
//        iconLabel.label.font = [UIFont systemFontOfSize:16.0];
//        iconLabel.label.text = NSLocalizedString(@"view_phone", nil);
//        CGRect frame = iconLabel.currentFrame;
//        iconLabel.frame = CGRectOffset(frame, 150 - frame.size.width / 2, 8);
//        iconLabel.userInteractionEnabled = NO;
//        [btn addSubview:iconLabel];

        UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 10.0, btn.frame.size.width, 16)];
        firstLabel.textColor = [EBStyle blueTextColor];
        firstLabel.textAlignment = NSTextAlignmentCenter;
        firstLabel.font = [UIFont systemFontOfSize:14.0];
        firstLabel.text = isHouse ? NSLocalizedString(@"view_phone", nil) : NSLocalizedString(@"view_client_phone", nil);
        firstLabel.backgroundColor = [UIColor clearColor];
        [btn addSubview:firstLabel];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, firstLabel.frame.origin.y + firstLabel.frame.size.height + 8,
                btn.frame.size.width, 13)];
        label.textColor = [EBStyle blueTextColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12.0];
        label.backgroundColor = [UIColor clearColor];
        label.text = remainTimes > 0 ? [NSString stringWithFormat:NSLocalizedString(@"view_phone_format", nil), remainTimes]
                                     : NSLocalizedString(@"view_phone_no_chance", nil);
        [btn addSubview:label];
    }
    else
    {
       [btn setTitle:isHouse ? NSLocalizedString(@"no_access_to_phone", nil) : NSLocalizedString(@"no_access_to_client_phone", nil) forState:UIControlStateNormal];
    }

    if (remainTimes < 0)
    {
        btn.adjustsImageWhenDisabled = YES;
        [btn setEnabled:NO];
    }

    return btn;
}

+ (UIView *)accessPhoneNumberViewForClient:(id)target action:(SEL)action client:(EBClient *)client view:(UIView *)faView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 87)];
    BOOL anonymous = client.enableanonymouscall;
    BOOL own = client.ownbyme;
    BOOL input = client.inputbyme;
    NSInteger remainTimes = client.timesRemain;
    NSArray *phoneNumbers = client.phoneNumbers;
//    remainTimes = -1;
    if (remainTimes < 0)
    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, [EBStyle screenWidth]-30, 57)];
        btn.tag = EBPhoneTypeHouseEnableShowNum;
        UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
        UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
        [btn setBackgroundImage:bgN forState:UIControlStateNormal];
        [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
        
        btn.adjustsImageWhenHighlighted = NO;
        [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
//        [btn setTitle:NSLocalizedString(@"no_access_to_client_phone", nil) forState:UIControlStateNormal];
        btn.adjustsImageWhenDisabled = YES;
        
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectZero];
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectZero];
        name.font = [UIFont systemFontOfSize:14];
        name.textColor = [EBStyle blueTextColor];
        name.textAlignment = NSTextAlignmentLeft;
        name.text = NSLocalizedString(@"no_access_to_client_phone", nil);
        CGSize Size = [EBViewFactory textSize:NSLocalizedString(@"no_access_to_client_phone", nil) font:[UIFont systemFontOfSize:14] bounding:CGSizeMake(220, 999)];
        name.frame = CGRectMake(0, 0, Size.width, Size.height);
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_phone_lock"]];
        CGRect imageFrame = imageView.frame;
        if (imageFrame.size.height > Size.height)
        {
            iconView.frame = CGRectMake(0, 0, imageFrame.size.width + 5 + Size.width, imageFrame.size.height);
            imageView.frame = CGRectOffset(imageFrame, 0, 0);
            name.frame = CGRectOffset(name.frame, imageFrame.size.width + 5, (imageFrame.size.height - name.frame.size.height) / 2);
        }
        else
        {
            iconView.frame = CGRectMake(0, 0, imageFrame.size.width + 5 + Size.width, Size.height);
            imageView.frame = CGRectOffset(imageFrame, 0, (name.frame.size.height - imageFrame.size.height) / 2);
            name.frame = CGRectOffset(name.frame, imageFrame.size.width + 5, 0);
        }
        [iconView addSubview:name];
        [iconView addSubview:imageView];
        iconView.frame = CGRectOffset(iconView.frame, (btn.frame.size.width - iconView.frame.size.width) / 2, (btn.frame.size.height - iconView.frame.size.height) / 2);
        [btn addSubview:iconView];
        
        [btn setEnabled:NO];
        [view addSubview:btn];
    }
    else
    {
        if(!anonymous)
        {
            if ([phoneNumbers count] > 0)
            {
                EBPhoneButton *callBtn = [[EBPhoneButton alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 57)];
                callBtn.isHouse = NO;
                if ([phoneNumbers count] == 1)
                {
                    callBtn.contactName = client.name;
                    callBtn.phoneNumber = [phoneNumbers objectAtIndex:0];
                    callBtn.isMutliPhone = NO;
                    [callBtn setNeedsLayout];
                }
                else
                {
                    callBtn.contactName = client.name;
                    callBtn.phoneNumber = NSLocalizedString(@"mutli_phonenum", nil);
                    callBtn.isMutliPhone = YES;
                    callBtn.phoneNumbers = phoneNumbers;
                    callBtn.view = faView;
                    [callBtn setNeedsLayout];
                }
                [view addSubview:callBtn];
            }
            else
            {
                if (!own && !input)
                {
                    //! 客户 未开启  非所有
                    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, [EBStyle screenWidth]-30, 57)];
                    btn.tag = EBPhoneTypeClientDisableOther;
                    UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                    UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                    [btn setBackgroundImage:bgN forState:UIControlStateNormal];
                    [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
                    
                    btn.adjustsImageWhenHighlighted = NO;
                    [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
                    
                    if (remainTimes >= 0)
                    {
                        EBIconLabel *iconLabel = [[EBIconLabel alloc] init];
                        iconLabel.imageView.image = [UIImage imageNamed:@"phone_eyes"];
                        iconLabel.iconPosition = EIconPositionLeft;
                        iconLabel.gap = 5;
                        iconLabel.iconVerticalCenter = YES;
                        iconLabel.label.textColor = [EBStyle blueTextColor];
                        iconLabel.label.font = [UIFont systemFontOfSize:16.0];
                        iconLabel.label.text = NSLocalizedString(@"view_client_phone", nil);
                        CGRect frame = iconLabel.currentFrame;
                        iconLabel.frame = CGRectOffset(frame, 150 - frame.size.width / 2, 8);
                        iconLabel.userInteractionEnabled = NO;
                        [btn addSubview:iconLabel];
                        
                        iconLabel.backgroundColor = [UIColor clearColor];
                        [btn addSubview:iconLabel];
                        
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, iconLabel.frame.origin.y + iconLabel.frame.size.height + 8,
                                                                                   btn.frame.size.width, 13)];
                        label.textColor = [EBStyle blueTextColor];
                        label.textAlignment = NSTextAlignmentCenter;
                        label.font = [UIFont systemFontOfSize:12.0];
                        label.backgroundColor = [UIColor clearColor];
                        label.text = remainTimes > 0 ? [NSString stringWithFormat:NSLocalizedString(@"view_phone_format_entire_client", nil), remainTimes]
                        : NSLocalizedString(@"view_phone_no_chance", nil);
                        [btn addSubview:label];
                    }
                    else
                    {
                        [btn setTitle:NSLocalizedString(@"no_access_to_client_phone", nil) forState:UIControlStateNormal];
                    }
                    
                    if (remainTimes < 0)
                    {
                        btn.adjustsImageWhenDisabled = YES;
                        [btn setEnabled:NO];
                    }
                    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
                    [view addSubview:btn];
                }
                else
                {
                    //! 客户 未开启  拥有
                    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, [EBStyle screenWidth]-30, 57)];
                    btn.tag = EBPhoneTypeClientDisableOwn;
                    UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                    UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                    [btn setBackgroundImage:bgN forState:UIControlStateNormal];
                    [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
                    
                    btn.adjustsImageWhenHighlighted = NO;
                    [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
                    
                    EBIconLabel *iconLabel = [[EBIconLabel alloc] init];
                    iconLabel.imageView.image = [UIImage imageNamed:@"phone_eyes"];
                    iconLabel.iconPosition = EIconPositionLeft;
                    iconLabel.gap = 5;
                    iconLabel.iconVerticalCenter = YES;
                    iconLabel.label.textColor = [EBStyle blueTextColor];
                    iconLabel.label.font = [UIFont systemFontOfSize:16.0];
                    iconLabel.label.text = NSLocalizedString(@"view_client_phone", nil);
                    CGRect frame = iconLabel.currentFrame;
                    iconLabel.frame = CGRectOffset(frame, 150 - frame.size.width / 2, 8);
                    iconLabel.userInteractionEnabled = NO;
                    [btn addSubview:iconLabel];
                    
                    iconLabel.backgroundColor = [UIColor clearColor];
                    [btn addSubview:iconLabel];
                    
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, iconLabel.frame.origin.y + iconLabel.frame.size.height + 8,
                                                                               btn.frame.size.width, 13)];
                    label.textColor = [EBStyle blueTextColor];
                    label.textAlignment = NSTextAlignmentCenter;
                    label.font = [UIFont systemFontOfSize:12.0];
                    label.backgroundColor = [UIColor clearColor];
                    label.text = NSLocalizedString(@"input_by_me_client", nil);
                    [btn addSubview:label];
                    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
                    [view addSubview:btn];
                }
            }
        }
        else
        {
            if ([phoneNumbers count] > 0)
            {
                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, 101.5, 57)];
                UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                [btn setBackgroundImage:bgN forState:UIControlStateNormal];
                [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
                
                btn.adjustsImageWhenHighlighted = NO;
                [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
                //                    UIButton *btn = [EBViewFactory blueButtonWithFrame:CGRectMake(15 + 148.5 * i, 0, 141.5, 57) title:@""
                //                                                                target:target action:action];
                UIView *labelView = [EBViewFactory anonymousCallBtn:YES name:client.name];
                [btn addSubview:labelView];
                
                EBPhoneButton *callBtn = [[EBPhoneButton alloc] initWithFrameCustom:CGRectMake(15 + 108.5, 15, 181.5, 57)];
                callBtn.isHouse = NO;
                if ([phoneNumbers count] == 1)
                {
                    callBtn.contactName = client.name;
                    callBtn.phoneNumber = [phoneNumbers objectAtIndex:0];
                    callBtn.isMutliPhone = NO;
                    [callBtn setNeedsLayout];
                }
                else
                {
                    
                    callBtn.contactName = client.name;
                    callBtn.phoneNumber = NSLocalizedString(@"mutli_phonenum", nil);
                    callBtn.isMutliPhone = YES;
                    callBtn.phoneNumbers = phoneNumbers;
                    callBtn.view = faView;
                    [callBtn setNeedsLayout];
                }
                [view addSubview:callBtn];
                btn.enabled = YES;
                btn.tag = EBPhoneTypeClientEnableOtherCall;
                [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:btn];
            }
            else
            {
                if(!own && !input)
                {
                    //!客户 开启  非拥有
                    NSArray *btnTitles = @[NSLocalizedString(@"hidden_call", nil), NSLocalizedString(@"view_client_phone", nil)];
                    for (NSInteger i = 0; i < 2; i++)
                    {
//                        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15 + 148.5 * i, 15, 141.5, 57)];
                        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];

                        UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                        UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                        [btn setBackgroundImage:bgN forState:UIControlStateNormal];
                        [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
                        
                        btn.adjustsImageWhenHighlighted = NO;
                        [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
                        if (i == 0)
                        {
                            btn.frame = CGRectMake(15, 15, 110, 57);
                            UIView *labelView = [EBViewFactory anonymousCallBtn:YES name:client.name];
                            [btn addSubview:labelView];
                        }
                        if (i == 1)
                        {
                            btn.frame = CGRectMake(15 + 120, 15,[EBStyle screenWidth] - 15 - 135, 57);
                            EBIconLabel *iconLabel = [[EBIconLabel alloc] initWithFrame:CGRectZero];
                            iconLabel.iconPosition = EIconPositionLeft;
                            iconLabel.label.textColor = [EBStyle blueTextColor];
                            iconLabel.label.font = [UIFont systemFontOfSize:14];
                            iconLabel.label.text = btnTitles[i];
                            iconLabel.gap = 5;
                            iconLabel.imageView.image = [UIImage imageNamed:@"phone_eyes"];
                            
                            iconLabel.userInteractionEnabled = NO;
                            iconLabel.tag = 88;
                            CGRect oldFrame = iconLabel.currentFrame;
                            CGFloat left = (btn.width - oldFrame.size.width)/2.0;
                            iconLabel.frame = CGRectMake(left, 8, oldFrame.size.width, oldFrame.size.height);
                            UILabel *labelTip = [[UILabel alloc] initWithFrame:CGRectMake(0.0, iconLabel.frame.origin.y + iconLabel.frame.size.height + 8,
                                                                                          btn.frame.size.width, 13)];
                            labelTip.textColor = [EBStyle blueTextColor];
                            labelTip.textAlignment = NSTextAlignmentCenter;
                            labelTip.font = [UIFont systemFontOfSize:12.0];
                            labelTip.backgroundColor = [UIColor clearColor];
                            labelTip.text = remainTimes > 0 ? [NSString stringWithFormat:NSLocalizedString(@"view_phone_format", nil), remainTimes]
                            : NSLocalizedString(@"view_phone_no_chance_anonymous", nil);
                            [btn addSubview:labelTip];
                            
                            [btn addSubview:iconLabel];
                        }
                        
                        if(i == 0)
                        {
                            btn.tag = EBPhoneTypeClientEnableOtherCall;
                        }
                        else
                        {
                            btn.tag = EBPhoneTypeClientEnableOtherView;
                        }
                        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
                        [view addSubview:btn];
                    }
                }
                if(own || input)
                {
                    //! 客户 开启  拥有
                    
                    NSArray *btnTitles = @[NSLocalizedString(@"hidden_call", nil), NSLocalizedString(@"view_client_phone", nil)];
                    for (NSInteger i = 0; i < 2; i++)
                    {
//                        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15 + 148.5 * i, 15, 141.5, 57)];
                        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];

                        UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                        UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                        [btn setBackgroundImage:bgN forState:UIControlStateNormal];
                        [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
                        
                        btn.adjustsImageWhenHighlighted = NO;
                        [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
                        
                        if (i == 0)
                        {
                            btn.frame = CGRectMake(15, 15, 110, 57);
                            UIView *labelView = [EBViewFactory anonymousCallBtn:YES name:client.name];
                            [btn addSubview:labelView];
                        }
                        if (i == 1)
                        {
                            btn.frame = CGRectMake(15 + 120, 15,[EBStyle screenWidth] - 15 - 135, 57);
                            EBIconLabel *iconLabel = [[EBIconLabel alloc] initWithFrame:CGRectZero];
                            iconLabel.iconPosition = EIconPositionLeft;
                            iconLabel.label.textColor = [EBStyle blueTextColor];
                            iconLabel.label.font = [UIFont systemFontOfSize:14];
                            iconLabel.label.text = btnTitles[i];
                            iconLabel.gap = 5;
                            iconLabel.imageView.image = [UIImage imageNamed:@"phone_eyes"];
                            
                            iconLabel.userInteractionEnabled = NO;
                            iconLabel.tag = 88;
                            CGRect oldFrame = iconLabel.currentFrame;
                            CGFloat left = (btn.width - oldFrame.size.width)/2.0;
                            iconLabel.frame = CGRectMake(left, 8, oldFrame.size.width, oldFrame.size.height);                            UILabel *labelTip = [[UILabel alloc] initWithFrame:CGRectMake(0.0, iconLabel.frame.origin.y + iconLabel.frame.size.height + 8,
                                                                                          btn.frame.size.width, 13)];
                            labelTip.textColor = [EBStyle blueTextColor];
                            labelTip.textAlignment = NSTextAlignmentCenter;
                            labelTip.font = [UIFont systemFontOfSize:12.0];
                            labelTip.backgroundColor = [UIColor clearColor];
                            labelTip.text = NSLocalizedString(@"own_by_me_client", nil);
                            [btn addSubview:labelTip];
                            
                            [btn addSubview:iconLabel];
                        }
                        
                        if(i == 0)
                        {
                            btn.tag = EBPhoneTypeClientEnableOwnCall;
                        }
                        else
                        {
                            btn.tag = EBPhoneTypeClientEnableOwnView;
                        }
                        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
                        [view addSubview:btn];
                    }
                }
            }
        }
    }
    return view;
}

//隐号通话
+ (UIView *)accessNewPhoneNumberViewForHouse:(id)target action:(SEL)action house:(EBHouse *)house view:(UIView *)faView{
    //    NSArray *phoneNumbers = [[NSArray alloc] initWithObjects:@"11134566",@"22331333", nil];
    NSArray *phoneNumbers = house.phoneNumbers;
    BOOL anonymous = house.enableanonymouscall;
    BOOL own = house.ownbyme;
    BOOL input = house.inputbyme;
    
    NSInteger remainTimes = house.timesRemain;
    //    anonymous = NO;
    //    remainTimes = -1;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 87)];
    if (remainTimes < 0)
    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, [EBStyle screenWidth]-30, 57)];
        btn.tag = EBPhoneTypeHouseDisableOther;
        UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
        UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
        [btn setBackgroundImage:bgN forState:UIControlStateNormal];
        [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
        
        btn.adjustsImageWhenHighlighted = NO;
        [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
        //        [btn setTitle:NSLocalizedString(@"no_access_to_phone", nil) forState:UIControlStateNormal];
        btn.adjustsImageWhenDisabled = YES;
        
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectZero];
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectZero];
        name.font = [UIFont systemFontOfSize:14];
        name.textColor = [EBStyle blueTextColor];
        name.textAlignment = NSTextAlignmentLeft;
        name.text = NSLocalizedString(@"making_call_no_access_to_phone", nil);
        CGSize Size = [EBViewFactory textSize:NSLocalizedString(@"making_call_no_access_to_phone", nil) font:[UIFont systemFontOfSize:14] bounding:CGSizeMake(220, 999)];
        name.frame = CGRectMake(0, 0, Size.width, Size.height);
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_phone_lock"]];
        CGRect imageFrame = imageView.frame;
        if (imageFrame.size.height > Size.height)
        {
            iconView.frame = CGRectMake(0, 0, imageFrame.size.width + 5 + Size.width, imageFrame.size.height);
            imageView.frame = CGRectOffset(imageFrame, 0, 0);
            name.frame = CGRectOffset(name.frame, imageFrame.size.width + 5, (imageFrame.size.height - name.frame.size.height) / 2);
        }
        else
        {
            iconView.frame = CGRectMake(0, 0, imageFrame.size.width + 5 + Size.width, Size.height);
            imageView.frame = CGRectOffset(imageFrame, 0, (name.frame.size.height - imageFrame.size.height) / 2);
            name.frame = CGRectOffset(name.frame, imageFrame.size.width + 5, 0);
        }
        [iconView addSubview:name];
        [iconView addSubview:imageView];
        iconView.frame = CGRectOffset(iconView.frame, (btn.frame.size.width - iconView.frame.size.width) / 2, (btn.frame.size.height - iconView.frame.size.height) / 2);
        [btn addSubview:iconView];
        
        [btn setEnabled:NO];
        [view addSubview:btn];
    }
    else
    {
        if(!anonymous)
        {
            if ([phoneNumbers count] > 0)
            {
                EBPhoneButton *callBtn = [[EBPhoneButton alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 57)];
                callBtn.isHouse = YES;
                if ([phoneNumbers count] == 1)
                {
                    callBtn.contactName = house.name;
                    callBtn.phoneNumber = [phoneNumbers objectAtIndex:0];
                    callBtn.isMutliPhone = NO;
                    callBtn.view = faView;
                    [callBtn setNeedsLayout];
                }
                else
                {
                    callBtn.contactName = house.name;
                    callBtn.phoneNumber = NSLocalizedString(@"mutli_phonenum", nil);
                    callBtn.isMutliPhone = YES;
                    callBtn.phoneNumbers = phoneNumbers;
                    callBtn.view = faView;
                    [callBtn setNeedsLayout];
                }
                [view addSubview:callBtn];
            }
            else
            {
                if (!own && !input)
                {
                    //! 房源 未开启  非所有
                    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, [EBStyle screenWidth]-30, 57)];
                    btn.tag = EBPhoneTypeHouseDisableOther;
                    UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                    UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                    [btn setBackgroundImage:bgN forState:UIControlStateNormal];
                    [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
                    
                    btn.adjustsImageWhenHighlighted = NO;
                    [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
                    
                    if (remainTimes >= 0)
                    {
                        EBIconLabel *iconLabel = [[EBIconLabel alloc] init];
                        iconLabel.imageView.image = [UIImage imageNamed:@"phone_eyes"];
                        iconLabel.iconPosition = EIconPositionRight;
                        iconLabel.gap = 5;
                        iconLabel.iconVerticalCenter = YES;
                        iconLabel.label.textColor = [EBStyle blueTextColor];
                        iconLabel.label.font = [UIFont systemFontOfSize:16.0];
                        iconLabel.label.text = NSLocalizedString(@"making_call", nil);
                        CGRect frame = iconLabel.currentFrame;
                        iconLabel.frame = CGRectOffset(frame, 150 - frame.size.width / 2 + 15, 8);
                        iconLabel.userInteractionEnabled = NO;
                        [btn addSubview:iconLabel];
                        
                        iconLabel.backgroundColor = [UIColor clearColor];
                        [btn addSubview:iconLabel];
                        
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, iconLabel.frame.origin.y + iconLabel.frame.size.height + 8,
                                                                                   btn.frame.size.width, 13)];
                        label.textColor = [EBStyle blueTextColor];
                        label.textAlignment = NSTextAlignmentCenter;
                        label.font = [UIFont systemFontOfSize:12.0];
                        label.backgroundColor = [UIColor clearColor];
                        label.text = remainTimes > 0 ? [NSString stringWithFormat:NSLocalizedString(@"making_call_format_times", nil), remainTimes]
                        : NSLocalizedString(@"making_call_no_chance_anonymous", nil);
                        [btn addSubview:label];
                    }
                    else
                    {
                        [btn setTitle:NSLocalizedString(@"making_call_no_access_to_phone", nil) forState:UIControlStateNormal];
                    }
                    
                    if (remainTimes < 0)
                    {
                        btn.adjustsImageWhenDisabled = YES;
                        [btn setEnabled:NO];
                    }
                    btn.tag = EBPhoneTypeHouseDisableOwn;
                    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
                    [view addSubview:btn];
                }
                else
                {
                    //! 房源 未开启  所有
                    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, [EBStyle screenWidth]-30, 57)];
                    btn.tag = EBPhoneTypeHouseDisableOwn;
                    UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                    UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                    [btn setBackgroundImage:bgN forState:UIControlStateNormal];
                    [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
                    
                    btn.adjustsImageWhenHighlighted = NO;
                    [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
                    
                    EBIconLabel *iconLabel = [[EBIconLabel alloc] init];
                    iconLabel.imageView.image = [UIImage imageNamed:@"phone_eyes"];
                    iconLabel.iconPosition = EIconPositionLeft;
                    iconLabel.gap = 5;
                    iconLabel.iconVerticalCenter = YES;
                    iconLabel.label.textColor = [EBStyle blueTextColor];
                    iconLabel.label.font = [UIFont systemFontOfSize:16.0];
                    iconLabel.label.text = NSLocalizedString(@"making_call", nil);
                    CGRect frame = iconLabel.currentFrame;
                    iconLabel.frame = CGRectOffset(frame, 150 - frame.size.width / 2, 8);
                    iconLabel.userInteractionEnabled = NO;
                    [btn addSubview:iconLabel];
                    
                    iconLabel.backgroundColor = [UIColor clearColor];
                    [btn addSubview:iconLabel];
                    
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, iconLabel.frame.origin.y + iconLabel.frame.size.height + 8,
                                                                               btn.frame.size.width, 13)];
                    label.textColor = [EBStyle blueTextColor];
                    label.textAlignment = NSTextAlignmentCenter;
                    label.font = [UIFont systemFontOfSize:12.0];
                    label.backgroundColor = [UIColor clearColor];
                    label.text = NSLocalizedString(@"own_by_me_house", nil);
                    [btn addSubview:label];
                    btn.tag = EBPhoneTypeHouseDisableOwn;
                    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
                    [view addSubview:btn];
                }
            }
        }
        else
        {
            if ([phoneNumbers count] > 0)
            {
                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, 101.5, 57)];
                UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                [btn setBackgroundImage:bgN forState:UIControlStateNormal];
                [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
                
                btn.adjustsImageWhenHighlighted = NO;
                [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
                
                UIView *labelView = [EBViewFactory anonymousCallBtn:YES name:house.name];
                [btn addSubview:labelView];
                
                
                EBPhoneButton *callBtn = [[EBPhoneButton alloc] initWithFrameCustom:CGRectMake(15 + 108.5, 15, 181.5, 57)];
                callBtn.isHouse = YES;
                if ([phoneNumbers count] == 1)
                {
                    callBtn.contactName = house.name;
                    callBtn.isMutliPhone = NO;
                    callBtn.phoneNumber = [phoneNumbers objectAtIndex:0];
                    [callBtn setNeedsLayout];
                }
                else
                {
                    callBtn.contactName = house.name;
                    callBtn.phoneNumber = NSLocalizedString(@"mutli_phonenum", nil);
                    callBtn.isMutliPhone = YES;
                    callBtn.phoneNumbers = phoneNumbers;
                    callBtn.view = faView;
                    [callBtn setNeedsLayout];
                }
                [view addSubview:callBtn];
                btn.tag = EBPhoneTypeHouseEnableOtherCall;
                [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:btn];
            }
            else
            {
                if(!own && !input)
                {
                    //! 房源 开启  非所有
                    NSArray *btnTitles = @[NSLocalizedString(@"hidden_call", nil), NSLocalizedString(@"making_call", nil)];
                    for (NSInteger i = 0; i < 2; i++)
                    {
                        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15 + 148.5 * i, 15, 141.5, 57)];
                        UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                        UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                        [btn setBackgroundImage:bgN forState:UIControlStateNormal];
                        [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
                        
                        btn.adjustsImageWhenHighlighted = NO;
                        [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
                        
                        if (i == 0)
                        {
                            btn.frame = CGRectMake(15, 15, 101.5, 57);
                            UIView *labelView = [EBViewFactory anonymousCallBtn:YES name:house.name];
                            [btn addSubview:labelView];
                        }
                        if (i == 1)
                        {
                            btn.frame = CGRectMake(15 + 108.5, 15, 181.5, 57);
                            EBIconLabel *iconLabel = [[EBIconLabel alloc] initWithFrame:CGRectZero];
                            iconLabel.iconPosition = EIconPositionLeft;
                            iconLabel.label.textColor = [EBStyle blueTextColor];
                            iconLabel.label.font = [UIFont systemFontOfSize:14];
                            iconLabel.label.text = btnTitles[i];
                            iconLabel.gap = 5;
                            iconLabel.imageView.image = [UIImage imageNamed:@"phone_eyes"];
                            iconLabel.userInteractionEnabled = NO;
                            iconLabel.tag = 88;
                            CGRect oldFrame = iconLabel.currentFrame;
                            iconLabel.frame = CGRectOffset(oldFrame, (181.5 - oldFrame.size.width) / 2, 8);
                            UILabel *labelTip = [[UILabel alloc] initWithFrame:CGRectMake(0.0, iconLabel.frame.origin.y + iconLabel.frame.size.height + 8,
                                                                                          btn.frame.size.width, 13)];
                            labelTip.textColor = [EBStyle blueTextColor];
                            labelTip.textAlignment = NSTextAlignmentCenter;
                            labelTip.font = [UIFont systemFontOfSize:12.0];
                            labelTip.backgroundColor = [UIColor clearColor];
                            labelTip.text = remainTimes > 0 ? [NSString stringWithFormat:NSLocalizedString(@"making_call_format_times", nil), remainTimes]
                            : NSLocalizedString(@"making_call_no_chance_anonymous", nil);
                            [btn addSubview:labelTip];
                            [btn addSubview:iconLabel];
                        }
                        
                        
                        if (i == 0)
                        {
                            btn.tag = EBPhoneTypeHouseEnableOtherCall;
                        }
                        else
                        {
                            btn.tag = EBPhoneTypeHouseEnableOtherView;
                        }
                        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
                        [view addSubview:btn];
                    }
                }
                if(own || input)
                {
                    //! 房源 开启  所有
                    
                    NSArray *btnTitles = @[NSLocalizedString(@"hidden_call", nil), NSLocalizedString(@"view_phone_house", nil)];
                    for (NSInteger i = 0; i < 2; i++)
                    {
                        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15 + 148.5 * i, 15, 141.5, 57)];
                        UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                        UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                        [btn setBackgroundImage:bgN forState:UIControlStateNormal];
                        [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
                        
                        btn.adjustsImageWhenHighlighted = NO;
                        [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
                        //                    UIButton *btn = [EBViewFactory blueButtonWithFrame:CGRectMake(15 + 148.5 * i, 0, 141.5, 57) title:@""
                        //                                                                target:target action:action];
                        if (i == 0)
                        {
                            btn.frame = CGRectMake(15, 15, 101.5, 57);
                            UIView *labelView = [EBViewFactory anonymousCallBtn:YES name:house.name];
                            [btn addSubview:labelView];
                        }
                        if (i == 1)
                        {
                            btn.frame = CGRectMake(15 + 108.5, 15, 181.5, 57);
                            EBIconLabel *iconLabel = [[EBIconLabel alloc] initWithFrame:CGRectZero];
                            iconLabel.iconPosition = EIconPositionRight;
                            iconLabel.label.textColor = [EBStyle blueTextColor];
                            iconLabel.label.font = [UIFont systemFontOfSize:14];
                            iconLabel.label.text = btnTitles[i];
                            iconLabel.gap = 5;
                            iconLabel.imageView.image = [UIImage imageNamed:@"phone_eyes"];
                            
                            iconLabel.userInteractionEnabled = NO;
                            iconLabel.tag = 88;
                            CGRect oldFrame = iconLabel.currentFrame;
                            iconLabel.frame = CGRectOffset(oldFrame, (181.5 - oldFrame.size.width) / 2, 8);
                            UILabel *labelTip = [[UILabel alloc] initWithFrame:CGRectMake(0.0, iconLabel.frame.origin.y + iconLabel.frame.size.height + 8,
                                                                                          btn.frame.size.width, 13)];
                            labelTip.textColor = [EBStyle blueTextColor];
                            labelTip.textAlignment = NSTextAlignmentCenter;
                            labelTip.font = [UIFont systemFontOfSize:12.0];
                            labelTip.backgroundColor = [UIColor clearColor];
                            labelTip.text = NSLocalizedString(@"own_by_me_house", nil);
                            [btn addSubview:labelTip];
                            
                            [btn addSubview:iconLabel];
                        }
                        
                        if (i == 0)
                        {
                            btn.tag = EBPhoneTypeClientEnableOwnCall;
                        }
                        else
                        {
                            btn.tag = EBPhoneTypeClientEnableOwnView;
                        }
                        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
                        [view addSubview:btn];
                    }
                }
            }
        }
    }
    return view;
}
+ (UIView *)accessPhoneHiddenNumberViewForHouse:(EBHouse *)house view:(UIView *)faView{
    
    NSArray *phoneNumbers = @[@"13528840773"];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 87)];
    EBPhoneButton *callBtn = [[EBPhoneButton alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 72)];
    callBtn.isHouse = YES;
    if ([phoneNumbers count] == 1)
    {
        callBtn.contactName = house.name;
        callBtn.phoneNumber = [phoneNumbers objectAtIndex:0];
        callBtn.isMutliPhone = NO;
        callBtn.isorNotHidden = YES;
        callBtn.view = faView;
        [callBtn setNeedsLayout];
    }
    else
    {
        callBtn.contactName = house.name;
        callBtn.phoneNumber = NSLocalizedString(@"mutli_phonenum", nil);
        callBtn.isMutliPhone = YES;
        callBtn.isorNotHidden = YES;
        callBtn.phoneNumbers = phoneNumbers;
        callBtn.view = faView;
        [callBtn setNeedsLayout];
    }
    [view addSubview:callBtn];
    return view;
}

+ (UIView *)accessPhoneNumberViewForHouse:(id)target action:(SEL)action house:(EBHouse *)house view:(UIView *)faView
{

    NSArray *phoneNumbers = house.phoneNumbers;
    BOOL anonymous = house.enableanonymouscall;
    BOOL own = house.ownbyme;
    BOOL input = house.inputbyme;

    NSInteger remainTimes = house.timesRemain;
//    anonymous = NO;
//    remainTimes = -1;
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 87)];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 87)];
//    view.backgroundColor = [UIColor redColor];
    if (remainTimes < 0)//没有权限查看电话
    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, [EBStyle screenWidth]-30, 57)];
        btn.tag = EBPhoneTypeHouseDisableOther;
        UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
        UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
        [btn setBackgroundImage:bgN forState:UIControlStateNormal];
        [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
        
        btn.adjustsImageWhenHighlighted = NO;
        [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
//        [btn setTitle:NSLocalizedString(@"no_access_to_phone", nil) forState:UIControlStateNormal];
        btn.adjustsImageWhenDisabled = YES;
        
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectZero];
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectZero];
        name.font = [UIFont systemFontOfSize:14];
        name.textColor = [EBStyle blueTextColor];
        name.textAlignment = NSTextAlignmentLeft;
        name.text = NSLocalizedString(@"no_access_to_phone", nil);
        CGSize Size = [EBViewFactory textSize:NSLocalizedString(@"no_access_to_phone", nil) font:[UIFont systemFontOfSize:14] bounding:CGSizeMake(220, 999)];
        name.frame = CGRectMake(0, 0, Size.width, Size.height);
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_phone_lock"]];
        CGRect imageFrame = imageView.frame;
        if (imageFrame.size.height > Size.height)
        {
            iconView.frame = CGRectMake(0, 0, imageFrame.size.width + 5 + Size.width, imageFrame.size.height);
            imageView.frame = CGRectOffset(imageFrame, 0, 0);
            name.frame = CGRectOffset(name.frame, imageFrame.size.width + 5, (imageFrame.size.height - name.frame.size.height) / 2);
        }
        else
        {
            iconView.frame = CGRectMake(0, 0, imageFrame.size.width + 5 + Size.width, Size.height);
            imageView.frame = CGRectOffset(imageFrame, 0, (name.frame.size.height - imageFrame.size.height) / 2);
            name.frame = CGRectOffset(name.frame, imageFrame.size.width + 5, 0);
        }
        [iconView addSubview:name];
        [iconView addSubview:imageView];
        iconView.frame = CGRectOffset(iconView.frame, (btn.frame.size.width - iconView.frame.size.width) / 2, (btn.frame.size.height - iconView.frame.size.height) / 2);
        [btn addSubview:iconView];
        
        [btn setEnabled:NO];
        [view addSubview:btn];
    }
    else
    {
        if(!anonymous)
        {
            if ([phoneNumbers count] > 0)
            {
                
                EBPhoneButton *callBtn = [[EBPhoneButton alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 72)];
                callBtn.isHouse = YES;
                if ([phoneNumbers count] == 1)
                {
                    callBtn.contactName = house.name;
                    callBtn.phoneNumber = [phoneNumbers objectAtIndex:0];
                    callBtn.isMutliPhone = NO;
                    callBtn.view = faView;
                    [callBtn setNeedsLayout];
                }
                else
                {
                    callBtn.contactName = house.name;
                    callBtn.phoneNumber = NSLocalizedString(@"mutli_phonenum", nil);
                    callBtn.isMutliPhone = YES;
                    callBtn.phoneNumbers = phoneNumbers;
                    callBtn.view = faView;
                    [callBtn setNeedsLayout];
                }
                [view addSubview:callBtn];
            }
            else
            {
                if (!own && !input)
                {
                    //! 房源 未开启  非所有
                    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, [EBStyle screenWidth]-30, 57)];
                    btn.tag = EBPhoneTypeHouseDisableOther;
                    UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                    UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                    [btn setBackgroundImage:bgN forState:UIControlStateNormal];
                    [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
                    
                    btn.adjustsImageWhenHighlighted = NO;
                    [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
                    
                    if (remainTimes >= 0)
                    {
                        EBIconLabel *iconLabel = [[EBIconLabel alloc] init];
                        iconLabel.imageView.image = [UIImage imageNamed:@"phone_eyes"];
                        iconLabel.iconPosition = EIconPositionLeft;
                        iconLabel.gap = 5;
                        iconLabel.iconVerticalCenter = YES;
                        iconLabel.label.textColor = [EBStyle blueTextColor];
                        iconLabel.label.font = [UIFont systemFontOfSize:16.0];
                        iconLabel.label.text = NSLocalizedString(@"view_phone_house", nil);
                        CGRect frame = iconLabel.currentFrame;
                        iconLabel.frame = CGRectOffset(frame, 150 - frame.size.width / 2, 8);
                        iconLabel.userInteractionEnabled = NO;
                        [btn addSubview:iconLabel];
                        
                        iconLabel.backgroundColor = [UIColor clearColor];
                        [btn addSubview:iconLabel];
                        
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, iconLabel.frame.origin.y + iconLabel.frame.size.height + 8,
                                                                                   btn.frame.size.width, 13)];
                        label.textColor = [EBStyle blueTextColor];
                        label.textAlignment = NSTextAlignmentCenter;
                        label.font = [UIFont systemFontOfSize:12.0];
                        label.backgroundColor = [UIColor clearColor];
                        label.text = remainTimes > 0 ? [NSString stringWithFormat:NSLocalizedString(@"view_phone_format_entire", nil), remainTimes]
                        : NSLocalizedString(@"view_phone_no_chance_anonymous", nil);
                        [btn addSubview:label];
                    }
                    else
                    {
                        [btn setTitle:NSLocalizedString(@"no_access_to_phone", nil) forState:UIControlStateNormal];
                    }
                    
                    if (remainTimes < 0)
                    {
                        btn.adjustsImageWhenDisabled = YES;
                        [btn setEnabled:NO];
                    }
                    btn.tag = EBPhoneTypeHouseDisableOwn;
                    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
                    [view addSubview:btn];
                }
                else
                {
                    //! 房源 未开启  所有
                    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, [EBStyle screenWidth]-30, 57)];
                    btn.tag = EBPhoneTypeHouseDisableOwn;
                    UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                    UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                    [btn setBackgroundImage:bgN forState:UIControlStateNormal];
                    [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
                    
                    btn.adjustsImageWhenHighlighted = NO;
                    [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
                    
                    EBIconLabel *iconLabel = [[EBIconLabel alloc] init];
                    iconLabel.imageView.image = [UIImage imageNamed:@"phone_eyes"];
                    iconLabel.iconPosition = EIconPositionLeft;
                    iconLabel.gap = 5;
                    iconLabel.iconVerticalCenter = YES;
                    iconLabel.label.textColor = [EBStyle blueTextColor];
                    iconLabel.label.font = [UIFont systemFontOfSize:16.0];
                    iconLabel.label.text = NSLocalizedString(@"view_phone_house", nil);
                    CGRect frame = iconLabel.currentFrame;
                    iconLabel.frame = CGRectOffset(frame, 150 - frame.size.width / 2, 8);
                    iconLabel.userInteractionEnabled = NO;
                    [btn addSubview:iconLabel];
                    
                    iconLabel.backgroundColor = [UIColor clearColor];
                    [btn addSubview:iconLabel];
                    
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, iconLabel.frame.origin.y + iconLabel.frame.size.height + 8,
                                                                               btn.frame.size.width, 13)];
                    label.textColor = [EBStyle blueTextColor];
                    label.textAlignment = NSTextAlignmentCenter;
                    label.font = [UIFont systemFontOfSize:12.0];
                    label.backgroundColor = [UIColor clearColor];
                    label.text = NSLocalizedString(@"own_by_me_house", nil);
                    [btn addSubview:label];
                    btn.tag = EBPhoneTypeHouseDisableOwn;
                    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
                    [view addSubview:btn];
                }
            }
        }
        else
        {
            if ([phoneNumbers count] > 0)
            {
                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, 101.5, 57)];
                UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                [btn setBackgroundImage:bgN forState:UIControlStateNormal];
                [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
                
                btn.adjustsImageWhenHighlighted = NO;
                [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
                
                UIView *labelView = [EBViewFactory anonymousCallBtn:YES name:house.name];
                [btn addSubview:labelView];
                
                
                EBPhoneButton *callBtn = [[EBPhoneButton alloc] initWithFrameCustom:CGRectMake(15 + 108.5, 15, 181.5, 57)];
                callBtn.isHouse = YES;
                if ([phoneNumbers count] == 1)
                {
                    callBtn.contactName = house.name;
                    callBtn.isMutliPhone = NO;
                    callBtn.phoneNumber = [phoneNumbers objectAtIndex:0];
                    [callBtn setNeedsLayout];
                }
                else
                {
                    callBtn.contactName = house.name;
                    callBtn.phoneNumber = NSLocalizedString(@"mutli_phonenum", nil);
                    callBtn.isMutliPhone = YES;
                    callBtn.phoneNumbers = phoneNumbers;
                    callBtn.view = faView;
                    [callBtn setNeedsLayout];
                }
                [view addSubview:callBtn];
                btn.tag = EBPhoneTypeHouseEnableOtherCall;
                [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:btn];
            }
            else
            {
                if(!own && !input)
                {
                    //! 房源 开启  非所有
                    NSArray *btnTitles = @[NSLocalizedString(@"hidden_call", nil), NSLocalizedString(@"view_phone_house", nil)];
                    for (NSInteger i = 0; i < 2; i++)
                    {
                        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15 + 148.5 * i, 15, 141.5, 57)];
                        UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                        UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                        [btn setBackgroundImage:bgN forState:UIControlStateNormal];
                        [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
                        
                        btn.adjustsImageWhenHighlighted = NO;
                        [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
                        
                        if (i == 0)
                        {
                            btn.frame = CGRectMake(15, 15, 101.5, 57);
                            UIView *labelView = [EBViewFactory anonymousCallBtn:YES name:house.name];
                            [btn addSubview:labelView];
                        }
                        if (i == 1)
                        {
                            btn.frame = CGRectMake(15 + 108.5, 15, 181.5, 57);
                            EBIconLabel *iconLabel = [[EBIconLabel alloc] initWithFrame:CGRectZero];
                            iconLabel.iconPosition = EIconPositionLeft;
                            iconLabel.label.textColor = [EBStyle blueTextColor];
                            iconLabel.label.font = [UIFont systemFontOfSize:14];
                            iconLabel.label.text = btnTitles[i];
                            iconLabel.gap = 5;
                            iconLabel.imageView.image = [UIImage imageNamed:@"phone_eyes"];
                            iconLabel.userInteractionEnabled = NO;
                            iconLabel.tag = 88;
                            CGRect oldFrame = iconLabel.currentFrame;
                            iconLabel.frame = CGRectOffset(oldFrame, (181.5 - oldFrame.size.width) / 2, 8);
                            UILabel *labelTip = [[UILabel alloc] initWithFrame:CGRectMake(0.0, iconLabel.frame.origin.y + iconLabel.frame.size.height + 8,
                                                                                          btn.frame.size.width, 13)];
                            labelTip.textColor = [EBStyle blueTextColor];
                            labelTip.textAlignment = NSTextAlignmentCenter;
                            labelTip.font = [UIFont systemFontOfSize:12.0];
                            labelTip.backgroundColor = [UIColor clearColor];
                            labelTip.text = remainTimes > 0 ? [NSString stringWithFormat:NSLocalizedString(@"view_phone_format", nil), remainTimes]
                            : NSLocalizedString(@"view_phone_no_chance_anonymous", nil);
                            [btn addSubview:labelTip];
                            [btn addSubview:iconLabel];
                        }
                        
                        
                        if (i == 0)
                        {
                            btn.tag = EBPhoneTypeHouseEnableOtherCall;
                        }
                        else
                        {
                            btn.tag = EBPhoneTypeHouseEnableOtherView;
                        }
                        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
                        [view addSubview:btn];
                    }
                }
                if(own || input)
                {
                    //! 房源 开启  所有
                    
                    NSArray *btnTitles = @[NSLocalizedString(@"hidden_call", nil), NSLocalizedString(@"view_phone_house", nil)];
                    for (NSInteger i = 0; i < 2; i++)
                    {
                        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15 + 148.5 * i, 15, 141.5, 57)];
                        UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                        UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
                        [btn setBackgroundImage:bgN forState:UIControlStateNormal];
                        [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
                        
                        btn.adjustsImageWhenHighlighted = NO;
                        [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
                        //                    UIButton *btn = [EBViewFactory blueButtonWithFrame:CGRectMake(15 + 148.5 * i, 0, 141.5, 57) title:@""
                        //                                                                target:target action:action];
                        if (i == 0)
                        {
                            btn.frame = CGRectMake(15, 15, 101.5, 57);
                            UIView *labelView = [EBViewFactory anonymousCallBtn:YES name:house.name];
                            [btn addSubview:labelView];
                        }
                        if (i == 1)
                        {
                            btn.frame = CGRectMake(15 + 108.5, 15, 181.5, 57);
                            EBIconLabel *iconLabel = [[EBIconLabel alloc] initWithFrame:CGRectZero];
                            iconLabel.iconPosition = EIconPositionLeft;
                            iconLabel.label.textColor = [EBStyle blueTextColor];
                            iconLabel.label.font = [UIFont systemFontOfSize:14];
                            iconLabel.label.text = btnTitles[i];
                            iconLabel.gap = 5;
                            iconLabel.imageView.image = [UIImage imageNamed:@"phone_eyes"];
                            
                            iconLabel.userInteractionEnabled = NO;
                            iconLabel.tag = 88;
                            CGRect oldFrame = iconLabel.currentFrame;
                            iconLabel.frame = CGRectOffset(oldFrame, (181.5 - oldFrame.size.width) / 2, 8);
                            UILabel *labelTip = [[UILabel alloc] initWithFrame:CGRectMake(0.0, iconLabel.frame.origin.y + iconLabel.frame.size.height + 8,
                                                                                          btn.frame.size.width, 13)];
                            labelTip.textColor = [EBStyle blueTextColor];
                            labelTip.textAlignment = NSTextAlignmentCenter;
                            labelTip.font = [UIFont systemFontOfSize:12.0];
                            labelTip.backgroundColor = [UIColor clearColor];
                            labelTip.text = NSLocalizedString(@"own_by_me_house", nil);
                            [btn addSubview:labelTip];
                            
                            [btn addSubview:iconLabel];
                        }
                        
                        if (i == 0)
                        {
                            btn.tag = EBPhoneTypeClientEnableOwnCall;
                        }
                        else
                        {
                            btn.tag = EBPhoneTypeClientEnableOwnView;
                        }
                        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
                        [view addSubview:btn];
                    }
                }
            }
        }
    }
    return view;
}

+ (UIView *)accessoryNewView:(id)target action:(SEL)action{
    
    NSArray *btnExTitles = @[NSLocalizedString(@"btn_view_record", nil), NSLocalizedString(@"btn_track_record", nil), NSLocalizedString(@"btn_call_recode", nil),
                             ];//! wyl
    NSArray *btnTitles = @[NSLocalizedString(@"btn_match_client", nil), NSLocalizedString(@"btn_marked", nil),
                           NSLocalizedString(@"btn_recommended", nil)];
    
    //    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 15, 320, 65)];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 15, [EBStyle screenWidth], 150)]; //! wyl

        for (NSInteger i = 0; i < 3; i++)
        {
            CGFloat width = ([EBStyle screenWidth] - 30 - 20)/3.0;
            
            UIButton *btn = [EBViewFactory blueButtonWithFrame:CGRectMake(15 + width * i + 10*i, 0, width, 36) title:@""  target:target action:action];
            EBIconLabel *label = [[EBIconLabel alloc] initWithFrame:CGRectZero];
            label.label.textColor = [EBStyle blueTextColor];
            label.label.font = [UIFont systemFontOfSize:14];
            label.label.text = btnExTitles[i];
            label.gap = 5;
            label.imageView.image = [UIImage imageNamed:@"blue_accessory"];
            label.userInteractionEnabled = NO;
            label.tag = 88;
            CGRect oldFrame = label.currentFrame;
            label.frame = CGRectOffset(oldFrame, (width - oldFrame.size.width) / 2, (36 - oldFrame.size.height) / 2);
            [btn addSubview:label];
            [view addSubview:btn];
            btn.tag = i + 4;
        }
    
    
        for (NSInteger i = 0; i < 3; i++)
        {
            CGFloat width = ([EBStyle screenWidth] - 30 - 20)/3.0;
//            CGFloat btnWidth = ([EBStyle screenWidth] -4*15)/3.0f;
            UIButton *btn = [EBViewFactory blueButtonWithFrame:CGRectMake(15 + width * i + 10*i, 50, width, 36) title:@""  target:target action:action];// hegit 0 - 50 wyl
            EBIconLabel *label = [[EBIconLabel alloc] initWithFrame:CGRectZero];
            label.label.textColor = [EBStyle blueTextColor];
            label.label.font = [UIFont systemFontOfSize:14];
            label.label.text = btnTitles[i];
            label.gap = 5;
            label.imageView.image = [UIImage imageNamed:@"blue_accessory"];
            label.userInteractionEnabled = NO;
            label.tag = 88;
            CGRect oldFrame = label.currentFrame;
            label.frame = CGRectOffset(oldFrame, (width - oldFrame.size.width) / 2, (36 - oldFrame.size.height) / 2);
            [btn addSubview:label];
            [view addSubview:btn];
            btn.tag = i + 1;
        }
    
        for (NSInteger i = 0; i < 1; i++)
        {
            CGFloat width = ([EBStyle screenWidth] - 30 - 20)/3.0;
//            CGFloat btnWidth = ([EBStyle screenWidth] -4*15)/3.0f;
            UIButton *btn = [EBViewFactory blueButtonWithFrame:CGRectMake(15 + width * i + 10*i, 100, width, 36) title:@""  target:target action:action];// hegit 0 - 50 wyl
            EBIconLabel *label = [[EBIconLabel alloc] initWithFrame:CGRectZero];
            label.label.textColor = [EBStyle blueTextColor];
            label.label.font = [UIFont systemFontOfSize:14];
            label.label.text = @"同小区房源";
            label.gap = 5;
            label.imageView.image = [UIImage imageNamed:@"blue_accessory"];
            label.userInteractionEnabled = NO;
            label.tag = 86;
            CGRect oldFrame = label.currentFrame;
            label.frame = CGRectOffset(oldFrame, (width - oldFrame.size.width) / 2, (36 - oldFrame.size.height) / 2);
            [btn addSubview:label];
            [view addSubview:btn];
            btn.tag = 86;
        }
    
    
    return view;

}

+ (UIView *)accessoryView:(id)target action:(SEL)action forHouse:(BOOL)forHouse
{
    NSArray *btnExTitles = @[NSLocalizedString(@"btn_client_invite", nil), NSLocalizedString(@"btn_view_record", nil), NSLocalizedString(@"btn_track_record", nil),
                             ];//! wyl
    NSArray *btnTitles = @[NSLocalizedString(@"btn_match_house", nil), NSLocalizedString(@"btn_marked", nil),
            NSLocalizedString(@"btn_recommended", nil)];

//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 15, 320, 65)];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 15, [EBStyle screenWidth], 100)]; //! wyl
    if  (forHouse)
    {
        for (NSInteger i = 0; i < 2; i++)
        {
            CGFloat btnWidth =([EBStyle screenWidth]-3*15)/2.0f;
            UIButton *btn = [EBViewFactory blueButtonWithFrame:CGRectMake(15 + (btnWidth+15) * i, 0, btnWidth, 36) title:@""
                                                        target:target action:action];
            EBIconLabel *label = [[EBIconLabel alloc] initWithFrame:CGRectZero];
//            label.iconPosition = EIconPositionRight;//debug
            label.label.textColor = [EBStyle blueTextColor];
            label.label.font = [UIFont systemFontOfSize:14];
            label.label.text = btnExTitles[i + 1];
            label.gap = 5;
            label.imageView.image = [UIImage imageNamed:@"blue_accessory"];
            label.userInteractionEnabled = NO;
            label.tag = 88;
            CGRect oldFrame = label.currentFrame;
            label.frame = CGRectOffset(oldFrame, (135 - oldFrame.size.width) / 2, (36 - oldFrame.size.height) / 2);
            [btn addSubview:label];
            [view addSubview:btn];
            btn.tag = i + 4;
        }
    }
    else
    {
        for (NSInteger i = 0; i < 3; i++)
        {
            CGFloat width = ([EBStyle screenWidth] - 30 - 20)/3.0;
            
            UIButton *btn = [EBViewFactory blueButtonWithFrame:CGRectMake(15 + width * i + 10*i, 0, width, 36) title:@""  target:target action:action];
            EBIconLabel *label = [[EBIconLabel alloc] initWithFrame:CGRectZero];
            label.label.textColor = [EBStyle blueTextColor];
            label.label.font = [UIFont systemFontOfSize:14];
            label.label.text = btnExTitles[i];
            label.gap = 5;
            label.imageView.image = [UIImage imageNamed:@"blue_accessory"];
            label.userInteractionEnabled = NO;
            label.tag = 88;
            CGRect oldFrame = label.currentFrame;
            label.frame = CGRectOffset(oldFrame, (width - oldFrame.size.width) / 2, (36 - oldFrame.size.height) / 2);
            [btn addSubview:label];
            [view addSubview:btn];
            btn.tag = i + 4;

            if (forHouse && i == 0)
            {
                label.label.text = NSLocalizedString(@"btn_match_client", nil);
            }
        }
    }


    for (NSInteger i = 0; i < 3; i++)
    {
        CGFloat btnWidth = ([EBStyle screenWidth] -4*15)/3.0f;
        UIButton *btn = [EBViewFactory blueButtonWithFrame:CGRectMake(15 + (btnWidth+15) * i, 50, btnWidth, 36) title:@""  target:target action:action];// hegit 0 - 50 wyl
        EBIconLabel *label = [[EBIconLabel alloc] initWithFrame:CGRectZero];
        label.label.textColor = [EBStyle blueTextColor];
        label.label.font = [UIFont systemFontOfSize:14];
        label.label.text = btnTitles[i];
        label.gap = 5;
        label.imageView.image = [UIImage imageNamed:@"blue_accessory"];
        label.userInteractionEnabled = NO;
        label.tag = 88;
        CGRect oldFrame = label.currentFrame;
        label.frame = CGRectOffset(oldFrame, (92 - oldFrame.size.width) / 2, (36 - oldFrame.size.height) / 2);
        [btn addSubview:label];
        [view addSubview:btn];
        btn.tag = i + 1;

        if (forHouse && i == 0)
        {
            label.label.text = NSLocalizedString(@"btn_match_client", nil);
        }
    }

    return view;
}

+ (UIView *)qrCodeNumberView:(NSString *)text
{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 270)];
//
//    UIImageView *qrImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 20, 160, 160)];
//    qrImageView.layer.opacity = 0.5;
//    [view addSubview:qrImageView];
//
//    qrImageView.image = [QREncoder renderDataMatrix:[QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:text]
//                 imageDimension:160];
//
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, 320, 40)];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.textColor = [EBStyle blackTextColor];
//    label.font = [UIFont systemFontOfSize:14.0];
//    label.numberOfLines = 2;
//    label.backgroundColor = [UIColor clearColor];
//    label.tag = 88;
//
//    [view addSubview:label];
//
//    return view;
//
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, [EBStyle screenWidth], 270)];
    
    UIImageView *qrImageView = [[UIImageView alloc] initWithFrame:CGRectMake(([EBStyle screenWidth]-190)/2.0f, 20, 190, 190)];
    qrImageView.layer.opacity = 0.7;
    [view addSubview:qrImageView];
    
    qrImageView.image = [QREncoder renderDataMatrix:[QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:text]
                                     imageDimension:160];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 210, [EBStyle screenWidth], 40)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [EBStyle blackTextColor];
    label.font = [UIFont systemFontOfSize:14.0];
    label.numberOfLines = 2;
    label.backgroundColor = [UIColor clearColor];
    label.tag = 88;
    
    [view addSubview:label];
    
    return view;
}

+ (CGFloat)addNote:(NSString *)note toView:(UIView *)parentView withYOffset:(CGFloat)yOffset
{
    UIFont *font = [UIFont systemFontOfSize:14.0];
    CGSize labelSize = [EBViewFactory textSize:note font:font bounding:CGSizeMake(274, 9999)];

    UIImageView *labelBgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"bg_note"] stretchableImageWithLeftCapWidth:7 topCapHeight:20]];
    labelBgView.contentMode = UIViewContentModeScaleToFill;
    labelBgView.frame = CGRectMake(15, yOffset, [EBStyle screenWidth]-30, labelSize.height + 20);
    [parentView addSubview:labelBgView];

    UITextView *noteLabel = [[UITextView alloc] initWithFrame:CGRectMake(15 + 8, yOffset + 10, labelSize.width, labelSize.height)];
    noteLabel.editable = NO;
    noteLabel.scrollEnabled = NO;

    if ([EBCompatibility isIOS7Higher])
    {
        noteLabel.textContainer.lineFragmentPadding = 0;
        noteLabel.textContainerInset = UIEdgeInsetsZero;
    }
    else
    {
        noteLabel.contentInset = UIEdgeInsetsMake(-4,-8,0,0);
    }

    noteLabel.font = font;
    noteLabel.textColor = [UIColor colorWithRed:155/255.0 green:140/255.0 blue:55/255.0 alpha:1.0];
    noteLabel.text = note;
    noteLabel.backgroundColor = [UIColor clearColor];
    [parentView addSubview:noteLabel];

    return labelBgView.frame.size.height;
}

+ (UIButton *)buttonWithImage:(UIImage *)image
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];

    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:[image imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];

    btn.adjustsImageWhenHighlighted = NO;

    return btn;
}

+ (RTLabel*)contactLabelWithFrame:(CGRect)frame name:(NSString *)name phone:(NSString *)phone date:(NSString *)date
{
    RTLabel *rtLabel = [[RTLabel alloc] initWithFrame:frame];
    rtLabel.linkAttributes = @{@"color":@"#197add"};
    rtLabel.selectedLinkAttributes = @{@"color":@"#197add44"};
    rtLabel.font = [UIFont systemFontOfSize:14];
    rtLabel.textColor = [EBStyle blackTextColor];

    if (phone.length > 0)
    {
        rtLabel.text = [NSString stringWithFormat:NSLocalizedString(@"deleagtion_format", nil),
                                                  phone, name, phone, date];
    }
    else
    {
        rtLabel.text = [NSString stringWithFormat:NSLocalizedString(@"deleagtion_format0", nil),
                                                  name, date];
    }

    return rtLabel;
}

+ (UILabel *)timestampLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, [EBStyle screenWidth], 12)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [EBStyle grayTextColor];
    label.font = [UIFont systemFontOfSize:12.0f];

    return label;
}

+ (UIView *)phoneButtonWithTarget:(id)target action:(SEL)action
{
    EBPhoneButton *phoneButton = [[EBPhoneButton alloc] initWithFrameCustom:CGRectZero];
    return phoneButton;
}

+ (UIButton *)smsPhoneNumberBtn:(NSString *)phone
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 15, 300, 57)];
    UIImage *bgN = [[UIImage imageNamed:@"big_blue_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
    UIImage *bgP = [[UIImage imageNamed:@"big_blue_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
    [btn setBackgroundImage:bgN forState:UIControlStateNormal];
    [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];

    btn.adjustsImageWhenHighlighted = NO;
    [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];

    EBIconLabel *iconLabel = [[EBIconLabel alloc] init];
    iconLabel.imageView.image = [UIImage imageNamed:@"icon_sms"];
    iconLabel.iconPosition = EIconPositionLeft;
    iconLabel.gap = 5;
    iconLabel.iconVerticalCenter = YES;
    iconLabel.label.textColor = [EBStyle blueTextColor];
    iconLabel.label.font = [UIFont systemFontOfSize:20.0];
    iconLabel.label.text = phone;
    CGRect frame = iconLabel.currentFrame;
    iconLabel.frame = CGRectOffset(frame, 150 - frame.size.width / 2, (57 - frame.size.height) / 2);
    iconLabel.userInteractionEnabled = NO;
    [btn addSubview:iconLabel];

    return btn;
}

//+ (UILabel *)tagLabelWithText:(NSString *)text color:(UIColor *)color
//{
//    CGSize size = [EBViewFactory tagLabelSize:text];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
//    label.font = [UIFont systemFontOfSize:14.0];
//    label.textColor = color;
//    label.layer.borderWidth = 1.0f;
//    label.layer.borderColor = color.CGColor;
//
//    label.text = text;
//
//    return label;
//}

+ (UIImageView *)bubbleImageView:(BOOL)isIncoming
{
    UIImage *normalBubble;
    UIImage *highlightedBubble;

    if (isIncoming)
    {
        normalBubble = [UIImage imageNamed:@"im_bubble_incoming"];
        highlightedBubble = [UIImage imageNamed:@"im_bubble_incoming_p"];
    }
    else
    {
        normalBubble = [UIImage imageNamed:@"im_bubble_outgoing"];
        highlightedBubble = [UIImage imageNamed:@"im_bubble_outgoing_p"];
    }

    // make image stretchable from center point
    CGPoint center = CGPointMake(15, 15);
    UIEdgeInsets capInsets = UIEdgeInsetsMake(center.y, center.x, center.y, center.x);

    return [[UIImageView alloc] initWithImage:[normalBubble resizableImageWithCapInsets:capInsets
                                                                           resizingMode:UIImageResizingModeStretch]
                             highlightedImage:[highlightedBubble resizableImageWithCapInsets:capInsets
                                     resizingMode:UIImageResizingModeStretch]];
}

+ (UIImage *)imageFromGender:(NSString *)gender big:(BOOL)big
{
    if (big)
    {
        if ([gender isEqualToString:@"m"])
        {
           return [UIImage imageNamed:@"avatar_m_big"];
        }
        else
        {
           return [UIImage imageNamed:@"avatar_f_big"];
        }
    }
    else
    {
        if ([gender isEqualToString:@"m"])
        {
            return [UIImage imageNamed:@"avatar_m"];
        }
        else
        {
            return [UIImage imageNamed:@"avatar_f"];
        }
    }
}

+ (UITableViewCell *)loadingMoreCellFor:(UITableView *)tableView cellHeight:(CGFloat)height cellIdentifier:(NSString *)identifier
{
    UITableViewCell *loadingCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (loadingCell == nil)
    {
        loadingCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];

        CGFloat indicatorSize = 20;
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.frame = CGRectMake(160 - indicatorSize / 2, (height - indicatorSize) / 2, indicatorSize, indicatorSize);
        indicatorView.tag = 99;
        indicatorView.hidesWhenStopped = YES;
        [loadingCell addSubview:indicatorView];

        height = 44;
        CGSize labelSize = CGSizeMake(200, 20);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(([EBStyle screenWidth] -labelSize.width) / 2.0f,
                (height - labelSize.height) / 2, labelSize.width, labelSize.height)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = [EBStyle grayTextColor];
        label.text = NSLocalizedString(@"no_more", nil);
        label.tag = 100;
        label.hidden = YES;
        [loadingCell addSubview:label];

        loadingCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return loadingCell;
}

+ (UIView *)anonymousCallBtn:(BOOL)halfTag name:(NSString *)title
{
    UIView *labelView = [[UIView alloc]initWithFrame:CGRectZero];
    if (halfTag)
    {
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectZero];
        name.font = [UIFont systemFontOfSize:14];
        name.textColor = [EBStyle blueTextColor];
        name.textAlignment = NSTextAlignmentLeft;
        name.text = title;
        CGSize nameSize = [EBViewFactory textSize:title font:[UIFont systemFontOfSize:14] bounding:CGSizeMake(220, 999)];
        if (nameSize.width > 72)
        {
            nameSize.width = 72;
        }
        UILabel *call = [[UILabel alloc] initWithFrame:CGRectZero];
        call.font = [UIFont systemFontOfSize:14];
        call.textColor = [EBStyle blueTextColor];
        call.textAlignment = NSTextAlignmentLeft;
        call.text = NSLocalizedString(@"hidden_call", nil);
        CGSize callSize = [EBViewFactory textSize:NSLocalizedString(@"hidden_call", nil) font:[UIFont systemFontOfSize:14] bounding:CGSizeMake(220, 999)];
        if (callSize.width > 72)
        {
            callSize.width = 72;
        }
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_phone_nomal"]];
//        imageView.frame = CGRectMake(0, 15, 24, 26);
        imageView.frame = CGRectOffset(imageView.frame, 0, (57 - imageView.frame.size.height) / 2);
        
        labelView.frame = CGRectMake(0, 0, imageView.frame.size.width + 2 + (nameSize.width > callSize.width ? nameSize.width : callSize.width), 57);
        [labelView addSubview:imageView];
        
        name.frame = CGRectMake(imageView.frame.size.width + 2, (57 - nameSize.height - callSize.height - 4)/2, nameSize.width, nameSize.height);
        [labelView addSubview:name];
        
        call.frame = CGRectMake(imageView.frame.size.width + 2, name.frame.origin.y + name.frame.size.height + 4, callSize.width, callSize.height);
        [labelView addSubview:call];
        
        labelView.frame = CGRectOffset(labelView.frame, (101.5 - labelView.frame.size.width) / 2, 0);
        labelView.userInteractionEnabled = NO;
    }
    else
    {
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectZero];
        name.font = [UIFont systemFontOfSize:14];
        name.textColor = [EBStyle blueTextColor];
        name.textAlignment = NSTextAlignmentLeft;
        name.text = title;
        CGSize nameSize = [EBViewFactory textSize:title font:[UIFont systemFontOfSize:14] bounding:CGSizeMake(220, 999)];
        UILabel *call = [[UILabel alloc] initWithFrame:CGRectZero];
        call.font = [UIFont systemFontOfSize:14];
        call.textColor = [EBStyle blueTextColor];
        call.textAlignment = NSTextAlignmentLeft;
        call.text = NSLocalizedString(@"hidden_call", nil);
        CGSize callSize = [EBViewFactory textSize:NSLocalizedString(@"hidden_call", nil) font:[UIFont systemFontOfSize:14] bounding:CGSizeMake(220, 999)];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_phone_nomal"]];
        imageView.frame = CGRectMake(0, 15, 27, 27);
        labelView.frame = CGRectMake(0, 0, imageView.frame.size.width +5 + (nameSize.width > callSize.width ? nameSize.width : callSize.width), 57);
        [labelView addSubview:imageView];
        name.frame = CGRectMake(imageView.frame.size.width + 5, (57 - nameSize.height - callSize.height - 4)/2, nameSize.width, nameSize.height);
        [labelView addSubview:name];
        call.frame = CGRectMake(imageView.frame.size.width + 5, name.frame.origin.y + name.frame.size.height + 4, callSize.width, callSize.height);
        [labelView addSubview:call];
        labelView.frame = CGRectOffset(labelView.frame, ([EBStyle screenWidth]-30 - labelView.frame.size.width) / 2, 0);
        labelView.userInteractionEnabled = NO;
    }
    return labelView;
}

+ (CGFloat)parentView:(UIView *)parent addKey:(NSString *)key value:(NSString *)value linkValue:(NSString *)linkValue xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset limitWidth:(CGFloat)limitWidth delegate:(id<RTLabelDelegate>)delegate
{
    if (value == nil || [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        return 0;
    }
    UIFont *font = [UIFont systemFontOfSize:14.0];
    CGFloat textLineHeight = [EBViewFactory textSize:@"A" font:font bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].height;
    CGSize contentSize = [EBViewFactory textSize:value font:font bounding:CGSizeMake(limitWidth - 5 - 75, 999)];
    if (contentSize.height > 34)
    {
        contentSize.height = 34;
    }
    if (linkValue == nil || linkValue.length == 0)
    {
        linkValue = value;
        UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0 + xOffset, yOffset, 60, textLineHeight)];
        keyLabel.font = font;
        keyLabel.textColor = [EBStyle grayTextColor];
        keyLabel.text = key;
        keyLabel.textAlignment = NSTextAlignmentRight;
        [parent addSubview:keyLabel];
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(75 + xOffset, yOffset, contentSize.width + 2, contentSize.height)];
        contentLabel.numberOfLines = 2;
        contentLabel.font = font;
        contentLabel.numberOfLines = 0;
        contentLabel.textColor = [EBStyle blackTextColor];
        contentLabel.text = value;
        [parent addSubview:contentLabel];
    }
    else
    {
        RTLabel *keyLabel = [[RTLabel alloc] initWithFrame:CGRectMake(10.0 + xOffset, yOffset, 60, textLineHeight)];
        keyLabel.font = font;
        keyLabel.textColor = [EBStyle grayTextColor];
        keyLabel.text = key;
        keyLabel.textAlignment = RTTextAlignmentRight;
        [parent addSubview:keyLabel];
        
        RTLabel *contentLabel = [[RTLabel alloc] initWithFrame:CGRectMake(75 + xOffset, yOffset, contentSize.width + 4, contentSize.height)];
        contentLabel.linkAttributes = @{@"color":@"#197add"};
        contentLabel.selectedLinkAttributes = @{@"color":@"#197add44"};
        contentLabel.font = font;
        contentLabel.textColor = [EBStyle blackTextColor];
        contentLabel.text = linkValue;
//        contentLabel.backgroundColor = [UIColor redColor];
        contentLabel.delegate = delegate;
        [parent addSubview:contentLabel];
    }
    
    return contentSize.height == 0 ?  0 : contentSize.height + 10;
}

+ (EBIconLabel *)parentView:(UIView *)parent iconTextWithImage:(UIImage *)image text:(NSString *)text
{
    EBIconLabel *iconLabel = [[EBIconLabel alloc] initWithFrame:CGRectZero];
    iconLabel.backgroundColor = [UIColor clearColor];
    iconLabel.iconPosition = EIconPositionTop;
    iconLabel.imageView.image = image;
    iconLabel.label.textColor = [EBStyle blackTextColor];
    iconLabel.label.font = [UIFont systemFontOfSize:14.0];
    iconLabel.label.text = text;
    iconLabel.gap = 2;
    [parent addSubview:iconLabel];
    
    return iconLabel;
}

+ (void)parentView:(UIView *)parent addLine:(CGFloat)yOffset
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, yOffset, [EBStyle screenWidth], 0.5)];
    line.backgroundColor = [EBStyle grayClickLineColor];
    [parent addSubview:line];
}

+ (CGFloat)parentView:(UIView *)parent addRecommendTag:(NSArray *)recommendTags xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset limitWidth:(CGFloat)limitWidth tagColor:(UIColor *)tagColor
{
    CGFloat height = yOffset;
    CGFloat tagXOffset = xOffset;
    NSInteger lines = 1;
    for (int i = 0; i < recommendTags.count; i++)
    {
        NSString *tag = recommendTags[i];
        UIColor *specialColor = tagColor;
        if ([tag rangeOfString:NSLocalizedString(@"tag_urgent", nil)].location != NSNotFound)
        {
            specialColor = [UIColor colorWithRed:247./255.f green:72./255.f blue:61./255.f alpha:1.0];
        }
        else if ([tag rangeOfString:NSLocalizedString(@"tag_full_price", nil)].location != NSNotFound)
        {
            specialColor = [UIColor colorWithRed:255./255.f green:144./255.f blue:0./255.f alpha:1.0];
        }
        else if ([tag rangeOfString:NSLocalizedString(@"tag_access_2", nil)].location != NSNotFound)
        {
            specialColor = [UIColor colorWithRed:81./255.f green:182./255.f blue:209./255.f alpha:1.0];
        }
        else if ([tag rangeOfString:NSLocalizedString(@"tag_access_1", nil)].location != NSNotFound)
        {
            specialColor = [UIColor colorWithRed:6./255.f green:213./255.f blue:206./255.f alpha:1.0];
        }
        else if ([tag rangeOfString:NSLocalizedString(@"tag_new", nil)].location != NSNotFound
                 || [tag rangeOfString:NSLocalizedString(@"tag_five", nil)].location != NSNotFound)
        {
            specialColor = [UIColor colorWithRed:64./255.f green:199./255.f blue:50./255.f alpha:1.0];
        }
        else if ([tag rangeOfString:NSLocalizedString(@"tag_rent", nil)].location != NSNotFound
                 || [tag rangeOfString:NSLocalizedString(@"tag_sale", nil)].location != NSNotFound)
        {
            specialColor = [UIColor colorWithRed:229./255.f green:71./255.f blue:254./255.f alpha:1.0];
        }
        else if ([tag rangeOfString:NSLocalizedString(@"tag_valid", nil)].location != NSNotFound)
        {
            specialColor = [UIColor colorWithRed:144./255.f green:191./255.f blue:0./255.f alpha:1.0];
        }
        else if ([tag rangeOfString:NSLocalizedString(@"tag_invalid", nil)].location != NSNotFound)
        {
            specialColor = [UIColor colorWithRed:178./255.f green:178./255.f blue:181./255.f alpha:1.0];
        }
        CGFloat titleWidth = [EBViewFactory textSize:tag font:[UIFont systemFontOfSize:12.0] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
        if (titleWidth == 0.0)
        {
            continue;
        }
        else
        {
            titleWidth += 2;
        }
        UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(tagXOffset, (lines - 1) * 20.0 + yOffset, titleWidth, 14.0)];
        tagLabel.textAlignment = NSTextAlignmentCenter;
        tagLabel.layer.borderColor = specialColor.CGColor;
        tagLabel.layer.borderWidth = 0.5;
        tagLabel.textColor = specialColor;
        tagLabel.font = [UIFont systemFontOfSize:10.0];
        tagLabel.text = tag;
        if (tagXOffset + titleWidth > parent.frame.origin.x + limitWidth)
        {
            tagLabel.frame = CGRectMake(xOffset, lines * 20.0 + yOffset, titleWidth, 14.0);
            lines += 1;
            height += 14.0 + 6.0;
        }
        tagXOffset = tagLabel.frame.origin.x + tagLabel.frame.size.width + 5;
        [parent addSubview:tagLabel];
    }
    return height == 15 ? 0 : height;
}

+ (UIView*)lineWithHeight:(CGFloat)height left:(CGFloat)leftMargin right:(CGFloat)rightMargin
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, height, [EBStyle screenWidth] - leftMargin - rightMargin, 0.5)];
    line.backgroundColor = [EBStyle grayUnClickLineColor];
    return line;
}

+ (CGFloat)myParentView:(UIView *)parent addKey:(NSString *)key value:(NSString *)value linkValue:(NSString *)linkValue xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset limitWidth:(CGFloat)limitWidth delegate:(id<RTLabelDelegate>)delegate
{
    if (value == nil || [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        return 0;
    }
    UIFont *font = [UIFont systemFontOfSize:14.0];
    CGFloat textLineHeight = [EBViewFactory textSize:@"A" font:font bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].height;
    CGSize contentSize = [EBViewFactory textSize:value font:font bounding:CGSizeMake(limitWidth - 5 - 75, 999)];
    if (linkValue == nil || linkValue.length == 0)
    {
        linkValue = value;
        UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0 + xOffset, yOffset, 60, textLineHeight)];
        keyLabel.font = font;
        keyLabel.textColor = [EBStyle grayTextColor];
        keyLabel.text = key;
        keyLabel.textAlignment = NSTextAlignmentRight;
        [parent addSubview:keyLabel];
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(75 + xOffset, yOffset, contentSize.width + 2, contentSize.height)];
        contentLabel.numberOfLines = 2;
        contentLabel.font = font;
        contentLabel.numberOfLines = 0;
        contentLabel.textColor = [EBStyle blackTextColor];
        contentLabel.text = value;
        [parent addSubview:contentLabel];
    }
    else
    {
        textLineHeight += 3.0;
        RTLabel *keyLabel = [[RTLabel alloc] initWithFrame:CGRectMake(10.0 + xOffset, yOffset, 60, textLineHeight)];
        keyLabel.font = font;
        keyLabel.textColor = [EBStyle grayTextColor];
        keyLabel.text = key;
        keyLabel.textAlignment = RTTextAlignmentRight;
        [parent addSubview:keyLabel];
        
        RTLabel *contentLabel = [[RTLabel alloc] initWithFrame:CGRectMake(75 + xOffset, yOffset, contentSize.width + 4, contentSize.height + 3.0)];
        contentLabel.linkAttributes = @{@"color":@"#197add"};
        contentLabel.selectedLinkAttributes = @{@"color":@"#197add44"};
        contentLabel.font = font;
        contentLabel.textColor = [EBStyle blackTextColor];
        contentLabel.text = linkValue;
        //        contentLabel.backgroundColor = [UIColor redColor];
        contentLabel.delegate = delegate;
        [parent addSubview:contentLabel];
    }
    
    return contentSize.height == 0 ?  0 : contentSize.height + 10;
}

@end
