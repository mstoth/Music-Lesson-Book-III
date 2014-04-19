//
//  MLB3EditStudentViewController.m
//  Music Lesson Book III
//
//  Created by Michael Toth on 12/18/13.
//  Copyright (c) 2013 Michael Toth. All rights reserved.
//

enum {
    kNameTextField,
    kPhoneTextField,
    kCategoryTextField,
    kEmailTextField
};

#import "MLB3EditStudentViewController.h"

@interface MLB3EditStudentViewController ()

@end

@implementation MLB3EditStudentViewController

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
    [self.nameTextView setDelegate:self];
    [self.phoneTextView setDelegate:self];
    [self.emailTextView setDelegate:self];
    [self.categoryTextView setDelegate:self];
    self.nameTextView.text = self.student.name;
    self.phoneTextView.text = self.student.phone;
    self.categoryTextView.text = self.student.category;
    self.emailTextView.text = self.student.email;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillDisappear:(BOOL)animated {
    
    NSManagedObjectContext *context = [(MLB3AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    [context save:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case kNameTextField:
            self.student.name = textField.text;
            break;
        case kPhoneTextField:
            self.student.phone = textField.text;
            break;
        case kCategoryTextField:
            self.student.category = textField.text;
            break;
        case kEmailTextField:
            self.student.email = textField.text;
            break;
        default:
            break;
    }
    [textField resignFirstResponder];
}

@end
