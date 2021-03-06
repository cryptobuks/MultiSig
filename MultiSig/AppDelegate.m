//
//  AppDelegate.m
//  MultiSig
//
//  Created by William Emmanuel on 3/30/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import "AppDelegate.h"
#import <coinbase-official/Coinbase.h>
#import <coinbase-official/CoinbaseOAuth.h>
#import "LoginViewController.h"
#import "CoinbaseSingleton.h"
#import <SSKeychain/SSKeychain.h>

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
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// For OAuth
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([[url scheme] isEqualToString:@"edu.self.multisig.coinbase-oauth"]) {
        // This is a redirect from the Coinbase OAuth web page or app.
        NSString *path = [[NSBundle mainBundle] pathForResource:
                          @"keys" ofType:@"plist"];
        NSMutableDictionary *keys = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        [CoinbaseOAuth finishOAuthAuthenticationForUrl:url
                                              clientId:[keys objectForKey:@"api_id"]
                                          clientSecret:[keys objectForKey:@"api_secret"]
                                            completion:^(id result, NSError *error) {
                                                if (error) {
                                                    NSLog(@"Error with authentication");
                                                } else {
                                                    // Tokens successfully obtained!
                                                    // Do something with them (store them, etc.)
                                                    NSString *access_token = result[@"access_token"];
                                                    Coinbase *apiClient = [Coinbase coinbaseWithOAuthAccessToken:access_token];
                                                    [apiClient doGet:@"users/self" parameters:nil completion:^(id response, NSError *error) {
                                                        if (error)
                                                        {
                                                            NSLog(@"%@",error.localizedDescription);
                                                        }
                                                        else {
                                                        NSString *user_id = response[@"user"][@"id"];
                                                        [[NSUserDefaults standardUserDefaults] setObject:user_id forKey:@"user_id"];
                                                        [SSKeychain setPassword:access_token forService:@"access_token" account:user_id];
                                                        [CoinbaseSingleton shared].client = apiClient;
                                                        
                                                        LoginViewController *controller = (LoginViewController *)((UINavigationController *)self.window.rootViewController).viewControllers[0];
                                                        [controller didFinishAuthentication];
                                                        // Note that you should also store 'expire_in' and refresh the token using [CoinbaseOAuth getOAuthTokensForRefreshToken] when it expires
                                                        NSLog(@"Success");
                                                        }

                                                    }];
                                                    
                                                    
                                                                                                    }
                                            }];
        return YES;
    }
    return NO;
    
}

@end
