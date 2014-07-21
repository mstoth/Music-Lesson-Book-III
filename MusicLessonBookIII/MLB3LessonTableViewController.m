//
//  MLB3LessonTableViewController.m
//  Music Lesson Book III
//
//  Created by Michael Toth on 12/31/13.
//  Copyright (c) 2013 Michael Toth. All rights reserved.
//

#import "MLB3LessonTableViewController.h"

@interface MLB3LessonTableViewController ()

@end

@implementation MLB3LessonTableViewController
@synthesize lessonsForTable = _lessonsForTable;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSMutableArray *)lessonsForTable {
    if (!_lessonsForTable) {
        _lessonsForTable =  [[NSMutableArray alloc] init];
        _lessonsForTable = [[[self.student.lessons allObjects] sortedArrayUsingComparator:^NSComparisonResult(Lesson *obj1, Lesson *obj2) {
            return [obj2.date compare:obj1.date];
        }] mutableCopy];
    }
    return _lessonsForTable;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.title = @"Lessons";
    
}

- (void)viewWillAppear:(BOOL)animated {
    MLB3AppDelegate *delegate = (MLB3AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = delegate.managedObjectContext;
    [context save:nil];
    _lessonsForTable = nil;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    MLB3AppDelegate *delegate = (MLB3AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = delegate.managedObjectContext;
    Lesson *lastLesson;
    if ([[self.student.lessons allObjects] count] > 0) {
        NSArray *lessons = [[self.student.lessons allObjects] sortedArrayUsingComparator:^NSComparisonResult(Lesson *obj1, Lesson *obj2) {
            NSDate *d1 = obj1.date;
            NSDate *d2 = obj2.date;
            return [d1 compare:d2];
        }];
        lastLesson = [lessons lastObject];
    } else {
        lastLesson = nil;
    }
    

    Lesson *newLesson = (Lesson *)[NSEntityDescription insertNewObjectForEntityForName:@"Lesson" inManagedObjectContext:context];
    if (lastLesson == nil) {
        newLesson.balance = 0.0;
    } else {
        newLesson.balance = lastLesson.balance;
    }
    
    newLesson.date = [NSDate date];
    [self.student addLessonsObject:newLesson];
    [context save:nil];
    self.lessonsForTable = nil;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.lessonsForTable count];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Lesson *lesson = [self.lessonsForTable objectAtIndex:[indexPath row]];
    MLB3EditLessonViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"EditLesson"];
    // MLB3EditLessonViewController *controller = [[MLB3EditLessonViewController alloc] initWithNibName:nil bundle:nil];
    [controller setLesson:lesson];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *ip = [self.tableView indexPathForSelectedRow];
    if (!ip) {
        return;
    }
    Lesson *selectedLesson = [self.lessonsForTable objectAtIndex:[ip row]];
    
    if ([segue.identifier isEqualToString:@"LessonDetail"]) {
        
        MLB3LessonDetailViewController *lessonDetailViewController = segue.destinationViewController;
        lessonDetailViewController.lesson = selectedLesson;
        
        if ([ip row] == [self.lessonsForTable count] - 1) {
            // no prior lessons
            lessonDetailViewController.lastLesson = nil;
        } else {
            lessonDetailViewController.lastLesson = [self.lessonsForTable objectAtIndex:[ip row]+1];
        }
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LessonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterMediumStyle;
    Lesson *lesson = [self.lessonsForTable objectAtIndex:[indexPath row]];
    cell.textLabel.text = [df stringFromDate:[lesson date]];
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        Lesson *selectedLesson = [self.lessonsForTable objectAtIndex:[indexPath row]];
        
        [self.student removeLessonsObject:selectedLesson];
        
        [context deleteObject:selectedLesson];
        
        [self.lessonsForTable removeObject:selectedLesson];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}


/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
