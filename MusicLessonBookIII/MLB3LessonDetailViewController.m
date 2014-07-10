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
- (IBAction)bigStep:(id)sender;
@property (weak, nonatomic) IBOutlet UIStepper *bigStepper;

@end

@implementation MLB3LessonDetailViewController
@synthesize lesson = _lesson;
@synthesize lastLesson = _lastLesson;
@synthesize pieces = _pieces;



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.lesson == nil) {
        return 0;
    }
    return [self.pieces count];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.metronomeButton setTitle:@"On" forState:UIControlStateNormal];
    metronomeOn = NO;

    self.pieces = nil;
    [self.pieceTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (myThread) {
        [myThread cancel];
    }
    metronomeOn = NO;
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
    for (Note *n in self.lesson.notes) {
        if ([n.piece isEqual:p]) {
            switch ([n.rating intValue]) {
                case 0:
                    [cell.imageView setImage:[UIImage imageNamed:@"outlinestar.png"]];
                    break;
                case 1:
                    [cell.imageView setImage:[UIImage imageNamed:@"greenstar.png"]];
                    break;
                case 2:
                case 3:
                    [cell.imageView setImage:[UIImage imageNamed:@"redstar.png"]];
                    break;
                case 4:
                    [cell.imageView setImage:[UIImage imageNamed:@"goldstar.png"]];
                    break;
                    
                default:
                    [cell.imageView setImage:[UIImage imageNamed:@"goldstar.png"]];

                    break;
            }
        }
    }
    
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

- (IBAction)jumpToTempo:(id)sender {
    UISegmentedControl *sc = sender;
    switch ([sc selectedSegmentIndex]) {
        case 0:
            [self setBpm:60];
            break;
        case 1:
            [self setBpm:80];
            break;
        case 2:
            [self setBpm:100];
            break;
        case 3:
            [self setBpm:120];
            break;
        case 4:
            [self setBpm:140];
            break;
        default:
            [self setBpm:60];
            break;
    }
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
    [self setBpm:60];
    self.bigStepper.value = 60.0;
    
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
        NSArray *notesFromLastLesson = [self.lastLesson.notes allObjects];
        for (Note *n in notesFromLastLesson) {
            if ([n.piece isEqual:p]) {
                newNote.rating = n.rating;
            }
        }
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
        [self.metronomeButton setTitle:@"On" forState:UIControlStateNormal];
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
    self.bigStepper.value = bpm;
    
    duration = (60.0 / bpm);
    self.metronomeTextField.text = [NSString stringWithFormat:@"%lu",(unsigned long)bpm];
}


- (void) metronomeChanged:(id)sender {
    NSUInteger t;
    t=[self.metronomeTextField.text intValue];
    [self setBpm:t];
}

- (NSUInteger)bpm {
    return lrint(ceil(60.0 / (duration)));
}

- (IBAction)bigStep:(id)sender {
    self.metronomeTextField.text = [NSString stringWithFormat:@"%.0f",self.bigStepper.value];
    [self setBpm:self.bigStepper.value];
}

#pragma mark -
#pragma mark Audio
- (IBAction)record:(id)sender {
    
    //NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:kA, AVEncoderAudioQualityKey, nil];
    //AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:fileName settings:settings error:&error];
    NSError *outError = nil;
    NSDictionary *settings = @{};
    NSURL *url = [[NSURL alloc] initWithString:@"File Name"];
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&outError];
    recorder = nil;
}



- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    
}
#pragma mark -
#pragma mark Email Functions


- (IBAction)emailLesson:(id)sender {
    [self actionEmailComposer];
}

- (IBAction)actionEmailComposer {
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Lesson"];
        
        if ([self.lesson.student email] == nil) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Email Error." message:@"Student has no email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            return;
        }
        [mailViewController setToRecipients:[NSArray arrayWithObject:[self.lesson.student email]]];
        [mailViewController setMessageBody:[self lessonBodyForPrint] isHTML:YES];
        //for (Piece *p in self.lesson.pieces) {
            //Recording *r = (Recording *)ps.recording;
//            if ((ps.recording != nil) && (r.data != nil)) {
//                NSString *message;
//                message = [[NSString alloc] initWithFormat:@"Include Recording for %@?",ps.pieceTitle];
//                BOOL includeRecording = [ModalAlertView ask:message];
//                NSString *fileName = [ps.pieceTitle stringByAppendingString:@".caf"];
//                if (includeRecording) {
//                    NSString *path = [[self applicationDocumentsDirectory] path];
//                    path = [path stringByAppendingPathComponent:fileName];
//                    [[NSFileManager defaultManager] createFileAtPath:path contents:r.data attributes:nil];
//                    [mailViewController addAttachmentData:r.data mimeType:@"audio/x-caf" fileName:fileName];
//                }
//            }
        //}
        [self presentViewController:mailViewController animated:YES completion:^{
            // do nothing
        }];
        
        //[self presentModalViewController:mailViewController animated:YES];
    } else {
        ////NSLog(@"Device is unable to send email.");
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller
         didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
//    for (Piece *p in self.lesson.pieces) {
//        NSString *path = [[self applicationDocumentsDirectory] path];
//        NSString *fileName = [ps.pieceTitle stringByAppendingString:@".caf"];
//        path = [path stringByAppendingPathComponent:fileName];
//        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
//    }
    if (result == MFMailComposeResultFailed) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Email Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [self dismissViewControllerAnimated:YES completion:^{
            // do nothing
        }];
    }
    if (result == MFMailComposeResultCancelled) {
        [self dismissViewControllerAnimated:YES completion:^{
            // do nothing
        }];
    }
    if (result == MFMailComposeResultSent) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSMutableString *)lessonBodyForPrint {
    NSMutableString *body = [[NSMutableString alloc] initWithString:@"<html><body>"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    
    [body appendFormat:@"<h1>%@</h1>",[df stringFromDate:self.lesson.date]];
    for (Note *n in self.lesson.notes) {
        for (Piece *p in self.lesson.pieces) {
            if ([p isEqual:n.piece]) {
                [body appendFormat:@"<h3>%@</h3><p>%@</p>",p.title,n.body];
            }
        }
    }
    [body appendString:@"</body></html>"];
    return body;
}






    @end
