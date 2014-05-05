//
//  Note.h
//  MusicLessonBookIII
//
//  Created by Michael Toth on 5/4/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Lesson, Piece;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) Lesson *lesson;
@property (nonatomic, retain) Piece *piece;

@end
