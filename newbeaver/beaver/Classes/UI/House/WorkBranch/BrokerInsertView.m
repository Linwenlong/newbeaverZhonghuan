//
//  BrokerInsertView.m
//  beaver
//
//  Created by mac on 18/1/30.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "BrokerInsertView.h"

@implementation BrokerInsertView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self = [super initWithFrame:(CGRect)frame]) {
        [self setUI];
    }
    return self;
}


- (void)setUI{
    
    _deleteImage = [UIImageView new];
    _deleteImage.userInteractionEnabled = YES;
    _deleteImage.image = [UIImage imageNamed:@"workDelete"];
    
    
    _backView = [UIView new];
    _backView.clipsToBounds = YES;
    _backView.layer.borderColor = LWL_LineColor.CGColor;
    _backView.layer.borderWidth = 1.0f;
    _backView.layer.cornerRadius = 3.0f;
    
    
    UILabel *name = [UILabel new];
    name.text = @"姓名";
    name.textAlignment = NSTextAlignmentLeft;
    name.font = [UIFont systemFontOfSize:14.0f];
    name.textColor = UIColorFromRGB(0x404040);
    
    _nameField = [UILabel new];
    _nameField.font = [UIFont systemFontOfSize:14.0f];
    _nameField.textColor = UIColorFromRGB(0x404040);
    _nameField.textAlignment = NSTextAlignmentLeft;
    
    UIView *line = [UIView new];
    line.backgroundColor = UIColorFromRGB(0xF5F5F5);
    
    UILabel *clinetCode = [UILabel new];
    clinetCode.text = @"客源号";
    clinetCode.textAlignment = NSTextAlignmentLeft;
    clinetCode.font = [UIFont systemFontOfSize:14.0f];
    clinetCode.textColor = UIColorFromRGB(0x404040);
    
    _chooseClientCode = [UIButton new];
    [_chooseClientCode setTitle:@"请选择客源编号" forState:UIControlStateNormal];
    _chooseClientCode.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_chooseClientCode setTitleColor:LWL_BlueColor forState:UIControlStateNormal];
    _chooseClientCode.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    
    UIView *line1 = [UIView new];
    line1.backgroundColor = UIColorFromRGB(0xF5F5F5);
    
    UILabel *lable = [UILabel new];
    lable.text = @"情况汇报及下一步方案";
    lable.textAlignment = NSTextAlignmentLeft;
    lable.font = [UIFont systemFontOfSize:14.0f];
    lable.textColor = UIColorFromRGB(0x404040);
    
    CGFloat radius = 5.0f;
    _contentTextView = [UITextView new];
    _contentTextView.font = [UIFont systemFontOfSize:14.0f];
    _contentTextView.textColor = [UIColor blackColor];
    _contentTextView.backgroundColor = UIColorFromRGB(0xEBEBEB);
    _contentTextView.layer.cornerRadius = radius;
    _contentTextView.clipsToBounds = YES;
    
    _tipLable = [UILabel new];
    _tipLable.text = @"0/200字";
    _tipLable.textAlignment = NSTextAlignmentRight;
    _tipLable.font = [UIFont systemFontOfSize:13.0f];
    _tipLable.textColor = UIColorFromRGB(0x808080);
    NSLog(@"self=%@",self.backView);
    
    [self.backView sd_addSubviews:@[name,_nameField,line,clinetCode,_chooseClientCode,line1,lable,_contentTextView,_tipLable]];
    
    [self sd_addSubviews:@[_backView,_deleteImage]];
    
    
    _deleteImage.sd_layout
    .topSpaceToView(self,0)
    .rightSpaceToView(self,8)
    .widthIs(21)
    .heightIs(21);
    
    _backView.sd_layout
    .topSpaceToView(self,8)
    .bottomSpaceToView(self,8)
    .leftSpaceToView(self,7)
    .rightSpaceToView(self,7);
    
    name.sd_layout
    .topSpaceToView(self.backView,15)
    .leftSpaceToView(self.backView,8)
    .widthIs(33)
    .heightIs(13);
    
    _nameField.sd_layout
    .topSpaceToView(self.backView,15)
    .leftSpaceToView(name,3)
    .rightSpaceToView(self.backView,8)
    .heightIs(13);
    
    line.sd_layout
    .topSpaceToView(name,15)
    .leftSpaceToView(self.backView,0)
    .rightSpaceToView(self.backView,0)
    .heightIs(1);
    
    clinetCode.sd_layout
    .topSpaceToView(line,15)
    .leftSpaceToView(self.backView,8)
    .widthIs(47)
    .heightIs(13);
    
    _chooseClientCode.sd_layout
    .topSpaceToView(line,15)
    .leftSpaceToView(clinetCode,8)
    .rightSpaceToView(self.backView,8)
    .heightIs(13);
    
    line1.sd_layout
    .topSpaceToView(clinetCode,15)
    .leftSpaceToView(self.backView,0)
    .rightSpaceToView(self.backView,0)
    .heightIs(1);
    
    lable.sd_layout
    .topSpaceToView(line1,15)
    .leftSpaceToView(self.backView,8)
    .widthIs(161)
    .heightIs(13);
    
    _contentTextView.sd_layout
    .topSpaceToView(lable,15)
    .leftSpaceToView(self.backView,8)
    .rightSpaceToView(self.backView,8)
    .heightIs(120);
    
    _tipLable.sd_layout
    .bottomSpaceToView(self.backView,22)
    .rightSpaceToView(self.backView,16)
    .widthIs(103)
    .heightIs(22);
    
    [self bringSubviewToFront:_deleteImage];
}


- (void)request:(NSString *)jsonStr{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer  = [AFJSONRequestSerializer serializer];
    
    [manager.requestSerializer setValue:[EBPreferences sharedInstance].token forHTTPHeaderField:@"token"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept" ];
    [manager.requestSerializer setValue:@"application/json; charset=gb2312" forHTTPHeaderField:@"Content-Type" ];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json",@"text/html", @"text/plain",nil];
    
    /**
     *  parameters最外层参数类型是一个字典，字典里面接受一接受一个数组"detailArr"(其中detailArr中添加一个字典对象)
     */
    //讲字典类型转换成json格式的数据，然后讲这个json字符串作为字典参数的value传到服务器
    
    NSLog(@"jsonStr:%@",jsonStr);
    //    [parm setObject:[EBPreferences sharedInstance].token forKey:@"token"];
    NSDictionary *params = @{@"token":[EBPreferences sharedInstance].token}; //服务器最终接受到的对象，是一个字典，key为“ios”，value为“json字符串”
    NSLog(@"params=%@",params);
    
    NSString *url=@"http://117.40.248.135:8010/jobsummary/jobSummaryOperated";
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //服务器默认返回的是一个NSData类型，需要将返回的这个类型转换成你所需要的类型，一般是id
        NSLog(@"result:%@",responseObject); //最后得到服务器返回的正确数据
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"jsonDict=%@",jsonDict);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


@end
