//
//  VOMineChangePasswordViewController.m
//  Voffice-ios
//
//  Created by 何广忠 on 2018/1/8.
//  Copyright © 2018年 何广忠. All rights reserved.
//

#import "VOMineChangePasswordViewController.h"
#import "VOPasswordTextField.h"

#import "UIResultMessageView.h"
#import "VONetworking+Session.h"

#import "VOMinePasswordManagerView.h"
#import "VOCategorySet.h"

@interface VOMineChangePasswordViewController ()<UITextFieldDelegate>
{
    VOPasswordTextField *_currentPW;
    VOPasswordTextField *_newPW;
    
    VOPasswordTextField *_comfirPW;
    UIButton *_commitButton;
}
@end

@implementation VOMineChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //title
    self.navigationItem.title = @"修改登录密码";
    
    [self _initSubViews];    
}

#pragma mark - _initSubViews
- (void)_initSubViews
{
    //当前密码
    UIView *currentBackView = [self backgroundView];
    currentBackView.frame = CGRectMake(0, 30., SCREEN_WIDTH, 46.);
    [self addLineWithSuperView:currentBackView isTop:YES];
    [self.view addSubview:currentBackView];
    
    _currentPW = [self getStandardTextField:@"当前密码"];
     _currentPW.frame =  CGRectMake(15., 0, SCREEN_WIDTH - 15.*2 , 46);
    [currentBackView addSubview:_currentPW];
    
    UIView *lineView = [self getLineView];
    lineView.frame = CGRectMake(0, _currentPW.bottom - 1, SCREEN_WIDTH, 1);
    [currentBackView addSubview:lineView];
    //right view
    _currentPW.leftViewMode = UITextFieldViewModeAlways;
    _currentPW.leftView = [self rightView];
    
    //新密码
    UIView *newBackView = [self backgroundView];
    newBackView.frame = CGRectMake(0, currentBackView.bottom, SCREEN_WIDTH, 46.);
    [self.view addSubview:newBackView];
    
    _newPW = [self getStandardTextField:@"新密码"];
    _newPW.frame =  CGRectMake(15., 0, SCREEN_WIDTH - 15.*2 , 46);
    [newBackView addSubview:_newPW];
    
    UIView *newLineView = [self getLineView];
    newLineView.frame = CGRectMake(0, _newPW.bottom -1, SCREEN_WIDTH, 1);
    [newBackView addSubview:newLineView];
    
    //right view
    _newPW.leftViewMode = UITextFieldViewModeAlways;
    _newPW.leftView = [self rightView];
    
    //确认密码
    UIView *comfirBackView = [self backgroundView];
    comfirBackView.frame = CGRectMake(0, newBackView.bottom, SCREEN_WIDTH, 46.);
    [self addLineWithSuperView:comfirBackView isTop:NO];
    [self.view addSubview:comfirBackView];
    
    _comfirPW = [self getStandardTextField:@"确认新密码"];
    _comfirPW.frame =  CGRectMake(15., 0, SCREEN_WIDTH - 15.*2 , 46);
    [comfirBackView addSubview:_comfirPW];
    
    //right view
    _comfirPW.leftViewMode = UITextFieldViewModeAlways;
    _comfirPW.leftView = [self rightView];;
    
    //提交
    _commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _commitButton.layer.backgroundColor = [UIColor hex:@"D1D2DC"].CGColor;
    _commitButton.layer.cornerRadius = 2.;
    _commitButton.layer.masksToBounds = YES;
    [_commitButton setTitle:@"提交" forState:UIControlStateNormal];
    [_commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _commitButton.titleLabel.font = [UIFont systemFontOfSize:16.];
    _commitButton.frame = CGRectMake(10., comfirBackView.bottom + 60., SCREEN_WIDTH - 10.*2, 42.);
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
    textField.secureTextEntry = YES;
    textField.delegate = self;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor hex:@"B2B1C0"],NSForegroundColorAttributeName,[UIFont systemFontOfSize:17.],NSFontAttributeName, nil]] ;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.text = @"";
    [textField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    
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

- (UIButton *)rightView
{
    UIButton *rightView = [UIButton buttonWithType:UIButtonTypeCustom];
    rightView.frame = CGRectMake(0, 0, 22, 16);
    [rightView setImage:[UIImage imageNamed:@"view"] forState:UIControlStateNormal];
    [rightView setImage:[UIImage imageNamed:@"unview"] forState:UIControlStateSelected];
    [rightView addTarget:self action:@selector(showPassword:) forControlEvents:UIControlEventTouchUpInside];
    return rightView;
}
#pragma mark - 提交新密码
- (void)commitNewPW
{
    if (_newPW.text.length < 8 || _comfirPW.text.length < 8 || _currentPW.text.length < 8)   //密码长度不得低于30个字数
    {
        UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10, SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
        [messageView showMessageViewWithMessage:@"密码长度必须在8至30个字之间"];
        return;
    }else if (_newPW.text.length > 30 || _comfirPW.text.length > 30 || _currentPW.text.length > 30)
    {
        UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10, SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
        [messageView showMessageViewWithMessage:@"密码长度必须在8至30个字之间"];
        return;
    }else if (![_newPW.text isEqualToString:_comfirPW.text])
    {
        UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10, SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
        [messageView showMessageViewWithMessage:@"新密码与确认密码不一致"];
        return;
    }
    
    NSDictionary *params =  @{
                              @"newPassword" : _newPW.text,
                              @"oldPassword" : _currentPW.text
                              };
    [VONetworking putWithUrl:@"/v1.0.0/api/user/account/password" refreshRequest:NO cache:NO params:params needSession:NO successBlock:^(id response) {
        //关闭键盘
        [self.view endEditing:YES];
        VOMinePasswordManagerView *managerView = [[VOMinePasswordManagerView alloc] initWithMangerType:VOManagerMinePassword];
        __weak VOMineChangePasswordViewController *weakSelf = self;
        managerView.block = ^{
            __strong VOMineChangePasswordViewController *strongSelf = weakSelf;
            [strongSelf.navigationController popViewControllerAnimated:YES];
        };
        [managerView showView];        
    } failBlock:^(NSError *error) {
        if (error.code != -9999)
        {
            NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
            UIResultMessageView *messageView = [[UIResultMessageView alloc] initWithFrame:CGRectMake(15., 10., SCREEN_WIDTH - 15.*2, 33) withIsSuccess:NO withSuperView:self.view];
            [messageView showMessageViewWithMessage:errorMessage];
        }
    }];
}

#pragma mark - textFieldDidChange
- (void)textFieldDidChange
{
    [self comfirStatus];
}

- (void)comfirStatus
{
    if (_commitButton.userInteractionEnabled)
    {
        if (!_currentPW.text.length || !_newPW.text.length || !_comfirPW.text.length )
        {
            _commitButton.userInteractionEnabled = NO;
            _commitButton.backgroundColor = [UIColor hex:@"D1D2DC"];
            
        }
    }else
    {
        if (_currentPW.text.length && _newPW.text.length && _comfirPW.text.length)
        {
            _commitButton.userInteractionEnabled = YES;
            _commitButton.backgroundColor = [UIColor hex:@"58A5F7"];
        }
    }
}

- (void)showPassword:(UIButton *)button
{
    button.selected = !button.isSelected;
    
    UITextField *superView = (UITextField *)[button superview];
    superView.secureTextEntry = !superView.secureTextEntry;
}
#pragma mark - 空白点击收起键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //清楚历史密码
    textField.text = @"";
    [self comfirStatus];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0)
        return YES;
    
    NSInteger existedLength = textField.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = string.length;
    if (existedLength - selectedLength + replaceLength > 30) {
        return NO;
    }
    
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
