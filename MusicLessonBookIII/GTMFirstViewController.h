//
//  GTMFirstViewController.h
//  Good Teaching Music
//
//  Created by Michael Toth on 3/12/13.
//  Copyright (c) 2013 Michael Toth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMPieceList.h"
#import "XMLReader.h"
#import "constants.h"

@interface GTMFirstViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource,UITableViewDataSource, UITableViewDelegate> {
    GTMPieceList *pieceList;
    NSMutableArray *instrumentList, *genreList, *difficultyList, *sortByList;
    NSDictionary *allPieces;
    NSMutableArray *pieceListForTable;
    NSMutableArray *titles, *genres, *difficulties, *composers, *instruments, *urls;
}
// @property (weak, nonatomic) IBOutlet UITableView *pieceTable;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *piecePicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *difficultyControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortByControl;
- (IBAction)changeDifficulty:(id)sender;
- (IBAction)changeSortBy:(id)sender;
@property (nonatomic, retain) NSMutableArray *pieceArray;
@end
