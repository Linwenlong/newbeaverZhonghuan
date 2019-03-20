//
// Created by 何 义 on 14-4-1.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "UIImageView+WebCache.h"
#import "EBContentHouseView.h"
#import "EBIMMessage.h"
#import "JSMessageTextView.h"
#import "JSMessageInputView.h"
#import "NSString+JSMessagesView.h"
#import "EBViewFactory.h"
#import "EBStyle.h"
#import "EBHouse.h"
#import "EBController.h"
#import "RDLabel.h"
#import "NewHouseWebViewController.h"

@interface EBContentHouseView()
{
    RDLabel *_detailView;
    UIImageView *_coverView;
}

@end

@implementation EBContentHouseView

- (id)init
{
    self = [super init];
    if (self)
    {
        _detailView = [[RDLabel alloc] initWithFrame:CGRectMake(69, 0, 121, 58)];
        _detailView.font = [UIFont systemFontOfSize:16];
        _detailView.textColor = [EBStyle blackTextColor];
        _detailView.backgroundColor = [UIColor clearColor];
        [self addSubview:_detailView];

        _coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
        [self addSubview:_coverView];
    }
    return self;
}

+ (CGSize)neededContentSize:(EBIMMessage *)message
{
    return CGSizeMake(190, 64);
}

- (void)updateContent:(EBIMMessage*)message
{
    [super updateContent:message];

    [_detailView setTruncatingText:message.content[@"desc"] forNumberOfLines:3];

    NSString *cover = message.content[@"img"];
    if (cover && cover.length)
    {
        [_coverView setImageWithURL:[[NSURL alloc] initWithString:cover] placeholderImage:[UIImage imageNamed:@"pl_house"]];
    }
    else
    {
       _coverView.image = [UIImage imageNamed:@"pl_house"];
    }
}

- (void)handleTapEvent
{
    if(self.message.type == EMessageContentTypeHouse)
    {
        EBHouse *house = [[EBHouse alloc] init];
        
        house.id = self.message.content[@"id"];
        house.rentalState = [self.message.content[@"type"] isEqualToString:@"sale"] ? EHouseRentalTypeSale  : EHouseRentalTypeRent;
        house.name =  self.message.content[@"name"];
        [[EBController sharedInstance] showHouseDetail:house];
    }
    else if(self.message.type == EMessageContentTypeNewHouse)
    {
        
        NewHouseWebViewController *viewController = [[NewHouseWebViewController alloc] init];
        NSString *URLString = [NSString stringWithFormat:NSLocalizedString(@"new_house_detail_format", nil), self.message.content[@"id"]];
        viewController.requestURL = URLString;
        [[[EBController sharedInstance] currentNavigationController] pushViewController:viewController animated:YES];
//        [[EBController sharedInstance] openWebViewWithUrl:[[NSURL alloc] initWithString:self.message.content[@"url"]]];
    }
}

- (NSString *)toPasteboard
{
    return _detailView.text;
}
@end
