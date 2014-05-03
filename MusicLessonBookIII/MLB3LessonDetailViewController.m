//
//  MLB3LessonDetailViewController.m
//  Music Lesson Book III
//
//  Created by Michael Toth on 2/6/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import "MLB3LessonDetailViewController.h"
#import "Piece.h"
#import "MLB3AppDelegate.h"
#import "MLB3PieceDetailViewController.h"

@interface MLB3LessonDetailViewController ()

@end

@implementation MLB3LessonDetailViewController
@synthesize lesson = _lesson;
@synthesize lastLesson = _lastLesson;
@synthesize pieces = _pieces;



- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.lesson == nil) {
        return 0;
    }
    return [self.pieces count];
}

- (void)viewWillAppear:(BOOL)animated {
    self.pieces = nil;
    [self.pieceTableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.navigationController == nil) {
        Piece *selectedPiece = [self.pieces objectAtIndex:[indexPath row]];
        Note *lastWeekNote;
        Piece *lastWeekPiece;
        if (self.lastLesson == nil) { // there is no older lesson
            lastWeekPiece = nil;
            lastWeekNote = nil;
        } else {
            NSArray *lastWeekPieces = [[self.lastLesson pieces] allObjects];
            NSArray *lastWeekNotes = [[self.lastLesson notes] allObjects];
            for (Piece *p in lastWeekPieces) {
                if ([p.title isEqualToString:selectedPiece.title]) {
                    for (Note *n in lastWeekNotes) {
                        if (n.piece == p) {
                            lastWeekNote = n;
                        }
                    }
                }
            }
        }
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
        MLB3NoteViewController *noteController = [storyBoard instantiateViewControllerWithIdentifier:@"NoteView"];
        noteController.lastWeekNote = lastWeekNote;
        noteController.titleString = selectedPiece.title;
        noteController.note = [self noteForPiece:selectedPiece];
        [self.navController pushViewController:noteController animated:YES];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    Piece *selectedPiece = [self.pieces objectAtIndex:[indexPath row]];
    Note *selectedNote = [self noteForPiece:selectedPiece];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (selectedNote) {
            [context deleteObject:selectedNote];
        }
        if (selectedPiece) {
            [self.lesson removePiecesObject:selectedPiece];
            [self.pieces removeObject:selectedPiece];
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PieceCell"];
    
    Piece *p = [self.pieces objectAtIndex:[indexPath row]];
    
    if (p.title) {
        cell.textLabel.text = p.title;
    } else {
        cell.textLabel.text = @"";
        p.title = @"";
    }
    if (p.composer) {
        cell.detailTextLabel.text = p.composer;
    } else {
        cell.detailTextLabel.text = @"";
        p.composer = @"";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Piece *piece = [self.pieces objectAtIndex:[indexPath row]];
    
    MLB3PieceDetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Edit Piece"];
    [controller setPiece:piece];
    if (self.navController) {
        [self.navController pushViewController:controller animated:YES];
    } else {
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (Note *)noteForPiece:(Piece *)p {
    Note *note;
    note = nil;
    for (Note *n in [self.lesson.notes allObjects]) {
        if ([n.piece isEqual:p]) {
            note = n;
            break;
        }
    }
    return note;
}

- (void)addPieceWithNavigationalController:(UINavigationController *)controller {
    Piece *newPiece = [[MLB3Store sharedStore] createPiece];
    [self.lesson addPiecesObject:newPiece];
    Note *newNote = (Note *)[NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
    newNote.piece = newPiece;
    [self.lesson addNotesObject:newNote];
    [context save:nil];
    
    [self.pieceTableView reloadData];
    MLB3PieceDetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Edit Piece"];
    viewController.piece = newPiece;
    [controller pushViewController:viewController
                          animated:YES];
    
}
- (void)addPiece {
    Piece *newPiece = [[MLB3Store sharedStore] createPiece];
    [self.lesson addPiecesObject:newPiece];
    
    Note *newNote = (Note *)[NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
    newNote.piece = newPiece;
    [self.lesson addNotesObject:newNote];
    
    [context save:nil];
    
    MLB3PieceDetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Edit Piece"];
    viewController.piece = newPiece;
    if (self.navController) {
        [self.navController pushViewController:viewController animated:YES];
    } else {
        [self.navigationController pushViewController:viewController
                                             animated:YES];
    }
    
}

- (void)viewDidLayoutSubviews {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGRect frame = self.pieceTableView.frame;
        frame.size.width *= 2.0;
        self.pieceTableView.frame = frame;
    }

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    metronomeOn = NO;
    MLB3AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    context = delegate.managedObjectContext;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPiece)];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    self.titleLabel.text = [NSString stringWithFormat:@"Lesson for %@",[df stringFromDate:self.lesson.date]];
    //self.pieceTableView.backgroundColor = [UIColor purpleColor];
    //self.pieceTableView.alpha = 0.3;
    [self.pieceTableView setDelegate:self];
    [self.pieceTableView setDataSource:self];
}

- (IBAction)copyPreviousLesson:(id)sender {
    for (Piece *p in self.lastLesson.pieces) {
        [self.lesson addPiecesObject:p];
        Note *newNote = [[MLB3Store sharedStore] createNote];
        newNote.piece = p;
        [self.lesson addNotesObject:newNote];
    }
    [context save:nil];
    self.pieces = nil;
    [self.pieceTableView reloadData];
}

- (NSMutableArray *)pieces {
    if (!_pieces) {
        _pieces = [[[self.lesson pieces] allObjects] mutableCopy];
        _pieces = [[_pieces sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(id obj1, id obj2) {
            Piece *p1,*p2;
            p1=obj1; p2=obj2;
            return [p1.title compare:p2.title];
        }] mutableCopy];
    }
    return _pieces;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender  {
    if (self.navigationController == nil) {
        return NO;
    } else {
        return YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"Note View"]) {
        NSIndexPath *ip = [self.pieceTableView indexPathForSelectedRow];
        Piece *selectedPiece = [self.pieces objectAtIndex:[ip row]];
        Note *lastWeekNote;
        Piece *lastWeekPiece;
        if (self.lastLesson == nil) { // there is no older lesson
            lastWeekPiece = nil;
            lastWeekNote = nil;
        } else {
            NSArray *lastWeekPieces = [[self.lastLesson pieces] allObjects];
            NSArray *lastWeekNotes = [[self.lastLesson notes] allObjects];
            for (Piece *p in lastWeekPieces) {
                if ([p.title isEqualToString:selectedPiece.title]) {
                    for (Note *n in lastWeekNotes) {
                        if (n.piece == p) {
                            lastWeekNote = n;
                        }
                    }
                }
            }
        }
        
        MLB3NoteViewController *vc = [segue destinationViewController];
        vc.lastWeekNote = lastWeekNote;
        vc.titleString = selectedPiece.title;
        vc.note = [self noteForPiece:selectedPiece];
        
    } else {
        
        MLB3PieceDetailViewController *vc = [segue destinationViewController];
        NSIndexPath *ip = [self.pieceTableView indexPathForSelectedRow];
        Piece *selectedPiece = [self.pieces objectAtIndex:[ip row]];
        [vc setPiece:selectedPiece];
    }
}


#pragma mark -
#pragma mark Metronome routines

- (IBAction)toggleMetronome:(id)sender {
    if (!metronomeOn) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSError *error = nil;
        
        NSURL *tickURL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"tick" ofType:@"caf"]];
        
        self.tickPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:tickURL error:&error];
        if (error) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Audio Error" message:@"Error Initializing Audio" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        if (!self.tickPlayer) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Can not initialize audio player." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            NSLog(@"no tickPlayer: %@", [error localizedDescription]);
            return;
        }
        
        metronomeOn = true;
        [self.metronomeButton setTitle:@"Off" forState:UIControlStateNormal];
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        myThread = [[NSThread alloc] initWithTarget:self
                                           selector:@selector(startDriverTimer:)
                                             object:nil];
        
        [myThread start];  // Actually create the thread
    } else {
        metronomeOn = false;
        [myThread cancel];
        myThread = nil;
        [self.metronomeButton setTitle:@"Metronome" forState:UIControlStateNormal];
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        // nothing to do
    }
}


// This method is invoked from the driver thread
- (void)startDriverTimer:(id)sender {
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Give the sound thread high priority to keep the timing steady.
    [NSThread setThreadPriority:1.0];
    BOOL continuePlaying = YES;
    
    while (continuePlaying) {  // Loop until cancelled.
        // An autorelease pool to prevent the build-up of temporary objects.
        //NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
        
        [self playSound];
        //NSLog(@"duration=%f",self.duration);
        NSDate *curtainTime = [[NSDate alloc] initWithTimeIntervalSinceNow:duration];
        NSDate *currentTime = [[NSDate alloc] init];
        
        // Wake up periodically to see if we've been cancelled.
        while (continuePlaying && ([currentTime compare:curtainTime] != NSOrderedDescending)) {
            [NSThread sleepForTimeInterval:0.01];
            currentTime = [[NSDate alloc] init];
            if (metronomeOn == false)
                continuePlaying = NO;
        }
    }
}

- (void)playSound {
    [self.tickPlayer play];
}

- (void)setBpm:(NSUInteger)bpm {
    if (bpm >= kMaxBPM) {
        bpm = kMaxBPM;
    } else if (bpm <= kMinBPM) {
        bpm = kMinBPM;
    }
    duration = (60.0 / bpm);
    self.metronomeTextField.text = [NSString stringWithFormat:@"%d",bpm];
}

- (void) metronomeChanged:(id)sender {
    NSUInteger t;
    t=[self.metronomeTextField.text intValue];
    [self setBpm:t];
}

- (NSUInteger)bpm {
    return lrint(ceil(60.0 / (duration)));
}

    @end
