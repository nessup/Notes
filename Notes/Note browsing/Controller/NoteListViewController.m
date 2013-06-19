//
//  NoteListViewController.m
//  Notes
//
//  Created by Dany on 5/21/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "NoteListViewController.h"

#import "MainSplitViewController.h"
#import "NoteManager.h"
#import "TranscriptViewController.h"
#import "EditNoteViewController.h"
#import "NotesCell.h"

@interface NoteListViewController () <UISearchBarDelegate, UISearchDisplayDelegate>
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@implementation NoteListViewController {
    BOOL _searching;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewNote:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
//    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
//    void (^insertNewNoteForToday)() = ^ {
//        Note *newNote = [[NoteManager sharedInstance] createNewNoteInNotebook:nil];
//
//        [[EditNoteViewController sharedInstance] setNote:newNote];
//    };
//    if( [sectionInfo numberOfObjects] ) {
//        Note *latestNote = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//        NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:latestNote.dateCreated];
//        NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
//        if([today day] == [otherDay day] &&
//           [today month] == [otherDay month] &&
//           [today year] == [otherDay year] &&
//           [today era] == [otherDay era]) {
//            [[EditNoteViewController sharedInstance] setNote:latestNote];
//        }
//        else {
//            insertNewNoteForToday();
//        }
//    }
//    else {
//        insertNewNoteForToday();
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Properties

- (void)setNotebook:(Notebook *)notebook
{
    _notebook = notebook;
    
    _fetchedResultsController = nil;
    self.title = notebook.name;
}

- (UITableView *)currentTableView
{
    return _searching ? self.searchDisplayController.searchResultsTableView : self.tableView;
}

#pragma mark - Actions

- (void)createNewNote:(id)sender
{
    [[NoteManager sharedInstance] createNewNoteInNotebook:self.notebook];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (NotesCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NotesCell";
    
    NotesCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[NotesCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(NotesCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Note *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if( note.title.length ) {
        cell.textLabel.text = note.title;
    }
    else {
        static NSDateFormatter *formatter = nil;
        if( !formatter ) {
            formatter = [NSDateFormatter new];
            formatter.dateStyle = NSDateFormatterMediumStyle;
        }
        cell.textLabel.text = [NSString stringWithFormat:@"Untitled Note on %@", [formatter stringFromDate:note.dateCreated]];
    }
    
    cell.detailTextLabel.numberOfLines = 1;
    cell.detailTextLabel.text = note.content;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];

        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Note *note = (Note *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    [[MainSplitViewController sharedInstance] setCurrentNote:note];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    _fetchedResultsController = [[NoteManager sharedInstance] fetchAllNotesInNotebook:self.notebook];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [controller prepareTableViewForChanges:self.currentTableView];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    [controller applySectionChangesOfType:type atIndex:sectionIndex toTableView:self.currentTableView];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    [controller applyObjectChangesOfType:type atIndexPath:indexPath newIndexPath:newIndexPath toTableView:self.currentTableView];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [controller endChangesToTableView:self.currentTableView];
}

#pragma mark - Searching

- (void)filterContentForSearchText:(NSString *)searchString
{
    NSPredicate *predicate = nil;
    if( searchString.length ) {
        predicate = [NSPredicate predicateWithFormat:@"(title contains[cd] %@) OR (content contains[cd] %@)", searchString, searchString];
    }
    
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    NSError *e = nil;
    [[self fetchedResultsController] performFetch:&e];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    _searching = YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    _searching = NO;
}

@end
