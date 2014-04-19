//
//  MLB3EditLessonViewController.m
//  Music Lesson Book III
//
//  Created by Michael Toth on 12/31/13.
//  Copyright (c) 2013 Michael Toth. All rights reserved.
//

#import "MLB3EditLessonViewController.h"

@interface MLB3EditLessonViewController ()

@end

@implementation MLB3EditLessonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //[self.datePicker setDate:[self.lesson date]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.datePicker setDate:[self.lesson date]];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)valueChanged:(id)sender {
    [self.lesson setDate:[(UIDatePicker *)sender date]];
}
@end
