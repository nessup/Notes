//
//  NotebookBrowseViewController.m
//  Notes
//
//  Created by Dany on 6/21/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "NotebookBrowseViewController.h"

#import "NoteManager.h"
#import "NotebookCell.h"
#import "PSTCollectionView.h"
#import "NSFetchedResultsController+UICollectionView.h"
#import "NotebookIconView.h"
#import "NoteListViewController.h"
#import "EditNotebookViewController.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "GlobalSearchViewController.h"
#import "SearchBar.h"

#define NumberOfColumns 2
#define VerticalMargin  10.f
#define TableViewWidth  500.f
#define HeaderHeight    300.f
#define SearchBarHeight 44.f

@interface NotebookBrowseViewController () <NSFetchedResultsControllerDelegate, PSTCollectionViewDataSource, PSTCollectionViewDelegate, PSTCollectionViewDelegateFlowLayout, UIPopoverControllerDelegate, NoteListViewControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) PSUICollectionView *collectionView;
@property (nonatomic, strong) UIImageView *titleView;
@property (nonatomic, strong) GlobalSearchViewController *globalSearchViewController;
@property (nonatomic, strong) SearchBar *searchBar;

// Notebook creation and editing
@property (nonatomic, strong) UIPopoverController *editingPopover;
@property (nonatomic, strong) NSIndexPath *editingIndexPath;
@property (nonatomic, strong) NotebookCell *editingNotebookCell;
@property (nonatomic, strong) Notebook *editingNotebook;
@property (nonatomic) BOOL skipReverseAnimation;
@end

@implementation NotebookBrowseViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self ) {
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.titleView];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.searchBar];
    
    [self addChildViewController:self.globalSearchViewController];
    self.globalSearchViewController.view.frame = self.collectionView.frame;
    [self.view addSubview:self.globalSearchViewController.view];
    [self.globalSearchViewController didMoveToParentViewController:self];
    self.globalSearchViewController.searchBar = self.searchBar;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    recognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:recognizer];
}

- (void)updateViews {
}

- (void)viewTapped:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.view];
    BOOL shouldDismissKeyboard = !(self.globalSearchViewController.editing && CGRectContainsPoint(self.globalSearchViewController.view.frame, location)) && !CGRectContainsPoint(self.searchBar.frame, location);
    if( shouldDismissKeyboard ) {
        [self.searchBar resignFirstResponder];
    }
}

#pragma mark - Title view

- (UIImageView *)titleView {
    if( _titleView ) {
        return _titleView;
    }

    _titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notes-logo"]];
    _titleView.frame = (CGRect) {
        roundf(self.view.frame.size.width / 2.f - _titleView.frame.size.width / 2.f),
        roundf(HeaderHeight / 2.f - _titleView.frame.size.height / 2.f),
        _titleView.frame.size
    };
    _titleView.alpha = 0.25f;

    return _titleView;
}

#pragma mark - Collection view

- (PSUICollectionView *)collectionView {
    if( _collectionView ) {
        return _collectionView;
    }

    _collectionView = [[PSUICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[PSUICollectionViewFlowLayout new]];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.frame = (CGRect) {
        CenterCoordinateHorizontallyInView(self.view, TableViewWidth),
        HeaderHeight,
        TableViewWidth,
        self.view.frame.size.height - HeaderHeight
    };
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[NotebookCell class] forCellWithReuseIdentifier:@"NotebookCell"];

    return _collectionView;
}

- (CGSize)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NotebookCell *sizingCell = nil;
    if( !sizingCell ) {
        sizingCell = [NotebookCell new];
    }
    [self configureNotebookCell:sizingCell forItemAtIndexPath:indexPath];
    [sizingCell sizeToFit];
    return sizingCell.frame.size;
}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.f;
}

- (NSInteger)collectionView:(PSUICollectionViewCell *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return self.fetchedResultsController.fetchedObjects.count;
    return self.fetchedResultsController.fetchedObjects.count + 1;
}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionViewCell *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NotebookCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"NotebookCell" forIndexPath:indexPath];
    [self configureNotebookCell:cell forItemAtIndexPath:indexPath];
    return cell;
}

- (void)configureNotebookCell:(NotebookCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if( indexPath.item == self.fetchedResultsController.fetchedObjects.count ) {
        [self configureNotebookCell:cell forAddNotebookAtIndexPath:indexPath];
    }
    else {
        [self configureNotebookCell:cell forNotebookAtIndexPath:indexPath];
    }
}

- (void)configureNotebookCell:(NotebookCell *)cell forAddNotebookAtIndexPath:(NSIndexPath *)indexPath {
    cell.iconView.firstLetterLabel.textColor = [UIColor greenColor];
    cell.iconView.firstLetterLabel.font = [FontManager boldAmericanTypewriter:48.f];
    cell.iconView.firstLetterLabel.text = @(indexPath.item).stringValue;
    cell.title = @"Add";
    NSLog(@"%f", cell.frame.size.width);
}

- (void)configureNotebookCell:(NotebookCell *)cell forNotebookAtIndexPath:(NSIndexPath *)indexPath {
    Notebook *notebook = self.fetchedResultsController.fetchedObjects[indexPath.item];
    [notebook configureNotebookCell:cell];
}

- (void)collectionView:(PSTCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    void (^presentPopover)(NSString *, BOOL) = ^ (NSString *title, BOOL creatingNotebook) {
        NoteListViewController *controller = [[NoteListViewController alloc] initWithNibName:nil bundle:nil];
        controller.editNotebookViewController.title = title;
        controller.editNotebookViewController.creatingNotebook = creatingNotebook;
        controller.notebook = self.editingNotebook;
        controller.editing = creatingNotebook;
        controller.delegate = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
        controller.parentPopoverController = popoverController;
        popoverController.delegate = self;
        controller.showsTableHeaverViewOnly = creatingNotebook;
        [self presentNotebookPopover:popoverController atIndexPath:indexPath top:YES];
    };
    
    [self.searchBar resignFirstResponder];
    if( indexPath.item == self.fetchedResultsController.fetchedObjects.count ) {
        self.editingNotebook = [[NoteManager sharedInstance] createNewNotebookNamed:@""];
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            presentPopover(@"Add Notebook", YES);
        });
    }
    else {
        self.editingNotebook = self.fetchedResultsController.fetchedObjects[indexPath.item];
        presentPopover(@"Edit Notebook", NO);
    }
}

- (void)noteListViewControllerDidFinish:(NoteListViewController *)noteListViewController {
    if( noteListViewController.editNotebookViewController.creatingNotebook ) {
        [[[NoteManager sharedInstance] context] deleteObject:self.editingNotebook];
    }
    [self.editingPopover dismissPopoverAnimated:YES];
    [self popoverControllerDidDismissPopover:self.editingPopover];
}

#pragma mark - Notebook creation and editing

- (void)setEditing:(BOOL)editing {
    [self setEditing:editing animated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    void (^setEditing)() = ^{
        CGFloat alpha = editing ? 0.f : 1.f;
        self.titleView.alpha = alpha;
        self.collectionView.alpha = alpha;
        self.searchBar.alpha = alpha;
    };

    if( animated ) {
        [UIView animateWithDuration:0.25f animations:setEditing];
    }
    else {
        setEditing();
    }
}

- (void)presentNotebookPopover:(UIPopoverController *)popoverController atIndexPath:(NSIndexPath *)indexPath top:(BOOL)top {
    self.editing = YES;
    NotebookCell *originalCell = (NotebookCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    self.editingIndexPath = indexPath;
    originalCell.hidden = YES;
    NotebookCell *newCell = [NotebookCell new];
    [self configureNotebookCell:newCell forItemAtIndexPath:indexPath];
    newCell.frame = [originalCell.superview convertRect:originalCell.frame toView:self.view];
    [self.view addSubview:newCell];
    self.editingNotebookCell = newCell;
    CGSize size = popoverController.contentViewController.contentSizeForViewInPopover;
    CGSize totalSize = (CGSize) {
        newCell.frame.size.width,
        newCell.frame.size.height + size.height
    };
    [self moveView:newCell assumeSize:totalSize assumeKeyboardWillBeUp:NO completion:^{
        popoverController.delegate = self;
        self.editingPopover = popoverController;
        [popoverController presentPopoverFromRect:newCell.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }];
}

- (void)moveView:(UIView *)view assumeSize:(CGSize)size assumeKeyboardWillBeUp:(BOOL)keyboardWillBeUp completion:(void (^)())completion {
    CGFloat keyboardHeight = 0;
    if( keyboardWillBeUp ) {
        keyboardHeight = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? 264.f : 352.f;
    }
    CGRect frame = (CGRect) {
        roundf(self.view.frame.size.width/2.f - size.width/2.f),
        roundf((self.view.frame.size.height - keyboardHeight)/2.f - size.height/2.f) - 50.f,
        view.frame.size
    };
    
    [UIView animateWithDuration:0.25f animations:^{
        view.frame = frame;
    } completion:^(BOOL finished) {
        if( completion ) {
            completion();
        }
    }];
}

- (void)finishPresentingPopover {
    self.editing = NO;
    void (^cleanup)(NotebookCell *originalCell) = ^ (NotebookCell *originalCell) {
        originalCell.hidden = NO;
        [self.editingNotebookCell removeFromSuperview];
        
        self.editingIndexPath = nil;
        self.editingNotebookCell = nil;
        self.editingPopover = nil;
        self.editingNotebook = nil;
        self.skipReverseAnimation = NO;
    };
    if( self.skipReverseAnimation ) {
        [UIView animateWithDuration:0.25f animations:^{
            self.editingNotebookCell.alpha = 0.f;
        }];
    }
    else {
        NotebookCell *originalCell = (NotebookCell *)[self.collectionView cellForItemAtIndexPath:self.editingIndexPath];
        originalCell.hidden = YES;
        [UIView animateWithDuration:0.25f animations:^{
            self.editingNotebookCell.frame = [originalCell.superview convertRect:originalCell.frame toView:self.view];
        } completion:^(BOOL finished) {
            cleanup(originalCell);
        }];
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    UINavigationController *navigationController = (UINavigationController *)popoverController.contentViewController;
    NoteListViewController *noteListViewController = (NoteListViewController *)navigationController.topViewController;
    if( noteListViewController.editing && noteListViewController.editNotebookViewController.madeChanges ) {
        [UIAlertView alertViewWithTitle:@"Are you sure you want to close this notebook?" message:@"You have unsaved changes." cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] onDismiss:^(int buttonIndex) {
            [popoverController dismissPopoverAnimated:YES];
            [self popoverControllerDidDismissPopover:popoverController];
        } onCancel:^{
        }];
        return NO;
    }
    [[NoteManager sharedInstance] saveToDisk];
    return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if( popoverController == self.editingPopover ) {
        [self finishPresentingPopover];
    }
}

#pragma mark - Data

- (NSFetchedResultsController *)fetchedResultsController {
    if( _fetchedResultsController != nil ) {
        return _fetchedResultsController;
    }

    _fetchedResultsController = [[NoteManager sharedInstance] fetchAllNotebooks];
    _fetchedResultsController.delegate = self;

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [controller prepareCollectionViewForChanges:(UICollectionView *)self.collectionView];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    [controller applySectionChangesOfType:type atIndex:sectionIndex toCollectionView:(UICollectionView *)self.collectionView];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    if( [anObject isEqual:self.editingNotebook] && type == NSFetchedResultsChangeDelete ) {
        self.skipReverseAnimation = YES;
        [self.editingPopover dismissPopoverAnimated:YES];
        [self finishPresentingPopover];
    }
    
    [controller applyObjectChangesOfType:type atIndexPath:indexPath newIndexPath:newIndexPath toCollectionView:(UICollectionView *)self.collectionView];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self configureNotebookCell:self.editingNotebookCell forItemAtIndexPath:self.editingIndexPath];
    [controller endChangesToCollectionView:(UICollectionView *)self.collectionView];
}

#pragma mark - Global search view controller

- (GlobalSearchViewController *)globalSearchViewController {
    if( _globalSearchViewController )
        return _globalSearchViewController;
    
    _globalSearchViewController = [GlobalSearchViewController new];
    
    return _globalSearchViewController;
}

- (SearchBar *)searchBar {
    if( _searchBar )
        return _searchBar;
    
    _searchBar = [SearchBar new];
    _searchBar.frame = (CGRect) {
        CenterCoordinateHorizontallyInView(self.view, TableViewWidth),
        HeaderHeight - SearchBarHeight - 20.f,
        TableViewWidth,
        SearchBarHeight
    };
    
    return _searchBar;
}

@end
