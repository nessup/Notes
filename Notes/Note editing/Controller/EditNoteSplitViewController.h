//
//  MainSplitViewController.h
//  Notes
//
//  Created by Dany on 6/18/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "MGSplitViewController.h"

@class EditNoteViewController, TranscriptViewController, NotebookListViewController, Note;

@interface EditNoteSplitViewController : MGSplitViewController

@property (nonatomic, strong, readonly) EditNoteViewController *editNoteViewController;
@property (nonatomic, strong, readonly) TranscriptViewController *transcriptViewController;
@property (nonatomic, strong) Note *currentNote;

+ (id)sharedInstance;

- (void)close;

@end
