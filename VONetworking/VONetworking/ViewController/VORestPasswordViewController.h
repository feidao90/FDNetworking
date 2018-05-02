//
//  VORestPasswordViewController.h
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/8.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "BaseViewController.h"

@interface VORestPasswordViewController : BaseViewController
typedef NS_ENUM (NSInteger, VOAccountType) {
    VOAccountTypeEnterprise = 0,    //企业账号
    VOAccountTypePersonal = 1,      //个人账号
};

@property (nonatomic,assign) VOAccountType accountType;
@end
