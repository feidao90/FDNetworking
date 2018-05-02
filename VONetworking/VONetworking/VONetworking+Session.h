//
//  VONetworking+Session.h
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/21.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "VONetworking.h"

/**
 处理sessoin
 
 @important      session与cookie是配套的
 */
@interface VONetworking (Session)

@property (nonatomic,copy) NSString *session;
@property (nonatomic,copy) NSString *cookie;

+ (instancetype)shareNetworking;

//- (BOOL)isSessionValid;         //  session是否有效

//  添加session
- (NSMutableDictionary *)parametersAddSession:(NSDictionary *)dict;

//  添加Cookie
- (void)requestAddCookie:(NSMutableURLRequest *)request;

//  更新cookie&session
- (void)updateCookieSessionWithResponse:(NSURLResponse *)response andWithReponseData:(id)responseObject;

//清除session、cookie
- (void)cleareSessionAndCookie;
@end
