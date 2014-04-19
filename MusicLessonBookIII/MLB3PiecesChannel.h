//
//  MLB3PiecesChannel.h
//  MusicLessonBookIII
//
//  Created by Michael Toth on 4/18/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLB3PiecesChannel : NSObject <NSXMLParserDelegate> {
    NSMutableString *currentString;
}

@property (nonatomic, weak) id parentParserDelegate;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *composer;
@property (nonatomic, readonly, strong) NSMutableArray *pieces;
@property (nonatomic, strong) NSString *instrument; 
@end
