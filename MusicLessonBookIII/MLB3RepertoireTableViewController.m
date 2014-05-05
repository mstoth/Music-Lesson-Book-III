 //
//  MLB3RepertoireTableViewController.m
//  MusicLessonBookIII
//
//  Created by Michael Toth on 5/2/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import "MLB3RepertoireTableViewController.h"

@interface MLB3RepertoireTableViewController ()

@end

@implementation MLB3RepertoireTableViewController
@synthesize student = _student;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = NSLocalizedString(@"Repertoire", @"Repertoire");
    pieces = [[NSMutableArray alloc] init];
    NSMutableSet *pieceSet = [[NSMutableSet alloc] init];
    for (Lesson *l in _student.lessons) {
        [pieceSet addObjectsFromArray:[l.pieces allObjects]];
    }
    pieces = [[pieceSet allObjects] mutableCopy];
}

- (NSDate *)earliestDate:(Piece *)piece {
    NSDate *result = nil;
    for (Lesson *l in _student.lessons) {
        NSDate *lessonDate = l.date;
        for (Piece *p in l.pieces) {
            if ([p.title isEqualToString:piece.title]) {
                if (result == nil) {
                    result = lessonDate;
                } else {
                    if ([result compare:lessonDate] == NSOrderedDescending) {
                        result = lessonDate;
                    }
                }
            }
        }
    }
    return result;
}
- (NSDate *)latestDate:(Piece *)piece {
    NSDate *result = nil;
    for (Lesson *l in _student.lessons) {
        NSDate *lessonDate = l.date;
        for (Piece *p in l.pieces) {
            if ([p.title isEqualToString:piece.title]) {
                if (result == nil) {
                    result = lessonDate;
                } else {
                    if ([result compare:lessonDate] == NSOrderedAscending) {
                        result = lessonDate;
                    }
                }
            }
        }
    }
    return result;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [pieces count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RepertoireCell" forIndexPath:indexPath];
    
    // Configure the cell...
    Piece *p = [pieces objectAtIndex:[indexPath row]];
    [cell.textLabel setText:p.title];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@ - %@",[df stringFromDate:[self earliestDate:p]],[df stringFromDate:[self latestDate:p]]]];
    return cell;
}

- (UIView *)headerView
{
    // If we haven't loaded the headerView yet...
    if (!headerView) {
        // Load HeaderView.xib
        [[NSBundle mainBundle] loadNibNamed:@"HeaderView" owner:self options:nil];
    }
    return headerView;
}

- (IBAction)sortByDate:(id)sender {
    [pieces sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[self earliestDate:obj1] compare:[self earliestDate:obj2]];
    }];
    [self.tableView reloadData];
}

- (IBAction)sortByTitle:(id)sender {
    [pieces sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 title] compare:[obj2 title]];
    }];
    [self.tableView reloadData];
}

- (IBAction)sortByComposer:(id)sender {
    [pieces sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 composer] compare:[obj2 composer]];
    }];
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    UIView *hv = [self headerView];
    return hv.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self headerView];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
