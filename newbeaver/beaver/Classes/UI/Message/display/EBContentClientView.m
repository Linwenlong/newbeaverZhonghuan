//
// Created by 何 义 on 14-4-1.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBContentClientView.h"
#import "EBIMMessage.h"
#import "EBViewFactory.h"
#import "EBStyle.h"
#import "EBClient.h"
#import "EBController.h"
#import "RDLabel.h"

@interface EBContentClientView()
{
    RDLabel *_detailView;
    UILabel *_lastNameView;
}

@end

@implementation EBContentClientView

- (id)init
{
    self = [super init];
    if (self)
    {
        _detailView = [[RDLabel alloc] initWithFrame:CGRectMake(63, 0, 127, 58)];
        _detailView.font = [UIFont systemFontOfSize:16];
        _detailView.textColor = [EBStyle blackTextColor];
        _detailView.backgroundColor = [UIColor clearColor];

        [self addSubview:_detailView];

        _lastNameView = [EBViewFactory lastNameLabel];
        _lastNameView.center = CGPointMake(24, 29);
        [self addSubview:_lastNameView];
    }
    return self;
}

+ (CGSize)neededContentSize:(EBIMMessage *)message
{
    return CGSizeMake(190, 58);
}

- (void)updateContent:(EBIMMessage*)message
{
    [super updateContent:message];
//    _detailView.text = message.content[@"desc"];
    [_detailView setTruncatingText:message.content[@"desc"] forNumberOfLines:3];
    _lastNameView.text = [message.content[@"name"] substringToIndex:1];
}

- (void)handleTapEvent
{
   EBClient *client = [[EBClient alloc] init];

   client.id = self.message.content[@"id"];
   client.rentalState = [self.message.content[@"type"] isEqualToString:@"sale"] ? EClientRequireTypeBuy : EClientRequireTypeRent;
   client.name = self.message.content[@"name"];

   [[EBController sharedInstance] showClientDetail:client];
}

- (NSString *)toPasteboard
{
    return _detailView.text;
}
@end