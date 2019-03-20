//
//  ZHDCUpdataPhotoViewController.m
//  beaver
//
//  Created by mac on 17/6/28.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ZHDCUpdataPhotoViewController.h"
#import "SDAutoLayout.h"
#import "XXTextView.h"
#import "EBUpdater.h"
#import "EBController.h"
#import "AESCrypt.h"
#import "HttpTool.h"
#import "EBPreferences.h"
#import "EBAlert.h"

@interface ZHDCUpdataPhotoViewController ()

@property (nonatomic, strong)UIImageView *updataImage;
@property (nonatomic,strong) XXTextView    *mainTextView;
@property (nonatomic, strong)UIButton  *btn;

@end

@implementation ZHDCUpdataPhotoViewController

- (void)updataimage:(UIButton *)btn{
    [self updatephoto:_image];
}


- (void)setUI{
    _updataImage = [UIImageView new];
    _updataImage.image = _image;
    
    _mainTextView = [XXTextView new];
    _mainTextView.backgroundColor = [UIColor whiteColor];
    _mainTextView.xx_placeholderFont = [UIFont systemFontOfSize:14.0f];
    _mainTextView.xx_placeholderColor = [UIColor lightGrayColor];
    _mainTextView.xx_placeholder = @"请输入图片备注...";
    
    _btn = [UIButton new];
    [_btn setTitle:@"点击上传" forState:UIControlStateNormal];
    [_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btn.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    _btn.backgroundColor = [UIColor redColor];
    [_btn addTarget:self action:@selector(updataimage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view sd_addSubviews:@[_updataImage,_mainTextView,_btn]];

    _updataImage.sd_layout
    .topSpaceToView(self.view,10)
    .centerXEqualToView(self.view)
    .widthIs(kScreenW)
    .heightIs(300);
    
    _mainTextView.sd_layout
    .topSpaceToView(_updataImage,20)
    .leftSpaceToView(self.view,0)
    .rightSpaceToView(self.view,0)
    .heightIs(200);
    
    _btn.sd_layout
    .bottomSpaceToView(self.view,0)
    .leftSpaceToView(self.view,0)
    .rightSpaceToView(self.view,0)
    .heightIs(50);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
    lable.textColor = [UIColor whiteColor];
    lable.text= @"上传图片";
    lable.textAlignment = NSTextAlignmentCenter;
    lable.font = [UIFont systemFontOfSize:20.0f];
    self.navigationItem.titleView = lable;
    [self setUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

- (void)updatephoto:(UIImage *)image{
    
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    NSDictionary* custom_detail = @{
                                    @"type" : @"house"
                                    };
    NSDictionary* dic = @{
                          @"image1":data
                          };
    NSString *talUrl = [NSString stringWithFormat:@"%@/newHouse/uploadImage?token=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token];
    NSLog(@"talurl = %@",talUrl);
    [EBAlert showLoading:@"图片上传中..."];
    [HttpTool updateImageWithUrl:talUrl HTTPMethod:@"POST" params:[[self wrappedParameters:custom_detail] mutableCopy] fileData:[dic mutableCopy] successBlock:^(id result) {
        //得到了图片,上传到服务器
        NSString *url = result[@"data"][@"url"];
        [self updataData:url];
    } failureBlock:^(NSError *error) {
        [EBAlert hideLoading];

        [EBAlert alertError:@"上传失败" length:2.0];
    }];
}

- (void)updataData:(NSString *)url{

    NSDictionary  *dic = @{
                           @"token":[EBPreferences sharedInstance].token,
                           @"new_house_id":_house_id,
                           @"records_id":_document_id,
                           @"uri":url,
                           @"content":_mainTextView.text
                           };
    NSLog(@"%@/NewHouse/addReportImage?token=%@&new_house_id=%@&records_id=%@&uri=%@&content=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,_house_id,_document_id,url,_mainTextView.text);
    [HttpTool post:@"NewHouse/addReportImage" parameters:dic success:^(id responseObject) {
         [EBAlert hideLoading];
        
      NSDictionary *dic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSNumber *number = dic[@"code"];
        if ([number intValue]== 0) {
            [EBAlert alertSuccess:@"上传成功" length:2.0];
        }else{
             [EBAlert alertSuccess:@"上传失败" length:2.0];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSError *error) {
        [EBAlert hideLoading];
         [EBAlert alertError:@"上传失败" length:2.0];
        [self dismissViewControllerAnimated:YES completion:nil];

    }];
}

#pragma mark -- 配置参数
- (NSDictionary *)wrappedParameters:(NSDictionary *)parameters
{
    EBPreferences *pref = [EBPreferences sharedInstance];
    NSMutableDictionary *md = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    
    md[@"token"] = pref.token;
    
    NSLog(@"md - token  =%@", md[@"token"] );
    md[@"b_p"] = @"iphone";
    md[@"b_v"] = [EBUpdater localVersion];
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([[NSDate date] timeIntervalSince1970]*1000)];
    md[@"eagle_time"] = timeSp;
    md[@"eagle_key"]  = [[EBController sharedInstance] getEagleKeyWithDate:timeSp];
    
    
    
    NSArray *encryptedArgs = @[@"passwd", @"password", @"old_password", @"new_password", @"account"];
    
    for (NSString *key in encryptedArgs)
    {
        if (md[key])
        {
            md[key] = [AESCrypt encryptStr:md[key]];
        }
    }
    
    return md;
}


@end
