//
//  MLB3MasterViewController.h
//  MusicLessonBookIII
//
//  Created by Michael Toth on 4/7/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLB3DetailViewController;

#import <CoreData/CoreData.h>

@interface MLB3MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) MLB3DetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
