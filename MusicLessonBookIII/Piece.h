//
//  Piece.h
//  MusicLessonBookIII
//
//  Created by Michael Toth on 4/7/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Lesson, Note;

@interface Piece : NSManagedObject

@property (nonatomic, retain) NSString * composer;
@property (nonatomic, retain) NSNumber * difficulty;
@property (nonatomic, retain) NSString * genre;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *lesson;
@property (nonatomic, retain) NSSet *note;
@end

@interface Piece (CoreDataGeneratedAccessors)

- (void)addLessonObject:(Lesson *)value;
- (void)removeLessonObject:(Lesson *)value;
- (void)addLesson:(NSSet *)values;
- (void)removeLesson:(NSSet *)values;

- (void)addNoteObject:(Note *)value;
- (void)removeNoteObject:(Note *)value;
- (void)addNote:(NSSet *)values;
- (void)removeNote:(NSSet *)values;

@end
