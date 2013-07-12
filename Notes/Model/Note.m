//
//  Note.m
//  Notes
//
//  Created by Dany on 5/23/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "Note.h"
#import "Notebook.h"
#import "NotesCell.h"
#import "TranscriptionSegment.h"

NSString *const NoteCategoryClassNotes = @"Class Notes";
NSString *const NoteCategoryAssignment = @"Assignments";

@implementation Note

@dynamic title;
@dynamic dateCreated;
@dynamic content;
@dynamic notebook;
@dynamic category;
@dynamic topRightLines;
@dynamic plainTextContent;
@dynamic transcriptionSegments;

- (NSString *)titlePlaceholder {
    static NSDateFormatter *formatter = nil;
    if( !formatter ) {
        formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterMediumStyle;
    }
    return [NSString stringWithFormat:@"Untitled Note on %@", [formatter stringFromDate:self.dateCreated]];
}

- (NSString *)plainTextContentPlaceholder {
    return @"No content";
}

- (NSString *)shortDateCreated {
    static NSDateFormatter *formatter = nil;
    if( !formatter ) {
        formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterShortStyle;
    }
    return [formatter stringFromDate:self.dateCreated];
}

- (void)configureNotesCell:(NotesCell *)cell {
    if( self.title.length ) {
        cell.textLabel.text = self.title;
    }
    else {
        cell.textLabel.text = [self titlePlaceholder];
    }
    if( self.plainTextContent.length ) {
        cell.detailTextLabel.text = self.plainTextContent;
    }
    else {
        cell.detailTextLabel.text = [self plainTextContentPlaceholder];
    }
}

@end
