//
//  AppDelegate.m
//  Piano
//
//  Created by Andranik on 3/27/17.
//  Copyright © 2017 Andranik. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [FIRApp configure];
    
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [GIDSignIn sharedInstance].delegate = self;
    
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
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Piano"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

#pragma mark - FireBase Auth

- (BOOL)application:(nonnull UIApplication *)application
            openURL:(nonnull NSURL *)url
            options:(nonnull NSDictionary<NSString *, id> *)options {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // ...
    if (error == nil) {
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                                                         accessToken:authentication.accessToken];
        
        
        [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser *user, NSError *error) {
            NSLog(@"In - AppDelegate 'signIn didSignInForUser'");
            
            
            
            FIRDatabaseReference *usersReference = [[[FIRDatabase database] referenceFromURL:@"https://piano-17dd1.firebaseio.com/users"]
                                                    child:user.uid];
            
            [usersReference observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
                
                if(![snapshot hasChild:@"nickName"]){
                    NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:
                                            user.displayName,@"nickName",
                                            nil];
                    [usersReference updateChildValues:values withCompletionBlock:^(NSError *__nullable err, FIRDatabaseReference * ref){
                        if(err) {
                            NSLog(@"In - AppDelegate Error in updateChildValues:values withCompletionBlock ");
                            return;
                        }
                        NSLog(@"Saved user seccessfully in FireBace db");
                    }];
                }
                if(![snapshot hasChild:@"email"]){
                    NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:
                                            user.email,@"email",
                                            nil];
                    [usersReference updateChildValues:values withCompletionBlock:^(NSError *__nullable err, FIRDatabaseReference * ref){
                        if(err) {
                            NSLog(@"In - AppDelegate Error in updateChildValues:values withCompletionBlock ");
                            return;
                        }
                        NSLog(@"Saved user seccessfully in FireBace db");
                    }];
                }
                if(![snapshot hasChild:@"profileImageURL"]){
                    NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:
                                            @"https://firebasestorage.googleapis.com/v0/b/piano-17dd1.appspot.com/o/User%20Male(528).png?alt=media&token=f7f797cd-0478-4d8e-a042-d30845cbb578",@"profileImageURL",
                                            nil];
                    [usersReference updateChildValues:values withCompletionBlock:^(NSError *__nullable err, FIRDatabaseReference * ref){
                        if(err) {
                            NSLog(@"In - AppDelegate Error in updateChildValues:values withCompletionBlock ");
                            return;
                        }
                        NSLog(@"Saved user seccessfully in FireBace db");
                    }];
                }
                
                
                
            }];
            if (error) {
                // ...
                return;
            }
        }];
        
    } else {
        // ...
    }
}

@end
