//
//  Lesson.h
//  MusicLessonBookIII
//
//  Created by Michael Toth on 4/7/14.
//  Copyright (c) 2014 Michael Toth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Student;

@interface Lesson : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) Student *student;
@property (nonatomic, retain) NSSet *notes;
@property (nonatomic, retain) NSSet *pieces;
@end

@interface Lesson (CoreDataGeneratedAccessors)

- (void)addNotesObject:(NSManagedObject *)value;
- (void)removeNotesObject:(NSManagedObject *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

- (void)addPiecesObject:(NSManagedObject *)value;
- (void)removePiecesObject:(NSManagedObject *)value;
- (void)addPieces:(NSSet *)values;
- (void)removePieces:(NSSet *)values;

@end
