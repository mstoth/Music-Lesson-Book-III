//
//  MLB3LessonTableViewController.h
//  Music Lesson Book III
//
//  Created by Michael Toth on 12/31/13.
//  Copyright (c) 2013 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Student.h"
#import "Lesson.h"
#import "MLB3EditLessonViewController.h"
#import "MLB3LessonDetailViewController.h"
#import "MLB3AppDelegate.h"

@interface MLB3LessonTableViewController : UITableViewController {
    NSManagedObjectContext *context;
}
@property (nonatomic, retain) NSMutableArray *lessonsForTable;
@property (nonatomic, retain) Student *student;
@end
