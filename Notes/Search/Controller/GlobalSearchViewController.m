//
//  GlobalSearchViewController.m
//  Notes
//
//  Created by Dany on 6/30/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "GlobalSearchViewController.h"

#import "EditNoteSplitViewController.h"
#import "NoteManager.h"
#import "NotesCell.h"
#import "EditNotebookViewController.h"
#import "TestView.h"
#import "OverlayView.h"
#import "TableView.h"
#import "TTTAttributedLabel.h"
#import "NoteListViewController.h"
#import "NotebookIconView.h"

#define Width       498.f
#define Height      600.f

@interface GlobalSearchViewController () <UIPopoverControllerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) UIBarButtonItem *addButton;
@property (nonatomic, strong) OverlayView *noNotesOverlayView;
@property (nonatomic, strong) TableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *notesFetchedResultsController;
@end

@implementation GlobalSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if( self ) {
        self.title = NSLocalizedString(@"Master", @"Master");

    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewNote:)];
    self.addButton = addButton;
    self.navigationItem.rightBarButtonItem = self.addButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateView];
}

- (void)updateView {
    self.view.hidden = !self.searching;
}

#pragma mark - Properties

- (UITableView *)tableView {
    if( _tableView )
        return _tableView;

    _tableView = [[TableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.layer.borderColor = [UIColor colorWithWhite:0.f alpha:0.3f].CGColor;
    _tableView.layer.borderWidth = 1.f;

    return _tableView;
}

- (OverlayView *)noNotesOverlayView {
    if( _noNotesOverlayView )
        return _noNotesOverlayView;
    
    _noNotesOverlayView = [OverlayView new];
    _noNotesOverlayView.titleLabel.text = @"No notes were found.";
    [_noNotesOverlayView.actionButton setTitle:@"Finish Searching" forState:UIControlStateNormal];
    [_noNotesOverlayView.actionButton addTarget:self action:@selector(finishSearching:) forControlEvents:UIControlEventTouchUpInside];
    
    return _noNotesOverlayView;
}

#pragma mark - Actions

- (void)finishSearching:(id)sender {

}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger count = [[self.notesFetchedResultsController sections] count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.notesFetchedResultsController sections][section];
    NSUInteger count = [sectionInfo numberOfObjects];
//    if( count == 0 ) {
//        self.tableView.overlayView = self.noNotesOverlayView;
//    }
//    else {
//        self.tableView.overlayView = nil;
//    }
    NSLog(@"hey %d", count);
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
        NotebookIconView *notebookIconView = [NotebookIconView new];
        notebookIconView.bounds = (CGRect) {
            CGPointZero,
            46.f,
            60.f
        };
        cell.leftView = notebookIconView;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(NotesCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Note *note = [self.notesFetchedResultsController objectAtIndexPath:indexPath];
    [note configureNotesCell:cell];
    NotebookIconView *notebookIconView = (NotebookIconView *)cell.leftView;
    [note.notebook configureNotebookIconView:notebookIconView];
    cell.highlightText = self.searchBar.text;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if( editingStyle == UITableViewCellEditingStyleDelete ) {
        NSManagedObjectContext *context = [self.notesFetchedResultsController managedObjectContext];
        [context deleteObject:[self.notesFetchedResultsController objectAtIndexPath:indexPath]];
        
        
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
    Note *note = (Note *)[[self notesFetchedResultsController] objectAtIndexPath:indexPath];
    [[EditNoteSplitViewController sharedInstance] setCurrentNote:note];
    [self presentViewController:[EditNoteSplitViewController sharedInstance] animated:YES completion:nil];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)notesFetchedResultsController {
    if( _notesFetchedResultsController != nil ) {
        return _notesFetchedResultsController;
    }
    
    _notesFetchedResultsController = [[NoteManager sharedInstance] fetchAllNotesInNotebook:nil];
    _notesFetchedResultsController.delegate = self;
    [self updateView];
    
    return _notesFetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [controller prepareTableViewForChanges:self.tableView];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    [controller applySectionChangesOfType:type atIndex:sectionIndex toTableView:self.tableView];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    [controller applyObjectChangesOfType:type atIndexPath:indexPath newIndexPath:newIndexPath toTableView:self.tableView];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [controller endChangesToTableView:self.tableView];
}

#pragma mark - Searching

- (void)setSearchBar:(UISearchBar *)searchBar {
    _searchBar = searchBar;
    _searchBar.delegate = self;
}

- (void)filterContentForSearchText:(NSString *)searchText {
    NSPredicate *predicate = nil;
    
    if( searchText.length ) {
        predicate = [NSPredicate predicateWithFormat:@"(title contains[cd] %@) OR (content contains[cd] %@)", searchText, searchText];
    }
    
    [self.notesFetchedResultsController.fetchRequest setPredicate:predicate];
    NSError *e = nil;
    [[self notesFetchedResultsController] performFetch:&e];
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterContentForSearchText:searchText];
    self.searching = searchText.length > 0;
}

- (void)setSearching:(BOOL)searching {
    _searching = searching;
    [self updateView];
}

@end
