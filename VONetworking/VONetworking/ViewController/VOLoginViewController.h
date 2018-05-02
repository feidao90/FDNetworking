//
//  VOLoginViewController.h
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/7.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "BaseViewController.h"
#import "VOLoginResponseModel.h"

static  NSString *LoginUserNameKey = @"LoginUserNameKey";  //获取userName
static NSString *LoginKey = @"loginkey";    //登录标示

@interface VOLoginViewController : BaseViewController<UITextFieldDelegate>

//获取输入框的用户名
- (NSString *)getInputUserName;

//获取输入框的秘密
- (NSString *)getInputUserPasswork;
@end
