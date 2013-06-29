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
#import "EditNoteSplitViewController.h"
#import "NoteManager.h"
#import "NoteTitleView.h"
#import "UIViewController+MGSplitViewController.h"
#import "NoteListViewController.h"

@interface EditNoteViewController ()
@property (nonatomic, strong) NoteListViewController *noteListViewController;
@property (strong, nonatomic) UIPopoverController *noteListPopoverController;
@property (nonatomic, strong) UIPopoverController *transcriptPopoverController;
@property (nonatomic, strong) UIBarButtonItem *notebookBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *libraryBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *transcriptButtonItem;
@property (nonatomic, strong) UIBarButtonItem *searchButtonItem;
@property (nonatomic, strong) UIBarButtonItem *createNoteButtonItem;
@property (nonatomic, strong) UIPopoverController *searchPopoverController;
@property (nonatomic, strong) NoteTitleView *titleView;

- (void)updateView;
@end

@implementation EditNoteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if( self ) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }

    return self;
}

#pragma mark - Managing the detail item

- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(toggleSearchPopover:)];
    self.createNoteButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewNote:)];
    self.libraryBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStyleBordered target:self action:@selector(close:)];
    self.notebookBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Notebook" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleNotebookPopover:)];

    [self.editTextController loadLocalPageNamed:@"NoteTemplate"];

    self.titleView = [NoteTitleView new];
    [self.titleView addTarget:self action:@selector(titleViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = self.titleView;
    
    [self updateLeftButtonItems];
}

- (void)updateView {
    NSString *title = self.note.title ? self.note.title : self.note.titlePlaceholder;

    self.titleView.title = title;
    self.titleView.subtitle = self.note.notebook.name;
    self.notebookBarButtonItem.title = self.note.notebook.name;
    self.editTextController.note = self.note;
}

#pragma mark - Properties

- (EditRichTextViewController *)editTextController {
    if( _editTextController ) {
        return _editTextController;
    }

    _editTextController = [EditRichTextViewController new];
    _editTextController.wantsFullScreenLayout = YES;
    [self addChildViewController:_editTextController];
    [self.view addSubview:_editTextController.view];
    [_editTextController didMoveToParentViewController:self];

    return _editTextController;
}

- (NoteListViewController *)noteListViewController {
    if( _noteListViewController )
        return _noteListViewController;
    
    _noteListViewController = [NoteListViewController new];
    
    return _noteListViewController;
}

#pragma mark - Note management

- (void)setNote:(Note *)note {
    if( _note != note ) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_note];
        _note = note;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];

        [self updateView];
    }

    [self.noteListPopoverController dismissPopoverAnimated:YES];
}

- (void)noteChanged:(id)sender {
    [self updateView];
}

#pragma mark - Bar button items

- (void)updateLeftButtonItems {
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:self.notebookBarButtonItem];
    [items addObject:self.libraryBarButtonItem];
    self.navigationItem.leftBarButtonItems = items;
}

- (void)updateRightButtonItems {
    NSMutableArray *items = [NSMutableArray array];

    if( self.createNoteButtonItem ) {
        [items addObject:self.createNoteButtonItem];
    }

    if( self.searchButtonItem ) {
        [items addObject:self.searchButtonItem];
    }

    if( self.transcriptButtonItem ) {
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

- (void)setcreateNoteButtonItem:(UIBarButtonItem *)createNoteButtonItem {
    _createNoteButtonItem = createNoteButtonItem;

    [self updateRightButtonItems];
}

#pragma mark - Split view

- (void)splitViewController:(MGSplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    UINavigationController *navigationController = (UINavigationController *)viewController;

    if( [navigationController.topViewController isKindOfClass:[TranscriptViewController class]] ) {
        barButtonItem.title = NSLocalizedString(@"Transcript", @"Transcript");
        self.transcriptButtonItem = barButtonItem;
        self.transcriptPopoverController = popoverController;
    }
}

- (void)splitViewController:(MGSplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    UINavigationController *navigationController = (UINavigationController *)viewController;

    if( [navigationController.topViewController isKindOfClass:[TranscriptViewController class]] ) {
        self.transcriptButtonItem = nil;
        self.transcriptPopoverController = nil;
    }
}

- (void)splitViewController:(MGSplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController {
    if( [svc isKindOfClass:[MGSplitViewController class]] ) {
    }
    else {
        [self.editTextController commitChangesToNote];
    }
}

#pragma mark - Actions

- (void)toggleSearchPopover:(id)sender {
    if( !self.searchPopoverController ) {
        NoteSearchViewController *controller = [NoteSearchViewController new];
        self.searchPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        controller.parentPopoverController = self.searchPopoverController;
    }

    if( self.searchPopoverController.popoverVisible ) {
        [self.searchPopoverController dismissPopoverAnimated:YES];
    }
    else {
        [self.searchPopoverController presentPopoverFromBarButtonItem:self.searchButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (void)createNewNote:(id)sender {
    [[EditNoteSplitViewController sharedInstance] setCurrentNote:[[NoteManager sharedInstance] createNewNoteInNotebook:self.note.notebook]];
}

- (void)titleViewTapped:(id)sender {
    [[[[EditNoteSplitViewController sharedInstance] editNoteViewController] editTextController] focusAndSelectTitle];
}

- (void)close:(id)sender {
    [[EditNoteSplitViewController sharedInstance] close];
}

- (void)toggleNotebookPopover:(id)sender {
    if( !self.noteListPopoverController ) {
        self.noteListViewController.contentSizeForViewInPopover = (CGSize) {
            320.f,
            [[UIScreen mainScreen] bounds].size.height
        };
        self.noteListPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.noteListViewController];
    }
    
    if( self.noteListPopoverController.popoverVisible ) {
        [self.noteListPopoverController dismissPopoverAnimated:YES];
    }
    else {
        [self.editTextController resignFirstResponder];
        [self.noteListPopoverController presentPopoverFromBarButtonItem:self.notebookBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//        self.noteListPopoverController.popoverContentSize =
    }
}

@end
