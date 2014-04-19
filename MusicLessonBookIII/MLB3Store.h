//
//  MLB3Store.h
//  Music Lesson Book III
//
//  Created by Michael Toth on 3/1/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLB3AppDelegate.h"
#import "MLB3Store.h"
#import "Piece.h"
#import "Note.h"
#import "Lesson.h"
#import "Student.h"
#import <DropboxSDK/DropboxSDK.h>
#import "MLB3PieceChannel.h"

@interface MLB3Store : NSObject <DBRestClientDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSXMLParserDelegate> {
    
    NSMutableArray *allPieces;
    NSManagedObjectContext *context;
    NSMutableArray *allOfDropBoxFiles;
    NSMutableData *xmlData;
    NSURLConnection *connection;
    MLB3PieceChannel *channel;
}
+ (MLB3Store *)sharedStore;

- (NSArray *)allPiecesFromDatabase;
- (Piece *)createPiece;
- (void)removePiece:(Piece *)piece;

- (Note *)createNote;
- (void)removeNote:(Note *)note;

- (Lesson *)createLesson;
- (void)removeLesson:(Lesson *)lesson;

- (void)loadAllPiecesFromDropBox;

- (NSArray *)allLessonsForStudent:(Student *)student;

@property (strong, nonatomic) NSMutableArray *dropboxFiles;
@property (strong, nonatomic) NSMutableArray *gtmPieces;
@property (strong, nonatomic) DBRestClient *restClient;
@end
