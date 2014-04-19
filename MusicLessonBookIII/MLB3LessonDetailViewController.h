//
//  MLB3LessonDetailViewController.h
//  Music Lesson Book III
//
//  Created by Michael Toth on 2/6/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lesson.h"
#import "MLB3Store.h"

@interface MLB3LessonDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableDictionary *notes;
    NSManagedObjectContext *context;
}
- (IBAction)copyPreviousLesson:(id)sender;
@property (strong, nonatomic) NSMutableArray *pieces;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *pieceTableView;
@property (strong, nonatomic) Lesson *lesson;
@property (weak, nonatomic) Lesson *lastLesson;
@property (nonatomic, retain) UINavigationController *navController;
- (void) addPieceWithNavigationalController:(UINavigationController *)controller;
@end
