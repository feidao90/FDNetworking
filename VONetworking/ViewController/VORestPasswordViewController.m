//
//  VORestPasswordViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/8.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "VORestPasswordViewController.h"
#import "UIResultMessageView.h"

#import "VONetworking+Session.h"
#import "VOPasswordTextField.h"

#import "VOBaseHeader.h"
@interface VORestPasswordViewController ()<UITextFieldDelegate>
{
    UITextField *_userName;
    UITextField *_identifyCode;
    
    UIButton *_getVerifyCode;
    VOPasswordTextField *_userNewPassword;
    
    UIButton *_commitButton;
    NSTimer *verifyTimer;
    NSInteger timerCounr;
}
@end

@implementation VORestPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"忘记密码";
    self.view.backgroundColor = [UIColor hex:@"F2F3F8"];
    
    //_initSubViews
    [self _initSubViews];
}

#pragma mark - _initSubViews
- (void)_initSubViews
{
    CGFloat offSet = 0;
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, offSet + 20, self.view.width, 46*2)];
    backView.backgroundColor = [UIColor whiteColor];
    [self addLineWithSuperView:backView isTop:YES];
    [self addLineWithSuperView:backView isTop:NO];
    [self.view addSubview:backView];
    
    //用户名
    _userName = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, backView.width - 15*2, 46)];
    _userName.borderStyle = UITextBorderStyleNone;
    _userName.backgroundColor = [UIColor clearColor];
    _userName.textColor = [UIColor blackColor];
    _userName.keyboardType = self.accountType ?  UIKeyboardTypeNumberPad : UIKeyboardTypeDefault;
    _userName.delegate = self;
    _userName.attributedPlaceholder = self.accountType ? [[NSAttributedString alloc] initWithString:@"登录手机号码" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor hex:@"B2B1C0"],NSForegroundColorAttributeName,[UIFont systemFontOfSize:17.],NSFontAttributeName, nil]] : [[NSAttributedString alloc] initWithString:@"登录邮箱" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor hex:@"B2B1C0"],NSForegroundColorAttributeName,[UIFont systemFontOfSize:17.],NSFontAttributeName, nil]];
    _userName.autocorrectionType = UITextAutocorrectionTypeNo;
    _userName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _userName.text = @"";
    [_userName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [backView addSubview:_userName];
    
    //lineview
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _userName.bottom - 1, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = [UIColor hex:@"EBEBEB"];
    [backView addSubview:lineView];
    
    //验证码
    _identifyCode = [[UITextField alloc] initWithFrame:CGRectMake(15, _userName.bottom, backView.width - 15*2, 46)];
    _identifyCode.borderStyle = UITextBorderStyleNone;
    _identifyCode.backgroundColor = [UIColor whiteColor];
    _identifyCode.textColor = [UIColor blackColor];
    _identifyCode.keyboardType = UIKeyboardTypeNumberPad;
    _identifyCode.delegate = self;
    _identifyCode.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"验证码" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor hex:@"B2B1C0"],NSForegroundColorAttributeName,[UIFont systemFontOfSize:17.],NSFontAttributeName, nil]];
    _identifyCode.autocorrectionType = UITextAutocorrectionTypeNo;
    _identifyCode.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _identifyCode.text = @"";
    [_identifyCode addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [backView addSubview:_identifyCode];
    
    //获取验证码
    _getVerifyCode = [UIButton buttonWithType:UIButtonTypeCustom];
    [_getVerifyCode setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_getVerifyCode setTitleColor:[UIColor hex:@"58A5F7"] forState:UIControlStateNormal];
    [_getVerifyCode addTarget:self action:@selector(getVerify) forControlEvents:UIControlEventTouchUpInside];
    _getVerifyCode.titleLabel.font = [UIFont systemFontOfSize:14.];
    CGSize verifySize = [_getVerifyCode.titleLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:_getVerifyCode.titleLabel.font,NSFontAttributeName, nil]];
    _getVerifyCode.frame = CGRectMake(backView.width - 15 - verifySize.width, _identifyCode.top + _identifyCode.height/2 - 20/2, verifySize.width, 20);
    [backView addSubview:_getVerifyCode];
    
    //横线条
    UIView *verLineView = [[UIView alloc] initWithFrame:CGRectMake(_getVerifyCode.left - .5 - 12, _getVerifyCode.top, 1, _getVerifyCode.height)];
    verLineView.backgroundColor = [UIColor hex:@"EBEBEB"];
    [backView addSubview:verLineView];
    
    //backview
    UIView *passwordBackView = [[UIView alloc] initWithFrame:CGRectMake(0, backView.bottom + 20, SCREEN_WIDTH, 46)];
    passwordBackView.backgroundColor = [UIColor whiteColor];
    [self addLineWithSuperView:passwordBackView isTop:YES];
    [self addLineWithSuperView:passwordBackView isTop:NO];
    [self.view addSubview:passwordBackView];
    //新密码
    _userNewPassword = [[VOPasswordTextField alloc] initWithFrame:CGRectMake(15, 0, backView.width - 15*2, 46)];
    //right view
    UIButton *rightView = [UIButton buttonWithType:UIButtonTypeCustom];
    rightView.frame = CGRectMake(0, 0, 22, 16);
    [rightView setImage:[UIImage imageNamed:@"view"] forState:UIControlStateNormal];
    [rightView setImage:[UIImage imageNamed:@"unview"] forState:UIControlStateSelected];
    [rightView addTarget:self action:@selector(showPassword:) forControlEvents:UIControlEventTouchUpInside];
    _userNewPassword.leftViewMode= UITextFieldViewModeAlways;
    _userNewPassword.leftView = rightView;
    
    _userNewPassword.clearButtonMode = UITextFieldViewModeAlways;
    _userNewPassword.borderStyle = UITextBorderStyleNone;
    _userNewPassword.secureTextEntry = YES;
    _userNewPassword.backgroundColor = [UIColor clearColor];
    _userNewPassword.textColor = [UIColor blackColor];
    _userNewPassword.keyboardType = UIKeyboardTypeDefault;
    _userNewPassword.delegate = self;
    _userNewPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    _userNewPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"新密码" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor hex:@"B2B1C0"],NSForegroundColorAttributeName,[UIFont systemFontOfSize:17.],NSFontAttributeName, nil]];
    _userNewPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    _userNewPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _userNewPassword.text = @"";
    [_userNewPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [passwordBackView addSubview:_userNewPassword];
    
    //确定按钮
    _commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _commitButton.backgroundColor = [UIColor hex:@"D1D2DC"];
    [_commitButton setTitle:@"确定" forState:UIControlStateNormal];
    [_commitButton setTitleColor:[UIColor hex:@"FFFFFF"] forState:UIControlStateNormal];
    _commitButton.frame = CGRectMake(20, passwordBackView.bottom + 60, SCREEN_WIDTH - 20*2, 42);
    [_commitButton addTarget:self action:@selector(commitInfo) forControlEvents:UIControlEventTouchUpInside];
    _commitButton.userInteractionEnabled = NO;
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
    borderLayer.lineWidth=2.;
    borderLayer.lineDashPattern= nil;
    borderLayer.fillColor= [UIColor hex:@"000000" alpha:8/255.].CGColor;
    borderLayer.strokeColor= [UIColor hex:@"000000" alpha:8/255.].CGColor;
    [superView.layer addSublayer:borderLayer];
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
    CGFloat offSet = 0;
    switch (self.accountType) {
        case VOAccountTypeEnterprise:   //企业
        {
            BOOL isAvaEmail =  [self isAvailableEmail:_userName.text];
            if (!isAvaEmail)
            {
                UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., offSet + 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
                [messageView showMessageViewWithMessage:@"登录邮箱格式错误"];
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
                NSDictionary *params =  [NSDictionary dictionaryWithObjectsAndKeys:_userName.text,@"email", nil];
                [VONetworking postWithUrl:@"/v1.0.0/api/user/account/forget/password/email/verifycode" refreshRequest:NO cache:NO params:params needSession:YES  successBlock:^(id response) {
                    UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., offSet + 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:YES withSuperView:self.view];
                    [messageView showMessageViewWithMessage:@"验证码已发送"];
                } failBlock:^(NSError *error) {
                    if (error)
                    {
                        timerCounr = 0;
                        if (error.code != -9999)
                        {
                            NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
                            UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
                            [messageView showMessageViewWithMessage:errorMessage];
                        }
                    }
                }];
            }
                break;
        }
        case VOAccountTypePersonal:     //个人
        {
            if (!verifyTimer)
            {
                _getVerifyCode.userInteractionEnabled = NO;
                timerCounr = 59.;
                [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                verifyTimer = [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(resetVerifyCode) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:verifyTimer  forMode:NSRunLoopCommonModes];
            }
            NSDictionary *params =  [NSDictionary dictionaryWithObjectsAndKeys:_userName.text,@"mobilePhone", nil];
            [VONetworking postWithUrl:@"/v1.0.0/api/user/account/forget/password/mobilephone/verifycode" refreshRequest:NO cache:NO params:params needSession:YES  successBlock:^(id response) {
                UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., offSet + 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:YES withSuperView:self.view];
                [messageView showMessageViewWithMessage:@"验证码已发送"];
            } failBlock:^(NSError *error) {
                if (error)
                {
                    timerCounr = 0;
                    if (error.code != -9999)
                    {
                        NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
                        UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
                        [messageView showMessageViewWithMessage:errorMessage];
                    }
                }
            }];
        }
        default:
            break;
    }
}

//正则表达 邮箱验证
- (BOOL)isAvailableEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark - 显示密码
- (void)showPassword:(UIButton *)button
{
    button.selected = !button.isSelected;
    if (button.isSelected)
    {
        _userNewPassword.secureTextEntry = NO;
    }else
    {
        _userNewPassword.secureTextEntry = YES;
    }
}
#pragma mark - 提交新密码
- (void)commitInfo
{
    
    if (_userNewPassword.text.length < 8)   //密码长度不得低于30个字数
    {
        UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10, SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
        [messageView showMessageViewWithMessage:@"密码长度必须在8至30个字之间"];
        return;
    }else if (_userNewPassword.text.length > 30)
    {
        UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10, SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
        [messageView showMessageViewWithMessage:@"密码长度必须在8至30个字之间"];
        return;
    }
    CGFloat statusHeight = kHeight_NavBar;
    switch (self.accountType)
    {
        case VOAccountTypeEnterprise:   //企业
        {
            NSDictionary *params =  [NSDictionary dictionaryWithObjectsAndKeys:_userName.text,@"email",
                                                                                                                                    _userNewPassword.text,@"password",
                                                                                                                                    _identifyCode.text,@"verifyCode" ,nil];
            [VONetworking putWithUrl:@"/v1.0.0/api/user/account/forget/password/email/password" refreshRequest:NO cache:NO params:params needSession:YES  successBlock:^(id response) {
                UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., statusHeight + 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:YES withSuperView:self.navigationController.view];
                [messageView showMessageViewWithMessage:@"密码重置成功"];
                //返回登录页面
                [self.navigationController popViewControllerAnimated:NO];
            } failBlock:^(NSError *error) {
                if (error.code != -9999)
                {
                    NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
                    UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.navigationController.view];
                    [messageView showMessageViewWithMessage:errorMessage];
                }
            }];
            break;
        }
        case VOAccountTypePersonal:     //个人
        {
            NSDictionary *params =  [NSDictionary dictionaryWithObjectsAndKeys:_userName.text,@"mobilePhone",
                                     _userNewPassword.text,@"password",
                                     _identifyCode.text,@"verifyCode" ,nil];
            [VONetworking putWithUrl:@"/v1.0.0/api/user/account/forget/password/mobilephone/password" refreshRequest:NO cache:NO params:params needSession:YES  successBlock:^(id response) {
                UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., statusHeight + 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:YES withSuperView:self.navigationController.view];
                [messageView showMessageViewWithMessage:@"密码重置成功"];
                //返回登录页面
                [self.navigationController popViewControllerAnimated:NO];
            } failBlock:^(NSError *error) {
                if (error)
                {
                    if (error.code != -9999)
                    {
                        NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
                        UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
                        [messageView showMessageViewWithMessage:errorMessage];
                    }
                }
            }];
            break;
        }
        default:
            break;
    }
}

#pragma mark - text field actions
- (void)textFieldDidChange:(UITextField *)textField
{
    if (self.accountType == VOAccountTypePersonal) {
        if (textField == _userName) {
            if (textField.text.length > 20) {
                textField.text = [textField.text substringToIndex:20];
            }
        }
    }else if (self.accountType == VOAccountTypeEnterprise)
    {
        if (textField == _userName) {
            if (textField.text.length > 190) {
                textField.text = [textField.text substringToIndex:190];
            }
        }
    }
  if (textField == _identifyCode)
    {
        if (textField.text.length > 6) {
            textField.text = [textField.text substringToIndex:6];
        }
    }else if (textField == _userNewPassword)
    {
        if (textField.text.length > 30) {
            textField.text = [textField.text substringToIndex:30];
        }
    }
    if (_commitButton.userInteractionEnabled)
    {
        if (!_userName.text.length || !_identifyCode.text.length || !_userNewPassword.text.length)
        {
            _commitButton.userInteractionEnabled = NO;
            _commitButton.backgroundColor = [UIColor hex:@"D1D2DC"];
        }
    }else
    {
        if (_userName.text.length && _identifyCode.text.length && _userNewPassword.text.length)
        {
            _commitButton.userInteractionEnabled = YES;            
            _commitButton.backgroundColor = [UIColor hex:@"58A5F7"];
        }
    }
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //清楚历史密码
    if (textField == _userNewPassword)
    {
        _userNewPassword.text = @"";
    }
}

#pragma mark - 空白点击收起键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}  

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
