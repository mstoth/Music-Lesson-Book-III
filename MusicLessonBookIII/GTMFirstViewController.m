    //
//  GTMFirstViewController.m
//  Good Teaching Music
//
//  Created by Michael Toth on 3/12/13.
//  Copyright (c) 2013 Michael Toth. All rights reserved.
//



#import "GTMFirstViewController.h"
#import "GTMPieceList.h"

@interface GTMFirstViewController ()

@end

@implementation GTMFirstViewController
@synthesize pieceArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //[self.pieceTable setDelegate:self];
    
    urls = [[NSMutableArray alloc] init];
    titles = [[NSMutableArray alloc] init];
    composers = [[NSMutableArray alloc] init];
    
    pieceList = [[GTMPieceList alloc] init];
    [self.activityIndicator startAnimating];
    self.statusLabel.text = [NSString stringWithFormat:@"Loading..."];

    pieceListForTable = [[NSMutableArray alloc] init];
    assert(pieceList != nil);
    self.pieceArray = [[NSMutableArray alloc] init];
    instrumentList = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDataChange:)
                                                 name:@"dataReceived"
                                               object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self changeMessage];
}

- (void)changeMessage {
    NSArray *messages = [NSArray arrayWithObjects:@"Add your own favorites at goodteachingmusic.com",
                         @"Don't be shy about sharing your own favorites!",
                         @"New teachers need help finding good material.",
                         @"If everyone shares one favorite this becomes very useful.",
                         @"goodteachingmusic.com",
                         @"It's all free and no log-in",
                         @"Just a way to share good music",
                         @"Keep track of your students with the Music Lesson Book app.",
                         @"Other ideas are at www.virtualpianist.com",
                         @"Check out the Music Lesson Book app.", nil];
    self.messageLabel.text = [messages objectAtIndex:arc4random() % 10];
    
}

- (void)handleDataChange:(NSNotification *)note {

    [self.pieceArray removeAllObjects];
    NSDictionary *pa = [pieceList.responseDictionary valueForKey:@"pieces"];
    //NSLog(@"pieces array is %d in size",pa.count);
    allPieces = [pa valueForKey:@"piece"];
    NSMutableArray *titlesLocal = [[allPieces valueForKey:@"title"] mutableCopy]    ;
    instruments = [allPieces valueForKey:@"instrument"];
    //NSLog(@"titles has %d items",[titles count]);
    if ([titlesLocal count] == 1) {
        [self.pieceArray addObject:[[titlesLocal valueForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    } else {
        for (NSDictionary *t in titles) {
            //NSLog(@"%@",[t description]);
        [   self.pieceArray addObject:[[t valueForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
    }
    
    [instrumentList removeAllObjects];
//    NSMutableArray *instruments = [pieces valueForKey:@"instrument"];
//    for (NSString *inst in instruments) {
//        NSLog(@"%@", [inst description]);
//        NSString *instrument = [[inst valueForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        
//        if (![instrumentList containsObject:instrument]) {
//            [instrumentList addObject:instrument];
//        }
//    }
    //genreList = [NSMutableArray arrayWithObjects:@"Pre-Baroque",@"Baroque", @"Classical", @"Romantic", @"20th Century", nil];
    genreList = kgenreList;
    
    //instrumentList = [NSMutableArray arrayWithObjects:@"Piano",@"Voice", @"Violin", @"Viola", @"Cello", @"Bass",@"Trumpet", @"Trombone",@"French Horn",@"Tuba", @"Oboe",@"English Horn",@"Bassoon", @"Flute/Piccolo", @"Percussion", nil];
    instrumentList = kinstrumentList;
    
    difficultyList = [NSMutableArray arrayWithObjects:@"Easy",@"Intermediate",@"Advanced", nil];
    sortByList = [NSMutableArray arrayWithObjects:@"title",@"composer",@"genre",@"difficulty",nil];
    
    [self.piecePicker reloadAllComponents];
    [self refreshPiecesTable];
}


- (void) refreshPiecesTable {
    
    NSString *genreChoice = [genreList objectAtIndex:[self.piecePicker selectedRowInComponent:0]];
    NSString *instrumentChoice = [instrumentList objectAtIndex:[self.piecePicker selectedRowInComponent:1]];
    NSString *difficultyChoice = [difficultyList objectAtIndex:[self.difficultyControl selectedSegmentIndex]];
    NSString *sortByChoice = [sortByList objectAtIndex:[self.sortByControl selectedSegmentIndex]];
    
    [pieceListForTable removeAllObjects];
    [urls removeAllObjects];
    [titles removeAllObjects];
    [composers removeAllObjects];

    //NSLog(@"allPieces class is %@",[allPieces class]);
    if (![allPieces isKindOfClass:[NSMutableArray class]]) {
        NSString *inst = [[allPieces valueForKey:@"instrument"] valueForKey:@"text"];
        NSString *diff = [[allPieces valueForKey:@"difficulty"] valueForKey:@"text"];
        NSString *genr = [[allPieces valueForKey:@"genre"] valueForKey:@"text"];
        
        inst = [inst stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        diff = [diff stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        genr = [genr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([inst isEqualToString:instrumentChoice] &&
            [genr isEqualToString:genreChoice] &&
            [diff isEqualToString:difficultyChoice]) {
            [pieceListForTable addObject:allPieces];
            [urls addObject:[[[allPieces valueForKey:@"recording"] valueForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            [titles addObject:[[[allPieces valueForKey:@"title"] valueForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            [composers addObject:[[[allPieces valueForKey:@"composer"] valueForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            
        }
    } else {
    for (NSDictionary *pc in allPieces) {
        
        NSString *inst = [[pc valueForKey:@"instrument"] valueForKey:@"text"];
        NSString *diff = [[pc valueForKey:@"difficulty"] valueForKey:@"text"];
        NSString *genr = [[pc valueForKey:@"genre"] valueForKey:@"text"];
        
        inst = [inst stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        diff = [diff stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        genr = [genr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([inst isEqualToString:instrumentChoice] &&
            [genr isEqualToString:genreChoice] &&
            [diff isEqualToString:difficultyChoice]) {
            [pieceListForTable addObject:pc];
        }
    }
    }
    
    
    if ([pieceListForTable count] > 1) {
        // sort an array that contains dictionaries, each of which contains a string for the key defined
        [pieceListForTable sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString* n1 = [[obj1 objectForKey:sortByChoice] objectForKey:@"text"];
            NSString* n2 = [[obj2 objectForKey:sortByChoice] objectForKey:@"text"];
            return [n1 compare:n2];
        }];
    }
    

    NSDictionary *dataDictionary = [NSDictionary dictionaryWithObject:pieceListForTable forKey:@"pieces"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"piecesUpdated" object:self userInfo:dataDictionary];
    self.statusLabel.text = [NSString stringWithFormat:@"%d Pieces",[pieceListForTable count]];
    [self.activityIndicator stopAnimating];
    //[self.pieceTable reloadData];
    [self changeMessage];
}


#pragma mark -
#pragma mark Picker View Delegate Routines

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [genreList count];
    }
    if (component == 1) {
        return [instrumentList count];
    }
    NSLog(@"Error for component number");
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return [genreList objectAtIndex:row];
    } else {
        return [instrumentList objectAtIndex:row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 1) {
        NSString *instrument = [instrumentList objectAtIndex:row];
        [pieceList reload:instrument];
    } else {
        [self refreshPiecesTable];
    }
}


- (IBAction)changeDifficulty:(id)sender {
    [self  refreshPiecesTable];
}   

- (IBAction)changeSortBy:(id)sender {
    [self refreshPiecesTable];
}


- (IBAction)closeWebView:(id)sender {
    [[self.view viewWithTag:100] removeFromSuperview];
}


#pragma mark -
#pragma mark tableView 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *selectedPiece = [pieceListForTable objectAtIndex:indexPath.row];
    NSString *urlString = [[[selectedPiece valueForKey:@"recording"] valueForKey:@"text"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    if ([url.path length] == 0) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Recording Found"
                                                          message:@"Sorry, no recording could be found on YouTube."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    } else {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        UIWebView *wv = [[UIWebView alloc] initWithFrame:self.view.frame];
        [wv setTag:100];
        [wv loadRequest:request];
        [self.view addSubview:wv];
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"Close" forState:UIControlStateNormal];
        button.frame = CGRectMake(40, 5, 160, 40);
        [button setTag:56];
        [button addTarget:self action:@selector(closeWebView:) forControlEvents:UIControlEventTouchUpInside];
        [wv addSubview:button];

    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"pieceTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *selectedPiece = [pieceListForTable objectAtIndex:indexPath.row];
    NSString *titleString = [[[selectedPiece valueForKey:@"title"] valueForKey:@"text"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *composerString = [[[selectedPiece valueForKey:@"composer"] valueForKey:@"text"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *genreString = [[[selectedPiece valueForKey:@"genre"] valueForKey:@"text"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    cell.textLabel.text = titleString;
    NSString *gstring = [NSString stringWithFormat:@" (%@)",genreString];
    cell.detailTextLabel.text = [composerString stringByAppendingString:gstring];
    
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [pieceListForTable count];
}





@end
