//
//  MLB3NoteViewController.m
//  Music Lesson Book III
//
//  Created by Michael Toth on 2/23/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import "MLB3NoteViewController.h"
#import "MLB3AppDelegate.h"

@interface MLB3NoteViewController ()

@end

@implementation MLB3NoteViewController
@synthesize note = _note;
@synthesize lastWeekNote = _lastWeekNote;

- (void) setNote:(Note *)note {
    _note = note;
    self.noteTextView.text = note.body;
}

- (void) setLastWeekNote:(Note *)lastWeekNote {
    _lastWeekNote = lastWeekNote;
    if (lastWeekNote.body) {
        self.lastLessonTextView.text = lastWeekNote.body;
    } else {
        self.lastLessonTextView.text = @"No Prior Lesson";
    }
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.gestureRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.gestureRecognizer setDelegate:self];
    self.noteTextView.text = self.note.body;
    if (self.lastWeekNote) {
        self.lastLessonTextView.text = self.lastWeekNote.body;
    } else {
        self.lastLessonTextView.text = @"No Prior Lesson";
    }
    self.titleLabel.text = self.titleString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(id)sender {
    self.note.body = self.noteTextView.text;
    MLB3AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    context = [delegate managedObjectContext];
    [context save:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)removeKeyboard:(id)sender {
    [self.view endEditing:YES];
}
@end
