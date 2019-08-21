//
//  UIResponder+JPUSH.h
//  RGThirdSDKWrapper_Example
//
//  Created by 浮生似梦、Dream on 2019/8/21.
//  Copyright © 2019年 18607304107@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

// 引入 JPush 功能所需头文件
#import "JPUSHService.h"
// iOS10 注册 APNs 所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

// 如果需要使用 idfa 功能所需要引入的头文件（可选）
//#import <AdSupport/AdSupport.h>


typedef void(^JpushNotiSucess)(NSDictionary *userInfo);


NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (JPUSH) <JPUSHRegisterDelegate>

/**
 注册SDK
 
 @param jpushInfo 注册的参数
 包含 @"JPushAppkey"  appkey
 包含 @"JPushChannel"  发布渠道. 可选.
 包含 @"isProduction"  是否生产环境. 如果为开发状态,设置为 NO; 如果为生产状态,应改为 YES.
 *                     App 证书环境取决于profile provision的配置，此处建议与证书环境保持一致.
 
 */
- (void)configureJPUSHSDKWithOptions:(NSDictionary *)launchOptions
                           jpushInfo:(NSDictionary *)jpushInfo;


/*
 各种iOS版本接收到推送消息后的处理
 @param IOS12Foreground  iOS12前台 (目前使用iOS12测试还是会走iOS10的回调,可能是极光文档有误)
 @param IOS12Background  iOS12后台
 @param IOS10Foreground  iOS10前台
 @param IOS10Background  iOS10后台
 @param IOS7Foreground   iOS7-9前台
 @param IOS7Background   iOS7-9后台
 
 */

- (void)receiveNotificationSucessIOS12Foreground:(JpushNotiSucess)IOS12Foreground
                                 IOS12Background:(JpushNotiSucess)IOS12Background IOS10Foreground:(JpushNotiSucess)IOS10Foreground IOS10Background:(JpushNotiSucess)IOS10Background IOS7Foreground:(JpushNotiSucess)IOS7Foreground IOS7Background:(JpushNotiSucess)IOS7Background;

@end

NS_ASSUME_NONNULL_END
