//
//  NSFetchedResultsController+UICollectionView.m
//  Notes
//
//  Created by Dany on 6/24/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "NSFetchedResultsController+UICollectionView.h"

#import <objc/runtime.h>

@interface NSFetchedResultsController ()
@property (nonatomic, strong) NSMutableArray *updateBlocks;
@end

@implementation NSFetchedResultsController (UICollectionView)

- (NSMutableArray *)updateBlocks {
    return objc_getAssociatedObject(self, @selector(updateBlocks));
}

- (void)setUpdateBlocks:(NSMutableArray *)updateBlocks {
    objc_setAssociatedObject(self, @selector(updateBlocks), updateBlocks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)prepareCollectionViewForChanges:(UICollectionView *)collectionView {
    self.updateBlocks = [NSMutableArray new];
}

- (void)applySectionChangesOfType:(NSFetchedResultsChangeType)type atIndex:(NSUInteger)sectionIndex toCollectionView:(UICollectionView *)collectionView {
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.updateBlocks
             addObject:^{
                 [collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
             }];
            break;
        }

        case NSFetchedResultsChangeDelete:
            [self.updateBlocks
             addObject: ^{
                 [collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
             }];
            break;
    }
}

- (void)applyObjectChangesOfType:(NSFetchedResultsChangeType)type atIndexPath:(NSIndexPath *)indexPath newIndexPath:(NSIndexPath *)newIndexPath toCollectionView:(UICollectionView *)collectionView {
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.updateBlocks
             addObject:^{
                 [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
             }];
            break;
        }

        case NSFetchedResultsChangeDelete: {
            [self.updateBlocks
             addObject:^{
                 [collectionView deleteItemsAtIndexPaths:@[newIndexPath]];
             }];
            break;
        }

        case NSFetchedResultsChangeUpdate: {
            [self.updateBlocks
             addObject:^{
                 [collectionView reloadItemsAtIndexPaths:@[indexPath]];
             }];
            break;
        }

        case NSFetchedResultsChangeMove: {
            [self.updateBlocks
             addObject:^{
                 [collectionView deleteItemsAtIndexPaths:@[indexPath]];
                 [collectionView insertItemsAtIndexPaths:@[indexPath]];
             }];
            break;
        }
    }
}

- (void)endChangesToCollectionView:(UICollectionView *)collectionView {
    [collectionView performBatchUpdates:^{
                        for (void (^block)() in self.updateBlocks) {
                        block();
                        }

                        self.updateBlocks = nil;
                    }

                             completion:nil];
}

@end
