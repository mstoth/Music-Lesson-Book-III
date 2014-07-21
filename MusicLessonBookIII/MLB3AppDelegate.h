//
//  MLB3AppDelegate.h
//  MusicLessonBookIII
//
//  Created by Michael Toth on 4/7/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MLB3MasterViewController.h"

@interface MLB3AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate> {
    MLB3MasterViewController *mvc;
}

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSURL *myUbiquityContainer;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
