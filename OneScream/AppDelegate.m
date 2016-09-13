//
//  AppDelegate.m
//  OneScream
//
//  Created by  Anwar Almojarkesh on 9/11/15.
//  Copyright (c) 2015  Anwar Almojarkesh. All rights reserved.
//

#import "AppDelegate.h"
#import "Stripe.h"
//#import <Parse/Parse.h>
#import "EngineMgr.h"
#import <Stripe/Stripe.h>
#import "StripeConstants.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "UserAddress.h"
#import "Backendless.h"
#import "AppConstants.h"
#import <UIAlertController+Window.h>
#import "DBHandler.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    [DBHandler creatAndCheckDatabase];
    [application setStatusBarHidden:YES];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"isScreamListening"];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    // Set background status value of Engine
    [[EngineMgr sharedInstance] setIsBackground:NO];
    
    // Initialize Stripe Pay module
    if (StripePublishableKey) {
        [Stripe setDefaultPublishableKey:StripePublishableKey];
    }
    
    // Initialize Backendless
    [backendless initApp:BK_APP_ID secret:BK_SECRET_KEY version:BK_VERSION_NUM];

    
    
//    // Initialize Parse.com Settings
//    [Parse enableLocalDatastore];
//    [Parse setApplicationId:@"HdNdCY5iTsjBUYkLDFBDGMOzF2XddXunAzkzQGE1"
//                  clientKey:@"TvJIRwOymkvwIWtiBHnJGvS36x6TQ0w8cpU708sh"];
    
//[UserAddress registerSubclass];
    /* [Optional] Track statistics around application opens. */
//    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
    // Override point for customization after application launch.
   
    

    [AppEventTracker initializeSDKKeys];
    
    BackendlessUser *user = backendless.userService.currentUser;
    
    if (user != nil){
        
        UserAddress *homeAddress = [user getProperty: HOME_ADDRESS_PARSE_COLOUMN];
//        [homeAddress fetchIfNeeded];
        UserAddress *workAddress = [user getProperty:WORK_ADDRESS_PARSE_COLOUMN];
//        [workAddress fetchIfNeeded];
        UserAddress *frequentedAddress = [user getProperty:FREQUENTED_ADDRESS_PARSE_COLOUMN];
//        [frequentedAddress fetchIfNeeded];
    }

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    // [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];

    if (![[EngineMgr sharedInstance] shouldBackgroundRunning]) {
        [[EngineMgr sharedInstance] terminateEngine];
        exit(0);
    }
    
    [[EngineMgr sharedInstance] setIsBackground:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"from_background" object:nil];
    [AppEventTracker saveAndUpdateUserData:NO];
    [[EngineMgr sharedInstance] setIsBackground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [AppEventTracker saveAndUpdateUserData:YES];
    [DBHandler ProcessTheInProcessScreams];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    @try {
    NSString *deviceTokenString = [backendless.messaging registerDeviceToken:deviceToken];
    [[NSUserDefaults standardUserDefaults]setObject:deviceTokenString forKey:@"deviceToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    @catch (Fault *fault) {
        NSLog(@"FAULT = %@ <%@>", fault.message, fault.detail);
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", [error description]);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //[PFPush handlePush:userInfo];
    if ([userInfo objectForKey:@"alert"]) {
        NSString *message = [userInfo objectForKey:@"alert"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"One Scream" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [alert show];
    }
    
//    if ([userInfo objectForKey:@"badge"]) {
//        NSInteger badgeNumber = [[userInfo objectForKey:@"badge"] integerValue];
//        [application setApplicationIconBadgeNumber:badgeNumber];
//    }
}

NSString * const NotificationCategoryIdent  = @"ACTIONABLE";
NSString * const NotificationActionOneIdent = @"ACTION_ONE";
NSString * const NotificationActionTwoIdent = @"ACTION_TWO";

- (void)registerForNotification {
    
//    UIMutableUserNotificationAction *action1;
//    action1 = [[UIMutableUserNotificationAction alloc] init];
//    [action1 setActivationMode:UIUserNotificationActivationModeBackground];
//    [action1 setTitle:@"Confirm"];
//    [action1 setIdentifier:NotificationActionOneIdent];
//    [action1 setDestructive:NO];
//    [action1 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationAction *action2;
    action2 = [[UIMutableUserNotificationAction alloc] init];
    [action2 setActivationMode:UIUserNotificationActivationModeBackground];
    [action2 setTitle:@"Cancel"];
    [action2 setIdentifier:NotificationActionTwoIdent];
    [action2 setDestructive:NO];
    [action2 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationCategory *actionCategory;
    actionCategory = [[UIMutableUserNotificationCategory alloc] init];
    [actionCategory setIdentifier:NotificationCategoryIdent];
    [actionCategory setActions:@[/*action1,*/ action2]
                    forContext:UIUserNotificationActionContextDefault];
    
    NSSet *categories = [NSSet setWithObject:actionCategory];
    UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                    UIUserNotificationTypeSound|
                                    UIUserNotificationTypeBadge);
    
    UIUserNotificationSettings *settings;
    settings = [UIUserNotificationSettings settingsForTypes:types
                                                 categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    
    if ([identifier isEqualToString:NotificationActionOneIdent]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"detection_confirmed" object:nil];
    }
    else if ([identifier isEqualToString:NotificationActionTwoIdent]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"detection_false" object:nil];
    }
    if (completionHandler) {
        
        completionHandler();
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler {
    
    if ([identifier isEqualToString:NotificationActionOneIdent]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"detection_confirmed" object:nil];
    }
    else if ([identifier isEqualToString:NotificationActionTwoIdent]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"detection_false" object:nil];
    }
    if (completionHandler) {
        
        completionHandler();
    }
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

@end
