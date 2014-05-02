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

@interface MLB3PieceDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
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
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.titleTextField setDelegate:self];
    [self.composerTextField setDelegate:self];
    [self.difficultyTextField setDelegate:self];
    [self.genreTextField setDelegate:self];
    
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
            self.difficultyTextField.text = [self.piece.difficulty stringValue];
        }
    }
    piecesForTable = [[[MLB3Store sharedStore] allPiecesFromDatabase] mutableCopy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropBoxFilesReady:) name:@"DropBoxFilesDownloaded" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GTMFilesReady:) name:@"GTMFilesDownloaded" object:nil];
    
	// Do any additional setup after loading the view.
}

- (void)dealloc {
    [[NSNotificationCenter  defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    piecesForTable = [[[MLB3Store sharedStore] allPiecesFromDatabase] mutableCopy];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropBoxFilesReady:) name:@"DropBoxFilesDownloaded" object:nil];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)save:(UIButton *)sender {
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Piece"];

    MLB3AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@ AND composer = %@",self.titleTextField.text, self.composerTextField.text];
    [request setPredicate:predicate];
    NSArray *result = [context executeFetchRequest:request error:&error];
    if ([result count] > 1) {
        [context deleteObject:self.piece];
        self.piece = [result firstObject];
    }
    
    self.piece.title = self.titleTextField.text;
    self.piece.composer = self.composerTextField.text;
    self.piece.genre = self.genreTextField.text;
    self.piece.difficulty = [NSNumber numberWithInt:[self.difficultyTextField.text intValue]];
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
    return [piecesForTable count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Piece *selectedPiece;
    NSString *selectedTitle;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PieceCell"];
    
    switch (self.sourceSegmentedControl.selectedSegmentIndex) {
        case 0:
            selectedPiece = [piecesForTable objectAtIndex:[indexPath row]];
            cell.textLabel.text = selectedPiece.title;
            cell.detailTextLabel.text = selectedPiece.composer;
            return cell;
            break;
        case 1:
            selectedTitle = [piecesForTable objectAtIndex:[indexPath row]];
            cell.textLabel.text = selectedTitle;
            return cell;
            break;
        case 2:
        {
            MLB3PieceChannel *pc = [piecesForTable objectAtIndex:[indexPath row]];
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
        [[MLB3Store sharedStore] removePiece:[piecesForTable objectAtIndex:[indexPath row]]];
        [piecesForTable removeObject:[piecesForTable objectAtIndex:[indexPath row]]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Piece *selectedPiece;
    NSString *selectedTitle;
    
    switch (self.sourceSegmentedControl.selectedSegmentIndex) {
        case 0: {
            selectedPiece = [piecesForTable objectAtIndex:[indexPath row]];
            self.titleTextField.text = selectedPiece.title;
            self.composerTextField.text = selectedPiece.composer;
            self.genreTextField.text = selectedPiece.genre;
            self.difficultyTextField.text = [selectedPiece.difficulty stringValue];
            [self.titleTextField setNeedsDisplay];
            [self.composerTextField setNeedsDisplay];
            [self.genreTextField setNeedsDisplay];
            [self.difficultyTextField setNeedsDisplay];
            break;
        }
        case 1: {
            selectedTitle = [piecesForTable objectAtIndex:[indexPath row]];
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
            MLB3PieceChannel *pc = [piecesForTable objectAtIndex:[indexPath row]];
            self.titleTextField.text = [pc title];
            self.composerTextField.text = [pc composer];
        }
        default:
            break;
    }
}

- (IBAction)changeSource:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        // local database
        piecesForTable = [[[MLB3Store sharedStore] allPiecesFromDatabase] mutableCopy];
        [self.tableView reloadData];
    }
    if (sender.selectedSegmentIndex == 1) {
        // drop box
        [[MLB3Store sharedStore] loadAllPiecesFromDropBox];
    }
    if (sender.selectedSegmentIndex == 2) {
        // good teaching music
        piecesForTable = [[MLB3Store sharedStore] gtmPieces];
        NSMutableArray *newPiecesForTable = [[NSMutableArray alloc] init];
        for (MLB3PieceChannel *pc in piecesForTable) {
            if ([[pc instrument] isEqual:@"Piano"]) {
                [newPiecesForTable addObject:pc];
            }
        }
        piecesForTable = newPiecesForTable;

        [self.tableView reloadData];
    }
}

- (void)dropBoxFilesReady:(NSNotification *)note {
    piecesForTable = [[MLB3Store sharedStore] dropboxFiles];
    [self.tableView reloadData];
}

- (void)GTMFilesReady:(NSNotification *)note {
    if ([self.sourceSegmentedControl selectedSegmentIndex] == 2) {
        piecesForTable = [[MLB3Store sharedStore] gtmPieces];
        
        NSMutableArray *newPiecesForTable = [[NSMutableArray alloc] init];
        for (MLB3PieceChannel *pc in piecesForTable) {
            if ([[pc instrument] isEqual:@"Piano"]) {
                [newPiecesForTable addObject:pc];
            }
        }
        piecesForTable = [[newPiecesForTable sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            MLB3PieceChannel *pc1 = obj1;
            MLB3PieceChannel *pc2 = obj2;
            return [[pc1 title] compare:[pc2 title]];
        }] mutableCopy];
    }
    [self.tableView reloadData];
}


@end
