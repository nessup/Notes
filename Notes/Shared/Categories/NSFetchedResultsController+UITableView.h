//
//  NSFetchedResultsController+UITableView.h
//  Notes
//
//  Created by Dany on 5/25/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSFetchedResultsController (UITableView)

- (void)prepareTableViewForChanges:(UITableView *)tableView;
- (void)applySectionChangesOfType:(NSFetchedResultsChangeType)type atIndex:(NSUInteger)sectionIndex toTableView:(UITableView *)tableView;
- (void)applyObjectChangesOfType:(NSFetchedResultsChangeType)type atIndexPath:(NSIndexPath *)indexPath newIndexPath:(NSIndexPath *)newIndexPath toTableView:(UITableView *)tableView;
- (void)endChangesToTableView:(UITableView *)tableView;

@end
