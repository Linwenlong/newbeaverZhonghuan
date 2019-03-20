//
//  HouseForceFollowupViewController.m
//  beaver
//
//  Created by mac on 17/10/24.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "HouseForceFollowupViewController.h"
#import "PINTextView.h"
#import "HttpTool.h"
#import "EBHttpClient.h"

@interface HouseForceFollowupViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *followupway;
@property (weak, nonatomic) IBOutlet UILabel *checkupNumber;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UILabel *followuptype;

@property (weak, nonatomic) IBOutlet PINTextView *followupContent;
@property (weak, nonatomic) IBOutlet UILabel *characterCount;
@property (weak, nonatomic) IBOutlet UIButton *comfirn;

@end

@implementation HouseForceFollowupViewController

- (void)setUI{
    
    _followupway.textColor = UIColorFromRGB(0x404040);
    _followuptype.textColor = UIColorFromRGB(0x404040);
    
    _checkupNumber.textColor = UIColorFromRGB(0x808080);
    
    _lineView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    _lineView.layer.borderColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.00].CGColor;
    _lineView.layer.borderWidth = 1.0f;
    
    _followupContent.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.00];
    _followupContent.placeholder = @"请输入跟进内容(必填)";
    _followupContent.placeholderColor = UIColorFromRGB(0x808080);
    _followupContent.layer.cornerRadius = 5.0f;
    _followupContent.delegate = self;
    
    _characterCount.textColor = UIColorFromRGB(0x808080);
    _comfirn.backgroundColor = UIColorFromRGB(0xff3800);
    _comfirn.layer.cornerRadius = 5.0f;
    [_comfirn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"强制跟进";
    NSLog(@"phoneNumber = %@",_phoneNum);
    [self setUI];
}
//提交数据
- (IBAction)updateData:(id)sender {
    if (self.followupContent.text.length < 5) {
        [EBAlert alertError:@"跟进字数必须大于5个" length:2.0f];
        return;
    }
   
    if (self.house_id == nil) {
        [EBAlert alertError:@"数据加载错误,请重新加载" length:2.0f];
        return;
    }

        //更新数据
        //关注小区
    NSString *urlStr = @"follow/addFollow";
    NSDictionary *parm = @{
                           @"house_id":self.house_id,
                           @"follow_way":@"查看电话",
                           @"content":_followupContent.text,
                           @"token":[EBPreferences sharedInstance].token
                           };
        [EBAlert showLoading:@"加载中..."];
        [HttpTool post:urlStr parameters:parm
            success:^(id responseObject) {
                [EBAlert hideLoading];
                NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                if ([currentDic[@"code"] integerValue] == 0) {
                     BOOL succeed = YES;
                    self.returnBlock(succeed);
                }else{
                    [EBAlert alertError:currentDic[@"desc"] length:2.0f];
                    //                self.textBlock();//调用block
                }
                 [self.navigationController popViewControllerAnimated:YES];
            } failure:^(NSError *error) {
                [EBAlert hideLoading];
                [EBAlert alertError:@"请检查网络" length:2.0f];
        }];
}

#define MAX_LIMIT_NUMS 500

#pragma mark -- UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger caninputlen = MAX_LIMIT_NUMS - comcatstr.length;
    if (caninputlen >= 0){
        return YES;
    }else{
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        if (rg.length > 0){
            NSString *s = [text substringWithRange:rg];
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
        }
        return NO;
    }
}

-(void)textViewDidChange:(UITextView *)textView{
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    if (existTextNum > MAX_LIMIT_NUMS){
        //截取到最大位置的字符
        NSString *s = [nsTextContent substringToIndex:MAX_LIMIT_NUMS];
        [textView setText:s];
    }
    self.characterCount.text = [NSString stringWithFormat:@"%ld/%d",MAX(0,existTextNum),MAX_LIMIT_NUMS];
}

@end
