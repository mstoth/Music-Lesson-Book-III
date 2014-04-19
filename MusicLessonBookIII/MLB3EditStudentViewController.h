//
//  MLB3EditStudentViewController.h
//  Music Lesson Book III
//
//  Created by Michael Toth on 12/18/13.
//  Copyright (c) 2013 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Student.h"
#import "MLB3AppDelegate.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface MLB3EditStudentViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) Student *student;
@property (weak, nonatomic) IBOutlet UITextField *nameTextView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextView;
@property (weak, nonatomic) IBOutlet UITextField *categoryTextView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextView;

@end
