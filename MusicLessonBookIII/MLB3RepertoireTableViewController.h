//
//  MLB3RepertoireTableViewController.h
//  MusicLessonBookIII
//
//  Created by Michael Toth on 5/2/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Student.h"
#import "Lesson.h"
#import "Piece.h"

@interface MLB3RepertoireTableViewController : UITableViewController {
    NSMutableArray *pieces;
    IBOutlet UIView *headerView;
}
- (UIView *) headerView;
- (IBAction)sortByDate:(id)sender;
- (IBAction)sortByTitle:(id)sender;
- (IBAction)sortByComposer:(id)sender;

@property (nonatomic, retain) Student *student;
@end
