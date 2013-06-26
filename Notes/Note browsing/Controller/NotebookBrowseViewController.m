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
#import "CreateNotebookViewController.h"
#import "NSFetchedResultsController+UICollectionView.h"
#import "NotebookIconView.h"

#define NumberOfColumns 2
#define VerticalMargin  10.f
#define TableViewWidth  250.f
#define HeaderHeight    300.f

@interface NotebookBrowseViewController () <NSFetchedResultsControllerDelegate, PSTCollectionViewDataSource, PSTCollectionViewDelegate, PSTCollectionViewDelegateFlowLayout, UIPopoverControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) PSUICollectionView *collectionView;
@property (nonatomic, strong) UIImageView *titleView;

// Notebook creation and editing
@property (nonatomic, strong) UIPopoverController *editingPopover;
@property (nonatomic, strong) NSIndexPath *editingIndexPath;
@property (nonatomic, strong) NotebookCell *editingNotebook;
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
}

- (void)updateViews {
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
        0.f,
        HeaderHeight,
        self.view.frame.size.width,
        self.view.frame.size.height - HeaderHeight
    };
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[NotebookCell class] forCellWithReuseIdentifier:@"NotebookCell"];

    return _collectionView;
}

- (CGSize)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(200, 200);
}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 50;
}

- (UIEdgeInsets)collectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.f, self.titleView.frame.origin.x, 0.f, self.view.frame.size.width - CGRectGetMaxX(self.titleView.frame));
}

- (NSInteger)collectionView:(PSUICollectionViewCell *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return self.fetchedResultsController.fetchedObjects.count;
    return self.fetchedResultsController.fetchedObjects.count + 1;
}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionViewCell *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NotebookCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"NotebookCell" forIndexPath:indexPath];

    if( indexPath.item == self.fetchedResultsController.fetchedObjects.count ) {
        cell.iconView.firstLetterLabel.textColor = [UIColor greenColor];
        cell.iconView.firstLetterLabel.font = [FontManager boldAmericanTypewriter:48.f];
        cell.iconView.firstLetterLabel.text = @"+";
        cell.titleLabel.text = @"Add";
    }
    else {
        [self configureNotebookCell:cell forItemAtIndexPath:indexPath];
    }

    return cell;
}

- (void)configureNotebookCell:(NotebookCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    Notebook *notebook = self.fetchedResultsController.fetchedObjects[indexPath.item];

    cell.iconView.firstLetterLabel.text = [notebook.name substringWithRange:NSMakeRange(0, 1)];
    cell.iconView.color = notebook.color;
    cell.titleLabel.text = notebook.name;
}

- (void)collectionView:(PSTCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if( indexPath.item == self.fetchedResultsController.fetchedObjects.count ) {
        CreateNotebookViewController *controller = [CreateNotebookViewController new];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    else {
        [self presentNotebookPopoverAtIndexPath:indexPath];
    }
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
    };

    if( animated ) {
        [UIView animateWithDuration:0.25f animations:setEditing];
    }
    else {
        setEditing();
    }
}

- (void)presentNotebookPopoverAtIndexPath:(NSIndexPath *)indexPath {
    self.editing = YES;
    NotebookCell *originalCell = (NotebookCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    self.editingIndexPath = indexPath;
    originalCell.hidden = YES;
    NotebookCell *newCell = [NotebookCell new];
    [self configureNotebookCell:newCell forItemAtIndexPath:indexPath];
    newCell.frame = [originalCell.superview convertRect:originalCell.frame toView:self.view];
    [self.view addSubview:newCell];
    self.editingNotebook = newCell;
    [UIView animateWithDuration:0.25f
                     animations:^{
                       [newCell centerHorizontally];
                     }

                     completion:^(BOOL finished) {
                       UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:[CreateNotebookViewController new]];
                       popover.delegate = self;
                       [popover presentPopoverFromRect:newCell.frame
                                          inView:self.view
                                      permittedArrowDirections:UIPopoverArrowDirectionUp
                                        animated:YES];
                       self.editingPopover = popover;
                     }];
}

- (void)finishPresentingPopover {
    self.editing = NO;
    NotebookCell *originalCell = (NotebookCell *)[self.collectionView cellForItemAtIndexPath:self.editingIndexPath];
    [UIView animateWithDuration:0.25f
                     animations:^{
                       self.editingNotebook.frame = [originalCell.superview
                                      convertRect:originalCell.frame
                                           toView:self.view];
                     }

                     completion:^(BOOL finished) {
                       originalCell.hidden = NO;
                       [self.editingNotebook removeFromSuperview];

                       self.editingIndexPath = nil;
                       self.editingNotebook = nil;
                       self.editingPopover = nil;
                     }];
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
    [controller applyObjectChangesOfType:type atIndexPath:indexPath newIndexPath:newIndexPath toCollectionView:(UICollectionView *)self.collectionView];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [controller endChangesToCollectionView:(UICollectionView *)self.collectionView];
}

@end
