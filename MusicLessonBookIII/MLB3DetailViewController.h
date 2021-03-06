//
//  MLB3DetailViewController.h
//  Music Lesson Book III
//
//  Created by Michael Toth on 12/18/13.
//  Copyright (c) 2013 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Student.h"
#import "MLB3LessonTableViewController.h"
#import "MLB3HelpViewController.h"
#import "MLB3AppDelegate.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MLB3RepertoireTableViewController.h"
#import "MLB3SummaryViewController.h"
#import "Photo.h"

@interface MLB3DetailViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate,ABPeoplePickerNavigationControllerDelegate,ABPersonViewControllerDelegate, ABNewPersonViewControllerDelegate, ABUnknownPersonViewControllerDelegate, UINavigationControllerDelegate> {
    NSManagedObjectContext *context;
    MLB3LessonDetailViewController *lessonDetailController;
}

@property (strong, nonatomic) Student *student;
- (IBAction)chooseStudent:(id)sender;
- (IBAction)showRepertoire:(id)sender;
- (IBAction)showSummary:(id)sender;
- (IBAction)showHelp:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *summaryTextView;

@property (weak, nonatomic) IBOutlet UIView *auxView;
@property (nonatomic, assign) ABAddressBookRef addressBook; 
@property (weak, nonatomic) IBOutlet UIButton *editStudentButton;
@property (weak, nonatomic) IBOutlet UIImageView *studentPhotoView;
@property (weak, nonatomic) IBOutlet UITableView *lessonTableView;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIButton *lessonButton;
@end
