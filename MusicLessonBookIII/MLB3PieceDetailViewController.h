//
//  MLB3PieceDetailViewController.h
//  Music Lesson Book III
//
//  Created by Michael Toth on 2/6/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLB3NoteViewController.h"
#import "Piece.h"
#import "MLB3PieceChannel.h"
#import <AVFoundation/AVFoundation.h>
@class MLB3PiecesChannel;

@interface MLB3PieceDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, NSXMLParserDelegate, UITextFieldDelegate, UIDocumentInteractionControllerDelegate, UIAlertViewDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate,  AVAudioSessionDelegate> {
    //NSMutableArray *piecesForTable;
    MLB3PiecesChannel *channel;
    NSString *selectedPath;
    UITapGestureRecognizer *tapper;
    BOOL autocomplete;
    UIDocumentInteractionController *docController;
}
@property (weak, nonatomic) Lesson *lesson;
@property (weak, nonatomic) IBOutlet UIButton *viewButton;
@property (weak, nonatomic) IBOutlet UIButton *autoCompleteButton;
- (IBAction)toggleAutocomplete:(id)sender;
- (IBAction)changeSource:(UISegmentedControl *)sender;
- (IBAction)viewPDF:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Piece *piece;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sourceSegmentedControl;
- (void) updateOtherTextFields;
@end
