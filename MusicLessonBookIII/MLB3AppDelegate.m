//
//  MLB3AppDelegate.m
//  MusicLessonBookIII
//
//  Created by Michael Toth on 4/7/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import "MLB3AppDelegate.h"
#import <DropboxSDK/DropboxSDK.h>
#import "MLB3MasterViewController.h"

@implementation MLB3AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize myUbiquityContainer = _myUbiquityContainer;

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString * dropBoxPath = [standardUserDefaults objectForKey:@"MLB3DropBoxPathPrefKey"];
    if (!dropBoxPath) {
        [self registerDefaultsFromSettingsBundle];
    }
    NSString *instrument = [standardUserDefaults objectForKey:@"MLB3InstrumentPrefKey"];
    if (!instrument) {
        [self registerDefaultsFromSettingsBundle];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
        UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
        mvc = (MLB3MasterViewController *)masterNavigationController.topViewController;
        mvc.managedObjectContext = self.managedObjectContext;
    } else {
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        mvc = (MLB3MasterViewController *)navigationController.topViewController;
        mvc.managedObjectContext = self.managedObjectContext;
    }
    
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayAndRecord
                    error: &setCategoryError];
    if (!success) {
        /* handle the error in setCategoryError */
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"AVAudioSession Error" message:[setCategoryError localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        
    }
    
    [self setupICloud];
    // register to observe notifications from the store
    
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector (storeDidChange:)
     name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification
     object: [NSUbiquitousKeyValueStore defaultStore]];
    
    // get changes that might have happened while this
    // instance of your app wasn't running
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    
    return YES;
}

- (void)setupICloud {
    id currentiCloudToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    
    
    BOOL firstLaunchWithiCloudAvailable = YES;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"iCloudDesired"] == nil) {
        firstLaunchWithiCloudAvailable = YES;
    }
    
    if (currentiCloudToken) {
        NSData *newTokenData =
        [NSKeyedArchiver archivedDataWithRootObject: currentiCloudToken];
        [[NSUserDefaults standardUserDefaults]
         setObject: newTokenData
         forKey: @"com.virtualpianist.MusicLessonBookIII.UbiquityIdentityToken"];
    } else {
        [[NSUserDefaults standardUserDefaults]
         removeObjectForKey: @"com.virtualpianist.MusicLessonBookIII.UbiquityIdentityToken"];
    }
    
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector (iCloudAccountAvailabilityChanged:)
     name: NSUbiquityIdentityDidChangeNotification
     object: nil];
    
    if (currentiCloudToken && firstLaunchWithiCloudAvailable) {
        
        UIAlertView *alert = [[UIAlertView alloc]
                              
                              initWithTitle: @"Choose Storage Option"
                              
                              message: @"Should documents be stored in iCloud and available on all your devices?"
                              delegate: self
                              cancelButtonTitle: @"Local Only"
                              otherButtonTitles: @"Use iCloud", nil];
        [alert show];
        
    }
    
    
    dispatch_async (dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        _myUbiquityContainer = [[NSFileManager defaultManager]
                                URLForUbiquityContainerIdentifier: nil];
        
        if (_myUbiquityContainer != nil) {
            // Your app can write to the ubiquity container
            dispatch_async (dispatch_get_main_queue (), ^(void) {
                // On the main thread, update UI and state as appropriate
                [mvc reloadInputViews];
            });
        }
    });

}

- (void)storeDidChange:(NSNotification *)note {
    // handle change in key-value icloud storage
    NSLog(@"HANDLE STORE DID CHANGE!!!");
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        // use icloud
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"iCloudDesired"];
    }
    if (buttonIndex == 1) {
        // use local
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"iCloudDesired"];
    }
    
}

- (void)iCloudAccountAvailabilityChanged:(NSNotification *)note {
    id currentiCloudToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    if (currentiCloudToken) {
        // handle turning on icloud
        [self setupICloud];
    } else {
        // handle turning off icloud
        NSLog(@"HANDLE TURNING OFF ICLOUD!!!");
    }
}


- (void)registerDefaultsFromSettingsBundle {
    // this function writes default settings as settings
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
            NSLog(@"writing as default %@ to the key %@",[prefSpecification objectForKey:@"DefaultValue"],key);
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    
    BOOL dropBoxOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"MLB3DropBoxPrefKey"];
    if (dropBoxOn)
        NSLog(@"Drop box is on.");
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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MusicLessonBookIII" withExtension:@"momd"];
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MusicLessonBookIII.sqlite"];
    
    NSDictionary *storeOptions =
    @{NSPersistentStoreUbiquitousContentNameKey: @"MusicLessonBookIIICloudStore"};
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:storeOptions error:&error]) {
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
