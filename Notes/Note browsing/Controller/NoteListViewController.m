//
//  NoteListViewController.m
//  Notes
//
//  Created by Dany on 5/21/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "NoteListViewController.h"

#import "EditNoteSplitViewController.h"
#import "NoteManager.h"
#import "TranscriptViewController.h"
#import "EditNoteViewController.h"
#import "NotesCell.h"
#import "EditNotebookViewController.h"
#import "TestView.h"
#import "OverlayView.h"
#import "TableView.h"
#import "TTTAttributedLabel.h"

#define Width       498.f
#define Height      600.f

@interface NoteListViewController () <UISearchBarDelegate, UISearchDisplayDelegate, EditNotebookViewControllerDelegate, UIPopoverControllerDelegate>
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UIBarButtonItem *addButton;
@property (nonatomic, strong) OverlayView *noNotesOverlayView;
@property (nonatomic, strong) TableView *tableView;
@end

@implementation NoteListViewController {
    BOOL _searching;
}

- (id)init {
    return [self initWithNibName:@"NoteListViewController" bundle:[NSBundle mainBundle]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if( self ) {
        self.title = NSLocalizedString(@"Master", @"Master");
        self.clearsSelectionOnViewWillAppear = YES;
        self.contentSizeForViewInPopover = CGSizeMake(498.f, 600.0);
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewNote:)];
    self.addButton = addButton;
    self.navigationItem.rightBarButtonItem = self.addButton;
    
    self.navigationController.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.tableView reloadData];
    [super viewDidDisappear:animated];
}

- (void)updateView {
    if( !self.editing ) {
        NSUInteger notesCount = self.fetchedResultsController.fetchedObjects.count;
        if( notesCount != 1 ) {
            self.title = [NSString stringWithFormat:@"%d Notes", notesCount];
        }
        else {
            self.title = @"1 note";
        }
    }
}

#pragma mark - Properties

- (void)setShowsTableHeaverViewOnly:(BOOL)showsTableHeaverViewOnly {
    _showsTableHeaverViewOnly = showsTableHeaverViewOnly;
    
    CGFloat height = 0;
    if( _showsTableHeaverViewOnly ) {
        height = self.editNotebookViewController.view.frame.size.height + 35.f;
    }
    else {
        height = CGRectGetMaxY(self.tableView.frame);
    }
    self.view.frame = (CGRect) {
        CGPointZero,
        Width,
        height
    };
    self.parentPopoverController.popoverContentSize = (CGSize) {
        Width,
        height
    };
    [UIView animateWithDuration:0.25f animations:^{
        self.tableView.overlayView.alpha = !showsTableHeaverViewOnly;
    }];
    self.tableView.scrollEnabled = !showsTableHeaverViewOnly;
}

- (void)setNotebook:(Notebook *)notebook {
    _notebook = notebook;

    _fetchedResultsController = nil;
    [self updateView];
}

- (UITableView *)currentTableView {
    return _searching ? self.searchDisplayController.searchResultsTableView : self.tableView;
}

- (EditNotebookViewController *)editNotebookViewController {
    if( _editNotebookViewController )
        return _editNotebookViewController;
    
    _editNotebookViewController = [EditNotebookViewController new];
    _editNotebookViewController.delegate = self;
    _editNotebookViewController.editButtonItem = self.editButtonItem;
    
    return _editNotebookViewController;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    UIBarButtonItem *leftButton, *rightButton;
    if( self.editing ) {
        self.editNotebookViewController.notebook = self.notebook;
        
        [self addChildViewController:self.editNotebookViewController];
        self.tableView.tableHeaderView = self.editNotebookViewController.view;
        [self.editNotebookViewController didMoveToParentViewController:self];
        
        leftButton = self.editNotebookViewController.navigationItem.leftBarButtonItem;
        rightButton = self.editNotebookViewController.navigationItem.rightBarButtonItem;
        self.title = self.editNotebookViewController.title;
        
        // Having an overlay view means we have no cells to show, so hide the
        // table view
        if( self.tableView.overlayView ) {
            self.showsTableHeaverViewOnly = YES;
        }
    }
    else {
        [self.editNotebookViewController willMoveToParentViewController:nil];
        self.tableView.tableHeaderView = nil;
        [self.editNotebookViewController removeFromParentViewController];
        
        leftButton = self.editButtonItem;
        rightButton = self.addButton;
        [self updateView];
        
        if( self.showsTableHeaverViewOnly ) {
            self.parentPopoverController.popoverContentSize = self.contentSizeForViewInPopover;
            self.showsTableHeaverViewOnly = NO;
        }
    }
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)editNotebookViewControllerDidFinishEditing:(EditNotebookViewController *)editNotebookViewController {
    if( editNotebookViewController.creatingNotebook ) {
        [self.delegate noteListViewControllerDidFinish:self];
    }
    else {
        self.editing = NO;
    }
}

- (OverlayView *)noNotesOverlayView {
    if( _noNotesOverlayView )
        return _noNotesOverlayView;
    
    _noNotesOverlayView = [OverlayView new];
    _noNotesOverlayView.titleLabel.text = @"This notebook has no notes.";
    [_noNotesOverlayView.actionButton setTitle:@"Add Your First Note" forState:UIControlStateNormal];
    [_noNotesOverlayView.actionButton addTarget:self action:@selector(createNewNote:) forControlEvents:UIControlEventTouchUpInside];
    
    return _noNotesOverlayView;
}

#pragma mark - Actions

- (void)createNewNote:(id)sender {
    [[NoteManager sharedInstance] createNewNoteInNotebook:self.notebook];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger count = [[self.fetchedResultsController sections] count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    NSUInteger count = [sectionInfo numberOfObjects];
//    if( count == 0 ) {
//        self.tableView.overlayView = self.noNotesOverlayView;
//        NSLog(@"y");
//    }
//    else {
//        self.tableView.overlayView = nil;
//                NSLog(@"n %d", count);
//    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotesCell *cell = (NotesCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return [cell cellHeightForWidth:self.tableView.frame.size.width];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NotesCell";

    NotesCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if( cell == nil ) {
        cell = [[NotesCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.numberOfLines = 2.f;
    }

    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(NotesCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Note *note = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if( note.title.length ) {
        cell.textLabel.text = note.title;
    }
    else {
        cell.textLabel.text = [note titlePlaceholder];
    }
    if( note.plainTextContent.length ) {
        cell.detailTextLabel.text = note.plainTextContent;
    }
    else {
        cell.detailTextLabel.text = [note plainTextContentPlaceholder];
    }
    cell.topRightTextLabel.text = [note shortDateCreated];
//    Note *currentNote = [[EditNoteSplitViewController sharedInstance] currentNote];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if( editingStyle == UITableViewCellEditingStyleDelete ) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];


        NSError *error = nil;

        if( ![context save:&error] ) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Note *note = (Note *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    [[EditNoteSplitViewController sharedInstance] setCurrentNote:note];
    [self presentViewController:[EditNoteSplitViewController sharedInstance] animated:YES completion:nil];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if( _fetchedResultsController != nil ) {
        return _fetchedResultsController;
    }

    _fetchedResultsController = [[NoteManager sharedInstance] fetchAllNotesInNotebook:self.notebook];
    _fetchedResultsController.delegate = self;
    [self updateView];

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [controller prepareTableViewForChanges:self.currentTableView];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
    atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    [controller applySectionChangesOfType:type atIndex:sectionIndex toTableView:self.currentTableView];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
    atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
    newIndexPath:(NSIndexPath *)newIndexPath {
    [controller applyObjectChangesOfType:type atIndexPath:indexPath newIndexPath:newIndexPath toTableView:self.currentTableView];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [controller endChangesToTableView:self.currentTableView];
}

#pragma mark - Searching

- (void)filterContentForSearchText:(NSString *)searchString {
    NSPredicate *predicate = nil;

    if( searchString.length ) {
        predicate = [NSPredicate predicateWithFormat:@"(title contains[cd] %@) OR (content contains[cd] %@)", searchString, searchString];
    }

    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    NSError *e = nil;
    [[self fetchedResultsController] performFetch:&e];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString];

    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    _searching = YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
    _searching = NO;
}

@end
