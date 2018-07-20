//
//  MapLeakViewController.m
//  MemoryLeaks
//
//  Created by shangkun on 2018/7/20.
//  Copyright © 2018年 wushangkun. All rights reserved.
//

#import "MapLeakViewController.h"

@interface MapLeakViewController ()

@end

@implementation MapLeakViewController

- (void)setup {
    
    [super setup];
    
    
//    for (int i = 0; i < 100000; i++) {
//        
//        NSString *string = @"Abc";
//        
//        string = [string lowercaseString];
//        
//        string = [string stringByAppendingString:@"xyz"];
//        
//        NSLog(@"%@", string);
//        
//    }
    
    
    for (int i = 0; i < 100000; i++) {
        
        @autoreleasepool {
            
            NSString *string = @"Abc";
            
            string = [string lowercaseString];
            
            string = [string stringByAppendingString:@"xyz"];
            
            NSLog(@"%@", string);
            
        }
        
    }
}





/*
 
 地图是比较耗费App内存的
 
 需要注意的有需在使用完毕时将地图、代理等滞空为nil，注意地图中标注（大头针）的复用
 
 在使用完毕时清空标注数组等。
 
 */

//- (void)clearMapView{
//
//    self.mapView = nil;
//
//    self.mapView.delegate =nil;
//
//    self.mapView.showsUserLocation = NO;
//
//    [self.mapView removeAnnotations:self.annotations];
//
//    [self.mapView removeOverlays:self.overlays];
//
//    [self.mapView setCompassImage:nil];
//
//}

@end
