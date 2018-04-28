//
//  VORegisterViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/8.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "VORegisterViewController.h"
#import "UIResultMessageView.h"

#import "VONetworking+Session.h"
#import "VOPasswordTextField.h"

#import "VOCategorySet.h"

@interface VORegisterViewController ()<UITextFieldDelegate>
{
    UITextField *_userName;
    UITextField *_phoneNum;
    
    UITextField *_verifyNum;
    VOPasswordTextField *_userPassword;
    
    UIButton *_registerButton;
    UIButton *_getVerifyCode;

    NSTimer *verifyTimer;
    NSInteger timerCounr;
}
@end

@implementation VORegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"注册";
    self.view.backgroundColor = [UIColor hex:@"F2F3F8"];
    
    [self _initSubViews];
}

#pragma mark - _initSubViews
- (void)_initSubViews
{
    CGFloat offset = 0.;
    //姓名
    _userName = [[UITextField alloc] initWithFrame:CGRectMake(0, offset + 20, self.view.width , 48)];
    _userName.borderStyle = UITextBorderStyleNone;
    _userName.backgroundColor = [UIColor whiteColor];
    _userName.textColor = [UIColor blackColor];
    _userName.keyboardType = UIKeyboardTypeDefault;
    _userName.delegate = self;
    _userName.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
    _userName.leftViewMode  =  UITextFieldViewModeAlways;
    _userName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"姓名" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor hex:@"B2B1C0"],NSForegroundColorAttributeName,[UIFont systemFontOfSize:17.],NSFontAttributeName, nil]] ;
    _userName.autocorrectionType = UITextAutocorrectionTypeNo;
    _userName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _userName.text = @"";
    [self addLineWithSuperView:_userName isTop:YES];
    [self addLineWithSuperView:_userName isTop:NO];
    [_userName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_userName];
    
    //手机号
    _phoneNum = [[UITextField alloc] initWithFrame:CGRectMake(0, _userName.bottom + 10, self.view.width , 48)];
    _phoneNum.borderStyle = UITextBorderStyleNone;
    _phoneNum.backgroundColor = [UIColor whiteColor];
    _phoneNum.textColor = [UIColor blackColor];
    _phoneNum.keyboardType = UIKeyboardTypeNumberPad;
    _phoneNum.delegate = self;
    _phoneNum.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
    _phoneNum.leftViewMode  =  UITextFieldViewModeAlways;
    _phoneNum.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"手机号" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor hex:@"B2B1C0"],NSForegroundColorAttributeName,[UIFont systemFontOfSize:17.],NSFontAttributeName, nil]] ;
    _phoneNum.autocorrectionType = UITextAutocorrectionTypeNo;
    _phoneNum.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _phoneNum.text = @"";
    [self addLineWithSuperView:_phoneNum isTop:YES];
    [_phoneNum addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_phoneNum];
    
    //手机验证码
    _verifyNum = [[UITextField alloc] initWithFrame:CGRectMake(0, _phoneNum.bottom, self.view.width , 48)];
    _verifyNum.borderStyle = UITextBorderStyleNone;
    _verifyNum.backgroundColor = [UIColor whiteColor];
    _verifyNum.textColor = [UIColor blackColor];
    _verifyNum.keyboardType = UIKeyboardTypeNumberPad;
    _verifyNum.delegate = self;
    _verifyNum.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
    _verifyNum.leftViewMode  =  UITextFieldViewModeAlways;
    _verifyNum.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入验证码" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor hex:@"B2B1C0"],NSForegroundColorAttributeName,[UIFont systemFontOfSize:17.],NSFontAttributeName, nil]] ;
    _verifyNum.autocorrectionType = UITextAutocorrectionTypeNo;
    _verifyNum.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _verifyNum.text = @"";
    [self addLineWithSuperView:_verifyNum isTop:NO];
    [_verifyNum addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_verifyNum];
    
    //lineview
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _phoneNum.bottom - 1, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = [UIColor hex:@"EBEBEB"];
    [self.view addSubview:lineView];
    
    //获取验证码
    _getVerifyCode = [UIButton buttonWithType:UIButtonTypeCustom];
    [_getVerifyCode setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_getVerifyCode setTitleColor:[UIColor hex:@"58A5F7"] forState:UIControlStateNormal];
    [_getVerifyCode addTarget:self action:@selector(getVerify) forControlEvents:UIControlEventTouchUpInside];
    _getVerifyCode.titleLabel.font = [UIFont systemFontOfSize:14.];
    CGSize verifySize = [_getVerifyCode.titleLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:_getVerifyCode.titleLabel.font,NSFontAttributeName, nil]];
    _getVerifyCode.frame = CGRectMake(self.view.width - 15 - verifySize.width, _verifyNum.top + _verifyNum.height/2 - 20/2, verifySize.width, 20);
    [self.view addSubview:_getVerifyCode];
    
    //横线条
    UIView *verLineView = [[UIView alloc] initWithFrame:CGRectMake(_getVerifyCode.left - .5 - 12, _getVerifyCode.top, 1, _getVerifyCode.height)];
    verLineView.backgroundColor = [UIColor hex:@"EBEBEB"];
    [self.view addSubview:verLineView];
    
    //backview
    UIView *passwordBackView = [[UIView alloc] initWithFrame:CGRectMake(0, _verifyNum.bottom + 10, SCREEN_WIDTH, 46)];
    passwordBackView.backgroundColor = [UIColor whiteColor];
    [self addLineWithSuperView:passwordBackView isTop:YES];
    [self addLineWithSuperView:passwordBackView isTop:NO];
    [self.view addSubview:passwordBackView];
    //登录密码
    _userPassword = [[VOPasswordTextField alloc] initWithFrame:CGRectMake(15., 0, passwordBackView.width - 15.*2 , 46)];
    _userPassword.borderStyle = UITextBorderStyleNone;
    _userPassword.backgroundColor = [UIColor whiteColor];
    _userPassword.textColor = [UIColor blackColor];
    _userPassword.keyboardType = UIKeyboardTypeDefault;
    _userPassword.delegate = self;
    _userPassword.secureTextEntry = YES;
    _userPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    _userPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"登录密码" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor hex:@"B2B1C0"],NSForegroundColorAttributeName,[UIFont systemFontOfSize:17.],NSFontAttributeName, nil]] ;
    _userPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    _userPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _userPassword.text = @"";
    [_userPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [passwordBackView addSubview:_userPassword];
    
    //right view
    UIButton *rightView = [UIButton buttonWithType:UIButtonTypeCustom];
    rightView.frame = CGRectMake(0, 0, 22, 16);
    [rightView setImage:[UIImage imageNamed:@"view"] forState:UIControlStateNormal];
    [rightView setImage:[UIImage imageNamed:@"unview"] forState:UIControlStateSelected];
    [rightView addTarget:self action:@selector(showPassword:) forControlEvents:UIControlEventTouchUpInside];
    _userPassword.leftViewMode = UITextFieldViewModeAlways;
    _userPassword.leftView = rightView;
    
    //确定按钮
    _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _registerButton.backgroundColor = [UIColor hex:@"D1D2DC"];
    [_registerButton setTitle:@"确定" forState:UIControlStateNormal];
    [_registerButton setTitleColor:[UIColor hex:@"FFFFFF"] forState:UIControlStateNormal];
    _registerButton.frame = CGRectMake(20, passwordBackView.bottom + 60, SCREEN_WIDTH - 20*2, 42);
    [_registerButton addTarget:self action:@selector(commitInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_registerButton];
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
#pragma mark - text field actions
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == _phoneNum) {
        if (textField.text.length > 20) {
            textField.text = [textField.text substringToIndex:20];
        }
    }else if (textField == _verifyNum)
    {
        if (textField.text.length > 6) {
            textField.text = [textField.text substringToIndex:6];
        }
    }else if (textField == _userPassword)
    {
        if (textField.text.length > 30) {
            textField.text = [textField.text substringToIndex:30];
        }
    }
    [self comfirStatus];
}

- (void)comfirStatus
{
    if (_registerButton.userInteractionEnabled)
    {
        if (!_userName.text.length || !_phoneNum.text.length || !_verifyNum.text.length || !_userPassword.text.length )
        {
            _registerButton.userInteractionEnabled = NO;
            _registerButton.backgroundColor = [UIColor hex:@"D1D2DC"];
            
        }
    }else
    {
        if (_userName.text.length && _phoneNum.text.length && _verifyNum.text.length && _userPassword.text.length )
        {
            _registerButton.userInteractionEnabled = YES;
            _registerButton.backgroundColor = [UIColor hex:@"58A5F7"];
        }
    }
}
#pragma mark - 空白点击收起键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
    CGFloat offSet = 0.;
    if (!verifyTimer)
    {
        _getVerifyCode.userInteractionEnabled = NO;
        timerCounr = 59.;
        [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
        verifyTimer =  [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(resetVerifyCode) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:verifyTimer  forMode:NSRunLoopCommonModes];
    }
    NSDictionary *params =  [NSDictionary dictionaryWithObjectsAndKeys:_phoneNum.text,@"mobilePhone", nil];
    [VONetworking postWithUrl:@"/v1.0.0/api/user/account/register/mobilephone/verifycode" refreshRequest:NO cache:NO params:params needSession:YES  successBlock:^(id response) {
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

//正则表达式 手机验证
- (BOOL)isAvalidateMobile:(NSString *)mobile
{
    // 130-139  150-153,155-159  180-189  145,147  170,171,173,176,177,178
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0-9])|(14[57])|(17[013678]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}
#pragma mark - 注册
- (void)commitInfo
{
    if (_userPassword.text.length < 8)   //密码长度不得低于30个字数
    {
        UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10, SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
        [messageView showMessageViewWithMessage:@"密码长度必须在8至30个字之间"];
        return;
    }else if (_userPassword.text.length > 30)
    {
        UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10, SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
        [messageView showMessageViewWithMessage:@"密码长度必须在8至30个字之间"];
        return;
    }
    
    NSDictionary *params =  [NSDictionary dictionaryWithObjectsAndKeys:_userName.text,@"name",
                                                                                                                            _phoneNum.text,@"mobilePhone",
                                                                                                                            _userPassword.text,@"password",
                                                                                                                            _verifyNum.text,@"verifyCode", nil];
    [VONetworking postWithUrl:@"/v1.0.0/api/user/account/register" refreshRequest:NO cache:NO params:params needSession:YES  successBlock:^(id response) {
        UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:YES withSuperView:self.view];
        [messageView showMessageViewWithMessage:@"注册成功"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:NO];
        });
    } failBlock:^(NSError *error) {
        if (error.code != -9999)
        {
            NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
            UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
            [messageView showMessageViewWithMessage:errorMessage];
        }
    }];
}

#pragma mark - 显示密码
- (void)showPassword:(UIButton *)button
{
    button.selected = !button.isSelected;
    if (button.isSelected)
    {
        _userPassword.secureTextEntry = NO;
    }else
    {
        _userPassword.secureTextEntry = YES;
    }
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //清楚历史密码
    if (textField == _userPassword)
    {
        _userPassword.text = @"";
        [self comfirStatus];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *textString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textString.length > 100) {
        textString = [textString substringToIndex:100];
        textField.text = textString;
        UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
        [messageView showMessageViewWithMessage:@"文字超过字数限制"];
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
