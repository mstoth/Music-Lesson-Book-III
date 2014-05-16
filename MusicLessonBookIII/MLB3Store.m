//
//  MLB3Store.m
//  Music Lesson Book III
//
//  Created by Michael Toth on 3/1/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import "MLB3Store.h"
#import "MLB3PieceDetailViewController.h"
#import "MLB3PieceChannel.h"

NSString * const MLB3DropBoxPathPrefKey = @"MLB3DropBoxPathPrefKey";

@implementation MLB3Store
@synthesize gtmPieces;
@synthesize autoCompletePiece = _autoCompletePiece;
@synthesize autoCompletePieceChannel = _autoCompletePieceChannel;

+ (MLB3Store *)sharedStore {
    static MLB3Store *sharedStore = nil;
    
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    
    }
    return sharedStore;
}

- (instancetype)init {
    NSError *error = nil;
    self = [super init];
    if (self) {
        _autoCompletePiece = nil;
        _autoCompletePieceChannel = nil;
        allPieces = [[NSMutableArray alloc] init];
        gtmPieces = [[NSMutableArray alloc] init];
        MLB3AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        context = delegate.managedObjectContext;
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Piece"];
        
        [request setSortDescriptors:@[sortDescriptor]];
        
        allPieces = [[context executeFetchRequest:request error:&error]mutableCopy];
        
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        }
        
        allOfDropBoxFiles = [[NSMutableArray alloc] init];
        gtmPieces = [[NSMutableArray alloc] init];
        
        NSURLRequest *urlRequest;
        NSURL *url = [NSURL URLWithString:@"http://secure-sierra-9006.herokuapp.com/pieces.xml"];
        urlRequest = [NSURLRequest requestWithURL:url];
        //connection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
        xmlData = [[NSMutableData alloc] init];
        connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];

    }
    
    DBSession* dbSession =
    [[DBSession alloc]
     initWithAppKey:@"mqrf94btlab7daa"
     appSecret:@"bfsgvafe28kedjl"
     root:kDBRootDropbox];// either kDBRootAppFolder or kDBRootDropbox;
    [DBSession setSharedSession:dbSession];

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootViewController = window.rootViewController;
    
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:rootViewController];
    }

    return self;
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
    connection = nil;
    xmlData = nil;
    NSString *errorString = [NSString stringWithFormat:@"Fetch Failed: %@", [error localizedDescription]];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [xmlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    [parser setDelegate:self];
    [parser parse];
    xmlData = nil;
    connection = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GTMFilesDownloaded" object:self];
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqual:@"piece"]) {
        channel = [[MLB3PieceChannel alloc] init];
        [channel setParentParserDelegate:self];
        [parser setDelegate:channel];
        [gtmPieces addObject:channel];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqual:@"pieces"]) {
        
    }
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {

    return [self sharedStore];
}

- (NSArray *)allPiecesFromDatabase {
    NSError *error = nil;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Piece"];
    [request setSortDescriptors:@[sortDescriptor]];

    NSArray *pieces = [context executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }
    return pieces;
}

- (void)loadAllPiecesFromDropBox {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *path = [defaults objectForKey:MLB3DropBoxPathPrefKey];
    if (path) {
        [[self restClient] loadMetadata:path];
    } else {
        [[self restClient] loadMetadata:@"/"];
    }
}

- (Piece *)createPiece {
    Piece *newPiece = (Piece *)[NSEntityDescription insertNewObjectForEntityForName:@"Piece" inManagedObjectContext:context];
    newPiece.title = @"New Piece";
    return newPiece;
}

- (void)removePiece:(Piece *)piece {
    [context deleteObject:piece];
}

- (Note *)createNote {
    Note *newNote = (Note *)[NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
    newNote.body = @"";
    return newNote;
}

- (void)removeNote:(Note *)note {
    [context deleteObject:note];
}

- (Lesson *)createLesson {
    Lesson *newLesson = (Lesson *)[NSEntityDescription insertNewObjectForEntityForName:@"Lesson" inManagedObjectContext:context];
    newLesson.date = [NSDate date];
    return newLesson;
}

- (void)removeLesson:(Lesson *)lesson {
    [context deleteObject:lesson];
}

- (NSArray *)dropBoxFiles {
    return self.allPiecesFromDatabase;
}

#pragma mark -
#pragma mark Rest Client Routines

- (DBRestClient *)restClient {
    if (!_restClient) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    //NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    [allOfDropBoxFiles removeAllObjects];
    if (metadata.isDirectory) {
        self.dropboxFiles = [metadata.contents mutableCopy];
        NSMutableArray *toRemove = [[NSMutableArray alloc] init];
        for (DBMetadata *file in self.dropboxFiles) {
            NSArray * rslt = [file.filename componentsSeparatedByString:@"."];
            if ([rslt count] < 2 ) {
                [toRemove addObject:file];
            } else {
                if (![[rslt lastObject] isEqualToString:@"pdf"]) {
                    [toRemove addObject:file];
                }
            }
        }
        for (DBMetadata *file in toRemove) {
            [self.dropboxFiles removeObject:file];
        }
    }
    [self.dropboxFiles removeAllObjects];
    for (DBMetadata *file in [metadata contents]) {
        [self.dropboxFiles addObject:file.filename];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DropBoxFilesDownloaded" object:self];
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Dropbox Error" message:[NSString stringWithFormat:@"There was an error in accessing your drop box. The error is %@",[error.userInfo valueForKey:@"error"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [av show];
    self.dropboxFiles = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DropBoxFilesFailed" object:self];

}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
    //NSLog(@"File loaded into path: %@", localPath);
    //    self.url = localPath;
    //    self.titleTextView.text = [[localPath lastPathComponent] stringByDeletingPathExtension];
    //    self.urlLabel.text = [localPath lastPathComponent];
    //    self.composerTextView.text = @"";
    //    self.difficultyTextField.text = @"";
    //    self.genreTextView.text = @"";
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    //NSLog(@"There was an error loading the file - %@", error);
    //self.url = @"";
}

- (NSArray *)allLessonsForStudent:(Student *)student {
    return [[[student lessons] allObjects] sortedArrayUsingComparator:^NSComparisonResult(Lesson *obj1, Lesson *obj2) {
        return [obj1.date compare:obj2.date];
    }];
    
}

- (void)autoCompleteTextFieldDidAutoComplete:(MLB3AutocompleteTextField *)autoCompleteField {
    NSLog(@"In autoCompleteTextFieldDidAutoComplete, autoCompleteField is %@", autoCompleteField);
}


- (void)autocompleteTextField:(MLB3AutocompleteTextField *)autocompleteTextField didChangeAutocompleteText:(NSString *)autocompleteText {
    NSLog(@"In autocompleteTextField, autocompleteText is %@",autocompleteText);
}


- (NSString*)textField:(MLB3AutocompleteTextField*)textField
   completionForPrefix:(NSString*)prefix
            ignoreCase:(BOOL)ignoreCase {
    NSMutableArray *combinedPieces;
    
//    if ([textField.text isEqualToString:prefix]) {
//        return @"";
//    }
    
    if ([prefix length] == 0) {
        return prefix;
    }
    
    combinedPieces = [[NSMutableArray alloc] init];
    
    [combinedPieces addObjectsFromArray:allPieces];
    [combinedPieces addObjectsFromArray:gtmPieces];
    [combinedPieces addObjectsFromArray:allOfDropBoxFiles];
    
    if ([combinedPieces count] > 0) {
        for (id p in combinedPieces) {
            if ([p isKindOfClass:[NSString class]]) {
                if ([prefix length] <= [p length]) {
                    NSString *subString = [p substringWithRange:NSRangeFromString([NSString stringWithFormat:@"0 %d",[prefix length]])];
                    if ([subString isEqualToString:prefix]) {
                        return [p substringFromIndex:[prefix length]];
                    }
                }
            }
            if ([p isKindOfClass:[MLB3PieceChannel class]]) {
                MLB3PieceChannel *pt = p;
                if ([prefix length] <= [pt.title length]) {
                    NSString *subString = [pt.title substringToIndex:[prefix length]];
                    if ([subString isEqualToString:prefix]) {
                        _autoCompletePieceChannel = pt;
                        return [pt.title substringFromIndex:[prefix length]];
                    }
                }
            }
            if ([p isKindOfClass:[Piece class]]) {
                Piece *pt = p;
                if ([prefix length] <= [pt.title length]) {
                    NSString *subString = [pt.title substringWithRange:NSRangeFromString([NSString stringWithFormat:@"0 %d",[prefix length]])];
                    if ([subString isEqualToString:prefix]) {
                        _autoCompletePiece = pt;
                        return [pt.title substringFromIndex:[prefix length]];
                    }
                }
            }
        }
    }
    return @"";
}


@end
