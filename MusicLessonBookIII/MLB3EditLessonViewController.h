//
//  MLB3EditLessonViewController.h
//  Music Lesson Book III
//
//  Created by Michael Toth on 12/31/13.
//  Copyright (c) 2013 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lesson.h"

@interface MLB3EditLessonViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
- (IBAction)valueChanged:(id)sender;
@property (nonatomic, retain) Lesson *lesson;
@end
