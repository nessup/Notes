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
@property (nonatomic, retain) NSSet *transcriptionSegments;

- (NSString *)titlePlaceholder;
- (NSString *)plainTextContentPlaceholder;
- (NSString *)shortDateCreated;
- (void)configureNotesCell:(NotesCell *)cell;

@end

@interface Note (CoreDataGeneratedAccessors)
- (void)addTranscriptionSegmentsObject:(TranscriptionSegment *)value;
- (void)removeTranscriptionSegmentsObject:(TranscriptionSegment *)value;
- (void)addTranscriptionSegments:(NSSet *)values;
- (void)removeTranscriptionSegments:(NSSet *)values;
@end
