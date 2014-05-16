//
//  MLB3PieceChannel.h
//  MusicLessonBookIII
//
//  Created by Michael Toth on 4/18/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Piece.h"

@interface MLB3PieceChannel : NSObject <NSXMLParserDelegate> {
    NSMutableString *currentString;
    Piece *currentPiece;
}
@property (nonatomic, weak) id parentParserDelegate;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *composer;
@property (nonatomic, strong) NSString *instrument;
@property (nonatomic, strong) NSString *genre;
@property (nonatomic, strong) NSString *difficulty;
@property (nonatomic, strong) NSMutableArray *pieces;
@end
