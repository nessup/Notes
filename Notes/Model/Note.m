//
//  Note.m
//  Notes
//
//  Created by Dany on 5/23/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "Note.h"
#import "Notebook.h"

NSString * const NoteCategoryClassNotes = @"Class Notes";
NSString * const NoteCategoryAssignment = @"Assignments";

@implementation Note

@dynamic title;
@dynamic dateCreated;
@dynamic content;
@dynamic notebook;
@dynamic category;
@dynamic topRightLines;
@dynamic transcription;
@dynamic transcriptionAudio;

@end