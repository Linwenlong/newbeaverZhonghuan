//
//  HouseAddFinishViewController.m
//  beaver
//
//  Created by wangyuliang on 14-8-14.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "HouseAddFinishViewController.h"
#import "UnderLineLabel.h"
#import "EBViewFactory.h"
#import "EBController.h"
#import "RIButtonItem.h"
#import "AGImagePickerController.h"
#import "HousePhotoPreUploadViewController.h"
#import "EBHousePhotoUploader.h"
#import "UIActionSheet+Blocks.h"

@interface HouseAddFinishViewController ()

@end

@implementation HouseAddFinishViewController

- (void)loadView
{
    [super loadView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_addhouse_sucess"]];
    imageView.frame = CGRectOffset(imageView.frame, [EBStyle screenWidth]/2.0f - imageView.frame.size.width / 2, 40);
    [self.view addSubview:imageView];
//    CGRect frame = imageView.frame;
//    
//    CGRect suerFrame = self.view.frame;
    
//    [self.view addSubview:[self createLabel:CGRectMake(25, imageView.frame.origin.y + imageView.frame.size.height + 25, [EBStyle screenWidth]- 50, 20) text:NSLocalizedString(@"house_add_success", nil)]];
//    
//    [self.view addSubview:[self createLabel:CGRectMake(25, imageView.frame.origin.y + imageView.frame.size.height + 55, [EBStyle screenWidth]- 50, 20) text:NSLocalizedString(@"house_up_photo_suggest_up", nil)]];
//    
//    [self.view addSubview:[self createLabel:CGRectMake(25, imageView.frame.origin.y + imageView.frame.size.height + 85, [EBStyle screenWidth]- 50, 20) text:NSLocalizedString(@"house_up_photo_suggest_down", nil)]];
    
    UILabel *successLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, imageView.bottom+25, [EBStyle screenWidth] - 50, 20)];
    successLabel.font = [UIFont systemFontOfSize:14.0];
    successLabel.textAlignment = NSTextAlignmentLeft;
    successLabel.textColor = [EBStyle blackTextColor];
    successLabel.numberOfLines = 0;
    successLabel.text = @"您已成功提交新房源。\n\n为了让房源更具吸引力，建议您为其上传照片。";
    [self.view addSubview:successLabel];
    CGSize sizeLabel = [successLabel sizeThatFits:CGSizeMake(successLabel.width, MAXFLOAT)];
    successLabel.height = sizeLabel.height;
    
    
    UIImage *bgN = [[UIImage imageNamed:@"btn_blue_normal"] stretchableImageWithLeftCapWidth:6 topCapHeight:1];
    UIImage *bgP = [[UIImage imageNamed:@"btn_blue_pressed"] stretchableImageWithLeftCapWidth:6 topCapHeight:1];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(25, successLabel.bottom +30, [EBStyle screenWidth]- 50, 36)];
    [btn setBackgroundImage:bgN forState:UIControlStateNormal];
    [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
    btn.adjustsImageWhenHighlighted = NO;
    [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
    [btn setTitle:NSLocalizedString(@"house_up_photo_now", nil) forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn addTarget:self action:@selector(uploadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    CGSize fontSize = [@"以后再说" boundingRectWithSize:CGSizeMake(200, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]} context:nil].size;
    
    UnderLineLabel *label = [[UnderLineLabel alloc] initWithFrame:CGRectMake(160 - fontSize.width/2, btn.bottom + 20, fontSize.width, 30)];
    [label setBackgroundColor:[UIColor clearColor]];
    // [label setBackgroundColor:[UIColor yellowColor]];
    [label setTitleColor:[EBStyle blueTextColor]];
//    [label setTextColor:[EBStyle blueTextColor]];
    label.font = [UIFont systemFontOfSize:14.0];
    label.highlightedColor = [EBStyle grayClickLineColor];
    label.shouldUnderline = YES;
    label.textAlignment = NSTextAlignmentCenter;
    [label setText:@"以后再说" andCenter:CGPointMake(160, 230)];
    [label addTarget:self action:@selector(labelClicked)];
    [self.view addSubview:label];
    label.centerX = [EBStyle screenWidth]/2.0f;
    
    [self addRightNavigationBtnWithTitle:NSLocalizedString(@"toolbar_done", nil) target:self action:@selector(endBtnClick:)];
    self.navigationItem.hidesBackButton = YES;
}

- (void)uploadBtnClick:(UIButton*)btn
{
    [[EBController sharedInstance] showHouseDetailBackRoot:_house uploadTag:YES openType:EHouseDetailOpenTypeAdd];
}

- (void)labelClicked
{
    [[EBController sharedInstance] showHouseDetailBackRoot:_house uploadTag:NO openType:EHouseDetailOpenTypeAdd];
}

- (void)endBtnClick:(UIButton*)btn
{
    [[EBController sharedInstance] showHouseDetailBackRoot:_house uploadTag:NO openType:EHouseDetailOpenTypeAdd];
}

- (UILabel*)createLabel:(CGRect)frame text:(NSString*)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont systemFontOfSize:14.0];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [EBStyle blackTextColor];
    label.numberOfLines = 0;
    label.text = text;
    return label;
}

@end
