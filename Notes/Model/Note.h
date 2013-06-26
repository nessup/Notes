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

@class Notebook;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSDate *dateCreated;
@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) Notebook *notebook;
@property (nonatomic, retain) NSString *topRightLines;
@property (nonatomic, retain) NSString *transcription;
@property (nonatomic, retain) NSData *transcriptionAudio;

- (NSString *)titlePlaceholder;

@end
