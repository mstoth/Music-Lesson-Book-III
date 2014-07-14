//
//  MLB3PieceDetailViewController.m
//  Music Lesson Book III
//
//  Created by Michael Toth on 2/6/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import "MLB3PieceDetailViewController.h"
#import "MLB3AppDelegate.h"
#import "MLB3Store.h"
#import "MLB3PiecesChannel.h"
#import "MLB3AutocompleteTextField.h"

@interface MLB3PieceDetailViewController ()
@property (weak, nonatomic) IBOutlet MLB3AutocompleteTextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *composerTextField;
@property (weak, nonatomic) IBOutlet UITextField *genreTextField;
@property (weak, nonatomic) IBOutlet UITextField *difficultyTextField;
- (IBAction)save:(UIButton *)sender;

@end

@implementation MLB3PieceDetailViewController



- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    NSLog(@"%@ found a %@ element", self, elementName);
    if ([elementName isEqual:@"piece"]) {
        channel = [[MLB3PiecesChannel alloc] init];
        [channel setParentParserDelegate:self];
        [parser setDelegate:channel];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedPath = nil;
    autocomplete = YES;
    [self.viewButton setHidden:YES];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    MLB3Store *sharedStore = [MLB3Store sharedStore];
    [self.titleTextField setAutocompleteDataSource:sharedStore];
    [self.titleTextField setAutoCompleteTextFieldDelegate:sharedStore];
    [self.titleTextField setDelegate:self];
    //[self.titleTextField setClearsOnBeginEditing:YES];
    [self.titleTextField setIgnoreCase:YES];
    [self.composerTextField setDelegate:self];
    [self.difficultyTextField setDelegate:self];
    [self.genreTextField setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOtherTextFields) name:@"MLB3AutocompleteTextFieldCommitted" object:nil];
    
    if (self.piece) {
        if (self.piece.title) {
            self.titleTextField.text = self.piece.title;
        }
        if (self.piece.composer) {
            self.composerTextField.text = self.piece.composer;
        }
        if (self.piece.genre) {
            self.genreTextField.text = self.piece.genre;
        }
        if (self.piece.difficulty) {
            self.difficultyTextField.text = self.piece.difficulty;
        }
    }
    //piecesForTable = [[[MLB3Store sharedStore] allPiecesFromDatabase] mutableCopy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropBoxFilesReady:) name:@"DropBoxFilesDownloaded" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GTMFilesReady:) name:@"GTMFilesDownloaded" object:nil];
    
	// Do any additional setup after loading the view.
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];

}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    
    [self.view endEditing:YES];
}


- (void)dealloc {
    [[NSNotificationCenter  defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    //piecesForTable = [[[MLB3Store sharedStore] allPiecesFromDatabase] mutableCopy];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropBoxFileLoaded:) name:@"DropBoxFileLoaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropBoxFilesReady:) name:@"DropBoxFilesDownloaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropBoxFilesFailed:) name:@"DropBoxFilesFailed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropBoxFileFailed:) name:@"DropBoxFileFailed" object:nil];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)save:(UIButton *)sender {
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Piece"];

    MLB3AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@ AND composer = %@",self.titleTextField.text, self.composerTextField.text];
    [request setPredicate:predicate];
    NSArray *result = [context executeFetchRequest:request error:&error];
    if ([result count] == 1) {
        [context deleteObject:self.piece];
        self.piece = [result firstObject];
        [self.lesson addPiecesObject:self.piece];
    }
    
    self.piece.title = self.titleTextField.text;
    self.piece.composer = self.composerTextField.text;
    self.piece.genre = self.genreTextField.text;
    self.piece.difficulty = self.difficultyTextField.text;
    self.piece.path = selectedPath;
    
    [context save:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLayoutSubviews {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGRect frame = self.tableView.frame;
        frame.size.width *= 2.0;
        self.tableView.frame = frame;
    }
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch ([self.sourceSegmentedControl selectedSegmentIndex]) {
        case 0:
            return [[[MLB3Store sharedStore] allPiecesFromDatabase] count];
            break;
        case 1:
            if ([[MLB3Store sharedStore] dropboxFiles] == nil) {
                return 0;
            } else {
                return [[[MLB3Store sharedStore] dropboxFiles] count];
            }
            break;
        case 2:
            if ([[MLB3Store sharedStore] gtmPieces] == nil) {
                return 0;
            } else {
                return [[[MLB3Store sharedStore] gtmPieces] count];
            }
            break;
        default:
            break;
    }
    return 0;
    //return [piecesForTable count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Piece *selectedPiece;
    //NSString *selectedTitle;
    DBMetadata *md;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PieceCell"];
    
    switch (self.sourceSegmentedControl.selectedSegmentIndex) {
        case 0:
            selectedPiece = [[[MLB3Store sharedStore] allPiecesFromDatabase] objectAtIndex:[indexPath row]];
            cell.textLabel.text = selectedPiece.title;
            cell.detailTextLabel.text = selectedPiece.composer;
            return cell;
            break;
        case 1:
            md = [[[MLB3Store sharedStore] dropboxFiles] objectAtIndex:[indexPath row]];
            cell.textLabel.text = [[md path] lastPathComponent];
            cell.detailTextLabel.text = @"";
            return cell;
            break;
        case 2:
        {
            MLB3PieceChannel *pc = [[[MLB3Store sharedStore] gtmPieces] objectAtIndex:[indexPath row]];
            cell.textLabel.text = [pc title];
            cell.detailTextLabel.text = [pc composer];
        }
        default:
            break;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[MLB3Store sharedStore] removePiece:[[[MLB3Store sharedStore] allPiecesFromDatabase] objectAtIndex:[indexPath row]]];
//        [piecesForTable removeObject:[[MLB3Store sharedStore] allPiecesFromDatabase objectAtIndex:[indexPath row]]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Piece *selectedPiece;
    NSString *selectedTitle;
    
    switch (self.sourceSegmentedControl.selectedSegmentIndex) {
        case 0: { // local database
            selectedPiece = [[[MLB3Store sharedStore] allPiecesFromDatabase] objectAtIndex:[indexPath row]];
            self.titleTextField.text = selectedPiece.title;
            self.composerTextField.text = selectedPiece.composer;
            self.genreTextField.text = selectedPiece.genre;
            self.difficultyTextField.text = selectedPiece.difficulty ;
            selectedPath = selectedPiece.path;
            if (selectedPath) {
                [self.viewButton setHidden:NO];
            } else {
                [self.viewButton setHidden:YES];
            }
            [self.titleTextField setNeedsDisplay];
            [self.composerTextField setNeedsDisplay];
            [self.genreTextField setNeedsDisplay];
            [self.difficultyTextField setNeedsDisplay];
            break;
        }
        case 1: { // drop box
            DBMetadata *md = [[[MLB3Store sharedStore] dropboxFiles] objectAtIndex:[indexPath row]];
            selectedPath = [md path];
            selectedTitle = [[md path] lastPathComponent];
            NSArray *components = [selectedTitle componentsSeparatedByString:@"by" ];
            if ([components count]==1) {
                NSArray *subComponents = [[components objectAtIndex:0] componentsSeparatedByString:@"."];
                if ([subComponents count]>2) {
                    NSString *fileNameWithPeriods = [subComponents objectAtIndex:0];
                    for (int i=1; i<[subComponents count]-1; i++) {
                        fileNameWithPeriods = [fileNameWithPeriods stringByAppendingString:@"."];
                        fileNameWithPeriods = [fileNameWithPeriods stringByAppendingString:[subComponents objectAtIndex:i]];
                    }
                    self.titleTextField.text = fileNameWithPeriods;
                    self.composerTextField.text = @"";
                } else {
                    self.titleTextField.text = [[subComponents objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    self.composerTextField.text =  @"";
                }
            } else {
                self.titleTextField.text = [[components objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSArray *subComponents = [[components objectAtIndex:1] componentsSeparatedByString:@"."];
                self.composerTextField.text = [[subComponents objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            break;
        }
        case  2:
        {
            MLB3PieceChannel *pc = [[[MLB3Store sharedStore] gtmPieces] objectAtIndex:[indexPath row]];
            self.titleTextField.text = [pc title];
            self.composerTextField.text = [pc composer];
            self.genreTextField.text = [pc genre];
            self.difficultyTextField.text = [pc difficulty];
        }
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            return;
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MLB3DropboxPrefKey"];
            [[MLB3Store sharedStore] initDropbox];
            break;
        case 2:
            return;
            break;
        default:
            break;
    }
}
- (IBAction)toggleAutocomplete:(id)sender {
    if (autocomplete) {
        [self.autoCompleteButton setTitle:@"Turn On" forState:UIControlStateNormal];
        autocomplete = NO;
        [self.titleTextField setAutocompleteDataSource:nil];
        [self.titleTextField setAutoCompleteTextFieldDelegate:nil];
    } else {
        autocomplete = YES;
        [self.autoCompleteButton setTitle:@"Turn Off" forState:UIControlStateNormal];
        [self.titleTextField setAutocompleteDataSource:[MLB3Store sharedStore]];
        [self.titleTextField setAutoCompleteTextFieldDelegate:[MLB3Store sharedStore]];
    }
}

- (IBAction)changeSource:(UISegmentedControl *)sender {
    
    switch ([self.sourceSegmentedControl selectedSegmentIndex]) {
        case 0:
            [self.tableView reloadData];
            [self.viewButton setHidden:YES];
            break;
        case 1: {
            BOOL db = [[NSUserDefaults standardUserDefaults] boolForKey:@"MLB3DropboxPrefKey"];
            
            
            if (!db) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Dropbox is off" message:@"The Dropbox option is turned off. Do you want to turn it on?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",@"No",nil];
                [av show];
                [self.sourceSegmentedControl setSelectedSegmentIndex:0];
            } else {
                // [[MLB3Store sharedStore] initDropbox];
                [[MLB3Store sharedStore] loadAllPiecesFromDropBox];
                [self.tableView reloadData];
                [self.viewButton setHidden:NO];
            }
            break;
        }
        case 2:
            [self.tableView reloadData];
            [self.viewButton setHidden:YES];
            break;
            
        default:
            break;
    }
    
//    if (sender.selectedSegmentIndex == 0) {
//        // local database
//        //piecesForTable = [[[MLB3Store sharedStore] allPiecesFromDatabase] mutableCopy];
//        [self.tableView reloadData];
//    }
//    if (sender.selectedSegmentIndex == 1) {
//        // drop box
//        //[[MLB3Store sharedStore] loadAllPiecesFromDropBox];
//        
//    }
//    if (sender.selectedSegmentIndex == 2) {
//        // good teaching music
//        piecesForTable = [[MLB3Store sharedStore] gtmPieces];
//        NSMutableArray *newPiecesForTable = [[NSMutableArray alloc] init];
//        for (MLB3PieceChannel *pc in piecesForTable) {
//            if ([[pc instrument] isEqual:@"Piano"]) {
//                [newPiecesForTable addObject:pc];
//            }
//        }
//        piecesForTable = newPiecesForTable;
//
//        [self.tableView reloadData];
//    }
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (IBAction)viewPDF:(id)sender {
    NSIndexPath *ip = [self.tableView indexPathForSelectedRow];
    if (ip == nil) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Piece Selected" message:@"Please select a piece." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    } else {
//        NSMutableArray *dbf = [[MLB3Store sharedStore] dropboxFiles];
//        if (dbf == nil) {
//            <#statements#>
//        }
//        DBMetadata *md = [dbf objectAtIndex:[ip row]];
//        NSString *path = [md path];
        [[MLB3Store sharedStore] viewPDF:selectedPath];
    }
}

- (void)dropBoxFilesReady:(NSNotification *)note {
    //piecesForTable = [[MLB3Store sharedStore] dropboxFiles];
    [self.tableView reloadData];
}

- (void)dropBoxFileLoaded:(NSNotification *)note {
    //piecesForTable = [[MLB3Store sharedStore] dropboxFiles];
    NSString *localPath = [note.userInfo valueForKey:@"localPath"];
    NSURL *localURL = [NSURL fileURLWithPath:localPath];
    docController = [self setupControllerWithURL:localURL usingDelegate:self];
    [docController presentPreviewAnimated:YES];
}

- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller {
    
    NSError *error = nil;
    BOOL removed;
    NSString *destPath = [NSString stringWithFormat:@"%@/%@",[[self applicationDocumentsDirectory] path], [selectedPath lastPathComponent]];

    removed = [[NSFileManager defaultManager] removeItemAtPath:destPath error:&error];
    if (!removed) {
        NSLog(@"Error removing file.");
    }
}


- (void)dropBoxFilesFailed:(NSNotification *)note {
    [self.sourceSegmentedControl setSelectedSegmentIndex:0];
    [self changeSource:self.sourceSegmentedControl];
}

- (void)dropBoxFileFailed:(NSNotification *)note {
    [self.sourceSegmentedControl setSelectedSegmentIndex:0];
    [self changeSource:self.sourceSegmentedControl];
}

- (void)GTMFilesReady:(NSNotification *)note {
    if ([self.sourceSegmentedControl selectedSegmentIndex] == 2) {
        //piecesForTable = [[MLB3Store sharedStore] gtmPieces];
        
        //        NSMutableArray *newPiecesForTable = [[NSMutableArray alloc] init];
        //        for (MLB3PieceChannel *pc in piecesForTable) {
        //            if ([[pc instrument] isEqual:@"Piano"]) {
        //                [newPiecesForTable addObject:pc];
        //            }
        //        }
        //        piecesForTable = [[newPiecesForTable sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        //            MLB3PieceChannel *pc1 = obj1;
        //            MLB3PieceChannel *pc2 = obj2;
        //            return [[pc1 title] compare:[pc2 title]];
        //        }] mutableCopy];
        //    }
        [self.tableView reloadData];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    //[self updateOtherTextFields];
    return YES;
}

- (void)updateOtherTextFields {
    if ([[MLB3Store sharedStore] autoCompletePiece] != nil) {
        Piece *pt = [[MLB3Store sharedStore] autoCompletePiece];
        self.composerTextField.text = pt.composer;
        self.difficultyTextField.text = pt.difficulty;
        self.genreTextField.text = pt.genre;
        [[MLB3Store sharedStore] setAutoCompletePiece:nil];
    }
    if ([[MLB3Store sharedStore] autoCompletePieceChannel] != nil) {
        MLB3PieceChannel *pt = [[MLB3Store sharedStore] autoCompletePieceChannel];
        self.composerTextField.text = pt.composer;
        self.difficultyTextField.text = pt.difficulty;
        self.genreTextField.text = pt.genre;
        [[MLB3Store sharedStore] setAutoCompletePieceChannel:nil];
    }
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL *) fileURL

                                               usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    
    
    
    UIDocumentInteractionController *interactionController =
    
    [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    
    interactionController.delegate = interactionDelegate;
    
    
    
    return interactionController;
    
}




@end
