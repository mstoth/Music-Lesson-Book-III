//
//  MLB3LessonDetailViewController.h
//  Music Lesson Book III
//
//  Created by Michael Toth on 2/6/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Student.h"
#import "Lesson.h"
#import "MLB3Store.h"

#define kMaxBPM 190
#define kMinBPM 40
#define kDefaultBPM 80

@interface MLB3LessonDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,MFMailComposeViewControllerDelegate,AVCaptureFileOutputRecordingDelegate> {
    NSMutableDictionary *notes;
    NSManagedObjectContext *context;
    BOOL metronomeOn;
    NSThread *myThread;
    CGFloat duration;

}
- (IBAction)record:(id)sender;
- (IBAction)emailLesson:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *metronomeTextField;
@property (nonatomic, retain) IBOutlet UIButton *metronomeButton;
- (IBAction)toggleMetronome:(id)sender;
@property (nonatomic, retain) AVAudioPlayer *tickPlayer;
- (IBAction)copyPreviousLesson:(id)sender;
@property (strong, nonatomic) NSMutableArray *pieces;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *pieceTableView;
@property (strong, nonatomic) Lesson *lesson;
@property (weak, nonatomic) Lesson *lastLesson;
@property (nonatomic, retain) UINavigationController *navController;
- (IBAction)jumpToTempo:(id)sender;
- (void) addPieceWithNavigationalController:(UINavigationController *)controller;
@end
