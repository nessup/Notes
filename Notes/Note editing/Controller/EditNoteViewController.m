//
//  EditNoteViewController.m
//  Notes
//
//  Created by Dany on 5/21/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "EditNoteViewController.h"

#import "EditRichTextViewController.h"
#import "MGSplitViewController.h"
#import "NoteSearchViewController.h"
#import "TranscriptViewController.h"
#import "MainSplitViewController.h"
#import "NoteManager.h"
#import "NoteTitleView.h"

@interface EditNoteViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) UIPopoverController *transcriptPopoverController;
@property (nonatomic, strong) UIBarButtonItem *transcriptButtonItem;
@property (nonatomic, strong) UIBarButtonItem *searchButtonItem;
@property (nonatomic, strong) UIBarButtonItem *createNewNoteButton;
@property (nonatomic, strong) UIPopoverController *searchPopoverController;
@property (nonatomic, strong) NoteTitleView *titleView;

- (void)updateView;
@end

@implementation EditNoteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }

    return self;
}

#pragma mark - Managing the detail item

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(toggleSearchPopover:)];
    self.searchButtonItem = searchButtonItem;
    UIBarButtonItem *newNoteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewNote:)];
    self.createNewNoteButton = newNoteButton;

    [self.editTextController loadLocalPageNamed:@"NoteTemplate"];

    self.titleView = [NoteTitleView new];
    [self.titleView addTarget:self action:@selector(titleViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = self.titleView;
}

- (void)updateView {
    NSString *title = self.note.title ? self.note.title : self.note.titlePlaceholder;

    self.titleView.title = title;
    self.titleView.subtitle = self.note.notebook.name;
    self.editTextController.note = self.note;
}

#pragma mark - Properties

- (EditRichTextViewController *)editTextController {
    if (_editTextController) return _editTextController;

    _editTextController = [EditRichTextViewController new];
    _editTextController.wantsFullScreenLayout = YES;
    [self addChildViewController:_editTextController];
    [self.view addSubview:_editTextController.view];
    [_editTextController didMoveToParentViewController:self];

    return _editTextController;
}

#pragma mark - Note management

- (void)setNote:(Note *)note {
    if (_note != note) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_note];
        _note = note;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];

        [self updateView];
    }

    [self.masterPopoverController dismissPopoverAnimated:YES];
}

- (void)noteChanged:(id)sender {
    [self updateView];
}

#pragma mark - Bar button items

- (void)updateRightButtonItems {
    NSMutableArray *items = [NSMutableArray array];

    if (self.createNewNoteButton) {
        [items addObject:self.createNewNoteButton];
    }

    if (self.searchButtonItem) {
        [items addObject:self.searchButtonItem];
    }

    if (self.transcriptButtonItem) {
        [items addObject:self.transcriptButtonItem];
    }

    [self.navigationItem setRightBarButtonItems:items animated:YES];
}

- (void)setTranscriptButtonItem:(UIBarButtonItem *)transcriptButtonItem {
    _transcriptButtonItem = transcriptButtonItem;

    [self updateRightButtonItems];
}

- (void)setSearchButtonItem:(UIBarButtonItem *)searchButtonItem {
    _searchButtonItem = searchButtonItem;

    [self updateRightButtonItems];
}

- (void)setCreateNewNoteButton:(UIBarButtonItem *)createNewNoteButton {
    _createNewNoteButton = createNewNoteButton;

    [self updateRightButtonItems];
}

#pragma mark - Split view

- (void)splitViewController:(MGSplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    UINavigationController *navigationController = (UINavigationController *)viewController;

    if ([navigationController.topViewController isKindOfClass:[TranscriptViewController class]]) {
        barButtonItem.title = NSLocalizedString(@"Transcript", @"Transcript");
        self.transcriptButtonItem = barButtonItem;
        self.transcriptPopoverController = popoverController;
    } else {
        barButtonItem.title = NSLocalizedString(@"Master", @"Master");
        [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
        self.masterPopoverController = popoverController;
    }
}

- (void)splitViewController:(MGSplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    UINavigationController *navigationController = (UINavigationController *)viewController;

    if ([navigationController.topViewController isKindOfClass:[TranscriptViewController class]]) {
        self.transcriptButtonItem = nil;
        self.transcriptPopoverController = nil;
    } else {
        // Called when the view is shown again in the split view, invalidating the button and popover controller.
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        self.masterPopoverController = nil;
    }
}

- (void)splitViewController:(MGSplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController {
    if ([svc isKindOfClass:[MGSplitViewController class]]) {
    } else {
        [self.editTextController commitChangesToNote];
    }
}

#pragma mark - Actions

- (void)toggleSearchPopover:(id)sender {
    if (!self.searchPopoverController) {
        NoteSearchViewController *controller = [NoteSearchViewController new];
        self.searchPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        controller.parentPopoverController = self.searchPopoverController;
    }

    if (self.searchPopoverController.popoverVisible) {
        [self.searchPopoverController dismissPopoverAnimated:YES];
    } else {
        [self.searchPopoverController presentPopoverFromBarButtonItem:self.searchButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (void)createNewNote:(id)sender {
    [[MainSplitViewController sharedInstance] setCurrentNote:[[NoteManager sharedInstance] createNewNoteInNotebook:self.note.notebook]];
}

- (void)titleViewTapped:(id)sender {
    [[[[MainSplitViewController sharedInstance] editNoteViewController] editTextController] focusAndSelectTitle];
}

@end
