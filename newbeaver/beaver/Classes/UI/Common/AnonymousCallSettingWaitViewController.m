//
//  AnonymousCallSettingWaitViewController.m
//  beaver
//
//  Created by YingChen on 14-7-4.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "AnonymousCallSettingWaitViewController.h"
#import "EBViewFactory.h"

@interface AnonymousCallSettingWaitViewController ()

@end

@implementation AnonymousCallSettingWaitViewController

- (void)loadView
{
    [super loadView];
    
    self.title = NSLocalizedString(@"anonymous_call_setting_wait_title", nil);
    
    UIImageView *firstIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"face"]];
    firstIcon.frame = CGRectMake(25.0, 55.0, 32.0, 32.0);
    
    NSString *labelText = [NSString stringWithFormat:NSLocalizedString(@"anonymous_call_setting_wait_label1", nil), @"13910393653"];
   
    CGFloat labelHeight = [EBViewFactory textSize:labelText font:[UIFont systemFontOfSize:16.0] bounding:CGSizeMake(228.0, MAXFLOAT)].height;
    UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0, 50.0, 228.0, labelHeight)];
    firstLabel.font = [UIFont systemFontOfSize:16.0];
    firstLabel.textColor = [EBStyle blackTextColor];
    firstLabel.numberOfLines = 0;
    firstLabel.text = labelText;
    
    [self.view addSubview:firstIcon];
    [self.view addSubview:firstLabel];
    
    UIImageView *secondIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hourglass"]];
    secondIcon.frame = CGRectMake(25.0, labelHeight > 37.0 ? firstLabel.frame.origin.y + labelHeight + 45 : 32.0, 32.0, 32.0);
    
    labelText = NSLocalizedString(@"anonymous_call_setting_wait_label2", nil);
    
    labelHeight = [EBViewFactory textSize:labelText font:[UIFont systemFontOfSize:16.0] bounding:CGSizeMake(228.0, MAXFLOAT)].height;
    UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0, secondIcon.frame.origin.y - 5, 228.0, labelHeight)];
    secondLabel.font = [UIFont systemFontOfSize:16.0];
    secondLabel.textColor = [EBStyle blackTextColor];
    secondLabel.numberOfLines = 0;
    secondLabel.text = labelText;
    
    [self.view addSubview:secondIcon];
    [self.view addSubview:secondLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
