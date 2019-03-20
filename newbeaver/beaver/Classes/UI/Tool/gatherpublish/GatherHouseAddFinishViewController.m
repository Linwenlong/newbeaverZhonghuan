//
//  GatherHouseAddFinishViewController.m
//  beaver
//
//  Created by wangyuliang on 14-9-9.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "GatherHouseAddFinishViewController.h"
#import "UnderLineLabel.h"
#import "EBViewFactory.h"
#import "EBController.h"
#import "RIButtonItem.h"
#import "AGImagePickerController.h"
#import "HousePhotoPreUploadViewController.h"
#import "EBHousePhotoUploader.h"
#import "UIActionSheet+Blocks.h"

@interface GatherHouseAddFinishViewController ()

@end

@implementation GatherHouseAddFinishViewController

- (void)loadView
{
    [super loadView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_addhouse_sucess"]];
    imageView.frame = CGRectOffset(imageView.frame, 160 - imageView.frame.size.width / 2, 40);
    [self.view addSubview:imageView];
//    CGRect frame = imageView.frame;
//    
//    CGRect suerFrame = self.view.frame;
    
    [self.view addSubview:[self createLabel:CGRectMake(25, imageView.frame.origin.y + imageView.frame.size.height + 25, 270, 20) text:NSLocalizedString(@"gather_house_add_erp_success", nil)]];
    
    [self.view addSubview:[self createLabel:CGRectMake(25, imageView.frame.origin.y + imageView.frame.size.height + 55, 280, 20) text:NSLocalizedString(@"house_up_photo_suggest_up", nil)]];
    
    [self.view addSubview:[self createLabel:CGRectMake(25, imageView.frame.origin.y + imageView.frame.size.height + 85, 280, 20) text:NSLocalizedString(@"house_up_photo_suggest_down", nil)]];
    
    UIImage *bgN = [[UIImage imageNamed:@"btn_blue_normal"] stretchableImageWithLeftCapWidth:6 topCapHeight:1];
    UIImage *bgP = [[UIImage imageNamed:@"btn_blue_pressed"] stretchableImageWithLeftCapWidth:6 topCapHeight:1];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(25, imageView.frame.size.height + 160, 270, 36)];
    [btn setBackgroundImage:bgN forState:UIControlStateNormal];
    [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
    btn.adjustsImageWhenHighlighted = NO;
    [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
    [btn setTitle:NSLocalizedString(@"house_up_photo_now", nil) forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn addTarget:self action:@selector(uploadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    CGSize fontSize =[@"以后再说" sizeWithFont:[UIFont systemFontOfSize:14.0]
                                  forWidth:200
                             lineBreakMode:NSLineBreakByTruncatingTail];
    UnderLineLabel *label = [[UnderLineLabel alloc] initWithFrame:CGRectMake(160 - fontSize.width/2, 255, 300, 30)];
    [label setBackgroundColor:[UIColor clearColor]];
    // [label setBackgroundColor:[UIColor yellowColor]];
    [label setTitleColor:[EBStyle blueTextColor]];
    //    [label setTextColor:[EBStyle blueTextColor]];
    label.font = [UIFont systemFontOfSize:14.0];
    label.highlightedColor = [EBStyle grayClickLineColor];
    label.shouldUnderline = YES;
    [label setText:@"以后再说" andCenter:CGPointMake(160, 230)];
    [label addTarget:self action:@selector(labelClicked)];
    [self.view addSubview:label];
    
    [self addRightNavigationBtnWithTitle:NSLocalizedString(@"toolbar_done", nil) target:self action:@selector(endBtnClick:)];
    self.navigationItem.hidesBackButton = YES;
}

- (void)uploadBtnClick:(UIButton*)btn
{
    [[EBController sharedInstance] showHouseDetailBackRoot:_house uploadTag:YES openType:EHouseDetailOpenTypeGatherToErp];
}

- (void)labelClicked
{
    [[EBController sharedInstance] showHouseDetailBackRoot:_house uploadTag:NO openType:EHouseDetailOpenTypeGatherToErp];
}

- (void)endBtnClick:(UIButton*)btn
{
    [[EBController sharedInstance] showHouseDetailBackRoot:_house uploadTag:NO openType:EHouseDetailOpenTypeGatherToErp];
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
