//
//  SKNetworking.m
//  SKNetworkingDemo
//
//  Created by wushangkun on 16/5/20.
//  Copyright © 2016年 wushangkun. All rights reserved.
//

#import "SKNetworking.h"
#import "AFNetworking.h"

static NSString *default_baseUrl = nil;
static NSTimeInterval default_timeout = 60;
static NSInteger default_maxConcurrentOperationCount = 3;
static NSDictionary *default_httpheaders = nil;
static BOOL default_enableInterfaceDebug = NO;
static NSMutableArray *default_requestTasks; //所有的下载任务
static AFHTTPSessionManager *default_sharedManager = nil;
static SKReachabilityStatusChangeBlock reachabilityStatusBlock = nil;
static SKNetworkReachabilityStatus currentNetworkStatus = SKNetworkReachabilityStatusUnknown;

NSString * const SKNetworkingReachabilityDidChangeNotification = @"com.sknetworking.reachability.change";
NSString * const SKNetworkingReachabilityNotificationStatusItem = @"SKNetworkingReachabilityNotificationStatusItem";

@interface SKDownloadTask : NSObject
@property (nonatomic, assign) int64_t lastbytesRead;
@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic, strong) NSString *speed;
@end

@implementation SKDownloadTask

- (instancetype)init {
    if (self = [super init]) {
        _lastDate = [NSDate date];
    }
    return self;
}

- (void)setLastDate:(NSDate *)lastDate {
    _lastDate = lastDate;
}

@end

@interface SKNetworking ()
@end

@implementation SKNetworking

static SKNetworking *_sknetworking = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _sknetworking = [[SKNetworking alloc]init];
    });
    return _sknetworking;
}

+ (NSString *)baseUrl {
   return  default_baseUrl;
}

+ (void)enableInterfaceDebug:(BOOL)isDebug{
    default_enableInterfaceDebug = isDebug;
}

+(void)setBaseUrl:(NSString *)baseUrl {
    default_baseUrl = baseUrl;
}

+ (void)setTimeout:(NSTimeInterval)timeout {
    default_timeout = timeout;
}
+ (void)setMaxOperationCount:(NSInteger)maxOperationCount {
    default_maxConcurrentOperationCount = maxOperationCount;
}

+ (void)setCommonHttpHeaders:(NSDictionary *)httpHeaders {
    default_httpheaders = httpHeaders;
}

static inline NSString *getCachePath() {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}



/**
 *  监听网络
 */
+ (void)startMonitoringNetwork {

    AFNetworkReachabilityManager *manager =  [AFNetworkReachabilityManager sharedManager];
    
    [manager startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            {
                NSLog(@"未知网络");
                currentNetworkStatus = SKNetworkReachabilityStatusUnknown;
                reachabilityStatusBlock ? reachabilityStatusBlock(SKNetworkReachabilityStatusUnknown) : nil;
            }
                break;
            case AFNetworkReachabilityStatusNotReachable:
            {
                NSLog(@"无网络");
                currentNetworkStatus = SKNetworkReachabilityStatusNotReachable;
                reachabilityStatusBlock ? reachabilityStatusBlock(SKNetworkReachabilityStatusNotReachable) : nil;
            }
                break;

            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                NSLog(@"手机网络");
                currentNetworkStatus = SKNetworkReachabilityStatusReachableViaWWAN;
                reachabilityStatusBlock ? reachabilityStatusBlock(SKNetworkReachabilityStatusReachableViaWWAN) : nil;
            }
                break;

            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                NSLog(@"WIFI网络");
                currentNetworkStatus = SKNetworkReachabilityStatusReachableViaWiFi;
                reachabilityStatusBlock ? reachabilityStatusBlock(SKNetworkReachabilityStatusReachableViaWiFi) : nil;

            }
                break;
                
            default:
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            NSDictionary *userInfo = @{ SKNetworkingReachabilityNotificationStatusItem: @(currentNetworkStatus) };
            [notificationCenter postNotificationName:SKNetworkingReachabilityDidChangeNotification object:nil userInfo:userInfo];
        });
    }];
}

/**
 *  监听网络
 */
+ (void)checkNetworkStatus:(SKReachabilityStatusChangeBlock)block {

    block ? reachabilityStatusBlock = block : nil ;
}

/**
 *  当前网络状态
 */
+ (SKNetworkReachabilityStatus)currentNetworkStatus {
    
    return currentNetworkStatus;
}


#pragma mark - GET请求
/**
 *  GET
 */
+ (SKURLSessionTask *)GETWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                         success:(SKResponseSuccess)success
                            fail:(SKResponseFailure)fail{
    
    return [self _requestWithUrl:url
                      httpMethod:1
                          params:params
                        progress:nil
                         success:success
                            fail:fail];
}
/**
 *  GET （progress）
 */
+ (SKURLSessionTask *)GETWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                        progress:(SKDownloadProgress)progress
                         success:(SKResponseSuccess)success
                            fail:(SKResponseFailure)fail{

    return [self _requestWithUrl:url
                      httpMethod:1
                          params:params
                        progress:progress
                         success:success
                            fail:fail];
}

#pragma mark - POST请求

/**
 *  POST
 */
+ (SKURLSessionTask *)POSTWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                          success:(SKResponseSuccess)success
                             fail:(SKResponseFailure)fail{

    return [self _requestWithUrl:url
                      httpMethod:2
                          params:params
                        progress:nil
                         success:success
                            fail:fail];
}
/**
 *  POST （progress）
 */
+ (SKURLSessionTask *)POSTWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                         progress:(SKDownloadProgress)progress
                          success:(SKResponseSuccess)success
                             fail:(SKResponseFailure)fail{
    return [self _requestWithUrl:url
                      httpMethod:2
                          params:params
                        progress:progress
                         success:success
                            fail:fail];

}

/**
 * 统一请求数据
 */
+ (SKURLSessionTask * )_requestWithUrl:(NSString *)url
                            httpMethod:(NSUInteger)httpMethod
                                params:(NSDictionary *)params
                              progress:(SKDownloadProgress)progress
                               success:(SKResponseSuccess)success
                                  fail:(SKResponseFailure)fail {
    
    if (![self checkUrlWithUrl:url]) {
        return nil;
    }
    
    AFHTTPSessionManager *manager = [self _manager];
    
    // 请求超时时间
    // manager.requestSerializer.timeoutInterval = default_timeout;
    // 允许同时最大并发数量
    manager.operationQueue.maxConcurrentOperationCount = default_maxConcurrentOperationCount;
    // 配置请求头
    for (NSString *key in default_httpheaders) {
        if (default_httpheaders[key] != nil) {
            [manager.requestSerializer setValue:default_httpheaders[key] forHTTPHeaderField:key];
        }
    }
    
    __block SKURLSessionTask *session = nil;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do something...
        
        if (httpMethod == 1) {  // GET
            
            session = [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progress) {
                        progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount,downloadProgress.localizedAdditionalDescription);
                    }
                });
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (responseObject) {
                        [self handleResponseObject:responseObject successCallBack:success url:url];
                    }
                });
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (fail) {
                        fail(error);
                    }
                });
            }];
        }
        
        if (httpMethod == 2) { // POST
            session = [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
               
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progress) {
                        progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount,uploadProgress.localizedAdditionalDescription);
                    }
                });
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (responseObject) {
                        [self handleResponseObject:responseObject successCallBack:success url:url];
                    } else {
                        if (fail) {
                            NSError *error1 = [NSError errorWithDomain:@"com.sknetworking" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"cuole"}];
                            fail(error1);
                        }
                    }
                });
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (fail) {
                        fail(error);
                    }
                });
            }];
        }
    });
    
    return session;
}


#pragma mark -- 下载文件 >> 推荐

+ (SKURLSessionDownloadTask *)downloadWithUrl:(NSString *)url
                                    cachePath:(NSString *)cachePath
                                     progress:(SKDownloadProgress)progress
                                      success:(SKResponseSuccess)success
                                      failure:(SKDownloadFailure)failure {
    
    if (![self checkUrlWithUrl:url]) {
        return nil;
    }
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:config];
    // AFHTTPSessionManager *manager = [self _manager];
    
    SKURLSessionDownloadTask *sessionTask = nil;
    //    NSURLCache *urlCache = [[NSURLCache alloc]initWithMemoryCapacity:5 * 1024 * 1024
    //                                                        diskCapacity:25 * 1024 * 1024
    //                                                            diskPath:nil];
    //    [NSURLCache setSharedURLCache:urlCache];
    //    NSMutableURLRequest *downloadRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    ////    [downloadRequest setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
    //    NSCachedURLResponse* cacheResponse = [[NSURLCache sharedURLCache]cachedResponseForRequest:downloadRequest];
    //    NSLog(@"cacheResponse.response = %@,\n cacheResponse.data = %@",cacheResponse.response,cacheResponse.data);
    
    SKDownloadTask *task = nil;
    for (NSMutableDictionary *sessionDict in [self allTasks]) {
        if (sessionDict[@"url"] == url) {
            task =(SKDownloadTask *)sessionDict[@"task"];
            task.lastDate = [NSDate date];
        }
    }
    
    if (!task) {
        task = [[SKDownloadTask alloc]init];
    }
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    if (![self _getSessionTaskWithUrl:url]) {  // 第一次下载
        
        sessionTask = [manager downloadTaskWithRequest:downloadRequest
                                              progress:^(NSProgress * _Nonnull downloadProgress) {
                                                  
                                                  [SKNetworking caculateSpeedWith:downloadProgress taskModel:task];
                                                  
                                                  if (progress) {
                                                      progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount,task.speed);
                                                  }
                                              }
                                           destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                               return [NSURL fileURLWithPath:cachePath];
                                           }
                                     completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                         if (error) {
                                             [self handleCallbackWithError:error fail:failure];
                                             if (default_enableInterfaceDebug) {
                                                 DLog(@"Download fail for url:%@ \n filePath:%@",[self absoluteUrlWithUrl:url],filePath);
                                             }
                                         }else {
                                             if (success) {
                                                 // 删除当前的下载任务
                                                 [self _deleteTaskDictWithUrl:url];
                                                 
                                                 success(filePath.absoluteString);
                                             }
                                             if (default_enableInterfaceDebug) {
                                                 DLog(@"Download success for url:%@ \n filePath:%@",[self absoluteUrlWithUrl:url],filePath);
                                             }
                                         }
                                     }];
        
        // 启动任务
        [sessionTask resume];
        
        if (sessionTask) {
            // 已经下载的局部数据
            NSData *partialData = nil;
            // 包装一个下载任务
            NSMutableDictionary *dicNew = [NSMutableDictionary
                                           dictionaryWithObjectsAndKeys:
                                           url,@"url",
                                           cachePath,@"path",
                                           sessionTask,@"session",
                                           partialData,@"partialData",
                                           nil];
            [dicNew setObject:task forKey:@"task"];
            
            // 保存下载任务
            [[self allTasks]addObject:dicNew];
            [self writeToLocalFileWithAllTask:[self allTasks]];
        }
        
        
    }else { //继续下载
        
        if (![self _getPartialDataWithUrl:url]) {
            return sessionTask;
        }
        
        sessionTask = [manager downloadTaskWithResumeData:[self _getPartialDataWithUrl:url]
                                                 progress:^(NSProgress * _Nonnull downloadProgress) {
                                                     
                                                     [SKNetworking caculateSpeedWith:downloadProgress taskModel:task];
                                                     
                                                     if (progress) {
                                                         progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount,task.speed);
                                                         
                                                     }
                                                 }
                                              destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                  //                                                  NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
                                                  //                                                  NSString *path = [cacheDir stringByAppendingPathComponent:response.suggestedFilename];
                                                  return [NSURL fileURLWithPath:cachePath];
                                              }
                                        completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                            if (error) {
                                                [self handleCallbackWithError:error fail:failure];
                                                if (default_enableInterfaceDebug) {
                                                    DLog(@"Download fail for url:%@ \n filePath:%@",[self absoluteUrlWithUrl:url],filePath);
                                                }
                                            }else {
                                                if (success) {
                                                    success(filePath.absoluteString);
                                                    [self _deleteTaskDictWithUrl:url];
                                                }
                                                if (default_enableInterfaceDebug) {
                                                    DLog(@"Download success for url:%@ \n filePath:%@",[self absoluteUrlWithUrl:url],filePath);
                                                }
                                            }
                                            
                                        }];
        
        
        for (NSMutableDictionary *sessionDict in [self allTasks]) {
            if (sessionDict[@"url"] == url) {
                sessionDict[@"partialData"] = nil;
                /**
                 *  这里是坑!!!!
                 *  sessionTask 的内存地址在这里会改变，与开始启动任务时的Task不一样,所以在这里需要重新存储一遍sessionTask
                 */
#warning 这里是坑!!!!
                sessionDict[@"session"] = sessionTask;
                [self writeToLocalFileWithAllTask:[self allTasks]];
            }
        }
        // 启动任务
        [sessionTask resume];
    }
    
    return sessionTask;
}


#pragma mark -- 开始下载
+ (SKURLSessionDownloadTask *)startDownloadWithUrl:(NSString *)url
                                 cachePath:(NSString *)cachePath
                                  progress:(SKDownloadProgress)progress
                                   success:(SKResponseSuccess)success
                                   failure:(SKDownloadFailure)failure{
    
    if (![self checkUrlWithUrl:url]) {
        return nil;
    }

    SKDownloadTask *task = [[SKDownloadTask alloc]init];
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:config];
    
    // AFHTTPSessionManager *manager = [self _manager];
    
    SKURLSessionDownloadTask *sessionTask = nil;
  
    sessionTask = [manager downloadTaskWithRequest:downloadRequest
                                      progress:^(NSProgress * _Nonnull downloadProgress) {
                                          
                                          [SKNetworking caculateSpeedWith:downloadProgress taskModel:task];
                                          
                                          if (progress) {
                                              progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount,task.speed);
                                          }

                                      }
                                   destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                       return [NSURL fileURLWithPath:cachePath];
                                   }
                             completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                 
                                 if (error) {
                                     [self handleCallbackWithError:error fail:failure];
                                     
                                     if (default_enableInterfaceDebug) {
                                         DLog(@"Download fail for url:%@ \n filePath:%@",[self absoluteUrlWithUrl:url],filePath);
                                     }
                                 }else {
                                     if (success) {
                                         // 删除当前的下载任务
                                         [self _deleteTaskDictWithUrl:url];
                                         
                                         success(filePath.absoluteString);
                                     }
                                     if (default_enableInterfaceDebug) {
                                         DLog(@"Download success for url:%@ \n filePath:%@",[self absoluteUrlWithUrl:url],filePath);
                                     }
                                 }
                             }];
    
    
    
    // 启动任务
    [sessionTask resume];

    if (sessionTask) {
        // 已经下载的局部数据
        NSData *partialData = nil;
        // 包装一个下载任务
        NSMutableDictionary *dicNew = [NSMutableDictionary
                                       dictionaryWithObjectsAndKeys:url,@"url",
                                                              cachePath,@"path",
                                                                sessionTask,@"session",
                                                            partialData,@"partialData", nil];

        // 保存下载任务
        [[self allTasks]addObject:dicNew];
        [self writeToLocalFileWithAllTask:[self allTasks]];
    }
    return sessionTask;
}

#pragma mark -- 暂停下载
+ (void)pauseDownloadWithUrl:(NSString *)url {
    
    if (![self _getSessionTaskWithUrl:url]) {
        return;
    }
    
    NSURLSessionDownloadTask *sessionTask = [self _getSessionTaskWithUrl:url];
 
    /**
     *  resumeData只是一个chunk，而不是已经下载的全部数据，因此无法通过它实现断点续传，只能实现简单的暂停和继续
     *
     *  @param resumeData 记录一下恢复点的数据
     *
     *  要保证通过resume创建downloadTask时使用的session和创建被取消的downloadTask时使用的session是同一个，也就是所谓的session没有离线
     */
    [sessionTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        
        NSLog( @"resumeData.length = %ld",resumeData.length);
        
        for (NSMutableDictionary *sessionDict in [self allTasks]) {
            if (sessionDict[@"url"] == url) {
                if (resumeData) {
                    [sessionDict setObject:resumeData forKey:@"partialData"];
                }
                [self writeToLocalFileWithAllTask:[self allTasks]];
            }
        }
    }];
}

#pragma mark --  继续下载
+ (SKURLSessionDownloadTask *)resumeDownloadWithUrl:(NSString *)url
                     progress:(SKDownloadProgress)progress
                      success:(SKResponseSuccess)success
                      failure:(SKDownloadFailure)failure {
    
    // 1.更新本地数据
    [self updateLocalAllTasks];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:config];
    
    SKURLSessionDownloadTask *sessionTask = nil;
    if (![self _getPartialDataWithUrl:url]) {
        return sessionTask;
    }
    
    SKDownloadTask *task = nil;
    for (NSMutableDictionary *sessionDict in [self allTasks]) {
        if (sessionDict[@"url"] == url) {
            task =(SKDownloadTask *)sessionDict[@"task"];
            task.lastDate = [NSDate date];
        }
    }
    
    if (!task) {
        task = [[SKDownloadTask alloc]init];
    }
    
    sessionTask = [manager downloadTaskWithResumeData:[self _getPartialDataWithUrl:url]
                                         progress:^(NSProgress * _Nonnull downloadProgress) {
                                             
                                             [SKNetworking caculateSpeedWith:downloadProgress taskModel:task];
                                             
                                             if (progress) {
                                                 progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount,task.speed);
                                                 
                                             }
                                         }
                                      destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                          return [NSURL fileURLWithPath:[self _getCachePathWithUrl:url]];
                                      }
                                completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
  
                                    if (error) {
                                        [self handleCallbackWithError:error fail:failure];
                                        if (default_enableInterfaceDebug) {
                                            DLog(@"Download fail for url:%@ \n filePath:%@",[self absoluteUrlWithUrl:url],filePath);
                                        }
                                    }else {
                                        if (success) {
                                            success(filePath.absoluteString);
                                            [self _deleteTaskDictWithUrl:url];
                                        }
                                        if (default_enableInterfaceDebug) {
                                            DLog(@"Download success for url:%@ \n filePath:%@",[self absoluteUrlWithUrl:url],filePath);
                                        }
                                    }
                                }];
    
    for (NSMutableDictionary *sessionDict in [self allTasks]) {
        if (sessionDict[@"url"] == url) {
            sessionDict[@"partialData"] = nil;
            /**
             *  这里是坑!!!!
             *  sessionTask 的内存地址在这里会改变，与开始启动任务时的Task不一样,所以在这里需要重新存储一遍sessionTask
             */
            #warning 这里是坑!!!!
            sessionDict[@"session"] = sessionTask;
            [self writeToLocalFileWithAllTask:[self allTasks]];
        }
    }
    
    // 启动任务
    [sessionTask resume];
    return sessionTask;
}

#pragma mark -- 取消下载
+ (void)cancelDownloadWithUrl:(NSString *)url {
    
    if (![self _getSessionTaskWithUrl:url]) {
        return;
    }
    
    NSURLSessionDownloadTask *sessionTask = [self _getSessionTaskWithUrl:url];
    [sessionTask cancel];
    sessionTask = nil;
    
    [self _deleteTaskDictWithUrl:url];
}

/**
 * 处理response
 */
+ (void)handleResponseObject:(id)responseObject successCallBack:(SKResponseSuccess)success url:(NSString *)url {
    if (success) {
        success([self parseResponseObject:responseObject url:url]);
    }
}

+ (id)parseResponseObject:(id)responseObject url:(NSString *)url {

    if ([responseObject isKindOfClass:[NSData class]]) {
        
        if (responseObject != nil) {
            
            NSError *error = nil;
            id response = [NSJSONSerialization JSONObjectWithData:responseObject
                                                          options:NSJSONReadingMutableContainers
                                                            error:&error];
            if (error != nil) {
                DLog(@"parseResponseObject error = %@",error.description);
            } else {
                if ([response isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *responseDict = (NSDictionary *)response;
                    DDLog(@"responseDict 1️⃣2️⃣4️⃣5️⃣6️⃣7️⃣8️⃣9️⃣🔟 = %@",responseDict);
                    return responseDict;
                }
            }
        }
        return responseObject;
    } else {
       
        NSData *data = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        DDLog(@"responseObject \n  1️⃣2️⃣4️⃣5️⃣6️⃣7️⃣8️⃣9️⃣🔟: %@ = \n%@",url ,jsonString);
        return responseObject;
    }
}


/**
 * 计算下载网速
 */
+ (void)caculateSpeedWith:(NSProgress *)downloadProgress taskModel:(SKDownloadTask *)task{
    //获取当前时间
    NSDate *currentDate = [NSDate date];
    if ([currentDate timeIntervalSinceDate:task.lastDate] >= 1) {
        //时间差
        double time = [currentDate timeIntervalSinceDate:task.lastDate];
        int64_t increase = downloadProgress.completedUnitCount - task.lastbytesRead;
        NSUInteger increaseSec = (increase / time);
        task.speed = [NSString stringWithFormat:@"%@/S",[SKNetworking convertSize:increaseSec]];
        task.lastDate = currentDate;
        NSLog(@"task.speed = %@",task.speed);
        task.lastbytesRead = downloadProgress.completedUnitCount;
    }
}


/**
 * 更新本地存储的下载任务
 */
+ (void)updateLocalAllTasks{

//    if ([self readLocalData]) {
//        [[self allTasks] removeAllObjects];
//        [[self allTasks] addObject:[self readLocalData]];
//    }
}

#pragma private Method

/**
 *  是否正在暂停
 */
+(BOOL)isPausingWithError:(NSError *)error {
    if (error.code == NSURLErrorCancelled) {
        return YES;
    }
    return NO;
}

/**
 *  删除任务
 */
+ (void)_deleteTaskDictWithUrl:(NSString *)url {
    
    __block NSMutableDictionary *sessionD  = nil;
    
    [[self allTasks] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *sessionDict = obj;
        if (sessionDict[@"url"] == url) {
            sessionD = sessionDict;
        }
    }];
    
    if (sessionD) {
        [[self allTasks] removeObject:sessionD];
        [self writeToLocalFileWithAllTask:[self allTasks]];
    }
}

/**
 *  读取本地的任务
 *
 *  @return 本地的任务
 */
+ (NSMutableArray *)readLocalData {
    NSString *documentPath = getCachePath();
    NSString *allTasksPath = [documentPath stringByAppendingPathComponent:@"allTasks.plist"];
    NSMutableArray *allTasks = [NSMutableArray arrayWithContentsOfFile:allTasksPath];
    return  allTasks;
}

/**
 *  根据url返回对应的sessionTask
 */
+ (SKURLSessionDownloadTask *)_getSessionTaskWithUrl:(NSString *)url {
    
    for (NSMutableDictionary *sessionDict in [self allTasks]) {
        if (sessionDict[@"url"] == url) {
            NSURLSessionDownloadTask *session = sessionDict[@"session"];
            return session;
        }
    }
    return nil;
    
}

/**
 *  根据url返回对应的sessionTask 本地已经存储的数据
 */
+ (NSData *)_getPartialDataWithUrl:(NSString *)url {
    
    for (NSMutableDictionary *sessionDict in [self allTasks]) {
        if (sessionDict[@"url"] == url) {
            NSData *partialData =(NSData *)sessionDict[@"partialData"];
            return partialData;
        }
    }
    return nil;
}

/**
 *  根据url返回对应的sessionTask缓存路径
 */
+ (NSString *)_getCachePathWithUrl:(NSString *)url {
    
    for (NSMutableDictionary *sessionDict in [self allTasks]) {
        if (sessionDict[@"url"] == url) {
            NSString *cachePath =(NSString *)sessionDict[@"path"];
            return cachePath;
        }
    }
    return nil;
}

/**
 *  将所有的下载任务存储在本地
 *
 *  @param allTasks 当前所有的下载任务
 */
+ (void)writeToLocalFileWithAllTask:(NSMutableArray *)allTasks{
    NSString *documentPath = getCachePath();
    NSString *allTasksPath = [documentPath stringByAppendingPathComponent:@"allTasks.plist"];
    [allTasks writeToFile:allTasksPath atomically:YES];
}


/**
 *  获取完整的请求链接
 *
 *  @param url 传过来的Url
 *
 *  @return 完整的请求链接
 */
+ (NSString *)absoluteUrlWithUrl:(NSString *)url {
    if (!url || url.length == 0) {
        return @"";
    }
    if (![self baseUrl] || [self baseUrl].length == 0) {
        return url;
    }
    
    NSString *absoluteUrl = @"";
    
    if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"]) { // url没有http开头
        
        if ([[self baseUrl]hasSuffix:@"/"])  // baseUrl的末尾字符是"/"
        {
            if([url hasPrefix:@"/"]) { // url的第一个字符是"/"
                NSMutableString *mutaUrl = [NSMutableString stringWithString:url];
                [mutaUrl deleteCharactersInRange:NSMakeRange(0, 1)];
                absoluteUrl = [NSString stringWithFormat:@"%@%@",[self baseUrl],mutaUrl];
            }
            if(![url hasPrefix:@"/"]) {// url的第一个字符没有"/"
                absoluteUrl = [NSString stringWithFormat:@"%@%@",[self baseUrl],url];
            }
        }
        
        if (![[self baseUrl]hasSuffix:@"/"])  //baseUrl的末尾字符没有"/"
        {
            if([url hasPrefix:@"/"]) { // url的第一个字符是"/"
                absoluteUrl = [NSString stringWithFormat:@"%@%@",[self baseUrl],url];
            }
            if(![url hasPrefix:@"/"]) { // url的第一个字符没有"/"
                absoluteUrl = [NSString stringWithFormat:@"%@/%@",[self baseUrl],url];
            }
        }
    }else { // http开头的
        absoluteUrl = url;
    }
    
    return absoluteUrl;
}

/**
 *  处理失败的回调
 */
+ (void)handleCallbackWithError:(NSError *)error
                           fail:(SKDownloadFailure)fail {

    if ([error code] == NSURLErrorCancelled) { //正在暂停
        // new add
        if (fail) {
            fail(error , kSKDownloadingStatusSuspended);
        }
    }else {
        if (fail) {
            fail(error, kSKDownloadingStatusFailed);
        }
    }
}

/**
 *  所有的请求任务
 */
+(NSMutableArray *)allTasks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (default_requestTasks == nil) {
            default_requestTasks = [[NSMutableArray alloc]init];
        }
    });
    return default_requestTasks;
}


+ (AFHTTPSessionManager *)_manager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        if (![self baseUrl]) {
            default_sharedManager = [AFHTTPSessionManager manager];
        }else {
            default_sharedManager = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:[self baseUrl]]];
        }

        default_sharedManager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
        default_sharedManager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                                  @"text/html",
                                                                                  @"text/json",
                                                                                  @"text/plain",
                                                                                  @"text/javascript",
                                                                                  @"text/xml",
                                                                                  @"image/*"]];
    });

    return default_sharedManager;
    
    
     // **** 采取单例模式  为了  修复 每次请求创建AFHTTPSessionManager 后没有释放  引起的内存泄漏 bug !!

    /*
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*"]];
    default_sharedManager = manager;
    
    return manager;
     */
    
}

/**
 * UTF8编码 URL
 */
+ (NSString *)sk_URLEncode:(NSString *)url {
    return [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}


/**
 * 检测URL是否有效
 */
+ (BOOL)checkUrlWithUrl:(NSString *)url{
    if (![self baseUrl]) {
        // nil
        if (![NSURL URLWithString:url]) {
            DLog(@"url无效，可能是URL中有中文,请尝试Encode URL");
            return NO;
        }
    }else {
        if (![NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[self baseUrl],url]]) {
            DLog(@"url无效，可能是URL中有中文,请尝试Encode URL");
            return NO;
        }
    }
    return YES;
}


/**
 * 计算缓存的占用存储大小
 */
+ (NSString *)convertSize:(NSUInteger)length
{
    if(length<1024)
        return [NSString stringWithFormat:@"%ldB",(NSUInteger)length];
    else if(length>=1024&&length<1024*1024)
        return [NSString stringWithFormat:@"%.0fK",(float)length/1024];
    else if(length >=1024*1024&&length<1024*1024*1024)
        return [NSString stringWithFormat:@"%.1fM",(float)length/(1024*1024)];
    else
        return [NSString stringWithFormat:@"%.1fG",(float)length/(1024*1024*1024)];
}

/**
 * encode filename base64
 */
+ (NSString *)encodeFilename:(NSString *)filename {
    NSData *data = [filename dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodeFilename = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodeFilename;
}

/**
 * decode filename base64
 */
+ (NSString *)decodeFilename:(NSString *)filename {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:filename options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *decodeFilename = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return decodeFilename;
}

+ (NSString *)getFileSizeWith:(unsigned long)size
{
    if(size >=1024*1024)//大于1M，则转化成M单位的字符串
    {
        return [NSString stringWithFormat:@"%1.1luM",size /1024/1024];
    }
    else if(size >=1024&&size<1024*1024) //不到1M,但是超过了1KB，则转化成KB单位
    {
        return [NSString stringWithFormat:@"%1.1luK",size/1024];
    }
    else//剩下的都是小于1K的，则转化成B单位
    {
        return [NSString stringWithFormat:@"%1.1luB",(unsigned long)size];
    }
}


@end
