//
//  AppDelegate.m
//  LQYTrackPlay
//
//  Created by 李青洋 on 2019/8/31.
//  Copyright © 2019 LQY. All rights reserved.
//

#import "AppDelegate.h"
#import "TrajectoryController.h"
#import <BaiduMapAPI_Base/BMKMapManager.h>
#import <BMKLocationKit/BMKLocationAuth.h>

#define kBMKMapKey @"Brv47wOyfn2nzhBGCQGu7q5FbIpOo3PC"
@interface AppDelegate ()
{
    BMKMapManager *_mapManager;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    TrajectoryController *viewController = [[TrajectoryController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = navi;
    
    self.window.backgroundColor = [UIColor groupTableViewBackgroundColor];

    [self.window makeKeyAndVisible];
    
    //百度地图
    _mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [_mapManager start:kBMKMapKey generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    //百度地图定位
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:kBMKMapKey authDelegate:self];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
