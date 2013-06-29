//
//  MainSplitViewController.m
//  Notes
//
//  Created by Dany on 6/18/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "EditNoteSplitViewController.h"

#import "NotebookListViewController.h"
#import "EditNoteViewController.h"
#import "NoteManager.h"
#import "Utility.h"
#import "MGSplitViewController.h"
#import "TranscriptViewController.h"

@interface EditNoteSplitViewController ()
@property (nonatomic, strong) EditNoteViewController *editNoteViewController;
@property (nonatomic, strong) TranscriptViewController *transcriptViewController;
@end

@implementation EditNoteSplitViewController

+ (id)sharedInstance {
    static EditNoteSplitViewController *controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [EditNoteSplitViewController new];
    });
    return controller;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if( self ) {
        self.editNoteViewController = [EditNoteViewController new];
        UINavigationController *editNoteNavigationController = [[UINavigationController alloc] initWithRootViewController:self.editNoteViewController];

        self.transcriptViewController = [TranscriptViewController new];
        UINavigationController *transcriptNavigationController = [[UINavigationController alloc] initWithRootViewController:self.transcriptViewController];

//        MGSplitViewController *self = [MGSplitViewController new];
        self.masterBeforeDetail = NO;
        self.viewControllers = @[
                transcriptNavigationController,
                editNoteNavigationController
            ];
        self.allowsDraggingDivider = YES;
        self.dividerStyle = MGSplitViewDividerStylePaneSplitter;
        self.delegate = self.editNoteViewController;

//        self.delegate = self.editNoteViewController;
//        self.viewControllers = @[self];
    }

    return self;
}

- (void)setCurrentNote:(Note *)currentNote {
    _currentNote = currentNote;

    self.editNoteViewController.note = _currentNote;
    self.transcriptViewController.note = _currentNote;
}

- (void)close {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
