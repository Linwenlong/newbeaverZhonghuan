//
//  AddMyMemoradumViewController.m
//  beaver
//
//  Created by mac on 17/8/15.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "AddMyMemoradumViewController.h"
#import "EBAlert.h"
#import "HttpTool.h"
#import "EBPreferences.h"

@interface AddMyMemoradumViewController ()<UITextViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *tip1;
@property (weak, nonatomic) IBOutlet UILabel *tip2;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UILabel *titleContent;

@end

@implementation AddMyMemoradumViewController

- (void)setUI{
    
    _titleContent.textColor = [UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.00];
    _content.textColor = [UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.00];
    
    
    _titleTextField.layer.borderColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00].CGColor;

    [_titleTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _titleTextField.layer.borderWidth = 1.0f;
    UILabel * leftView = [[UILabel alloc] initWithFrame:CGRectMake(10,0,7,26)];
    
    leftView.backgroundColor = [UIColor clearColor];
    _titleTextField.leftView = leftView;
    _titleTextField.leftViewMode = UITextFieldViewModeAlways;
    _titleTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
   
    _contentTextView.layer.borderColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00].CGColor;
    _contentTextView.delegate = self;
    _contentTextView.layer.borderWidth = 1.0f;
    
    
    _tip1.textColor = UIColorFromRGB(0xa4a4a4);
    _tip2.textColor = UIColorFromRGB(0xa4a4a4);
    
    
    _addBtn.layer.cornerRadius = 5.0f;
    _addBtn.clipsToBounds = YES;
    _addBtn.backgroundColor = UIColorFromRGB(0xff3800);
    [_addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _addBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"新增";
    
    _contentTextView.text = @"";
    
    [self setUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

- (IBAction)btnClick:(id)sender {
    //判断是否为空
    if (_titleTextField.text.length == 0 ) {
        [EBAlert alertError:@"请输入标题" length:1.0];
        return;
    }
    if (_contentTextView.text.length == 0) {
        [EBAlert alertError:@"请输入内容" length:1.0];
        return;
    }
    if (_contentTextView.text.length < 20) {
        [EBAlert alertError:@"输入的内容必须超过20个字" length:1.0];
        return;
    }
    //获取当前日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm"];
    NSString *currentOlderOneDateStr = [dateFormatter stringFromDate:[NSDate date]];
    
    //新增备忘录
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/Memo/memoAdd?token=%@&date=%@&title=%@&content=%@",[EBPreferences sharedInstance].token,currentOlderOneDateStr,_titleTextField.text,_contentTextView.text]);
    NSString *urlStr = @"Memo/memoAdd";
    [EBAlert showLoading:@"添加中..."];
    [HttpTool post:urlStr parameters:
     @{ @"token":[EBPreferences sharedInstance].token,
           @"date":currentOlderOneDateStr,
           @"title":_titleTextField.text,
           @"content":_contentTextView.text
       }success:^(id responseObject) {
            [EBAlert hideLoading];
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           if ([currentDic[@"code"] integerValue] == 0) {
               [EBAlert alertSuccess:@"添加成功" allowUserInteraction:1.0f];
               self.textBlock();//调用block
               [self.navigationController popViewControllerAnimated:YES];
           }else{
               [EBAlert alertSuccess:@"添加失败"];
            
           }
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
     self.tip2.text = [NSString stringWithFormat:@"%ld/%d",existTextNum,MAX_LIMIT_NUMS];
}

#define MAX_LENGTH 14

- (void)textFieldDidChange:(UITextField *)textField{
    NSString *toBeString = textField.text;
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制,防止中文被截断
    if (!position){
        if (toBeString.length > MAX_LENGTH){
            //中文和emoj表情存在问题，需要对此进行处理
            NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, MAX_LENGTH)];
            textField.text = [toBeString substringWithRange:rangeRange];
        }else{
          _tip1.text = [NSString stringWithFormat:@"%lu/%d",textField.text.length,MAX_LENGTH];
        }
    }
}


@end
