//
//  MainSplitViewController.m
//  Notes
//
//  Created by Dany on 6/18/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "MainSplitViewController.h"

#import "NotebookListViewController.h"
#import "EditNoteViewController.h"
#import "NoteManager.h"
#import "Utility.h"
#import "MGSplitViewController.h"
#import "TranscriptViewController.h"

@interface MainSplitViewController ()
@property (nonatomic, strong) EditNoteViewController *editNoteViewController;
@property (nonatomic, strong) TranscriptViewController *transcriptViewController;
@property (nonatomic, strong) NotebookListViewController *notebookListViewController;
@end

@implementation MainSplitViewController

+ (MainSplitViewController *)sharedInstance {
    static MainSplitViewController *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        self.editNoteViewController = [EditNoteViewController new];
        UINavigationController *editNoteNavigationController = [[UINavigationController alloc] initWithRootViewController:self.editNoteViewController];

        self.transcriptViewController = [TranscriptViewController new];
        UINavigationController *transcriptNavigationController = [[UINavigationController alloc] initWithRootViewController:self.transcriptViewController];

        MGSplitViewController *subSplit = [MGSplitViewController new];
        subSplit.masterBeforeDetail = NO;
        subSplit.viewControllers = @[
                transcriptNavigationController,
                editNoteNavigationController
            ];
        subSplit.allowsDraggingDivider = YES;
        subSplit.dividerStyle = MGSplitViewDividerStylePaneSplitter;
        subSplit.delegate = self.editNoteViewController;

        self.notebookListViewController = [NotebookListViewController new];
        UINavigationController *noteNavigationController = [[UINavigationController alloc] initWithRootViewController:self.notebookListViewController];

        self.delegate = self.editNoteViewController;
        self.viewControllers = @[noteNavigationController, subSplit];
    }

    return self;
}

- (void)setCurrentNote:(Note *)currentNote {
    _currentNote = currentNote;

    self.editNoteViewController.note = _currentNote;
    self.transcriptViewController.note = _currentNote;
}

@end
