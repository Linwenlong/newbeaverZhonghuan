//
// Created by 何 义 on 14-4-1.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBIMMessage.h"
#import "EBContentLocationShareView.h"
#import "EBController.h"

@interface EBContentLocationShareView()
{
    UILabel *_nameLabel;
    UILabel *_addressLabel;
}
@end

@implementation EBContentLocationShareView

- (id)init
{
    self = [super init];
    if (self)
    {
         UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"im_share_location"]];
        [self addSubview:imageView];

        CGFloat width = imageView.bounds.size.width;
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 71.5, width, 43)];
        bgView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        [imageView addSubview:bgView];

        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 4, width - 8, 20)];
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:16.0];
        [bgView addSubview:_nameLabel];

        _addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 24, width - 8, 15)];
        _addressLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _addressLabel.textColor = [UIColor whiteColor];
        _addressLabel.font = [UIFont systemFontOfSize:14.0];
        [bgView addSubview:_addressLabel];

    }
    return self;
}

+ (CGSize)neededContentSize:(EBIMMessage *)message
{
    return [UIImage imageNamed:@"im_share_location"].size;
}

- (void)updateContent:(EBIMMessage*)message
{
    [super updateContent:message];

    _nameLabel.text = message.content[@"name"];
    _addressLabel.text = message.content[@"address"];
}

- (void)handleTapEvent
{
   [[EBController sharedInstance] showLocationInMap:self.message.content showKeywordLocation:NO];
}

- (NSString *)toPasteboard
{
    return @"share_location";
}
@end