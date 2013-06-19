//
//  MainSplitViewController.h
//  Notes
//
//  Created by Dany on 6/18/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditNoteViewController, TranscriptViewController, NotebookListViewController, Note;

@interface MainSplitViewController : UISplitViewController

@property (nonatomic, strong, readonly) EditNoteViewController *editNoteViewController;
@property (nonatomic, strong, readonly) TranscriptViewController *transcriptViewController;
@property (nonatomic, strong, readonly) NotebookListViewController *notebookListViewController;

@property (nonatomic, strong) Note *currentNote;

+ (MainSplitViewController *)sharedInstance;
@end
