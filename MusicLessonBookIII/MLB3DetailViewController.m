//
//  MLB3DetailViewController.m
//  Music Lesson Book III
//
//  Created by Michael Toth on 12/18/13.
//  Copyright (c) 2013 Michael Toth. All rights reserved.
//

#import "MLB3DetailViewController.h"
#import "MLB3LessonDetailViewController.h"

@interface MLB3DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation MLB3DetailViewController

#pragma mark - Managing the detail item

- (void)setStudent:(Student *)newStudent
{
    if (_student != newStudent) {
        _student = newStudent;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.student) {
        [self.lessonTableView reloadData];
        self.studentPhotoView.image = self.student.photo.image;
        [self setTitle:[self.student valueForKey:@"name"]];
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addLesson:)];
    }
    if (lessonDetailController) {
        lessonDetailController.lesson = nil;
        lessonDetailController.lastLesson = nil;
        [lessonDetailController.pieceTableView reloadData];
    }
}

- (void)addLesson:(id)lessonButton {
    Lesson *newLesson = [NSEntityDescription insertNewObjectForEntityForName:@"Lesson" inManagedObjectContext:context];
    newLesson.date = [NSDate date];
    [self.student addLessonsObject:newLesson];
    [self.lessonTableView reloadData];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([[segue identifier] isEqualToString:@"LessonTableView"]) {
        [(MLB3LessonTableViewController *)[segue destinationViewController] setStudent:self.student];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self configureView];
    MLB3AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    context = [delegate managedObjectContext];
    [context save:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showRepertoire:(id)sender {
    MLB3RepertoireTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Repertoire"];
    [vc setStudent:self.student];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[(Student *)self.student lessons] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Lesson *lastLesson;
    NSArray *studentArray =[[[(Student *)self.student lessons] allObjects] sortedArrayUsingComparator:^NSComparisonResult(Lesson *obj1, Lesson *obj2) {
        return [obj2.date compare:obj1.date];
    }];
    
    Lesson *lesson = [studentArray objectAtIndex:[indexPath row]];
    if ([indexPath row] < [studentArray count]-1) {
        lastLesson = [studentArray objectAtIndex:[indexPath row]+1];
        
        lessonDetailController.lastLesson = lastLesson;
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (lessonDetailController) {
            [lessonDetailController.view removeFromSuperview];
            lessonDetailController = nil;
        }
        lessonDetailController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil]instantiateViewControllerWithIdentifier:@"Lesson Detail"];
        lessonDetailController.lesson = lesson;
        lessonDetailController.lastLesson = lastLesson;
        CGRect newFrame = self.lessonTableView.frame;
        newFrame.origin.x += newFrame.size.width;
        lessonDetailController.view.frame = newFrame;
        lessonDetailController.navController = self.navigationController;
//        [self.view addSubview:lessonDetailController.view];
        [self.navigationController pushViewController:lessonDetailController animated:YES];

    }
    //[self.navigationController pushViewController:vc animated:YES];
    //[self.auxView addSubview:vc.view];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    Lesson *lesson = [[[[(Student *)self.student lessons] allObjects] sortedArrayUsingComparator:^NSComparisonResult(Lesson *obj1, Lesson *obj2) {
        return [obj2.date compare:obj1.date];
    }] objectAtIndex:[indexPath row]];
    
    MLB3EditLessonViewController *controller = [[MLB3EditLessonViewController alloc] initWithNibName:nil bundle:nil];
    [controller setLesson:lesson];
    [self.navigationController pushViewController:controller animated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LessonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterMediumStyle;
    Lesson *lesson = [[[[(Student *)self.student lessons] allObjects] sortedArrayUsingComparator:^NSComparisonResult(Lesson *obj1, Lesson *obj2) {
        return [obj2.date compare:obj1.date];
    }] objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = [df stringFromDate:[lesson date]];
    return cell;
}


- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [peoplePicker resignFirstResponder];
    [peoplePicker dismissViewControllerAnimated:YES completion:^{
        // do nothing
    }];
}

#pragma mark -
#pragma mark Address Book Access
// Check the authorization status of our application for Address Book
-(void)checkAddressBookAccess
{
    switch (ABAddressBookGetAuthorizationStatus())
    {
            // Update our UI if the user has granted access to their Contacts
        case  kABAuthorizationStatusAuthorized:
            [self accessGrantedForAddressBook];
            break;
            // Prompt the user for access to Contacts if there is no definitive answer
        case  kABAuthorizationStatusNotDetermined :
            [self requestAddressBookAccess];
            break;
            // Display a message if the user has denied or restricted access to Contacts
        case  kABAuthorizationStatusDenied:
        case  kABAuthorizationStatusRestricted:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Warning"
                                                            message:@"Permission was not granted for Contacts."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}

// Prompt the user for access to their Address Book data
-(void)requestAddressBookAccess
{
    MLB3DetailViewController * __weak weakSelf = self;
    
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 if (granted)
                                                 {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [weakSelf accessGrantedForAddressBook];
                                                         
                                                     });
                                                 }
                                             });
}

// This method is called when the user has granted access to their address book data.
-(void)accessGrantedForAddressBook
{
    // Load data from the plist file
	//NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Menu" ofType:@"plist"];
	//self.menuArray = [NSMutableArray arrayWithContentsOfFile:plistPath];
    //[self.tableView reloadData];
}


- (IBAction)chooseStudent:(id)sender {
    ABPeoplePickerNavigationController *controller = [[ABPeoplePickerNavigationController alloc] init];
    controller.peoplePickerDelegate = self;
    
    [self presentViewController:controller animated:YES completion:^{
        // do nothing;
    }];
    
}

- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownPersonView didResolveToPerson:(ABRecordRef)person {
    
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person {
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue {
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    NSError *error = nil;
//    MLB3AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
//    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    [self displayPerson:person];
    [self dismissViewControllerAnimated:YES completion:^{
        // do nothing
    }];
    NSString* name = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString* lname = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    self.student.name = [NSString stringWithFormat:@"%@ %@",name,lname];
    self.title = self.student.name;
    
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    if (ABMultiValueGetCount(emails) > 0) {
        self.student.email = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emails, 0);
    } else {
        self.student.email = @"[None]";
    }
    
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge_transfer NSString*)
        ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    } else {
        phone = @"[None]";
    }
    self.student.phone = phone;

    if(ABPersonHasImageData(person)){
        self.studentPhotoView.image = [UIImage imageWithData:(__bridge_transfer NSData *)ABPersonCopyImageData(person)];
    }

    if ([self.student valueForKey:@"photo"]) {
        [context deleteObject:[self.student valueForKey:@"photo"]];
    }
    
    Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
    photo.image = self.studentPhotoView.image;
    self.student.photo = photo;

    [context save:&error];
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    NSString* name = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString* lname = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    self.student.name = [NSString stringWithFormat:@"%@ %@",name,lname];
    return NO;
}

- (void) displayPerson:(ABRecordRef)person {
    
}


- (IBAction)addPiece:(id)sender {
    
    [lessonDetailController addPieceWithNavigationalController:self.navigationController];
}
@end
