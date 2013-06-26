//
//  NotebookListViewController.m
//  Notes
//
//  Created by Dany on 5/25/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "NotebookListViewController.h"

#import "NoteManager.h"
#import "CreateNotebookViewController.h"
#import "NoteListViewController.h"
#import "NotesCell.h"

@interface NotebookListViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation NotebookListViewController {
    UIPopoverController *_createNotePopover;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if( self ) {
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Notebooks";

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewNotebook:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)createNewNotebook:(id)sender {
    if( _createNotePopover ) {
        return;
    }

    CreateNotebookViewController *controller = [CreateNotebookViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];

    [controller sizeToFitForModalController:navigationController];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (NotesCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    NotesCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if( cell == nil ) {
        cell = [[NotesCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    [self configureCell:cell atIndexPath:indexPath];
    return cell;
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
    Notebook *notebook = (Notebook *)[[self fetchedResultsController] objectAtIndexPath:indexPath];

    NoteListViewController *controller = [NoteListViewController new];

    controller.notebook = notebook;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if( _fetchedResultsController != nil ) {
        return _fetchedResultsController;
    }

    _fetchedResultsController = [[NoteManager sharedInstance] fetchAllNotebooks];
    _fetchedResultsController.delegate = self;

    return _fetchedResultsController;
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

- (void)configureCell:(NotesCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Notebook *notebook = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.textLabel.text = notebook.name;
    cell.colorLayer.backgroundColor = (__bridge CGColorRef)((id)notebook.color.CGColor);

    NSString *countString = nil;

    if( notebook.notes.count ) {
        if( notebook.notes.count > 1 ) {
            countString = [NSString stringWithFormat:@"%d notes", ((NSArray *)notebook.notes).count];
        }
        else {
            countString = @"1 note";
        }
    }
    else {
        countString = @"No notes";
    }

    cell.detailTextLabel.text = countString;
}

@end
