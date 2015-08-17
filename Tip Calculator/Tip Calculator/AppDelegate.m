//
//  AppDelegate.m
//  Tip Calculator
//
//  Created by admin on 8/13/15.
//  Copyright (c) 2015 mattmo. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Constants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self recordStateBeforeTermination];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self recordStateBeforeTermination];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self recordStateBeforeTermination];
}

#pragma mark - Helpers
- (void)recordStateBeforeTermination {
    // Record the time when app is closed
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastCloseDate];
    
    // Record the tip settings when app is closed
    if([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController * controller = [(UINavigationController*)self.window.rootViewController visibleViewController];
        if([controller isKindOfClass:[ViewController class]]) {
            ViewController * tipController = (ViewController *)controller;
            [tipController recordLastTipPercentageSettings];
        }
    }
}

@end
