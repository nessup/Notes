//
//  AppDelegate.m
//  Notes
//
//  Created by Dany on 5/21/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "AppDelegate.h"

#import "NotebookListViewController.h"
#import "EditNoteViewController.h"
#import "NoteManager.h"
#import "Utility.h"
#import "MGSplitViewController.h"
#import "TranscriptViewController.h"

#import "SpeechToTextManager.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [[NoteManager sharedInstance] setContext:self.managedObjectContext];
    
    EditNoteViewController *editNoteViewController = [EditNoteViewController sharedInstance];
    UINavigationController *editNoteNavigationController = [[UINavigationController alloc] initWithRootViewController:editNoteViewController];
    
    TranscriptViewController *transcriptViewController = [TranscriptViewController sharedInstance];
    UINavigationController *transcriptNavigationController = [[UINavigationController alloc] initWithRootViewController:transcriptViewController];
    
    MGSplitViewController *subSplit = [MGSplitViewController new];
    subSplit.masterBeforeDetail = NO;
    subSplit.viewControllers = @[
                                 transcriptNavigationController,
                                 editNoteNavigationController
                                 ];
    subSplit.allowsDraggingDivider = YES;
    subSplit.dividerStyle = MGSplitViewDividerStylePaneSplitter;
    subSplit.delegate = editNoteViewController;
    
    NotebookListViewController *notebookListViewController = [NotebookListViewController new];
    UINavigationController *noteNavigationController = [[UINavigationController alloc] initWithRootViewController:notebookListViewController];

    self.splitViewController = [[UISplitViewController alloc] init];
    self.splitViewController.delegate = editNoteViewController;
    self.splitViewController.viewControllers = @[noteNavigationController, subSplit];
    
    if ([self.splitViewController respondsToSelector:@selector(setPresentsWithGesture:)]) {
        [self.splitViewController setPresentsWithGesture:YES];
    }
    
    self.window.rootViewController = self.splitViewController;
    [self.window makeKeyAndVisible];
    
//    double delayInSeconds = 2.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [subSplit showMasterPopover:nil];
//    });
    
    return YES;
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
    
    UIBackgroundTaskIdentifier backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
    }];
    
    [self saveContext];
    
    [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
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
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Notes" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [ApplicationDocumentsDirectory() URLByAppendingPathComponent:@"Notes.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
//    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
//    abort();

    return _persistentStoreCoordinator;
}

@end
