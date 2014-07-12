//
//  MLB3NoteViewController.h
//  Music Lesson Book III
//
//  Created by Michael Toth on 2/23/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "Note.h"

@interface MLB3NoteViewController : UIViewController <UIGestureRecognizerDelegate,AVAudioSessionDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate> {
    NSManagedObjectContext *context;
    AVAudioPlayer *player;
    AVAudioRecorder *recorder;
    NSURL *recordingURL;

}
- (IBAction)record:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) Note *note;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
- (IBAction)deleteRecording:(id)sender;
@property (strong, nonatomic) Note *lastWeekNote;
- (IBAction)save:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *lastLessonTextView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) NSString *titleString;
- (IBAction)removeKeyboard:(id)sender;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *gestureRecognizer;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
- (IBAction)toggleGreen:(id)sender;
- (IBAction)toggleGold:(id)sender;
- (IBAction)toggleRed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *goldStar;
@property (weak, nonatomic) IBOutlet UIButton *redStar;
@property (weak, nonatomic) IBOutlet UIButton *greenStar;

@end
