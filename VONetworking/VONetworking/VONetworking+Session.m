//
//  VONetworking+Session.m
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/21.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "VONetworking+Session.h"
#import "VOCategorySet.h"

static NSString *VOConnectionSessionKey = @"VOConnectionSessionKey";
static NSString *VOConnectionCookieKey = @"VOConnectionCookieKey";
//static NSString *VOConnectionExpireKey = @"VOConnectionExpireKey";

@implementation VONetworking (Session)
//------------------------------------------------------------------------------------------------------------
+ (VONetworking *)shareNetworking
{
    static VONetworking *shareNet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (shareNet == nil)
            shareNet = [[VONetworking alloc] init];
    });
    return shareNet;
};

#pragma mark - session
- (NSString *)session {
//    if (![self isSessionValid]) {
//        return nil;
//    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *session = [defaults stringForKey:VOConnectionSessionKey];
    return session;
}

- (void)setSession:(NSString *)session {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:session forKey:VOConnectionSessionKey];
    [defaults synchronize];
}

#pragma mark - cookie
- (NSString *)cookie {
//    if (![self isSessionValid]) {
//        return nil;
//    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *cookie = [defaults objectForKey:VOConnectionCookieKey];
    return cookie;
}


- (void)setCookie:(NSString *)cookie {
    NSArray *array = [cookie componentsSeparatedByString:@"; "];
    NSString *vofficeText = nil;
    for (NSString *text in array) {
        if ([text containsString:@"voffice"]) {
            vofficeText = text;
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //
    if (vofficeText.length) {
        [defaults setObject:vofficeText forKey:VOConnectionCookieKey];
    }
    //
//    if (maxAgeText.length) {
//        NSArray *arr = [maxAgeText componentsSeparatedByString:@"="];
//        if (arr.count == 2) {
//            NSTimeInterval maxAge = [arr[1] integerValue];
//            NSDate *date = [[NSDate date] dateByAddingTimeInterval:maxAge];
//            [defaults setObject:date forKey:VOConnectionExpireKey];
//        }
//    }
    
    [defaults synchronize];
}

//#pragma mark -检测session是否过期
//- (BOOL)isSessionValid {
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSDate *expireDate = [defaults objectForKey:VOConnectionExpireKey];
//    if (expireDate == nil) {
//        return NO;
//    }
//    NSDate *now = [NSDate date];
//    BOOL isValid = [expireDate earlierDate:now] == now ? true : false;
//    return isValid;
//}

#pragma mark -  添加session
- (NSMutableDictionary *)parametersAddSession:(NSDictionary *)dict {
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    NSString *sid = self.session;
    if (sid != nil) {
        [mDict setObject:sid forKey:@"sid"];
    }
    return mDict;
}

#pragma mark -  添加Cookie
- (void)requestAddCookie:(NSMutableURLRequest *)request {
    NSString *cookie = self.cookie;
    if (cookie != nil) {
        [request setValue:cookie forHTTPHeaderField:@"Cookie"];
    }
}

//------------------------------------------------------------------------------------------------------------

#pragma mark -  更新cookie&session
- (void)updateCookieSessionWithResponse:(NSURLResponse *)response andWithReponseData:(id)responseObject
{
    //  登陆需要处理session、cookie
    if (response)
    {
        //更新session cookie
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSDictionary *data = [responseObject safeObjectForKey:@"data"];
        self.session = [data safeObjectForKey:@"sid"];
        self.cookie = [httpResponse.allHeaderFields valueForKey:@"Set-Cookie"];
    }
}
#pragma mark - 清除session、cookie
- (void)cleareSessionAndCookie
{
    self.session = nil;
    self.cookie = nil;
}
@end
