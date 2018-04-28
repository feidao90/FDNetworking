//
//  VOLoginManager.m
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/29.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "VOLoginManager.h"
#import "VOLoginViewController.h"

#import "VONetworking+Session.h"
#import <GTSDK/GeTuiSdk.h>

@interface VOLoginManager()

@property (nonatomic,strong) id currentLoginVC;
@end

@implementation VOLoginManager

+ (instancetype)shared
{
    static VOLoginManager *login = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        login = [[VOLoginManager alloc] init];
    });
    return login;
}

-(void)setCurrentLoginVC:(id)currentLoginVC
{
    _currentLoginVC = currentLoginVC;
}

#pragma mark - 登录
- (void)loginWithCompleteBlock:(LoginErrorBlock)errorBlock
{
    NSDictionary *params = @{@"loginId" : [self.currentLoginVC getInputUserName],
                             @"password" : [self.currentLoginVC getInputUserPasswork]};
    __block NSString *userId =  [self.currentLoginVC getInputUserName];
    [VONetworking postWithUrl:@"/v1.0.0/api/user/account/login" refreshRequest:NO cache:NO params:params needSession:YES  successBlock:^(id response) {
        //用户名缓存
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:LoginUserNameKey];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LoginKey];
        //用户信息缓存
        [self cacheInDiskOfUserInfo:[[VOLoginResponseModel alloc] initWithJSONDictionary:response]];
        //关闭登录页面
        Class rootClass = NSClassFromString(@"ViewController");
        [UIApplication sharedApplication].delegate.window.rootViewController = [rootClass new];
        //登录
        [[NSNotificationCenter defaultCenter] postNotificationName:kLogedinNotification object:nil];
        
        //开启推送
        [VOLoginManager logedInConnectPush];
    } failBlock:^(NSError *error) {
        if (error)
        {
            NSString *errorMessage = [error.userInfo safeObjectForKey:@"messageCN"];
            errorMessage = errorMessage.length ? errorMessage : @"登录出错";
            errorBlock(errorMessage);
        }
    }];
}
#pragma mark - 刷新登录数据
- (void)refreshLoginfo:(LoginRefreshCompleteBlock)complete
{
    [VONetworking getWithUrl:@"/v1.0.0/api/user/account/login" refreshRequest:NO cache:NO params:nil needSession:NO  successBlock:^(id response)
    {
        //用户信息缓存
        [self cacheInDiskOfUserInfo:[[VOLoginResponseModel alloc] initWithJSONDictionary:response]];
        if (complete) {
            complete(YES);
        }
        //更新用户信息
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginInfoChanggeNotification object:nil];
    } failBlock:^(NSError *error) {
        if (complete) {
            complete(NO);
        }
    }];
}

- (void)refreshLoginfoWithOutNotification:(LoginRefreshCompleteBlock)complete
{
    [VONetworking getWithUrl:@"/v1.0.0/api/user/account/login" refreshRequest:NO cache:NO params:nil needSession:NO  successBlock:^(id response)
     {
         //用户信息缓存
         [self cacheInDiskOfUserInfo:[[VOLoginResponseModel alloc] initWithJSONDictionary:response]];
         if (complete) {
             complete(YES);
         }
     } failBlock:^(NSError *error) {
         if (complete) {
             complete(NO);
         }
     }];
}
#pragma mark - 验证是否登录
+ (BOOL)isLogined
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:LoginKey];
}

#pragma mark - 获取用户信息
+ (NSString *)getUserName //获取userName
{
    NSString *userName =  [[NSUserDefaults standardUserDefaults] objectForKey:LoginUserNameKey];
    return userName.length ? userName : @"";
}

- (NSString *)getUserId
{
    VOLoginResponseModel *loginModel = [[VOLoginResponseModel alloc] initWithJSONDictionary:[self getUserInfoFormDisk]];
    return loginModel.user.userId;
}

#pragma mark - 获取登录信息
- (VOLoginResponseModel *)getLoginInfo;
{
    return [[VOLoginResponseModel alloc] initWithJSONDictionary:[self getUserInfoFormDisk]];
}

#pragma mark - 验证登录态
- (void)verifyLoginStatus
{
    if (![VOLoginManager isLogined])
    {
        [self presentLoginView:[NSNumber numberWithBool:NO]];
    }else
    {
        [[VOLoginManager shared] refreshLoginfo:^(BOOL isSuccess)
         {
         }];
    }
}

- (void)presentLoginView:(NSNumber *)num
{
    dispatch_async(dispatch_get_main_queue(), ^{
        Class logClass = NSClassFromString(@"VOLoginViewController");
        self.currentLoginVC = [logClass new];
        VOBaseNavViewController *nav = [[VOBaseNavViewController alloc] initWithRootViewController:self.currentLoginVC];
        [UIApplication sharedApplication].delegate.window.rootViewController = nav;
    });
}

#pragma mark - 退出登录
+ (void)logout
{
    //断开个推连接
    [VOLoginManager deleteClientId];
}

// 解绑clientId
+ (void)deleteClientId
{
    [GeTuiSdk destroy];
    NSDictionary *params = @{
                             @"clientId" :  [[NSUserDefaults standardUserDefaults] objectForKey:kPushClientId]
                             };
    [VONetworking deleteWithUrl:@"/v1.0.0/api/push/client/bind" refreshRequest:NO cache:NO params:params needSession:NO successBlock:^(id response) {
        //退出登录
        [VOLoginManager logoutAccount];
    } failBlock:^(NSError *error) {
        //退出登录
        [VOLoginManager logoutAccount];
    }];
}

+ (void)logoutAccount
{
    //notifiction
    [[NSNotificationCenter defaultCenter] postNotificationName:kLogedOutNotification object:nil];
    
    NSString *apiUrl = @"/v1.0.0/api/user/account/login";
    [VONetworking deleteWithUrl:apiUrl refreshRequest:NO cache:NO params:nil needSession:NO  successBlock:^(id response) {
        //移除登录信息
        [[VOLoginManager shared] removeLoginInfo];
        
        //移除登录标示
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:LoginKey];
        
        //弹出登录页面
        [[VOLoginManager shared] verifyLoginStatus];
        
        //清楚cookie&&session
        [[VONetworking shareNetworking] cleareSessionAndCookie];
    } failBlock:^(NSError *error) {
        //移除登录信息
        [[VOLoginManager shared] removeLoginInfo];
        
        //移除登录标示
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:LoginKey];
        
        //弹出登录页面
        [[VOLoginManager shared] verifyLoginStatus];
        
        //清楚cookie&&session
        [[VONetworking shareNetworking] cleareSessionAndCookie];
    }];
}

+ (void)logoutWithComplete:(LoginOutCompleteBlock)compelete
{
    //断开个推连接
    [VOLoginManager deleteClientId:compelete];
}

// 解绑clientId
+ (void)deleteClientId:(LoginOutCompleteBlock)compelete
{
    [GeTuiSdk destroy];
    NSDictionary *params = @{
                             @"clientId" :  [[[NSUserDefaults standardUserDefaults] objectForKey:kPushClientId] length] ? [[NSUserDefaults standardUserDefaults] objectForKey:kPushClientId] : @""
                             };
    [VONetworking deleteWithUrl:@"/v1.0.0/api/push/client/bind" refreshRequest:NO cache:NO params:params needSession:NO successBlock:^(id response) {
        //退出登录
        [VOLoginManager logoutAccountWithCompelete:compelete];
    } failBlock:^(NSError *error) {
        //退出登录
        [VOLoginManager logoutAccountWithCompelete:compelete];
    }];
}

+ (void)logoutAccountWithCompelete:(LoginOutCompleteBlock)compelete
{
    //notifiction
    [[NSNotificationCenter defaultCenter] postNotificationName:kLogedOutNotification object:nil];
    
    NSString *apiUrl = @"/v1.0.0/api/user/account/login";
    [VONetworking deleteWithUrl:apiUrl refreshRequest:NO cache:NO params:nil needSession:NO  successBlock:^(id response) {
        //移除登录信息
        [[VOLoginManager shared] removeLoginInfo];
        
        //修改登录标示
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:LoginKey];
        
        //弹出登录页面
        [[VOLoginManager shared] verifyLoginStatus];
        
        //清楚cookie&&session
        [[VONetworking shareNetworking] cleareSessionAndCookie];
        compelete();
    } failBlock:^(NSError *error) {
        //移除登录信息
        [[VOLoginManager shared] removeLoginInfo];
        
        //修改登录标示
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:LoginKey];
        
        //弹出登录页面
        [[VOLoginManager shared] verifyLoginStatus];
        
        //清楚cookie&&session
        [[VONetworking shareNetworking] cleareSessionAndCookie];
        compelete();
    }];
}

#pragma mark - 登录成功更新clientid
+ (void)logedInConnectPush
{
    [GeTuiSdk resume];
    NSString *clientId = [[NSUserDefaults standardUserDefaults] objectForKey:kPushClientId];
    NSString *mineDeviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceTokenData];
    NSDictionary *params = @{
                             @"clientId" : clientId.length ? clientId : @"",
                             @"type" : @"1",
                             @"deviceToken" : mineDeviceToken.length ? mineDeviceToken : @""
                             };
    [VONetworking postWithUrl:@"/v1.0.0/api/push/client/bind" refreshRequest:NO cache:NO params:params needSession:NO successBlock:^(id response) {
        
    } failBlock:^(NSError *error) {
        
    }];
}

//user-type
- (NSString *)getUserType
{
    VOLoginResponseModel *model = [[VOLoginManager shared] getLoginInfo];
    return model.user.type;
}
#pragma mark - 归档
//移除归档信息
- (void)removeLoginInfo
{
    [[NSFileManager defaultManager] removeItemAtPath:[self getUserInfoPath] error:nil];
}

//归档目录信息
- (NSString *)getUserInfoPath
{
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) safeObjectAtIndex:0];
    return [basePath stringByAppendingPathComponent:@"userinfo.archive"];
}

//归档
- (void)cacheInDiskOfUserInfo:(VOLoginResponseModel *)model
{
    NSDictionary *userInfo = [model toJSONDictionary];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:[self getUserInfoPath]])
    {
        [fileManager createFileAtPath:[self getUserInfoPath] contents:nil attributes:nil];
    }
    [NSKeyedArchiver archiveRootObject:userInfo toFile:[self getUserInfoPath]];
}

//解归档
- (NSDictionary *)getUserInfoFormDisk
{
    return  [NSKeyedUnarchiver unarchiveObjectWithFile:[self getUserInfoPath]];
}
@end
