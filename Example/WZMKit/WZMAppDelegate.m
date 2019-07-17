//
//  WZMAppDelegate.m
//  WZMKit
//
//  Created by wangzhaomeng on 07/15/2019.
//  Copyright (c) 2019 wangzhaomeng. All rights reserved.
//

/*
 ------------------------------------------------------
 ====================↓ 常用类库举例 ↓====================
 ------------------------------------------------------
 📂 WZMImageCache: 网络图片缓存
 📂 WZMRefresh: 上拉加载、下拉刷新
 📂 WZMNetWorking: 网络请求(GET POST PUT DELETE等等)
 📂 WZMGifImageView: GIF展示, 优化了GIF图片的内存占用
 📂 WZMPhotoBrowser: 图片浏览器, 支持网络或本地, 支持GIF
 📂 WZMPlayer: 高度自定义音/视频播放, 支持播放状态回调
 📂 WZMVideoPlayerView: 一个功能齐全的视频播放器
 📂 WZMReaction: 仿rac, 响应式交互, 使用block方式回调
 ------------------------------------------------------
 ====================↓ 常用方法举例 ↓====================
 ------------------------------------------------------
 @wzm_weakify(self)、@wzm_strongify(self)
 [UIImage wzm_imageByColor]、WZM_R_G_B(50,50,50)
 view.wzm_width、.wzm_height、.wzm_minX、.wzm_minY
 ...等等扩展类便捷方法、宏定义、自定义
 ------------------------------------------------------
 ======================== 结束 =========================
 ------------------------------------------------------
 */

#import "WZMAppDelegate.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"

@implementation WZMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    FirstViewController *firstVC = [[FirstViewController alloc] init];
    UINavigationController *firstNav = [[UINavigationController alloc] initWithRootViewController:firstVC];
    
    SecondViewController *secondVC = [[SecondViewController alloc] init];
    UINavigationController *secondNav = [[UINavigationController alloc] initWithRootViewController:secondVC];
    
    ThirdViewController *thirdVC = [[ThirdViewController alloc] init];
    UINavigationController *thirdNav = [[UINavigationController alloc] initWithRootViewController:thirdVC];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [tabBarController addChildViewController:firstNav];
    [tabBarController addChildViewController:secondNav];
    [tabBarController addChildViewController:thirdNav];
    [self setTabBarConfig:tabBarController];
    self.window.rootViewController = tabBarController;
    
#if DEBUG
    [WZMLogView startLog];
    wzm_openLogEnable(YES);
    WZMInstallSignalHandler();
    WZMInstallUncaughtExceptionHandler();
    [self.window wzm_startObserveFpsAndCpu];
#endif
    
    NSLog(@"恭喜你，成功打印日志！");
    
    return YES;
}

- (void)setTabBarConfig:(UITabBarController *)tabBarController {
    NSArray *titles = @[@"第一页",@"第二页",@"第三页"];
    NSArray *normalImages = @[@"tabbar_icon",@"tabbar_icon",@"tabbar_icon"];
    NSArray *selectImages = @[@"tabbar_icon_on",@"tabbar_icon_on",@"tabbar_icon_on"];
    
    for (NSInteger i = 0; i < tabBarController.viewControllers.count; i ++) {
        
        UIViewController *viewController = tabBarController.viewControllers[i];
        
        NSDictionary *atts = @{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:12]};
        NSDictionary *selAtts = @{NSForegroundColorAttributeName:THEME_COLOR,NSFontAttributeName:[UIFont systemFontOfSize:12]};
        
        UIImage *img = [[UIImage imageNamed:normalImages[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage *selImg = [[UIImage imageNamed:selectImages[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        viewController.tabBarItem.title = titles[i];
        viewController.tabBarItem.image = img;
        viewController.tabBarItem.selectedImage = selImg;
        [viewController.tabBarItem setTitleTextAttributes:atts forState:UIControlStateNormal];
        [viewController.tabBarItem setTitleTextAttributes:selAtts forState:UIControlStateSelected];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
