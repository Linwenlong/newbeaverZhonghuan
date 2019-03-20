//
//  MyMemorandumDetailViewController.m
//  beaver
//
//  Created by mac on 17/8/16.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MyMemorandumDetailViewController.h"
#import "MyMemoranduModel.h"

@interface MyMemorandumDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *myTitle;//标题
@property (weak, nonatomic) IBOutlet UILabel *date;//日期
@property (weak, nonatomic) IBOutlet UITextView *content;//内容

@end

@implementation MyMemorandumDetailViewController

- (void)setUI{
    _myTitle.textColor = UIColorFromRGB(0x404040);
    _date.textColor = UIColorFromRGB(0x808080);
    _content.textColor = UIColorFromRGB(0x808080);
    _myTitle.text = _model.title;
    _date.text = _model.create_time;
    _content.text = [NSString stringWithFormat:@"    %@",_model.content];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"备忘详情";
    [self setUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
