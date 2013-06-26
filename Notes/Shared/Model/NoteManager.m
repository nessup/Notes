//
//  NoteManager.m
//  Notes
//
//  Created by Dany on 5/25/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "NoteManager.h"

#import "Model.h"

@implementation NoteManager

+ (NoteManager *)sharedInstance {
    static NoteManager *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];

    if( self ) {
    }

    return self;
}

#pragma mark - Disk

- (void)saveToDisk {
    NSError *error = nil;

    if( ![self.context save:&error] ) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Notebook

- (Notebook *)createNewNotebookNamed:(NSString *)name {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notebook" inManagedObjectContext:self.context];
    Notebook *notebook = (Notebook *)[NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:self.context];

    notebook.name = name;

    return notebook;
}

- (NSFetchedResultsController *)fetchAllNotebooks {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notebook" inManagedObjectContext:self.context];

    [fetchRequest setEntity:entity];

    [fetchRequest setFetchBatchSize:20];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];

    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:@"Notebooks"];

    NSError *error = nil;

    if( ![aFetchedResultsController performFetch:&error] ) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return aFetchedResultsController;
}

#pragma mark - Note

- (Note *)createNewNoteInNotebook:(Notebook *)notebook {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.context];
    Note *note = (Note *)[NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:self.context];

    note.dateCreated = [NSDate date];
    note.category = NoteCategoryClassNotes;
    note.notebook = notebook;

    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterShortStyle;
    note.topRightLines = [NSString stringWithFormat:@"Your Name<br />%@<br />%@", [formatter stringFromDate:note.dateCreated], notebook.name];

    return note;
}

- (NSFetchedResultsController *)fetchAllNotesInNotebook:(Notebook *)notebook {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.context];

    [fetchRequest setEntity:entity];

    [fetchRequest setFetchBatchSize:20];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];

    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];

    NSError *error = nil;

    if( ![aFetchedResultsController performFetch:&error] ) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return aFetchedResultsController;
}

@end
