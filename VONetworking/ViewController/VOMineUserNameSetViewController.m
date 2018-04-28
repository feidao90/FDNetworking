//
//  VOMineUserNameSetViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/8.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOMineUserNameSetViewController.h"
#import "VOPasswordTextField.h"

#import "VONetworking.h"
#import "UIResultMessageView.h"

#import "VOMinePasswordManagerView.h"
#import "VOLoginManager.h"

#define kUserNameLabelTag 0xDDDDDD
@interface VOMineUserNameSetViewController ()
{
    UIButton *_commitButton;
    UITextField *_newUserName;
    
    UITextField *_verifyInput;
    UIButton *_getVerifyCode;
    
    NSTimer *verifyTimer;
    NSInteger timerCounr;
}
@end

@implementation VOMineUserNameSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //title
    if ([self.userModel.type integerValue] == 1)
    {
        self.navigationItem.title = @"修改登录邮箱";
    }else if ([self.userModel.type integerValue] == 2)
    {
        self.navigationItem.title = @"修改登录手机号";
    }
    
    [self _initSubViews];
}

#pragma mark - _initSubViews
- (void)_initSubViews
{
    //username label
    UILabel *userNameLabel = [UILabel new];
    userNameLabel.tag = kUserNameLabelTag;
    userNameLabel.backgroundColor = [UIColor clearColor];
    userNameLabel.font = [UIFont systemFontOfSize:15.];
    userNameLabel.numberOfLines = 0;
    NSString *baseString = @"";
    NSString *resultString = @"";
    if ([self.userModel.type integerValue] == 1)
    {
        baseString = @"当前登录邮箱：";
        resultString = [baseString stringByAppendingString:self.userModel.email];
    }else if ([self.userModel.type integerValue] == 2)
    {
        baseString = @"当前登录手机号：";
        resultString = [baseString stringByAppendingString:self.userModel.mobilePhone];
    }
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:resultString.length ?  resultString : @""];
    // 设置字体大小
    [attrStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15.] range:NSMakeRange(0, baseString.length)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.] range:NSMakeRange(baseString.length, resultString.length - baseString.length)];
    //字体颜色
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, baseString.length)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor hex:@"8D8C8C"] range:NSMakeRange(baseString.length, resultString.length - baseString.length)];
    CGSize userNameSize = [attrStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 15.*2, 5000) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    userNameLabel.frame = CGRectMake(15., 30., SCREEN_WIDTH - 15.*2, userNameSize.height);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, resultString.length)];
    userNameLabel.attributedText = attrStr;
    [self.view addSubview:userNameLabel];
    
    //新手机号 || 邮箱
    UIView *backgroundView = [self backgroundView];
    backgroundView.frame = CGRectMake(0, userNameLabel.bottom + 20, SCREEN_WIDTH, 46.);
    [self addLineWithSuperView:backgroundView isTop:YES];
    [self.view addSubview:backgroundView];
    
    _newUserName = [self.userModel.type integerValue] == 1 ?  [self getStandardTextField:@"新登录邮箱"] : [self getStandardTextField:@"新登录手机号"];
    _newUserName.frame = CGRectMake(15., 0, SCREEN_WIDTH - 15.*2, 46.);
    [backgroundView addSubview:_newUserName];
    
    UIView *lineView = [self getLineView];
    lineView.frame = CGRectMake(0, _newUserName.bottom - 1, SCREEN_WIDTH, 1);
    [backgroundView addSubview:lineView];
    
    //验证码
    UIView *backgroundViewA = [self backgroundView];
    backgroundViewA.frame = CGRectMake(0, backgroundView.bottom, SCREEN_WIDTH, 46.);
    [self addLineWithSuperView:backgroundViewA isTop:NO];
    [self.view addSubview:backgroundViewA];
    
    _verifyInput = [self getStandardTextField:@"验证码"];
    _verifyInput.frame = CGRectMake(15., 0, SCREEN_WIDTH - 15.*2 - 83. - 15. - 5 - 20., 46.);
    [backgroundViewA addSubview:_verifyInput];
    
    //获取验证码
    _getVerifyCode = [UIButton buttonWithType:UIButtonTypeCustom];
    [_getVerifyCode setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_getVerifyCode setTitleColor:[UIColor hex:@"58A5F7"] forState:UIControlStateNormal];
    [_getVerifyCode addTarget:self action:@selector(getVerify) forControlEvents:UIControlEventTouchUpInside];
    _getVerifyCode.titleLabel.font = [UIFont systemFontOfSize:14.];
    _getVerifyCode.frame = CGRectMake(SCREEN_WIDTH - 83. - 15., backgroundViewA.height/2 - 21./2, 83., 21.);
    [backgroundViewA addSubview:_getVerifyCode];
    
    //竖线条
    UIView *verLineView = [[UIView alloc] initWithFrame:CGRectMake(_getVerifyCode.left - .5 - 20., backgroundViewA.height/2 - 20./2, 1, 20.)];
    verLineView.backgroundColor = [UIColor hex:@"EBEBEB"];
    [backgroundViewA addSubview:verLineView];
    
    //提交
    _commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _commitButton.layer.backgroundColor = [UIColor hex:@"D1D2DC"].CGColor;
    _commitButton.layer.cornerRadius = 2.;
    _commitButton.layer.masksToBounds = YES;
    [_commitButton setTitle:@"提交" forState:UIControlStateNormal];
    [_commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _commitButton.titleLabel.font = [UIFont systemFontOfSize:16.];
    _commitButton.frame = CGRectMake(10., backgroundViewA.bottom + 60., SCREEN_WIDTH - 10.*2, 42.);
    _commitButton.userInteractionEnabled = NO;
    [_commitButton addTarget:self action:@selector(commitNewPW) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_commitButton];
}

//添加边框
- (void)addLineWithSuperView:(UIView *)superView isTop:(BOOL)isTop
{
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.bounds = CGRectMake(superView.left, isTop ? superView.top : superView.bottom, superView.width, 1.);
    borderLayer.position= CGPointMake(superView.left + superView.width/2, isTop ? 0 : (superView.height + 1));
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(superView.left, isTop ? superView.top : superView.bottom)];
    [path addLineToPoint:CGPointMake(superView.width, isTop ? superView.top : superView.bottom)];
    
    borderLayer.path = path.CGPath;
    borderLayer.lineWidth=1.;
    borderLayer.lineDashPattern= nil;
    borderLayer.fillColor= [UIColor clearColor].CGColor;
    borderLayer.strokeColor= [UIColor hex:@"000000" alpha:8/255.].CGColor;
    [superView.layer addSublayer:borderLayer];
}

- (VOPasswordTextField *)getStandardTextField:(NSString *)placeholder
{
    VOPasswordTextField *textField = [VOPasswordTextField new];
    textField.borderStyle = UITextBorderStyleNone;
    textField.backgroundColor = [UIColor whiteColor];
    textField.textColor = [UIColor blackColor];
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor hex:@"B2B1C0"],NSForegroundColorAttributeName,[UIFont systemFontOfSize:17.],NSFontAttributeName, nil]] ;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.text = @"";
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    return textField;
}

- (UIView *)getLineView
{
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor hex:@"EBEBEB"];
    return lineView;
}

- (UIView *)backgroundView
{
    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = [UIColor whiteColor];
    return backView;
}

- (void)refreshUserName:(NSString *)result
{
    UILabel *userNameLabel = [self.view viewWithTag:kUserNameLabelTag];
    NSString *baseString = @"";
    NSString *resultString = @"";
    if ([self.userModel.type integerValue] == 1)
    {
        baseString = @"当前登录邮箱：";
        resultString = [baseString stringByAppendingString:result];
    }else if ([self.userModel.type integerValue] == 2)
    {
        baseString = @"当前登录手机号：";
        resultString = [baseString stringByAppendingString:result];
    }
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:resultString.length ?  resultString : @""];
    // 设置字体大小
    [attrStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15.] range:NSMakeRange(0, baseString.length)];
    //字体颜色
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, baseString.length)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor hex:@"8D8C8C"] range:NSMakeRange(baseString.length, resultString.length - baseString.length)];
    userNameLabel.attributedText = attrStr;
}
#pragma mark - 验证码倒计时
- (void)resetVerifyCode
{
    if (timerCounr) {
        [_getVerifyCode setTitle:[NSString stringWithFormat:@"%ld秒后重获",(long)timerCounr] forState:UIControlStateNormal];
        CGSize verifySize = [_getVerifyCode.titleLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:_getVerifyCode.titleLabel.font,NSFontAttributeName, nil]];
        _getVerifyCode.width = verifySize.width;
        timerCounr -= 1;
    }else
    {
        _getVerifyCode.userInteractionEnabled = YES;
        [_getVerifyCode setTitle:@"获取验证码" forState:UIControlStateNormal];
        CGSize verifySize = [_getVerifyCode.titleLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:_getVerifyCode.titleLabel.font,NSFontAttributeName, nil]];
        _getVerifyCode.width = verifySize.width;
        [verifyTimer invalidate];
        verifyTimer = nil;
    }
}

#pragma mark - 获取验证码
- (void)getVerify
{
    switch ([self.userModel.type integerValue]) {
        case 1:
        {
            if ([_newUserName.text isEqualToString:self.userModel.email])
            {
                UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15.,  10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
                [messageView showMessageViewWithMessage:@"新登录邮箱与当前相同"];
                return;
            }else
            {
                if (!verifyTimer)
                {
                    _getVerifyCode.userInteractionEnabled = NO;
                    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                    verifyTimer =  [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(resetVerifyCode) userInfo:nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:verifyTimer  forMode:NSRunLoopCommonModes];
                }
                timerCounr = 59.;
                NSDictionary *params =  [NSDictionary dictionaryWithObjectsAndKeys:_newUserName.text,@"email", nil];
                [VONetworking postWithUrl:@"/v1.0.0/api/user/account/email/verifycode" refreshRequest:NO cache:NO params:params needSession:NO  successBlock:^(id response) {
                    UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15.,  10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:YES withSuperView:self.view];
                    [messageView showMessageViewWithMessage:@"验证码已发送"];
                } failBlock:^(NSError *error) {
                    if (error)
                    {
                        timerCounr = 0;
                        if (error.code != -9999)    // -9999为无网络码
                        {
                            NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
                            UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
                            [messageView showMessageViewWithMessage:errorMessage];
                        }
                    }
                }];
            }
        }
            break;
        case 2:
        {
            if ([_newUserName.text isEqualToString:self.userModel.mobilePhone])
            {
                UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15.,  10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
                [messageView showMessageViewWithMessage:@"新登录手机号与当前相同"];
                return;
            }else
            {
                if (!verifyTimer)
                {
                    _getVerifyCode.userInteractionEnabled = NO;
                    timerCounr = 59.;
                    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                    verifyTimer = [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(resetVerifyCode) userInfo:nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:verifyTimer  forMode:NSRunLoopCommonModes];
                }
                NSDictionary *params =  [NSDictionary dictionaryWithObjectsAndKeys:_newUserName.text,@"mobilePhone", nil];
                [VONetworking postWithUrl:@"/v1.0.0/api/user/account/mobilephone/verifycode" refreshRequest:NO cache:NO params:params needSession:NO  successBlock:^(id response) {
                    UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15.,  10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:YES withSuperView:self.view];
                    [messageView showMessageViewWithMessage:@"验证码已发送"];
                } failBlock:^(NSError *error) {
                    if (error)
                    {
                        timerCounr = 0;
                        if (error.code != -9999)    // -9999为无网络码
                        {
                            NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
                            UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
                            [messageView showMessageViewWithMessage:errorMessage];
                        }
                    }
                }];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - textFieldDidChange
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == _newUserName) {
        if([[[VOLoginManager shared] getUserType] integerValue] == 1)
        {
            if (textField.text.length > 190) {
                textField.text = [textField.text substringToIndex:190];
            }
        }else
        {
            if (textField.text.length > 20) {
                textField.text = [textField.text substringToIndex:20];
            }
        }
    }else if (textField == _verifyInput)
    {
        if (textField.text.length > 6) {
            textField.text = [textField.text substringToIndex:6];
        }
    }
    [self comfirStatus];
}

- (void)comfirStatus
{
    if (_commitButton.userInteractionEnabled)
    {
        if (!_newUserName.text.length || !_verifyInput.text.length)
        {
            _commitButton.userInteractionEnabled = NO;
            _commitButton.backgroundColor = [UIColor hex:@"D1D2DC"];
            
        }
    }else
    {
        if (_newUserName.text.length && _verifyInput.text.length)
        {
            _commitButton.userInteractionEnabled = YES;
            _commitButton.backgroundColor = [UIColor hex:@"58A5F7"];
        }
    }
}

#pragma mark - 提交新密码
- (void)commitNewPW
{
   switch ([self.userModel.type integerValue]) {
           case 1:
       {
           NSDictionary *params =  [NSDictionary dictionaryWithObjectsAndKeys:_newUserName.text,@"email", _verifyInput.text,@"verifyCode", nil];
           [VONetworking putWithUrl:@"/v1.0.0/api/user/account/email" refreshRequest:NO cache:NO params:params needSession:NO  successBlock:^(id response) {
               //关闭键盘
               [self.view endEditing:YES];
               VOMinePasswordManagerView *managerView = [[VOMinePasswordManagerView alloc] initWithMangerType:VOManagerMineEmail];
               managerView.userName = _newUserName.text;
               //刷新当前页面
               [self refreshUserName:_newUserName.text];
               //更新数据源
               self.userModel.email = _newUserName.text;
               __weak VOMineUserNameSetViewController *weakSelf = self;
               managerView.block = ^{
                   __strong VOMineUserNameSetViewController *strongSelf = weakSelf;
                   [strongSelf.navigationController popViewControllerAnimated:YES];
               };
               [managerView showView];
           } failBlock:^(NSError *error) {
               if (error)
               {
                   if (error.code != -9999)    // -9999为无网络码
                   {
                       NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
                       UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
                       [messageView showMessageViewWithMessage:errorMessage];
                   }
               }
           }];
       }
           break;
           case 2:
       {
           NSDictionary *params =  [NSDictionary dictionaryWithObjectsAndKeys:_newUserName.text,@"mobilePhone",_verifyInput.text,@"verifyCode", nil];
           [VONetworking putWithUrl:@"/v1.0.0/api/user/account/mobilephone" refreshRequest:NO cache:NO params:params needSession:NO  successBlock:^(id response) {
               //关闭键盘
               [self.view endEditing:YES];
               VOMinePasswordManagerView *managerView = [[VOMinePasswordManagerView alloc] initWithMangerType:VOManagerMinePhone];
               managerView.userName = _newUserName.text;
               //刷新当前页面
               [self refreshUserName:_newUserName.text];
               //更新数据源
               self.userModel.mobilePhone = _newUserName.text;
               __weak VOMineUserNameSetViewController *weakSelf = self;
               managerView.block = ^{
                   __strong VOMineUserNameSetViewController *strongSelf = weakSelf;
                   [strongSelf.navigationController popViewControllerAnimated:YES];
               };
               [managerView showView];
           } failBlock:^(NSError *error) {
               if (error)
               {
                   if (error.code != -9999)    // -9999为无网络码
                   {
                       NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
                       UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
                       [messageView showMessageViewWithMessage:errorMessage];
                   }
               }
           }];
       }
           break;
           default:
                break;
   }
}

#pragma mark - 收起键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
