//
//  NSFetchedResultsController+UITableView.m
//  Notes
//
//  Created by Dany on 5/25/13.
//  Copyright (c) 2013 Dany. All rights reserved.
//

#import "NSFetchedResultsController+UITableView.h"

@implementation NSFetchedResultsController (UITableView)

- (void)prepareTableViewForChanges:(UITableView *)tableView {
    [tableView beginUpdates];
}

- (void)applySectionChangesOfType:(NSFetchedResultsChangeType)type atIndex:(NSUInteger)sectionIndex toTableView:(UITableView *)tableView {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)applyObjectChangesOfType:(NSFetchedResultsChangeType)type atIndexPath:(NSIndexPath *)indexPath newIndexPath:(NSIndexPath *)newIndexPath toTableView:(UITableView *)tableView {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)endChangesToTableView:(UITableView *)tableView {
    [tableView endUpdates];
}

@end
