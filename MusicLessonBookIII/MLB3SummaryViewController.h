//
//  MLB3SummaryViewController.h
//  MusicLessonBookIII
//
//  Created by Michael Toth on 5/3/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Student.h"
#import "Lesson.h"
#import "Piece.h"

@interface MLB3SummaryViewController : UIViewController {
    NSMutableArray *lessons;
    NSMutableString *report;
}
@property (nonatomic, retain) Student *student;
@end
