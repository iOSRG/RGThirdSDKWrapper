//
//  UIResponder+JPUSH.m
//  RGThirdSDKWrapper_Example
//
//  Created by 浮生似梦、Dream on 2019/8/21.
//  Copyright © 2019年 18607304107@163.com. All rights reserved.
//

#import "UIResponder+JPUSH.h"
#import <Objc/runtime.h>

static const void *IOS12ForegroundKey = &IOS12ForegroundKey;
static const void *IOS12BackgroundKey = &IOS12BackgroundKey;
static const void *IOS10ForegroundKey = &IOS10ForegroundKey;
static const void *IOS10BackgroundKey = &IOS10BackgroundKey;
static const void *IOS7ForegroundKey = &IOS7ForegroundKey;
static const void *IOS7BackgroundKey = &IOS7BackgroundKey;

@implementation UIResponder (JPUSH)

- (void)configureJPUSHSDKWithOptions:(NSDictionary *)launchOptions
                           jpushInfo:(NSDictionary *)jpushInfo {
    
    //1.添加初始化 APNs 代码
    //Required
    //notice: 3.0.0 及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    if (@available(iOS 12.0, *)) {
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionProvidesAppNotificationSettings;
    } else {
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义 categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    
    //添加初始化 JPush 代码
    // Optional
    // 获取 IDFA
    // 如需使用 IDFA 功能请添加此代码并在初始化方法的 advertisingIdentifier 参数中填写对应值
    //    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *advertisingId = nil;
    
    
    
    // Required
    // init Push
    // notice: 2.1.5 版本的 SDK 新增的注册方法，改成可上报 IDFA，如果没有使用 IDFA 直接传 nil
    NSString *JPushAppkey =  jpushInfo[@"JPushAppkey"];
    NSString *JPushChannel = jpushInfo[@"JPushChannel"];
    BOOL isProduction = [jpushInfo[@"isProduction"] boolValue];
    
    [JPUSHService setupWithOption:launchOptions appKey:JPushAppkey
                          channel:JPushChannel
                 apsForProduction:isProduction
            advertisingIdentifier:advertisingId];
}

//注册 APNs 成功并上报 DeviceToken
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
    NSLog(@"注册成功");
}

//实现注册 APNs 失败接口（可选）
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}


//MARK: - 接收到通知后的操作

- (void)receiveNotificationSucessIOS12Foreground:(JpushNotiSucess)IOS12Foreground
                                 IOS12Background:(JpushNotiSucess)IOS12Background IOS10Foreground:(JpushNotiSucess)IOS10Foreground IOS10Background:(JpushNotiSucess)IOS10Background IOS7Foreground:(JpushNotiSucess)IOS7Foreground IOS7Background:(JpushNotiSucess)IOS7Background {
    
    objc_setAssociatedObject(self, IOS12ForegroundKey, IOS12Foreground, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, IOS12BackgroundKey, IOS12Background, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, IOS10ForegroundKey, IOS10Foreground, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, IOS10BackgroundKey, IOS10Background, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, IOS7ForegroundKey, IOS7Foreground, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, IOS7BackgroundKey, IOS7Background, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

//MARK: - JPUSHRegisterDelegate
//MARK: - iOS 12 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification{
    
    
    
    if (notification && [notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        
        //从通知界面直接进入应用
        NSLog(@"iOS12从通知界面直接进入应用");
        NSDictionary * userInfo = notification.request.content.userInfo;
        JpushNotiSucess sucess = objc_getAssociatedObject(self, IOS12BackgroundKey);
        if (sucess) {sucess(userInfo);}
        
    }else{
        //从通知设置界面进入应用
        NSLog(@"iOS12从通知设置界面进入应用");
        
    }
}


//MARK: - iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 前台收到远程通知:%@", userInfo);
        JpushNotiSucess sucess = objc_getAssociatedObject(self, IOS10ForegroundKey);
        if (sucess) {sucess(userInfo);}
        
        
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
    
}

//后台进入前台状态
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        NSLog(@"iOS10 后台收到远程通知:%@", userInfo);
        JpushNotiSucess sucess = objc_getAssociatedObject(self, IOS10BackgroundKey);
        if (sucess) {sucess(userInfo);}
    }
    completionHandler();  // 系统要求执行这个方法
}

//MARK: - iOS 7-9 Support

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"iOS7-iOS9系统，收到通知:%@", userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
    
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
        NSLog(@"激活状态");
        JpushNotiSucess sucess = objc_getAssociatedObject(self, IOS7ForegroundKey);
        if (sucess) {sucess(userInfo);}
        
        
    }else if([UIApplication sharedApplication].applicationState == UIApplicationStateInactive){
        
        NSLog(@"未激活状态");
        JpushNotiSucess sucess = objc_getAssociatedObject(self, IOS7BackgroundKey);
        if (sucess) {sucess(userInfo);}
    }
}


@end
