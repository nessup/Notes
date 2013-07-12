//
//  Note.h
//  Notes
//
//  Created by Dany on 5/23/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString *const NoteCategoryClassNotes;
extern NSString *const NoteCategoryAssignment;

@class Notebook, NotesCell, TranscriptionSegment;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSDate *dateCreated;
@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) Notebook *notebook;
@property (nonatomic, retain) NSString *topRightLines;
@property (nonatomic, retain) NSString *plainTextContent;
@property (nonatomic, retain) NSOrderedSet *transcriptionSegments;
@end

@interface Note (CoreDataGeneratedAccessors)

- (void)insertObject:(TranscriptionSegment *)value inTranscriptionSegmentsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTranscriptionSegmentsAtIndex:(NSUInteger)idx;
- (void)insertTranscriptionSegments:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTranscriptionSegmentsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTranscriptionSegmentsAtIndex:(NSUInteger)idx withObject:(TranscriptionSegment *)value;
- (void)replaceTranscriptionSegmentsAtIndexes:(NSIndexSet *)indexes withTranscriptionSegments:(NSArray *)values;
- (void)addTranscriptionSegmentsObject:(TranscriptionSegment *)value;
- (void)removeTranscriptionSegmentsObject:(TranscriptionSegment *)value;
- (void)addTranscriptionSegments:(NSOrderedSet *)values;
- (void)removeTranscriptionSegments:(NSOrderedSet *)values;

@end

@interface Note (Convenience)
- (NSString *)titlePlaceholder;
- (NSString *)plainTextContentPlaceholder;
- (NSString *)shortDateCreated;
- (void)configureNotesCell:(NotesCell *)cell;
@end
