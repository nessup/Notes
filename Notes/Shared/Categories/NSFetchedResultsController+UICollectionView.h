//
//  NSFetchedResultsController+UICollectionView.h
//  Notes
//
//  Created by Dany on 6/24/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSFetchedResultsController (UICollectionView)
- (void)prepareCollectionViewForChanges:(UICollectionView *)collectionView;
- (void)applySectionChangesOfType:(NSFetchedResultsChangeType)type atIndex:(NSUInteger)sectionIndex toCollectionView:(UICollectionView *)collectionView;
- (void)applyObjectChangesOfType:(NSFetchedResultsChangeType)type atIndexPath:(NSIndexPath *)indexPath newIndexPath:(NSIndexPath *)newIndexPath toCollectionView:(UICollectionView *)collectionView;
- (void)endChangesToCollectionView:(UICollectionView *)collectionView;
@end
