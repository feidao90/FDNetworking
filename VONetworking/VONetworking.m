//
//  VONetworking.m
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/21.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import "VONetworking.h"
#import "AFNetworking.h"

#import "AFNetworkActivityIndicatorManager.h"
#import "VONetworking+RequestManager.h"

#import "VOCacheManager.h"
#import "VONetworking+Session.h"

#import "VOLoginManager.h"
#import "VOBaseHeader.h"

#import "MBProgressHUD.h"

#define VO_ERROR_IMFORMATION @"网络出现错误，请检查网络连接"
#define VOBaseURLCacheKeyIndex @"netbaseurlcachekeyIndex"
#define VO_ERROR [NSError errorWithDomain:@"com.hVO.VONetworking.ErrorDomain" code:-9999 userInfo:@{ NSLocalizedDescriptionKey:VO_ERROR_IMFORMATION}]

/*********************************************************环境配置***************************************************************/
#ifdef DEBUG //开发环境

#define kEnviromentType 0

#else //正式环境
#define kEnviromentType 3
#endif

//超时message
#define kTimeOutMessage @"BS99999999"

static NSMutableArray   *requestTasksPool;

static NSDictionary     *headers;

static VONetworkStatus  networkStatus;

static NSTimeInterval   requestTimeout = 20.;

@implementation VONetworking
#pragma mark - manager
+ (AFHTTPSessionManager *)manager {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //默认解析模式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //安全策略 - 默认采用的是AFSSLPinningModeCertificate
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES;
    [securityPolicy setValidatesDomainName:NO];
     [manager setSecurityPolicy:securityPolicy];
    
    //配置请求序列化
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    
    [serializer setRemovesKeysWithNullValues:YES];
    
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    
    manager.requestSerializer.timeoutInterval = requestTimeout;
    
    for (NSString *key in headers.allKeys) {
        if (headers[key] != nil) {
            [manager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    
    //配置响应序列化
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*",
                                                                              @"application/octet-stream",
                                                                              @"application/zip",
                                                                              @"multipart/form-data"]];
    
    [self checkNetworkStatus];
    
    //每次网络请求的时候，检查此时磁盘中的缓存大小，阈值默认是40MB，如果超过阈值，则清理LRU缓存,同时也会清理过期缓存，缓存默认SSL是7天，磁盘缓存的大小和SSL的设置可以通过该方法[VOCacheManager shareManager] setCacheTime: diskCapacity:]设置
    [[VOCacheManager shareManager] clearLRUCache];
    
    return manager;
}

#pragma mark - get base URL
+ (NSString *)baseUrl
{
    NSInteger index = kEnviromentType;//默认生产环境
    NSString *path = [[NSBundle mainBundle]  pathForResource:@"enviroment" ofType:@"plist"];
    NSArray *enviromentList = [NSArray arrayWithContentsOfFile:path];
    NSDictionary *enviromentInfo =  [enviromentList safeObjectAtIndex:index];
     return [enviromentInfo safeObjectForKey:@"appbaseurl"];
}

+ (NSString *)h5BaseUrl
{
    NSInteger index = kEnviromentType;//默认生产环境
    NSString *path = [[NSBundle mainBundle]  pathForResource:@"enviroment" ofType:@"plist"];
    NSArray *enviromentList = [NSArray arrayWithContentsOfFile:path];
    NSDictionary *enviromentInfo =  [enviromentList safeObjectAtIndex:index];
    return [enviromentInfo safeObjectForKey:@"h5baseurl"];
}

#pragma mark - 检查网络
+ (VONetworkStatus)checkNetworkStatus {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                networkStatus = VONetworkStatusNotReachable;
                break;
            case AFNetworkReachabilityStatusUnknown:
                networkStatus = VONetworkStatusUnknown;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                networkStatus = VONetworkStatusReachableViaWWAN;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                networkStatus = VONetworkStatusReachableViaWiFi;
                break;
            default:
                networkStatus = VONetworkStatusUnknown;
                break;
        }
    }];
    return networkStatus;
}

+ (NSMutableArray *)allTasks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (requestTasksPool == nil) requestTasksPool = [NSMutableArray array];
    });
    
    return requestTasksPool;
}

#pragma mark - get
+ (VOURLSessionTask *)getWithUrl:(NSString *)url
                  refreshRequest:(BOOL)refresh
                           cache:(BOOL)cache
                          params:(NSDictionary *)params
                        needSession:(BOOL)isNeed
                    successBlock:(VOResponseSuccessBlock)successBlock
                       failBlock:(VOResponseFailBlock)failBlock
{
    //配置session
    if (!isNeed)    //非登录接口 才配置session
    {
        params =  [[self shareNetworking] parametersAddSession:params];
    }
    //配置完整url
    NSString *baseURL = [self baseUrl];
    url = [NSString stringWithFormat:@"%@%@",baseURL,url];
    //配置session
    params =  [[self shareNetworking] parametersAddSession:params];
    
    //将session拷贝到堆中，block内部才可以获取得到session
    __block VOURLSessionTask *session = nil;
    
    AFHTTPSessionManager *manager = [self manager];
    
    if (networkStatus == VONetworkStatusNotReachable) {
        //无网络弹窗
        [VONetworking invalidNetAlert];
        if (failBlock)
        {
            failBlock(VO_ERROR);
        }
        [[self allTasks] removeObject:session];
        return session;
    }
    
    id responseObj = [[VOCacheManager shareManager] getCacheResponseObjectWithRequestUrl:url params:params];
    
    if (responseObj && cache) {
        if (successBlock) successBlock([responseObj safeObjectForKey:@"data"]);
    }
    
    session = [manager GET:url
                parameters:params
                  progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      NSInteger errorCode =[[responseObject safeObjectForKey:@"code"] integerValue];
                      if (errorCode == 200)
                      {
                          if (successBlock)
                              successBlock([responseObject safeObjectForKey:@"data"]);
                        if (cache) [[VOCacheManager shareManager] cacheResponseObject:responseObject requestUrl:url params:params];
                      }else
                      {
                        if ([[responseObject safeObjectForKey:@"message"]  isEqualToString:@"BS00050001"] || [[responseObject safeObjectForKey:@"message"] isEqualToString:@"BS00050002"])  //session || cookie失效
                          {
                              [[VONetworking shareNetworking] alertInvalidleSession];
                          }else if([[responseObject safeObjectForKey:@"message"] isEqualToString:@"BS00140002"])    //账号被禁用
                          {
                              [[VONetworking shareNetworking] alertProhibitAccount];
                          }
                          NSError *error = [NSError errorWithDomain:@"com.voffice.response.errorcode" code:errorCode userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[responseObject safeObjectForKey:@"messageCN"],@"messageCN", [responseObject safeObjectForKey:@"message"], @"message", nil]];
                          if (failBlock) failBlock(error);
                      }                      
                      [[self allTasks] removeObject:session];
                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      //超时处理
                      if (error.code == -1001) {
                          error = [NSError errorWithDomain:@"com.voffice.response.errorcode" code:error.code userInfo:[NSDictionary dictionaryWithObjectsAndKeys: @"网络超时",@"messageCN", kTimeOutMessage, @"message", nil]];
                      }
                      if (error.code != -999) {
                          if (failBlock) failBlock(error);
                          [[self allTasks] removeObject:session];
                      }
                  }];
    
    if ([self haveSameRequestInTasksPool:session] && !refresh) {
        //取消新请求
        [session cancel];
        return session;
    }else {
        //无论是否有旧请求，先执行取消旧请求，反正都需要刷新请求
        VOURLSessionTask *oldTask = [self cancleSameRequestInTasksPool:session];
        if (oldTask) [[self allTasks] removeObject:oldTask];
        if (session) [[self allTasks] addObject:session];
        [session resume];
        return session;
    }
}

#pragma mark - update session &  cookie
+ (void)updateSessionAndCookieWithTask:(NSURLSessionDataTask *)task andResponseObjec:(id)responseObject
{
    //登录后 更新session & cookie
    if ([task.response.URL.absoluteString  containsString:@"/v1.0.0/api/user/account/login"])
    {
        [[self shareNetworking] updateCookieSessionWithResponse:task.response andWithReponseData:responseObject];
    }
}

#pragma mark - post
+ (VOURLSessionTask *)postWithUrl:(NSString *)url
                   refreshRequest:(BOOL)refresh
                            cache:(BOOL)cache
                           params:(NSDictionary *)params
                            needSession:(BOOL)isNeed
                     successBlock:(VOResponseSuccessBlock)successBlock
                        failBlock:(VOResponseFailBlock)failBlock
{
    //配置session
    if (!isNeed)    //非登录接口 才配置session
    {
            params =  [[self shareNetworking] parametersAddSession:params];
    }
    
    //配置完整url
    NSString *baseURL = [self baseUrl];
    url = [NSString stringWithFormat:@"%@%@",baseURL,url];
    
    
    __block VOURLSessionTask *session = nil;
    
    AFHTTPSessionManager *manager = [self manager];
    
    if (networkStatus == VONetworkStatusNotReachable) {
        //无网络弹窗
        [VONetworking invalidNetAlert];
        if (failBlock)
        {
            failBlock(VO_ERROR);
        }
        [[self allTasks] removeObject:session];
        return session;
    }
    
    id responseObj = [[VOCacheManager shareManager] getCacheResponseObjectWithRequestUrl:url params:params];
    
    if (responseObj && cache) {
        if (successBlock)
            successBlock([responseObj safeObjectForKey:@"data"]);
    }

    session = [manager POST:url
                 parameters:params
                   progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
                       NSInteger errorCode =[[responseObject safeObjectForKey:@"code"] integerValue];
                       if (errorCode == 200)
                       {
                           //更新session & cookie
                           [self  updateSessionAndCookieWithTask:task andResponseObjec:responseObject];
                           if (successBlock)
                               successBlock([responseObject safeObjectForKey:@"data"]);
                           
                           //缓存
                           if (cache) [[VOCacheManager shareManager] cacheResponseObject:responseObject requestUrl:url params:params];
                       }else
                       {
                           if ([[responseObject safeObjectForKey:@"message"]  isEqualToString:@"BS00050001"] || [[responseObject safeObjectForKey:@"message"] isEqualToString:@"BS00050002"])  //session || cookie失效
                           {
                               [[VONetworking shareNetworking] alertInvalidleSession];
                           }else if([[responseObject safeObjectForKey:@"message"] isEqualToString:@"BS00140002"])    //账号被禁用
                           {
                               [[VONetworking shareNetworking] alertProhibitAccount];
                           }
                           NSError *error = [NSError errorWithDomain:@"com.voffice.response.errorcode" code:errorCode userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[responseObject safeObjectForKey:@"messageCN"],@"messageCN", [responseObject safeObjectForKey:@"message"], @"message", nil]];
                           if (failBlock) failBlock(error);
                       }
                       
                       //清除重复请求
                       if ([[self allTasks] containsObject:session]) {
                           [[self allTasks] removeObject:session];
                       }
                       
                   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                       //超时处理
                       if (error.code == -1001) {
                           error = [NSError errorWithDomain:@"com.voffice.response.errorcode" code:error.code userInfo:[NSDictionary dictionaryWithObjectsAndKeys: @"网络超时",@"messageCN", kTimeOutMessage, @"message", nil]];
                       }
                       if (error.code != -999) {
                           if (failBlock) failBlock(error);
                           [[self allTasks] removeObject:session];
                       }
                   }];
    
    if ([self haveSameRequestInTasksPool:session] && !refresh) {
        [session cancel];
        return session;
    }else {
        VOURLSessionTask *oldTask = [self cancleSameRequestInTasksPool:session];
        if (oldTask) [[self allTasks] removeObject:oldTask];
        if (session) [[self allTasks] addObject:session];
        [session resume];
        return session;
    }
}

#pragma mark - PUT
+ (VOURLSessionTask *)putWithUrl:(NSString *)url
                  refreshRequest:(BOOL)refresh
                           cache:(BOOL)cache
                          params:(NSDictionary *)params
                     needSession:(BOOL)isNeed
                    successBlock:(VOResponseSuccessBlock)successBlock
                       failBlock:(VOResponseFailBlock)failBlock
{
    //配置session
    if (!isNeed)    //非登录接口 才配置session
    {
        params =  [[self shareNetworking] parametersAddSession:params];
    }
    
    //配置完整url
    NSString *baseURL = [self baseUrl];
    url = [NSString stringWithFormat:@"%@%@",baseURL,url];
    
    
    __block VOURLSessionTask *session = nil;
    
    AFHTTPSessionManager *manager = [self manager];
    
    if (networkStatus == VONetworkStatusNotReachable) {
        //无网络弹窗
        [VONetworking invalidNetAlert];
        if (failBlock)
        {
            failBlock(VO_ERROR);
        }
        [[self allTasks] removeObject:session];
        return session;
    }
    
    id responseObj = [[VOCacheManager shareManager] getCacheResponseObjectWithRequestUrl:url params:params];
    
    if (responseObj && cache) {
        if (successBlock)
            successBlock([responseObj safeObjectForKey:@"data"]);
    }
    
    session = [manager PUT:url
                 parameters:params
                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
                       NSInteger errorCode =[[responseObject safeObjectForKey:@"code"] integerValue];
                       if (errorCode == 200)
                       {
                           if (successBlock)
                               successBlock([responseObject safeObjectForKey:@"data"]);
                           
                           //缓存
                           if (cache) [[VOCacheManager shareManager] cacheResponseObject:responseObject requestUrl:url params:params];
                       }else
                       {
                           if ([[responseObject safeObjectForKey:@"message"]  isEqualToString:@"BS00050001"] || [[responseObject safeObjectForKey:@"message"] isEqualToString:@"BS00050002"])  //session || cookie失效
                           {
                               [[VONetworking shareNetworking] alertInvalidleSession];
                           }else if([[responseObject safeObjectForKey:@"message"] isEqualToString:@"BS00140002"])    //账号被禁用
                           {
                               [[VONetworking shareNetworking] alertProhibitAccount];
                           }
                           NSError *error = [NSError errorWithDomain:@"com.voffice.response.errorcode" code:errorCode userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[responseObject safeObjectForKey:@"messageCN"],@"messageCN", [responseObject safeObjectForKey:@"message"], @"message", nil]];
                           if (failBlock) failBlock(error);
                       }
                       
                       //清除重复请求
                       if ([[self allTasks] containsObject:session]) {
                           [[self allTasks] removeObject:session];
                       }
                       
                   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                       //超时处理
                       if (error.code == -1001) {
                           error = [NSError errorWithDomain:@"com.voffice.response.errorcode" code:error.code userInfo:[NSDictionary dictionaryWithObjectsAndKeys: @"网络超时",@"messageCN", kTimeOutMessage, @"message", nil]];
                       }
                       if (error.code != -999) {
                           if (failBlock) failBlock(error);
                           [[self allTasks] removeObject:session];
                       }
                   }];
    
    
    if ([self haveSameRequestInTasksPool:session] && !refresh) {
        [session cancel];
        return session;
    }else {
        VOURLSessionTask *oldTask = [self cancleSameRequestInTasksPool:session];
        if (oldTask) [[self allTasks] removeObject:oldTask];
        if (session) [[self allTasks] addObject:session];
        [session resume];
        return session;
    }
}

#pragma mark - DELETE
+ (VOURLSessionTask *)deleteWithUrl:(NSString *)url
                     refreshRequest:(BOOL)refresh
                              cache:(BOOL)cache
                             params:(NSDictionary *)params
                        needSession:(BOOL)isNeed
                       successBlock:(VOResponseSuccessBlock)successBlock
                          failBlock:(VOResponseFailBlock)failBlock
{
    //配置session
    if (!isNeed)    //非登录接口 才配置session
    {
        params =  [[self shareNetworking] parametersAddSession:params];
    }
    
    //配置完整url
    NSString *baseURL = [self baseUrl];
    url = [NSString stringWithFormat:@"%@%@",baseURL,url];
    
    
    __block VOURLSessionTask *session = nil;
    
    AFHTTPSessionManager *manager = [self manager];
    
    if (networkStatus == VONetworkStatusNotReachable) {
        //无网络弹窗
        [VONetworking invalidNetAlert];
        if (failBlock)
        {
            failBlock(VO_ERROR);
        }
        [[self allTasks] removeObject:session];
        return session;
    }
    
    id responseObj = [[VOCacheManager shareManager] getCacheResponseObjectWithRequestUrl:url params:params];
    
    if (responseObj && cache) {
        if (successBlock)
            successBlock([responseObj safeObjectForKey:@"data"]);
    }
    
    session = [manager DELETE:url
                parameters:params
                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
                       NSInteger errorCode =[[responseObject safeObjectForKey:@"code"] integerValue];
                       if (errorCode == 200)
                       {
                           if (successBlock)
                               successBlock([responseObject safeObjectForKey:@"data"]);
                           
                           //缓存
                           if (cache) [[VOCacheManager shareManager] cacheResponseObject:responseObject requestUrl:url params:params];
                       }else
                       {
                           if ([[responseObject safeObjectForKey:@"message"]  isEqualToString:@"BS00050001"] || [[responseObject safeObjectForKey:@"message"] isEqualToString:@"BS00050002"])  //session || cookie失效
                           {
                               [[VONetworking shareNetworking] alertInvalidleSession];
                           }else if([[responseObject safeObjectForKey:@"message"] isEqualToString:@"BS00140002"])    //账号被禁用
                           {
                               [[VONetworking shareNetworking] alertProhibitAccount];
                           }
                           NSError *error = [NSError errorWithDomain:@"com.voffice.response.errorcode" code:errorCode userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[responseObject safeObjectForKey:@"messageCN"],@"messageCN", [responseObject safeObjectForKey:@"message"], @"message", nil]];
                           if (failBlock) failBlock(error);
                       }
                       
                       //清除重复请求
                       if ([[self allTasks] containsObject:session]) {
                           [[self allTasks] removeObject:session];
                       }
                       
                   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                       //超时处理
                       if (error.code == -1001) {
                           error = [NSError errorWithDomain:@"com.voffice.response.errorcode" code:error.code userInfo:[NSDictionary dictionaryWithObjectsAndKeys: @"网络超时",@"messageCN", kTimeOutMessage, @"message", nil]];
                       }
                       if (error.code != -999) {
                           if (failBlock) failBlock(error);
                           [[self allTasks] removeObject:session];
                       }
                   }];
    
    
    if ([self haveSameRequestInTasksPool:session] && !refresh) {
        [session cancel];
        return session;
    }else {
        VOURLSessionTask *oldTask = [self cancleSameRequestInTasksPool:session];
        if (oldTask) [[self allTasks] removeObject:oldTask];
        if (session) [[self allTasks] addObject:session];
        [session resume];
        return session;
    }
}

#pragma mark - 文件上传
+ (VOURLSessionTask *)uploadFileWithUrl:(NSString *)url
                         OSSAccessKeyId:(NSString *)OSSAccessKeyId
                               callback:(NSString *)callback
                                 expire:(NSString *)expire
                                    key:(NSString *)key
                                 policy:(NSString *)policy
                              signature:(NSString *)signature
                                   file:(NSData *)file
                           successBlock:(VOResponseSuccessBlock)successBlock
                              failBlock:(VOResponseFailBlock)failBlock
{
    __block VOURLSessionTask *session = nil;
    
    AFHTTPSessionManager *manager = [self manager];
    
    if (networkStatus == VONetworkStatusNotReachable) {
        //无网络弹窗
        [VONetworking invalidNetAlert];
        if (failBlock)
        {
            failBlock(VO_ERROR);
        }
        [[self allTasks] removeObject:session];
        return session;
    }
    
    //cookie && session
    session = [manager POST:url
                 parameters:nil
  constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
      //OSSAccessKeyId
      [formData appendPartWithFormData:[OSSAccessKeyId dataUsingEncoding:NSUTF8StringEncoding] name:@"OSSAccessKeyId"];
      //callback
      [formData appendPartWithFormData:[callback dataUsingEncoding:NSUTF8StringEncoding] name:@"callback"];
      //expire
      [formData appendPartWithFormData:[expire dataUsingEncoding:NSUTF8StringEncoding] name:@"expire"];
      //key
      [formData appendPartWithFormData:[key dataUsingEncoding:NSUTF8StringEncoding] name:@"key"];
      //policy
      [formData appendPartWithFormData:[policy dataUsingEncoding:NSUTF8StringEncoding] name:@"policy"];
      //signature
      [formData appendPartWithFormData:[signature dataUsingEncoding:NSUTF8StringEncoding] name:@"signature"];
      //fileInfo
      [formData appendPartWithFormData:file name:@"file"];
      
      NSString *fileName = nil;
      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      formatter.dateFormat = @"yyyyMMddHHmmss";
      NSString *day = [formatter stringFromDate:[NSDate date]];
      fileName = [NSString stringWithFormat:@"%@.%@",day,@"jpg"];
      //Content-Disposition
      [formData appendPartWithFormData:[fileName dataUsingEncoding:NSUTF8StringEncoding] name:@"Content-Disposition"];
      
  } progress:^(NSProgress * _Nonnull uploadProgress) {
  } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
      if (successBlock) successBlock(responseObject);
      [[self allTasks] removeObject:session];
      
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
      if (failBlock) failBlock(error);
      [[self allTasks] removeObject:session];
      
  }];
    
    
    [session resume];
    
    if (session) [[self allTasks] addObject:session];
    
    return session;
}

#pragma mark - 文件上传 带进度
+ (VOURLSessionTask *)uploadFileWithUrl:(NSString *)url
                         OSSAccessKeyId:(NSString *)OSSAccessKeyId
                               callback:(NSString *)callback
                                 expire:(NSString *)expire
                                    key:(NSString *)key
                                 policy:(NSString *)policy
                              signature:(NSString *)signature
                                   file:(NSData *)file
                               progress:(VODownloadProgress)progressBlock
                           successBlock:(VOResponseSuccessBlock)successBlock
                              failBlock:(VOResponseFailBlock)failBlock
{
    __block VOURLSessionTask *session = nil;
    
    AFHTTPSessionManager *manager = [self manager];
    
    if (networkStatus == VONetworkStatusNotReachable) {
        //无网络弹窗
        [VONetworking invalidNetAlert];
        if (failBlock)
        {
            failBlock(VO_ERROR);
        }
        [[self allTasks] removeObject:session];
        return session;
    }
    //cookie && session
    session = [manager POST:url
                 parameters:nil
  constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
      //OSSAccessKeyId
      [formData appendPartWithFormData:[OSSAccessKeyId dataUsingEncoding:NSUTF8StringEncoding] name:@"OSSAccessKeyId"];
      //callback
      [formData appendPartWithFormData:[callback dataUsingEncoding:NSUTF8StringEncoding] name:@"callback"];
      //expire
      [formData appendPartWithFormData:[expire dataUsingEncoding:NSUTF8StringEncoding] name:@"expire"];
      //key
      [formData appendPartWithFormData:[key dataUsingEncoding:NSUTF8StringEncoding] name:@"key"];
      //policy
      [formData appendPartWithFormData:[policy dataUsingEncoding:NSUTF8StringEncoding] name:@"policy"];
      //signature
      [formData appendPartWithFormData:[signature dataUsingEncoding:NSUTF8StringEncoding] name:@"signature"];
      //fileInfo
      [formData appendPartWithFormData:file name:@"file"];
      
      NSString *fileName = nil;
      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      formatter.dateFormat = @"yyyyMMddHHmmss";
      NSString *day = [formatter stringFromDate:[NSDate date]];
      fileName = [NSString stringWithFormat:@"%@.%@",day,@"jpg"];
      //Content-Disposition
      [formData appendPartWithFormData:[fileName dataUsingEncoding:NSUTF8StringEncoding] name:@"Content-Disposition"];
      
  } progress:^(NSProgress * _Nonnull uploadProgress) {
      if (progressBlock) {
          progressBlock(uploadProgress);
      }
      if(uploadProgress.fractionCompleted)  [[self allTasks] removeObject:session];
  } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
      if (successBlock) successBlock([responseObject safeObjectForKey:@"data"]);
      [[self allTasks] removeObject:session];
      
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
      if (failBlock) failBlock(error);
      [[self allTasks] removeObject:session];
      
  }];
    [session resume];
    
    if (session) [[self allTasks] addObject:session];
    
    return session;
}

#pragma mark - 无网络弹窗
+ (void)invalidNetAlert
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"网络连接出了问题" message:@"请检查您的网络连接活着进入\"设置\"中允许\"VOffice\"访问网络数据" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString * urlString = @"App-Prefs:root=WIFI";
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            }
        }
    }];
    [alertVC addAction:firstAction];
    UIAlertAction *secAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVC addAction:secAction];
    if ([[UIApplication sharedApplication].delegate.window.rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *) [UIApplication sharedApplication].delegate.window.rootViewController;
        if ([[tab class] isKindOfClass:[UITabBarController class]]) {
            [tab.selectedViewController presentViewController:alertVC animated:YES completion:nil];
        }
    }
}

#pragma mark - session过期验证
- (void)alertInvalidleSession
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"会话过期" message:@"当前会话已过期，请重新登录" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //弹出登录页面
        __block UITabBarController *tabbar = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        __block MBProgressHUD *hud;
        if ([tabbar isKindOfClass:[UITabBarController class]]) {
            if (tabbar.selectedViewController.view) {
                hud = [MBProgressHUD showHUDAddedTo:tabbar.selectedViewController.view animated:YES];
            }
        }else if ([tabbar isKindOfClass:[VOBaseNavViewController class]])
        {
            hud = [MBProgressHUD showHUDAddedTo:tabbar.view animated:YES];
        }
        [VOLoginManager logoutWithComplete:^{
            [hud hideAnimated:YES];
            if ([[tabbar class] isKindOfClass:[UITabBarController class]]) {
                [tabbar.selectedViewController popToRootViewControllerAnimated:NO];
                UITabBarController *tabVC = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
                if ([[tabVC class] isKindOfClass:[UITabBarController class]]) {
                    tabVC.selectedIndex = 0;
                }
            }
        }];
    }];
    [alertVC addAction:firstAction];
    if ([[UIApplication sharedApplication].delegate.window.rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        if ([[tab class] isKindOfClass:[UITabBarController class]]) {
            [tab.selectedViewController presentViewController:alertVC animated:YES completion:nil];
        }
    }
}

- (void)alertProhibitAccount
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"您的账号已被禁用，暂时无法使用应用" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //弹出登录页面
        __block UITabBarController *tabbar = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        MBProgressHUD *hud;
        if (tabbar.selectedViewController.view) {
            hud = [MBProgressHUD showHUDAddedTo:tabbar.selectedViewController.view animated:YES];
            [hud hideAnimated:YES afterDelay:.5];
        }
        [VOLoginManager logoutWithComplete:^{
            [tabbar.selectedViewController popToRootViewControllerAnimated:NO];
            UITabBarController *tabVC = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
            if ([[tabVC class] isKindOfClass:[UITabBarController class]]) {
                tabVC.selectedIndex = 0;
            }
        }];
    }];
    [alertVC addAction:firstAction];
    if ([[UIApplication sharedApplication].delegate.window.rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        if ([[tab class] isKindOfClass:[UITabBarController class]]) {
            [tab.selectedViewController presentViewController:alertVC animated:YES completion:nil];
        }
    }
}
#pragma mark - other method
+ (void)setupTimeout:(NSTimeInterval)timeout {
    requestTimeout = timeout;
}

+ (void)cancleAllRequest {
    @synchronized (self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(VOURLSessionTask  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[VOURLSessionTask class]]) {
                [obj cancel];
            }
        }];
        [[self allTasks] removeAllObjects];
    }
}

+ (void)cancelRequestWithURL:(NSString *)url {
    if (!url) return;
    @synchronized (self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(VOURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[VOURLSessionTask class]]) {
                if ([obj.currentRequest.URL.absoluteString hasSuffix:url]) {
                    [obj cancel];
                    *stop = YES;
                }
            }
        }];
    }
}

+ (void)configHttpHeader:(NSDictionary *)httpHeader {
    headers = httpHeader;
}

+ (NSArray *)currentRunningTasks {
    return [[self allTasks] copy];
}

@end

@implementation VONetworking (cache)
+ (NSUInteger)totalCacheSize {
    return [[VOCacheManager shareManager] totalCacheSize];
}

+ (NSUInteger)totalDownloadDataSize {
    return [[VOCacheManager shareManager] totalDownloadDataSize];
}

+ (void)clearDownloadData {
    [[VOCacheManager shareManager] clearDownloadData];
}

+ (NSString *)getDownDirectoryPath {
    return [[VOCacheManager shareManager] getDownDirectoryPath];
}

+ (NSString *)getCacheDiretoryPath {
    
    return [[VOCacheManager shareManager] getCacheDiretoryPath];
}

+ (void)clearTotalCache {
    [[VOCacheManager shareManager] clearTotalCache];
}
@end
