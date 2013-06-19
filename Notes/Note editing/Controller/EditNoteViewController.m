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

@interface EditNoteViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) UIPopoverController *transcriptPopoverController;
@property (nonatomic, strong) UIBarButtonItem *transcriptButtonItem;
@property (nonatomic, strong) UIBarButtonItem *searchButtonItem;
@property (nonatomic, strong) UIBarButtonItem *createNewNoteButton;
@property (nonatomic, strong) UIPopoverController *searchPopoverController;

- (void)configureView;
@end

@implementation EditNoteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(toggleSearchPopover:)];
    self.searchButtonItem = searchButtonItem;
    UIBarButtonItem *newNoteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newNote:)];
    self.createNewNoteButton = newNoteButton;
    
    [self.editTextController loadLocalPageNamed:@"NoteTemplate"];
}

- (void)configureView
{
    if (self.note) {
//        self.detailDescriptionLabel.text =
        self.editTextController.note = self.note;
    }
}

#pragma mark - Properties

- (EditRichTextViewController *)editTextController
{
    if( _editTextController )
        return _editTextController;
    
    _editTextController = [EditRichTextViewController new];
    _editTextController.wantsFullScreenLayout = YES;
    [self addChildViewController:_editTextController];
    [self.view addSubview:_editTextController.view];
    [_editTextController didMoveToParentViewController:self];
    
    return _editTextController;
}

- (void)setNote:(Note *)note
{
    if (_note != note) {
        _note = note;
        
        [self configureView];
    }
    
    [self.masterPopoverController dismissPopoverAnimated:YES];
}

#pragma mark - Bar button items

- (void)updateRightButtonItems
{
    NSMutableArray *items = [NSMutableArray array];
    
    if( self.createNewNoteButton ) {
        [items addObject:self.createNewNoteButton];
    }
    if( self.searchButtonItem ) {
        [items addObject:self.searchButtonItem];
    }
    if( self.transcriptButtonItem ) {
        [items addObject:self.transcriptButtonItem];
    }
    
    [self.navigationItem setRightBarButtonItems:items animated:YES];
}

- (void)setTranscriptButtonItem:(UIBarButtonItem *)transcriptButtonItem
{
    _transcriptButtonItem = transcriptButtonItem;
    
    [self updateRightButtonItems];
}

- (void)setSearchButtonItem:(UIBarButtonItem *)searchButtonItem
{
    _searchButtonItem = searchButtonItem;
    
    [self updateRightButtonItems];
}

- (void)setCreateNewNoteButton:(UIBarButtonItem *)createNewNoteButton
{
    _createNewNoteButton = createNewNoteButton;
    
    [self updateRightButtonItems];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    if( [splitController isKindOfClass:[MGSplitViewController class]] ) {
        barButtonItem.title = NSLocalizedString(@"Transcript", @"Transcript");
        self.transcriptButtonItem = barButtonItem;
        self.transcriptPopoverController = popoverController;
    }
    else {
        barButtonItem.title = NSLocalizedString(@"Master", @"Master");
        [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
        self.masterPopoverController = popoverController;
    }
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if( [splitController isKindOfClass:[MGSplitViewController class]] ) {
        self.transcriptButtonItem = nil;
        self.transcriptPopoverController = nil;
    }
    else {
        // Called when the view is shown again in the split view, invalidating the button and popover controller.
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        self.masterPopoverController = nil;
    }
}

- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController
{
    if( [svc isKindOfClass:[MGSplitViewController class]] ) {
        
    }
    else {
        [self.editTextController commitChangesToNote];
    }
}

#pragma mark - Actions

- (void)toggleTranscript:(id)sender
{
    
}

- (void)toggleSearchPopover:(id)sender
{
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

- (void)newNote:(id)sender
{
    
}

@end
