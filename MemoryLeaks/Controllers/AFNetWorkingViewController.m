//
//  AFNetWorkingViewController.m
//  MemoryLeaks
//
//  Created by shangkun on 2018/7/19.
//  Copyright © 2018年 wushangkun. All rights reserved.
//

#import "AFNetWorkingViewController.h"
#import "AFNetworking.h"

@interface AFNetWorkingViewController ()

@end

@implementation AFNetWorkingViewController

- (void)setup {
    
    [super setup];
    
    NSString *url = @"http://dev.cjjl.chelun.com/xc_v1/SuperCoachApi/tasks?_lat=37.78583401977729&_lng=-122.4064169999999&_token=d22ec3d13ca340b8bb56516125832da8&apiVersion=4&appversion=4.2.4&channelid=80000&deviceid=84599c1b55b66adc7a232a76b41c28f0f8663860&os=ios&packagename=com.xueche.supercoach&productId=28&usertype=2";
    
//    AFHTTPSessionManager * manager = [self.class sessionManager];
    
    for (NSInteger i = 0 ; i < 5; i ++) {
        
        AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
        
        [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [self.class parseResponseObject:responseObject url:url];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            NSLog(@"networking request fail");
        }];
    }
}

- willde


/**
 *  采取单例模式  为了  修复 每次请求创建AFHTTPSessionManager 后没有释放  引起的内存泄漏 bug !!
 */

+ (AFHTTPSessionManager*)sessionManager {
    
    static AFHTTPSessionManager *manager;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        manager = [AFHTTPSessionManager manager];
        
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                                  @"text/html",
                                                                                  @"text/json",
                                                                                  @"text/plain",
                                                                                  @"text/javascript",
                                                                                  @"text/xml",
                                                                                  @"image/*"]];
        
    });
    
    return manager;
    
}


+ (id)parseResponseObject:(id)responseObject url:(NSString *)url {
    
    if ([responseObject isKindOfClass:[NSData class]]) {
        
        if (responseObject != nil) {
            
            NSError *error = nil;
            id response = [NSJSONSerialization JSONObjectWithData:responseObject
                                                          options:NSJSONReadingMutableContainers
                                                            error:&error];
            if (error != nil) {
                DDLog(@"parseResponseObject error = %@",error.description);
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

@end
