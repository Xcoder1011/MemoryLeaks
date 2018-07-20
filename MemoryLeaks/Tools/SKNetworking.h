//
//  SKNetworking.h
//  SKNetworkingDemo
//
//  Created by wushangkun on 16/5/20.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define DLog(s, ... ) NSLog(@"[%@ in line %d] ==== %@",[[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s),##__VA_ARGS__])
#else
#define DLog(s, ... )
#endif

typedef NS_ENUM(NSInteger, SKNetworkReachabilityStatus) {
    SKNetworkReachabilityStatusUnknown          = -1,  /** 未知网络*/
    SKNetworkReachabilityStatusNotReachable     = 0,   /** 无网络*/
    SKNetworkReachabilityStatusReachableViaWWAN = 1,   /** 手机网络*/
    SKNetworkReachabilityStatusReachableViaWiFi = 2,   /** WIFI网络*/
};

typedef NS_ENUM(NSInteger, SKDownloadingStatus) {

    kSKDownloadingStatusSuspended = 1, // 暂定状态
    kSKDownloadingStatusFailed ,       // 下载失败

};

/**
 *  下载进度
 *
 *  @param bytesRead      已下载文件的大小
 *  @param totalBytesRead 文件总大小
 */
typedef void(^SKDownloadProgress)(int64_t bytesRead,
                                  int64_t totalBytesRead,
                                  NSString *speed);

/**
 *  请求成功
 *
 *  @param response 请求成功返回的数据
 */
typedef void(^SKResponseSuccess)(id response);

/**
 *  请求失败
 *
 *  @param error 请求失败错误信息
 */
typedef void(^SKResponseFailure)(NSError *error);

/**
 *  下载失败回调
 *
 *  @param error 下载失败错误信息
 */
typedef void(^SKDownloadFailure)(NSError *error , SKDownloadingStatus downloadStatus);

/**
 *  网络状态回调
 *
 *  @param networkReachabilityStatus 当前网络状态
 */
typedef void(^SKReachabilityStatusChangeBlock)(SKNetworkReachabilityStatus networkReachabilityStatus);


/**
 *  所有接口返回的类型都是基类NSURLSessionTask，若要接收返回值
 *  且处理，请转换成对应的子类类型
 */
typedef NSURLSessionTask SKURLSessionTask;
typedef NSURLSessionDownloadTask SKURLSessionDownloadTask;



@interface SKNetworking : NSObject 

/**
 *  获取网络接口的基础URL
 */
+ (NSString *)baseUrl;

/**
 *  开启或关闭接口打印信息,默认是NO
 *
 *  @param isDebug 开发期，是否开启打印信息
 */
+ (void)enableInterfaceDebug:(BOOL)isDebug;

/**
 *  设置网络接口的基础url
 */
+ (void)setBaseUrl:(NSString *)baseUrl;

/**
 *  设置请求超时时间，默认为60秒
 *
 *  @param timeout 超时时间
 */
+(void)setTimeout:(NSTimeInterval)timeout;

/**
 *  设置允许同时最大并发数量，默认为3
 */
+(void)setMaxOperationCount:(NSInteger)maxOperationCount;

/**
 *   配置公共的请求头,只调用一次即可，通常放在应用启动的时候配置就可以了
 *
 *  @param httpHeaders 只需要将与服务器确定的固定参数设置即可
 */
+ (void)setCommonHttpHeaders:(NSDictionary *)httpHeaders;

/**
 *  开始监听网络
 */
+ (void)startMonitoringNetwork;

/**
 *  监听网络回调
 */
+ (void)checkNetworkStatus:(SKReachabilityStatusChangeBlock)block;

/**
 *  当前网络状态
 */
+ (SKNetworkReachabilityStatus)currentNetworkStatus;

/**
 *  GET 请求
 */
+ (SKURLSessionTask *)GETWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                         success:(SKResponseSuccess)success
                            fail:(SKResponseFailure)fail;
/**
 *  GET 请求 （progress）
 */
+ (SKURLSessionTask *)GETWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                        progress:(SKDownloadProgress)progress
                         success:(SKResponseSuccess)success
                            fail:(SKResponseFailure)fail;

/**
 *  POST 请求
 */
+ (SKURLSessionTask *)POSTWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                          success:(SKResponseSuccess)success
                             fail:(SKResponseFailure)fail;
/**
 *  POST 请求 （progress）
 */
+ (SKURLSessionTask *)POSTWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                         progress:(SKDownloadProgress)progress
                          success:(SKResponseSuccess)success
                             fail:(SKResponseFailure)fail;


/**
 *  -------------  下 载  -------------
 *
 *  推 荐 --> 自动判别是 第一次下载 还是 继续下载,
 *         把 开始下载 和 继续下载 结合在一起
 *
 *  @param url       下载文件的URL
 *  @param cachePath 缓存路径
 *  @param progress  下载进度
 *  @param success   下载成功回调
 *  @param failure   下载失败回调
 */
+ (SKURLSessionDownloadTask *)downloadWithUrl:(NSString *)url
                                    cachePath:(NSString *)cachePath
                                     progress:(SKDownloadProgress)progress
                                      success:(SKResponseSuccess)success
                                      failure:(SKDownloadFailure)failure;

/**
 *  开始下载
 *
 *  @param url       下载文件的URL
 *  @param cachePath 缓存路径
 *  @param progress  下载进度
 *  @param success   下载成功回调
 *  @param failure   下载失败回调
 */
+ (SKURLSessionDownloadTask *)startDownloadWithUrl:(NSString *)url
                                 cachePath:(NSString *)cachePath
                                  progress:(SKDownloadProgress)progress
                                   success:(SKResponseSuccess)success
                                   failure:(SKDownloadFailure)failure;

/**
 *  暂定下载
 *
 *  @param url 下载文件的URL
 */
+ (void)pauseDownloadWithUrl:(NSString *)url;


/**
 *  继续下载
 */
+ (SKURLSessionDownloadTask *)resumeDownloadWithUrl:(NSString *)url
                     progress:(SKDownloadProgress)progress
                      success:(SKResponseSuccess)success
                      failure:(SKDownloadFailure)failure;

/**
 *  取消下载
 *
 *  @param url 下载文件的URL
 */
+ (void)cancelDownloadWithUrl:(NSString *)url;


/**
 *  更新本地存储的下载任务
 */
+ (void)updateLocalAllTasks;


/**
 * 计算缓存的占用存储大小
 */
+ (NSString *)convertSize:(NSUInteger)length;


+ (instancetype)shareInstance;

@end

/**
 * Posted when network reachability changes.
 */
FOUNDATION_EXPORT NSString * const SKNetworkingReachabilityDidChangeNotification;
FOUNDATION_EXPORT NSString * const SKNetworkingReachabilityNotificationStatusItem;

