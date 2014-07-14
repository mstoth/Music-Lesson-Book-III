//
//  MLB3SummaryViewController.m
//  MusicLessonBookIII
//
//  Created by Michael Toth on 5/3/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import "MLB3SummaryViewController.h"

@interface MLB3SummaryViewController ()
@property (weak, nonatomic) IBOutlet UILabel *headingLabel;
@property (weak, nonatomic) IBOutlet UITextView *reportTextView;

@end

@implementation MLB3SummaryViewController

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
    report = [self createReport];
    [self.reportTextView setText:report];
    
}

- (NSMutableString *)createReport
{
    report = [[NSMutableString alloc] init];
    // Do any additional setup after loading the view.
    [self.headingLabel setText:[self.student name]];
    lessons = [[[self.student lessons] allObjects] mutableCopy];
    [lessons sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj2 date] compare:[obj1 date]];
    }];
    Lesson *lastLesson = [lessons firstObject];
    [report appendString:[NSString stringWithFormat:@"%@ is currently working on %d pieces.",[self.student name],[[lastLesson pieces] count]]];
    int i=0;
    int lcount=0;
    
    
    NSMutableDictionary *lcounts = [[NSMutableDictionary alloc] init];
    for (Piece *p in lastLesson.pieces) {
        for (Lesson *lsn in lessons) {
            if ([lsn.pieces containsObject:p]) {
                lcount+=1;
            }
        }
        [lcounts addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:lcount] forKey:p.title]];
        lcount = 0;
    }
    for (Piece *p in lastLesson.pieces) {
        i=i+1;
        [report appendString:[NSString stringWithFormat:@"\n\t%d. %@ (%d)",i,p.title,[[lcounts valueForKey:p.title] intValue]]];
    }
    NSMutableDictionary *allPieces = [[NSMutableDictionary alloc] init];
    for (Lesson *lsn in lessons) {
        for (Piece *p in lsn.pieces) {
            if ([allPieces valueForKey:p.title] == nil) {
                [allPieces addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@1 forKey:p.title]];
            } else {
                int val = [[allPieces valueForKey:p.title] intValue];
                val++;
                [allPieces setValue:[NSNumber numberWithInt:val] forKeyPath:p.title];
            }
        }
    }
    [report appendString:[NSString stringWithFormat:@"\n%d Lessons",[lessons count]]];
    [report appendString:[NSString stringWithFormat:@"\n%d Pieces",[allPieces count]]];
    int total = 0;
    for (NSNumber *n in [allPieces allValues]) {
        total = total + [n intValue];
    }
    total = total/[allPieces count];
    [report appendString:[NSString stringWithFormat:@"\n%d Lessons/Piece (avg.)",total]];
    return report;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
