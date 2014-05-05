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
    if ([self.note.rating intValue] & 1) {
        [self.greenStar setImage:[UIImage imageNamed:@"greenstar.png"] forState:UIControlStateNormal];
    }
    if ([self.note.rating intValue] & 2) {
        [self.redStar setImage:[UIImage imageNamed:@"redstar.png"] forState:UIControlStateNormal];
    }
    if ([self.note.rating intValue] & 4) {
        [self.goldStar setImage:[UIImage imageNamed:@"goldstar.png"] forState:UIControlStateNormal];
    }
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


- (IBAction)toggleGreen:(id)sender {
    UIButton *greenButton = sender;
    int irating = [self.note.rating intValue];
    irating = irating ^ 1;
    self.note.rating = [NSNumber numberWithInt:irating];
    switch (irating & 1) {
        case 0:
            [greenButton setImage:[UIImage imageNamed:@"outlinestar.png"] forState:UIControlStateNormal];
            break;
        case 1:
            [greenButton setImage:[UIImage imageNamed:@"greenstar.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (IBAction)toggleGold:(id)sender {
    UIButton *goldButton = sender;
    int irating = [self.note.rating intValue];
    irating = irating ^ 4;
    self.note.rating = [NSNumber numberWithInt:irating];
    switch (irating & 4) {
        case 0:
            [goldButton setImage:[UIImage imageNamed:@"outlinestar.png"] forState:UIControlStateNormal];
            break;
        case 4:
            [goldButton setImage:[UIImage imageNamed:@"goldstar.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }

}

- (IBAction)toggleRed:(id)sender {
    UIButton *redButton = sender;
    int irating = [self.note.rating intValue];
    irating = irating ^ 2;
    self.note.rating = [NSNumber numberWithInt:irating];
    switch (irating & 2) {
        case 0:
            [redButton setImage:[UIImage imageNamed:@"outlinestar.png"] forState:UIControlStateNormal];
            break;
        case 2:
            [redButton setImage:[UIImage imageNamed:@"redstar.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}




@end
