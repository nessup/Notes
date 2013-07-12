//
//  NoteManager.h
//  Notes
//
//  Created by Dany on 5/25/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Model.h"

@interface NoteManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext *context;

+ (NoteManager *)sharedInstance;

- (void)saveToDisk;

- (Notebook *)createNewNotebookNamed:(NSString *)name;
- (NSFetchedResultsController *)fetchAllNotebooks;

- (Note *)createNewNoteInNotebook:(Notebook *)notebook;
- (NSFetchedResultsController *)fetchAllNotesInNotebook:(Notebook *)notebook;

- (TranscriptionSegment *)createNewTranscriptionSegmentForNote:(Note *)note;

@end
