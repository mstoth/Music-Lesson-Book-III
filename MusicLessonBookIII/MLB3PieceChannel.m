//
//  MLB3PieceChannel.m
//  MusicLessonBookIII
//
//  Created by Michael Toth on 4/18/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import "MLB3PieceChannel.h"

@implementation MLB3PieceChannel
@synthesize pieces, composer, title, genre, difficulty,  parentParserDelegate;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqual:@"piece"]) {
        currentPiece = [[Piece alloc] init];
    } else if ([elementName isEqual:@"title"]) {
        currentString = [[NSMutableString alloc] init];
        [self setTitle:currentString];
    } else if ([elementName isEqual:@"path"]) {
        currentString = [[NSMutableString alloc] init];
        [self setPath:currentString];
    } else if ([elementName isEqual:@"composer"]) {
        currentString = [[NSMutableString alloc] init];
        [self setComposer:currentString];
    } else if ([elementName isEqual:@"genre"]) {
        currentString = [[NSMutableString alloc] init];
        [self setGenre:currentString];
    } else if ([elementName isEqual:@"difficulty"]) {
        currentString = [[NSMutableString alloc] init];
        [self setDifficulty:currentString];
    } else if ([elementName isEqual:@"instrument"]) {
        currentString = [[NSMutableString alloc] init];
        [self setInstrument:currentString];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    currentString = nil;
    if ([elementName isEqual:@"piece"]) {
        [parser setDelegate:parentParserDelegate];
    }
}
@end
