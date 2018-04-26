//
//  VONetworking.h
//  Voffice-ios
//
//  Created by 何广忠 on 2017/12/21.
//  Copyright © 2017年 何广忠. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  网络状态
 */
typedef NS_ENUM(NSInteger, VONetworkStatus) {
    /**
     *  未知网络
     */
    VONetworkStatusUnknown             = 1 << 0,
    /**
     *  无法连接
     */
    VONetworkStatusNotReachable        = 1 << 1,
    /**
     *  WWAN网络
     */
    VONetworkStatusReachableViaWWAN    = 1 << 2,
    /**
     *  WiFi网络
     */
    VONetworkStatusReachableViaWiFi    = 1 << 3
};

/**
 *  请求任务
 */
typedef NSURLSessionTask VOURLSessionTask;

/**
 *  成功回调
 *
 *  @param response 成功后返回的数据
 */
typedef void(^VOResponseSuccessBlock)(id response);

/**
 *  失败回调
 *
 *  @param error 失败后返回的错误信息
 */
typedef void(^VOResponseFailBlock)(NSError *error);

/**
 *  下载进度
 *
 *  @param uploadProgress              已下载进度
 */
typedef void (^VODownloadProgress)(NSProgress * uploadProgress);

/**
 *  下载成功回调
 *
 *  @param url                       下载存放的路径
 */
typedef void(^VODownloadSuccessBlock)(NSURL *url);


/**
 *  上传进度
 *
 *  @param bytesWritten              已上传的大小
 *  @param totalBytes                总上传大小
 */
typedef void(^VOUploadProgressBlock)(int64_t bytesWritten,
                                     int64_t totalBytes);
/**
 *  多文件上传成功回调
 *
 *  @param responses 成功后返回的数据
 */
typedef void(^VOMultUploadSuccessBlock)(NSArray *responses);

/**
 *  多文件上传失败回调
 *
 *  @param errors 失败后返回的错误信息
 */
typedef void(^VOMultUploadFailBlock)(NSArray *errors);

typedef VODownloadProgress VOGetProgress;

typedef VODownloadProgress VOPostProgress;

typedef VOResponseFailBlock VODownloadFailBlock;
@interface VONetworking : NSObject

/*
    base-url
 */
+ (NSString *)baseUrl;
/**
 *  正在运行的网络任务
 *
 *  @return task
 */

/*
 h5BaseUrl
 */
+ (NSString *)h5BaseUrl;
+ (NSArray *)currentRunningTasks;


/*
 检查网络
 */
+ (VONetworkStatus)checkNetworkStatus;

/**
 *  配置请求头
 *
 *  @param httpHeader 请求头
 */
+ (void)configHttpHeader:(NSDictionary *)httpHeader;

/**
 *  取消GET请求
 */
+ (void)cancelRequestWithURL:(NSString *)url;

/**
 *  取消所有请求
 */
+ (void)cancleAllRequest;

/**
 *    设置超时时间
 *
 *  @param timeout 超时时间
 */
+ (void)setupTimeout:(NSTimeInterval)timeout;

/**
 *  GET请求
 *
 *  @param url              请求路径
 *  @param cache            是否缓存
 *  @param refresh          是否刷新请求(遇到重复请求，若为YES，则会取消旧的请求，用新的请求，若为NO，则忽略新请求，用旧请求)
 *  @param params           拼接参数
 *  @param isNeed           是否需要session
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (VOURLSessionTask *)getWithUrl:(NSString *)url
                  refreshRequest:(BOOL)refresh
                           cache:(BOOL)cache
                          params:(NSDictionary *)params
                        needSession:(BOOL)isNeed
                    successBlock:(VOResponseSuccessBlock)successBlock
                       failBlock:(VOResponseFailBlock)failBlock;




/**
 *  POST请求
 *
 *  @param url              请求路径
 *  @param cache            是否缓存
 *  @param refresh          解释同上
 *  @param params           拼接参数
 *  @param isNeed           是否需要session
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (VOURLSessionTask *)postWithUrl:(NSString *)url
                   refreshRequest:(BOOL)refresh
                            cache:(BOOL)cache
                           params:(NSDictionary *)params
                      needSession:(BOOL)isNeed
                     successBlock:(VOResponseSuccessBlock)successBlock
                        failBlock:(VOResponseFailBlock)failBlock;


/**
 *  PUT请求
 *
 *  @param url              请求路径
 *  @param cache            是否缓存
 *  @param refresh          解释同上
 *  @param params           拼接参数
 *  @param isNeed           是否需要session
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */

+ (VOURLSessionTask *)putWithUrl:(NSString *)url
                   refreshRequest:(BOOL)refresh
                            cache:(BOOL)cache
                           params:(NSDictionary *)params
                      needSession:(BOOL)isNeed
                     successBlock:(VOResponseSuccessBlock)successBlock
                        failBlock:(VOResponseFailBlock)failBlock;

/**
 *  DELETE请求
 *
 *  @param url              请求路径
 *  @param cache            是否缓存
 *  @param refresh          解释同上
 *  @param params           拼接参数
 *  @param isNeed           是否需要session
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */

+ (VOURLSessionTask *)deleteWithUrl:(NSString *)url
                  refreshRequest:(BOOL)refresh
                           cache:(BOOL)cache
                          params:(NSDictionary *)params
                     needSession:(BOOL)isNeed
                    successBlock:(VOResponseSuccessBlock)successBlock
                       failBlock:(VOResponseFailBlock)failBlock;


/**
 *  文件上传
 */
+ (VOURLSessionTask *)uploadFileWithUrl:(NSString *)url
                               OSSAccessKeyId:(NSString *)OSSAccessKeyId
                                   callback:(NSString *)callback
                                    expire:(NSString *)expire
                                    key:(NSString *)key
                                   policy:(NSString *)policy
                                    signature:(NSString *)signature
                                   file:(NSData *)file
                           successBlock:(VOResponseSuccessBlock)successBlock
                              failBlock:(VOResponseFailBlock)failBlock;

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
                              failBlock:(VOResponseFailBlock)failBlock;
@end



@interface VONetworking (cache)

/**
 *  获取缓存目录路径
 *
 *  @return 缓存目录路径
 */
+ (NSString *)getCacheDiretoryPath;

/**
 *  获取下载目录路径
 *
 *  @return 下载目录路径
 */
+ (NSString *)getDownDirectoryPath;

/**
 *  获取缓存大小
 *
 *  @return 缓存大小
 */
+ (NSUInteger)totalCacheSize;

/**
 *  清除所有缓存
 */
+ (void)clearTotalCache;

/**
 *  获取所有下载数据大小
 *
 *  @return 下载数据大小
 */
+ (NSUInteger)totalDownloadDataSize;

/**
 *  清除下载数据
 */
+ (void)clearDownloadData;
@end
