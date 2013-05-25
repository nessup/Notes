//
//  Note.m
//  Notes
//
//  Created by Dany on 5/23/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "Note.h"
#import "Course.h"

NSString * const NoteCategoryClassNotes = @"Class Notes";
NSString * const NoteCategoryAssignment = @"Assignments";

@implementation Note

@dynamic title;
@dynamic dateCreated;
@dynamic content;
@dynamic course;
@dynamic category;
@dynamic topRightLines;

@end
