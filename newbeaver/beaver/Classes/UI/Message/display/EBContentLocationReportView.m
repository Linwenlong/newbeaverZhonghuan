//
// Created by 何 义 on 14-4-1.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBIMMessage.h"
#import "EBStyle.h"
#import "EBContentLocationReportView.h"
#import "RTLabel.h"
#import "EBController.h"

@interface EBContentLocationReportView()
{
    RTLabel *_addressView;
}
@end

@implementation EBContentLocationReportView
- (id)init
{
    self = [super init];
    if (self)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"im_report_location"]];
        [self addSubview:imageView];

        _addressView = [[RTLabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 10.0, -8, 127, 70)];
        _addressView.textColor = [EBStyle blackTextColor];
        [self addSubview:_addressView];
    }
    return self;
}

+ (CGSize)neededContentSize:(EBIMMessage *)message
{
    return CGSizeMake(190, 53);
}

- (void)updateContent:(EBIMMessage*)message
{
    [super updateContent:message];

    _addressView.text = [NSString stringWithFormat:NSLocalizedString(@"im_report_location", nil), message.content[@"address"]];
}

- (void)handleTapEvent
{
    [[EBController sharedInstance] showLocationInMap:self.message.content showKeywordLocation:NO];
}
@end