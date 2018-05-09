//
//  VOLoginManager.h
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/29.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VOLoginResponseModel.h"

static NSString * kLoginInfoChanggeNotification = @"vologininfochangenotification";
static NSString * kLogedinNotification = @"vologedinnotification";

static NSString * kLogedOutNotification = @"vologedoutnotification";
static NSString *kLeaveEnterpriseNotification = @"voleaveenterprisenotification";

typedef void(^LoginErrorBlock)(NSString *errorMessage);
typedef void(^LoginRefreshCompleteBlock)(BOOL isSuccess);


typedef void(^LoginOutCompleteBlock)(void);
@interface VOLoginManager : NSObject

+ (instancetype)shared;

//登录
- (void)loginWithCompleteBlock:(LoginErrorBlock)errorBlock;

//验证是否登录
+ (BOOL)isLogined;

//获取userName
+ (NSString *)getUserName;

//获取用户Id
- (NSString *)getUserId;

//获取登录信息
- (VOLoginResponseModel *)getLoginInfo;

//验证登录态
- (void)verifyLoginStatus;

//退出登录
+ (void)logout;

//退出登录
+ (void)logoutWithComplete:(LoginOutCompleteBlock)compelete;

//归档缓存
- (void)cacheInDiskOfUserInfo:(VOLoginResponseModel *)model;

//刷新登录数据
- (void)refreshLoginfo:(LoginRefreshCompleteBlock)complete;

//刷新登录数据-no notification
- (void)refreshLoginfoWithOutNotification:(LoginRefreshCompleteBlock)complete;

// 解绑clientId
+ (void)deleteClientId;
//user-type
- (NSString *)getUserType;
@end
