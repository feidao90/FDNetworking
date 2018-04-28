//
//  VOLoginViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/7.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "VOLoginViewController.h"
#import "VORestPasswordViewController.h"

#import "VORegisterViewController.h"
#import "UIResultMessageView.h"

#import "VONetworking+Session.h"
#import "VOLoginRequestModel.h"

#import "VOLoginManager.h"

@interface VOLoginViewController ()
{
    UIImageView *_backGroungView;
    UITextField *_userName;
    
    UITextField *_userPassword;
    UIButton *_login;
    
    UIButton *_reSetPassword;
    UIButton *_register;
    
    UIView *_lineView;
    VOLoginResponseModel *_userInfoModel;
}
@end

@implementation VOLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _initSubViews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
#pragma mark _initSubViews
- (void)_initSubViews
{
    //大背景图
    _backGroungView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    NSInteger width = SCREEN_HEIGHT;
    switch (width) {
        case 480:
        {
            _backGroungView.image = [UIImage imageNamed:@"loginbg640x960.jpg"];
            break;
        }
        case 568:
        {
            _backGroungView.image = [UIImage imageNamed:@"loginbg640x1136.jpg"];
            break;
        }
        case 667:
        {
            _backGroungView.image = [UIImage imageNamed:@"loginbg750x1334.jpg"];
            break;
        }
        case 812:
        {
            _backGroungView.image = [UIImage imageNamed:@"iPhoneX-bg"];
            break;
        }
        default:
            _backGroungView.image = [UIImage imageNamed:@"loginbg1242x2208.jpg"];
            break;
    }
    [self.view addSubview:_backGroungView];
    
    //textfiled backview
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT/3, SCREEN_WIDTH - 20*2, 101)];
    backView.layer.backgroundColor = [UIColor hex:@"373745" alpha:.2].CGColor;
    backView.layer.cornerRadius = 2.;
    backView.layer.masksToBounds = YES;
    [self.view addSubview:backView];
    
    //用户名输入
    _userName = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, backView.width - 15*2, 50.)];
    _userName.borderStyle = UITextBorderStyleNone;
    _userName.backgroundColor = [UIColor clearColor];
    _userName.textColor = [UIColor whiteColor];
    _userName.keyboardType = UIKeyboardTypeDefault;
    _userName.delegate = self;
    _userName.clearButtonMode = UITextFieldViewModeWhileEditing;
    _userName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"邮箱/手机号码" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithWhite:1.0 alpha:.5],NSForegroundColorAttributeName, nil]];
    _userName.autocorrectionType = UITextAutocorrectionTypeNo;
    _userName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _userName.text = [VOLoginManager getUserName];
    [_userName addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    [backView addSubview:_userName];
    
    //密码输入
    _userPassword = [[UITextField alloc] initWithFrame:CGRectMake(15, _userName.bottom + 1, backView.width - 15*2, 50.)];
    _userPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    _userPassword.borderStyle = UITextBorderStyleNone;
    _userPassword.backgroundColor = [UIColor clearColor];
    _userPassword.textColor = [UIColor whiteColor];
    _userPassword.keyboardType = UIKeyboardTypeDefault;
    _userPassword.delegate = self;
    _userPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"密码" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithWhite:1.0 alpha:.5],NSForegroundColorAttributeName, nil]];
    _userPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    _userPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _userPassword.secureTextEntry = YES;
    _userPassword.text = @"";
    [_userPassword addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    [backView addSubview:_userPassword];
    
    //分割线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, _userName.bottom, backView.width - 15*2, 1)];
    lineView.backgroundColor = [UIColor hex:@"B2B1C0"];
    [backView addSubview:lineView];
    
    //登录
    _login = [UIButton buttonWithType:UIButtonTypeCustom];
    _login.frame = CGRectMake(20, backView.bottom + 40, SCREEN_WIDTH - 20*2, 44);
    _login.backgroundColor = _userName.text.length&&_userPassword.text.length ? [UIColor hex:@"58A5F7" alpha:1.] : [UIColor hex:@"58A5F7" alpha:.5];
    _login.userInteractionEnabled = _userName.text.length&&_userPassword.text.length ? YES : NO;
    [_login setTitle:@"登录" forState:UIControlStateNormal];
    _login.titleLabel.font = [UIFont systemFontOfSize:15.];
    [_login setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     [_login addTarget:self action:@selector(loginHighlighted) forControlEvents:UIControlEventTouchDown];
    [_login addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_login];
    
    //忘记密码
    _reSetPassword = [UIButton buttonWithType:UIButtonTypeCustom];
    _reSetPassword.frame = CGRectMake(20, SCREEN_HEIGHT - 30 - 22, 120, 22);
    _reSetPassword.backgroundColor = [UIColor clearColor];
    [_reSetPassword setTitle:@"忘记密码?" forState:UIControlStateNormal];
    _reSetPassword.titleLabel.font = [UIFont systemFontOfSize:15.];
    [_reSetPassword setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _reSetPassword.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //设置button的title就距左边10个像素的距离。
    _reSetPassword.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [_reSetPassword addTarget:self action:@selector(resetPassword) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_reSetPassword];
    
    //个人注册
    _register = [UIButton buttonWithType:UIButtonTypeCustom];
    _register.frame = CGRectMake(SCREEN_WIDTH - 20 - 120, SCREEN_HEIGHT - 30 - 22, 120, 22);
    _register.backgroundColor = [UIColor clearColor];
    [_register setTitle:@"个人注册 →" forState:UIControlStateNormal];
    _register.titleLabel.font = [UIFont systemFontOfSize:15.];
    [_register setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _register.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    //设置button的title就距左边10个像素的距离。
    _register.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    [_register addTarget:self action:@selector(registerPassword) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_register];
}

//获取输入框的用户名
- (NSString *)getInputUserName
{
    return _userName.text;
}

//获取输入框的秘密
- (NSString *)getInputUserPasswork
{
    return _userPassword.text;
}

#pragma mark - 登录
- (void)login
{
    _login.backgroundColor = _userName.text.length&&_userPassword.text.length ? [UIColor hex:@"58A5F7" alpha:1.] : [UIColor hex:@"58A5F7" alpha:.5];
    //收起键盘
    [_userPassword resignFirstResponder];
    [_userName resignFirstResponder];
    NSString *password = _userPassword.text;
    //密码长度-本地验证
    if (password.length < 8)   //密码长度不得低于30个字数
    {
        UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 74., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
        [messageView showMessageViewWithMessage:@"密码长度必须在8至30个字之间"];
        return;
    }else if (password.length > 30)
    {
        UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 74., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
        [messageView showMessageViewWithMessage:@"密码长度必须在8至30个字之间"];
        return;
    }
    
    [[VOLoginManager shared] loginWithCompleteBlock:^(NSString *errorMessage) {
        UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 74., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
        [messageView showMessageViewWithMessage:errorMessage];
    }];
}

- (void)loginHighlighted
{
    _login.backgroundColor = [UIColor hex:@"5A99DD"];
}
#pragma mark - 忘记密码
- (void)resetPassword
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"选择需要找回密码的账号类型" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"企业账户" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        VORestPasswordViewController *resetPassword = [[VORestPasswordViewController alloc] init];
        resetPassword.accountType = VOAccountTypeEnterprise;
        [self.navigationController pushViewController:resetPassword animated:YES];
    }];
    [alertVC addAction:firstAction];
    
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"个人账户" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        VORestPasswordViewController *resetPassword = [[VORestPasswordViewController alloc] init];
        resetPassword.accountType = VOAccountTypePersonal;
        [self.navigationController pushViewController:resetPassword animated:YES];
    }];
    [alertVC addAction:secondAction];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {        
    }];
    [alertVC addAction:cancleAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}
#pragma mark - 注册
- (void)registerPassword
{
    VORegisterViewController *registerVC = [[VORegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

#pragma mark - textfield method
- (void)textFieldDidChange
{
    if (!_login.userInteractionEnabled)
    {
        if (_userName.text.length && _userPassword.text.length)
        {
            _login.userInteractionEnabled = YES;
            _login.backgroundColor = [UIColor hex:@"58A5F7" alpha:1.];
        }
    }else
    {
        if (!_userName.text.length || !_userPassword.text.length) {
            _login.userInteractionEnabled = NO;
            _login.backgroundColor = [UIColor hex:@"58A5F7" alpha:.5];
        }
    }
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //清楚历史密码
    if (textField == _userPassword)
    {
        _userPassword.text = @"";
        _login.backgroundColor = _userName.text.length&&_userPassword.text.length ? [UIColor hex:@"58A5F7" alpha:1.] : [UIColor hex:@"58A5F7" alpha:.5];
        _login.userInteractionEnabled = NO;
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
