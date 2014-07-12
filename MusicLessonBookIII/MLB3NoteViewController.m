//
//  MLB3NoteViewController.m
//  Music Lesson Book III
//
//  Created by Michael Toth on 2/23/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import "MLB3NoteViewController.h"
#import "MLB3AppDelegate.h"

@interface MLB3NoteViewController ()

@end

@implementation MLB3NoteViewController
@synthesize note = _note;
@synthesize lastWeekNote = _lastWeekNote;

- (void) setNote:(Note *)note {
    _note = note;
    self.noteTextView.text = note.body;
}

- (void) setLastWeekNote:(Note *)lastWeekNote {
    _lastWeekNote = lastWeekNote;
    if (lastWeekNote.body) {
        self.lastLessonTextView.text = lastWeekNote.body;
    } else {
        self.lastLessonTextView.text = @"No Prior Lesson";
    }
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [player stop];
    player = nil;
    [recorder stop];
    recorder = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.gestureRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.gestureRecognizer setDelegate:self];
    self.noteTextView.text = self.note.body;
    if ([self.note.rating intValue] & 1) {
        [self.greenStar setImage:[UIImage imageNamed:@"greenstar.png"] forState:UIControlStateNormal];
    }
    if ([self.note.rating intValue] & 2) {
        [self.redStar setImage:[UIImage imageNamed:@"redstar.png"] forState:UIControlStateNormal];
    }
    if ([self.note.rating intValue] & 4) {
        [self.goldStar setImage:[UIImage imageNamed:@"goldstar.png"] forState:UIControlStateNormal];
    }
    if (self.lastWeekNote) {
        self.lastLessonTextView.text = self.lastWeekNote.body;
    } else {
        self.lastLessonTextView.text = @"No Prior Lesson";
    }
    self.titleLabel.text = self.titleString;
    if (self.note.recording) {
        [self.recordButton setTitle:@"Play" forState:UIControlStateNormal];
    } else {
        [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
        [self.deleteButton setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(id)sender {
    self.note.body = self.noteTextView.text;
    self.note.recording = [NSData dataWithContentsOfURL:recordingURL];
    MLB3AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    context = [delegate managedObjectContext];
    [context save:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)removeKeyboard:(id)sender {
    [self.view endEditing:YES];
}


- (IBAction)toggleGreen:(id)sender {
    UIButton *greenButton = sender;
    int irating = [self.note.rating intValue];
    irating = irating ^ 1;
    self.note.rating = [NSNumber numberWithInt:irating];
    switch (irating & 1) {
        case 0:
            [greenButton setImage:[UIImage imageNamed:@"outlinestar.png"] forState:UIControlStateNormal];
            break;
        case 1:
            [greenButton setImage:[UIImage imageNamed:@"greenstar.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (IBAction)toggleGold:(id)sender {
    UIButton *goldButton = sender;
    int irating = [self.note.rating intValue];
    irating = irating ^ 4;
    self.note.rating = [NSNumber numberWithInt:irating];
    switch (irating & 4) {
        case 0:
            [goldButton setImage:[UIImage imageNamed:@"outlinestar.png"] forState:UIControlStateNormal];
            break;
        case 4:
            [goldButton setImage:[UIImage imageNamed:@"goldstar.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }

}

- (IBAction)toggleRed:(id)sender {
    UIButton *redButton = sender;
    int irating = [self.note.rating intValue];
    irating = irating ^ 2;
    self.note.rating = [NSNumber numberWithInt:irating];
    switch (irating & 2) {
        case 0:
            [redButton setImage:[UIImage imageNamed:@"outlinestar.png"] forState:UIControlStateNormal];
            break;
        case 2:
            [redButton setImage:[UIImage imageNamed:@"redstar.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}



#pragma mark -
#pragma mark Audio

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"Finished Recording.");
    [self.recordButton setTitle:@"Play" forState:UIControlStateNormal];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"Error %@",[error localizedDescription]);
}


- (IBAction)record:(id)sender {
    
    //NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:kA, AVEncoderAudioQualityKey, nil];
    //AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:fileName settings:settings error:&error];
    NSError *outError = nil;
    
    NSDictionary *settings =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithInt:AVAudioQualityMin],AVEncoderAudioQualityKey,
     [NSNumber numberWithInt:16],AVEncoderBitRateKey,
     [NSNumber numberWithInt: 1],AVNumberOfChannelsKey,
     [NSNumber numberWithFloat:44100.0],AVSampleRateKey,nil];
    
    UIButton *b = sender;
    
    if ([b.titleLabel.text isEqualToString:@"Record"]) {
        recordingURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"recording.caf"];
        
        recorder = [[AVAudioRecorder alloc] initWithURL:recordingURL settings:settings error:&outError];
        [recorder setDelegate:self];
        [recorder prepareToRecord];
        [recorder record];
        [b setTitle:@"Stop" forState:UIControlStateNormal];
        
    } else if ([b.titleLabel.text isEqualToString:@"Stop"]) {
        [b setTitle:@"Play" forState:UIControlStateNormal];
        [self.deleteButton setHidden:NO];
        [recorder stop];
        [player stop];
    } else if ([b.titleLabel.text isEqualToString:@"Play"]) {
        if (self.note.recording) {
            player = [[AVAudioPlayer alloc] initWithData:self.note.recording error:&outError];
        } else {
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:recordingURL error:&outError];
        }
        [player setDelegate:self];
        AVAudioSession *session = [AVAudioSession sharedInstance];
        
        NSError *setCategoryError = nil;
        if (![session setCategory:AVAudioSessionCategoryPlayAndRecord
                      withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                            error:&setCategoryError]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"AVAudio Error" message:[setCategoryError localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        [player prepareToPlay];
        [player play];
        [b setTitle:@"Stop" forState:UIControlStateNormal];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"Finished Playing.");
    [self.recordButton setTitle:@"Play" forState:UIControlStateNormal];
    
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"Error %@",[error localizedDescription]);
    [self.recordButton setTitle:@"Play" forState:UIControlStateNormal];
    
}
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    NSLog(@"finished recording to file");
    [self.recordButton setTitle:@"Play" forState:UIControlStateNormal];
    
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    NSLog(@"Started recording to file");
    [self.recordButton setTitle:@"Stop" forState:UIControlStateNormal];
    
}


- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



- (IBAction)deleteRecording:(id)sender {
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:[recordingURL path] error:&error];
    [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
    if (self.note.recording) {
        [context deleteObject:self.note.recording];
        self.note.recording = nil;
    }
    [self.deleteButton setHidden:YES];
}

@end
